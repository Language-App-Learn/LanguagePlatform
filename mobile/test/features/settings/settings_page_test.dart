import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/core/theme/theme_mode_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_platform/app/router/app_routes.dart';

import '../../helpers/pump_app.dart';

Future<ProviderContainer> _pumpSettings(
  WidgetTester tester, {
  AppLanguage? language = AppLanguage.en,
  ThemeMode themeMode = ThemeMode.light,
}) => pumpApp(
  tester,
  language: language,
  themeMode: themeMode,
  initialLocation: AppRoutes.settings,
);

void main() {
  group('metin ve yön', () {
    const cases = {
      AppLanguage.en: (TextDirection.ltr, 'App language'),
      AppLanguage.tr: (TextDirection.ltr, 'Uygulama dili'),
      AppLanguage.ar: (TextDirection.rtl, 'لغة التطبيق'),
    };
    for (final entry in cases.entries) {
      final (direction, title) = entry.value;
      testWidgets('${entry.key.code}: başlık ve $direction', (tester) async {
        await _pumpSettings(tester, language: entry.key);
        expect(find.text(title), findsOneWidget);
        expect(currentDirection(tester), direction);
      });
    }

    testWidgets('desteklenmeyen cihaz dilinde İngilizceye düşer', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('fr')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await _pumpSettings(tester, language: null);
      expect(find.text('App language'), findsOneWidget);
      expect(currentDirection(tester), TextDirection.ltr);
    });
  });

  group('dil seçici', () {
    testWidgets('çalışma anında en → ar → tr geçişi yön ve metni değiştirir', (
      tester,
    ) async {
      final container = await _pumpSettings(tester);
      expect(currentDirection(tester), TextDirection.ltr);

      await tester.tap(find.byKey(const ValueKey('interface-language:ar')));
      await tester.pumpAndSettle();
      expect(container.read(appLanguageProvider), AppLanguage.ar);
      expect(currentDirection(tester), TextDirection.rtl);
      expect(find.text('لغة التطبيق'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('interface-language:tr')));
      await tester.pumpAndSettle();
      expect(currentDirection(tester), TextDirection.ltr);
      expect(find.text('Uygulama dili'), findsOneWidget);
    });

    testWidgets('dil adları her zaman kendi dillerinde gösterilir', (
      tester,
    ) async {
      await _pumpSettings(tester, language: AppLanguage.ar);
      for (final entry in {
        'en': 'English',
        'tr': 'Türkçe',
        'ar': 'العربية',
      }.entries) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('interface-language:${entry.key}')),
            matching: find.text(entry.value),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('etkin dil seçili görünür', (tester) async {
      await _pumpSettings(tester, language: AppLanguage.tr);
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('interface-language:tr')),
            )
            .selected,
        isTrue,
      );
    });

    testWidgets('LTR ikon sola, RTL sağa hizalanır (yön aynalama)', (
      tester,
    ) async {
      await _pumpSettings(tester);
      final chip = find.byKey(const ValueKey('interface-language:en'));
      final ltrX = tester.getCenter(chip).dx;
      await tester.tap(find.byKey(const ValueKey('interface-language:ar')));
      await tester.pumpAndSettle();
      final rtlX = tester.getCenter(chip).dx;
      expect(ltrX, lessThan(rtlX));
    });
  });

  group('tema', () {
    testWidgets('açık → koyu → açık', (tester) async {
      await _pumpSettings(tester);
      Brightness brightness() =>
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness;
      expect(brightness(), Brightness.light);

      await tester.tap(find.byKey(const ValueKey('theme-mode:dark')));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.dark);

      await tester.tap(find.byKey(const ValueKey('theme-mode:light')));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.light);
    });

    testWidgets('seçim provider state ile senkron', (tester) async {
      final container = await _pumpSettings(tester, themeMode: ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  for (final language in AppLanguage.values) {
    testWidgets('${language.code}: 320dp genişlikte taşma olmaz', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pumpSettings(tester, language: language);
      expect(tester.takeException(), isNull);
    });
  }
}
