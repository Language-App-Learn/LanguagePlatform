// Renders screens 4-7 of the REAL app (real router, pages and providers) to
// PNG files for design review. Skipped in normal runs. To (re)generate:
//
//   $env:LP_RENDER_PREVIEWS = '1'
//   flutter test test/preview/render_learning_screens_test.dart --update-goldens
//
// Output: docs/design/screens-4-7/*.png
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/app.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/l10n/app_language.dart';

import '../helpers/pump_app.dart';
import 'preview_support.dart';

const _out = '../../docs/design/screens-4-7';

void main() {
  final enabled = Platform.environment['LP_RENDER_PREVIEWS'] == '1';

  setUpAll(() async {
    if (enabled) await loadPreviewFonts();
  });

  Future<void> shot(
    WidgetTester tester,
    String name, {
    required AppLanguage language,
    required String route,
  }) async {
    usePreviewPhone(tester);
    await withRealShadows(() async {
      await pumpApp(
        tester,
        language: language,
        initialLocation: route,
        overrides: [trToArPreferences],
      );
      await tester.pump(const Duration(seconds: 1));
      await expectLater(
        find.byType(LanguagePlatformApp),
        matchesGoldenFile('$_out/$name.png'),
      );
    });
  }

  final cases = <(String, AppLanguage, String)>[
    ('04_language_pair_tr', AppLanguage.tr, AppRoutes.languagePair),
    ('04b_language_pair_ar_rtl', AppLanguage.ar, AppRoutes.languagePair),
    ('05_arabic_sections_tr', AppLanguage.tr, AppRoutes.arabicSections),
    ('06_level_selection_tr', AppLanguage.tr, '/track/tr-ar'),
    ('07_lesson_menu_tr', AppLanguage.tr, '/stages/ar-a1-l1'),
    ('07b_lesson_menu_ar_rtl', AppLanguage.ar, '/stages/ar-a1-l1'),
  ];
  for (final (name, language, route) in cases) {
    testWidgets(
      name,
      (tester) => shot(tester, name, language: language, route: route),
      skip: !enabled,
    );
  }
}
