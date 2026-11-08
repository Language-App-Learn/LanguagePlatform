import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/l10n/app_language.dart';
import 'package:language_platform/core/storage/app_preferences.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/language_selection/application/learning_preferences.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';
import 'package:language_platform/features/splash/application/startup_route.dart';

import '../helpers/persistent_app.dart';
import '../helpers/pump_app.dart';

final _tr = LearningLanguage.fromCode('tr')!;
final _ar = LearningLanguage.fromCode('ar')!;

/// Every path of the removed former app. None may ever open an old screen.
const _legacyPaths = [
  '/onboarding',
  '/language-setup',
  '/home',
  '/courses',
  '/vocabulary',
  '/progress',
  '/profile',
  '/settings',
  '/course/c1',
  '/lesson/l1',
  '/quiz/l1',
  '/review',
  '/review-history',
];

Future<MemoryKeyValueStore> _storeWithLanguage() async {
  final store = MemoryKeyValueStore();
  await AppPreferencesRepository(store)
      .save(const AppPreferences(interfaceLanguage: 'tr'));
  return store;
}

void main() {
  group('splash', () {
    testWidgets('app language chosen -> main menu', (tester) async {
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
      );
      expect(currentPath(container), AppRoutes.menu);
    });

    testWidgets('no app language yet -> the one-time language screen', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        language: null,
        initialLocation: AppRoutes.splash,
      );
      expect(currentPath(container), AppRoutes.appLanguage);
    });

    testWidgets('a failing decision shows an error with a working retry', (
      tester,
    ) async {
      var attempts = 0;
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
        overrides: [
          startupRouteProvider.overrideWith((ref) async {
            attempts++;
            if (attempts == 1) throw Exception('boom');
            return AppRoutes.menu;
          }),
        ],
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(currentPath(container), AppRoutes.splash);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(currentPath(container), AppRoutes.menu);
    });
  });

  group('startup of the real app (persisted state, browser URLs)', () {
    testWidgets('first use: splash -> app language -> main menu', (
      tester,
    ) async {
      final store = MemoryKeyValueStore();
      final c = await launchApp(tester, store);
      expect(currentPath(c), AppRoutes.appLanguage);
      await tester.tap(find.byKey(const ValueKey('app-language-continue')));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.menu);
      expect(c.read(appLanguageProvider), isNotNull); // saved
    });

    testWidgets('later use (language saved): splash -> main menu', (
      tester,
    ) async {
      final c = await launchApp(tester, await _storeWithLanguage());
      expect(currentPath(c), AppRoutes.menu);
      expect(c.read(appLanguageProvider), AppLanguage.tr);
    });

    for (final path in _legacyPaths) {
      testWidgets('old URL $path never opens a legacy screen', (tester) async {
        final c = await launchApp(
          tester,
          await _storeWithLanguage(),
          initialLocation: path,
        );
        expect(currentPath(c), AppRoutes.menu); // splash decided: menu
        expect(find.text('Dil Öğren'), findsOneWidget);
      });
    }

    testWidgets('old URL on first use: goes through the language choice', (
      tester,
    ) async {
      final c = await launchApp(
        tester,
        MemoryKeyValueStore(),
        initialLocation: '/onboarding',
      );
      expect(currentPath(c), AppRoutes.appLanguage);
    });

    testWidgets('a refresh on the menu without a saved language cannot skip '
        'the one-time language choice', (tester) async {
      final c = await launchApp(
        tester,
        MemoryKeyValueStore(),
        initialLocation: AppRoutes.menu,
      );
      expect(currentPath(c), AppRoutes.appLanguage);
    });

    testWidgets('a refresh on the menu with a saved language stays on it', (
      tester,
    ) async {
      final c = await launchApp(
        tester,
        await _storeWithLanguage(),
        initialLocation: AppRoutes.menu,
      );
      expect(currentPath(c), AppRoutes.menu);
    });

    testWidgets('the app is always light (no saved or system dark mode)', (
      tester,
    ) async {
      final store = await _storeWithLanguage();
      await AppPreferencesRepository(store).update(
        (p) => p.copyWith(themeMode: () => 'dark'), // an old saved choice
      );
      await launchApp(tester, store);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
      expect(app.darkTheme, isNull);
    });
  });

  group('LearningPreferences', () {
    test('the same language twice is not a complete pair', () {
      expect(
        LearningPreferences(knownLanguage: _tr, targetLanguage: _tr).isComplete,
        isFalse,
      );
    });

    test(
      'the notifier rejects the target as known language and vice versa',
      () {
        final container = ProviderContainer.test();
        final notifier = container.read(learningPreferencesProvider.notifier);
        notifier.selectKnown(_tr);
        notifier.selectTarget(_tr);
        expect(
          container.read(learningPreferencesProvider).targetLanguage,
          isNull,
        );
        notifier.selectTarget(_ar);
        notifier.selectKnown(_ar);
        expect(container.read(learningPreferencesProvider).knownLanguage, _tr);
        expect(container.read(learningPreferencesProvider).isComplete, isTrue);
      },
    );
  });
}
