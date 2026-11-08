import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/features/language_selection/application/learning_preferences.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';
import 'package:language_platform/features/onboarding/application/onboarding_state.dart';
import 'package:language_platform/features/splash/application/startup_route.dart';

import '../helpers/pump_app.dart';

final _tr = LearningLanguage.fromCode('tr')!;
final _ar = LearningLanguage.fromCode('ar')!;

void main() {
  group('startupRouteFor', () {
    test('tanıtım görülmediyse onboarding', () {
      expect(
        startupRouteFor(
          onboardingCompleted: false,
          preferences: const LearningPreferences(),
        ),
        AppRoutes.onboarding,
      );
    });

    test('tanıtım tamam, diller eksikse dil kurulumu', () {
      expect(
        startupRouteFor(
          onboardingCompleted: true,
          preferences: LearningPreferences(knownLanguage: _tr),
        ),
        AppRoutes.languageSetup,
      );
    });

    test('her şey tamamsa ana sayfa', () {
      expect(
        startupRouteFor(
          onboardingCompleted: true,
          preferences: LearningPreferences(
            knownLanguage: _tr,
            targetLanguage: _ar,
          ),
        ),
        AppRoutes.home,
      );
    });
  });

  group('LearningPreferences', () {
    test('aynı dil seçilirse tamamlanmış sayılmaz', () {
      expect(
        LearningPreferences(knownLanguage: _tr, targetLanguage: _tr).isComplete,
        isFalse,
      );
    });

    test('notifier hedefle aynı bilinen dili reddeder ve tersi', () {
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
    });
  });

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

    testWidgets('yönlendirme hesaplanamazsa hata ve tekrar dene', (
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
            return AppRoutes.onboarding;
          }),
        ],
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(currentPath(container), AppRoutes.splash);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(currentPath(container), AppRoutes.onboarding);
    });
  });

  group('onboarding', () {
    testWidgets('ileri, geri ve tamamla çalışır', (tester) async {
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.onboarding,
      );
      expect(find.text('Learn a new language'), findsOneWidget);
      expect(find.text('Back').hitTestable(), findsNothing);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Grow with interactive lessons'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Learn a new language'), findsOneWidget);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Track your progress'), findsOneWidget);
      expect(find.text('Next'), findsNothing);

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(container.read(onboardingCompletedProvider), isTrue);
      expect(currentPath(container), AppRoutes.languageSetup);
    });

    testWidgets('geç tanıtımı tamamlayıp dil kurulumuna götürür', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.onboarding,
      );
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(container.read(onboardingCompletedProvider), isTrue);
      expect(currentPath(container), AppRoutes.languageSetup);
    });

    testWidgets('Arapçada RTL: ileri butonu ekranın solunda', (tester) async {
      await pumpApp(
        tester,
        language: AppLanguage.ar,
        initialLocation: AppRoutes.onboarding,
      );
      expect(currentDirection(tester), TextDirection.rtl);
      expect(find.text('تعلّم لغة جديدة'), findsOneWidget);
      // RTL'de birincil eylem satırın başında (sağda) değil sonunda (solda).
      final next = tester.getCenter(find.text('التالي')).dx;
      final screenCenter =
          tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
      expect(next, lessThan(screenCenter));
    });

    testWidgets('kaydırma (swipe) sonraki adıma geçer', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.onboarding);
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Grow with interactive lessons'), findsOneWidget);
    });
  });

  group('dil seçimi', () {
    testWidgets('devam, iki farklı dil seçilene kadar kapalıdır', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.languageSetup,
      );
      FilledButton continueButton() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue'),
      );
      expect(continueButton().onPressed, isNull);

      await tester.ensureVisible(
        find.byKey(const ValueKey('known-language:tr')),
      );
      await tester.tap(find.byKey(const ValueKey('known-language:tr')));
      await tester.pump();
      expect(continueButton().onPressed, isNull);

      await tester.ensureVisible(
        find.byKey(const ValueKey('target-language:ar')),
      );
      await tester.tap(find.byKey(const ValueKey('target-language:ar')));
      await tester.pump();
      expect(continueButton().onPressed, isNotNull);

      final prefs = container.read(learningPreferencesProvider);
      expect(prefs.knownLanguage, _tr);
      expect(prefs.targetLanguage, _ar);
    });

    testWidgets('üç tercih birbirinden bağımsız saklanır', (tester) async {
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.languageSetup,
      );
      await tester.tap(find.byKey(const ValueKey('interface-language:ar')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('known-language:en')),
      );
      await tester.tap(find.byKey(const ValueKey('known-language:en')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('target-language:tr')),
      );
      await tester.tap(find.byKey(const ValueKey('target-language:tr')));
      await tester.pumpAndSettle();

      expect(container.read(appLanguageProvider), AppLanguage.ar);
      final prefs = container.read(learningPreferencesProvider);
      expect(prefs.knownLanguage?.code, 'en');
      expect(prefs.targetLanguage?.code, 'tr');
      expect(currentDirection(tester), TextDirection.rtl);
    });

    testWidgets('bilinen dil hedef olarak seçilemez', (tester) async {
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.languageSetup,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('known-language:tr')),
      );
      await tester.tap(find.byKey(const ValueKey('known-language:tr')));
      await tester.pump();
      await tester.ensureVisible(
        find.byKey(const ValueKey('target-language:tr')),
      );
      await tester.tap(find.byKey(const ValueKey('target-language:tr')));
      await tester.pump();
      expect(
        container.read(learningPreferencesProvider).targetLanguage,
        isNull,
      );
    });

    testWidgets('devam giriş ekranına götürür', (tester) async {
      final container = await pumpApp(
        tester,
        initialLocation: AppRoutes.languageSetup,
        overrides: [
          learningPreferencesProvider.overrideWith(
            () => LearningPreferencesNotifier(
              LearningPreferences(knownLanguage: _tr, targetLanguage: _ar),
            ),
          ),
        ],
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(currentPath(container), AppRoutes.login);
    });
  });
}
