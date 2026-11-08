// Renders the first three screens (and the logo) to PNG files for design
// review. Skipped in normal runs. To (re)generate the images:
//
//   $env:LP_RENDER_PREVIEWS = '1'
//   flutter test test/preview/render_first_screens_test.dart --update-goldens
//
// Output: docs/design/first-three-screens/*.png (real glyphs come from the
// Windows Segoe UI fonts, which also cover Turkish and Arabic).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/app.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/design_system/widgets/app_logo.dart';
import 'package:language_platform/core/l10n/app_language.dart';

import '../helpers/pump_app.dart';
import 'preview_support.dart';

const _out = '../../docs/design/first-three-screens';

void main() {
  final enabled = Platform.environment['LP_RENDER_PREVIEWS'] == '1';
  final skip = enabled ? null : 'Set LP_RENDER_PREVIEWS=1 (design previews)';

  setUpAll(() async {
    if (enabled) {
      await loadPreviewFonts();
    }
  });

  Future<void> shot(
    WidgetTester tester,
    String name, {
    required AppLanguage language,
    required String route,
  }) async {
    usePreviewPhone(tester);
    // The flag must be off while the frame is PAINTED, so it wraps the pump.
    await withRealShadows(() async {
      await pumpApp(tester, language: language, initialLocation: route);
      await tester.pump(const Duration(seconds: 1)); // entrance finished
      await expectLater(
        find.byType(LanguagePlatformApp),
        matchesGoldenFile('$_out/$name.png'),
      );
    });
  }

  testWidgets('01 splash (tr)', (tester) async {
    usePreviewPhone(tester);
    await pumpApp(
      tester,
      language: AppLanguage.tr,
      initialLocation: AppRoutes.splash,
      splashHold: const Duration(minutes: 5),
      settle: false,
    );
    await tester.pump(const Duration(seconds: 1));
    await withRealShadows(
      () => expectLater(
        find.byType(LanguagePlatformApp),
        matchesGoldenFile('$_out/01_splash.png'),
      ),
    );
    // Let the hold timer finish so the test ends cleanly.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 6));
  }, skip: skip != null);

  testWidgets('02 app language (tr selected)', (tester) async {
    await shot(
      tester,
      '02_app_language_tr',
      language: AppLanguage.tr,
      route: AppRoutes.appLanguage,
    );
  }, skip: skip != null);

  testWidgets('02b app language (ar selected, RTL)', (tester) async {
    await shot(
      tester,
      '02b_app_language_ar_rtl',
      language: AppLanguage.ar,
      route: AppRoutes.appLanguage,
    );
  }, skip: skip != null);

  testWidgets('03 main menu (tr)', (tester) async {
    await shot(
      tester,
      '03_main_menu_tr',
      language: AppLanguage.tr,
      route: AppRoutes.menu,
    );
  }, skip: skip != null);

  testWidgets('03b main menu (ar, RTL)', (tester) async {
    await shot(
      tester,
      '03b_main_menu_ar_rtl',
      language: AppLanguage.ar,
      route: AppRoutes.menu,
    );
  }, skip: skip != null);

  testWidgets('03c main menu (en)', (tester) async {
    await shot(
      tester,
      '03c_main_menu_en',
      language: AppLanguage.en,
      route: AppRoutes.menu,
    );
  }, skip: skip != null);

  testWidgets('logo mark (1024, white and transparent)', (tester) async {
    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: ColoredBox(
            color: Colors.white,
            child: Center(child: LogoMark(size: 900)),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('$_out/logo_mark_1024.png'),
    );
    // Reference to keep the ui import honest for icon export experiments.
    expect(ui.PlatformDispatcher.instance.views, isNotEmpty);
  }, skip: skip != null);
}
