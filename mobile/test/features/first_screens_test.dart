import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/design_system/widgets/app_logo.dart';
import 'package:language_platform/core/l10n/app_language.dart';
import 'package:language_platform/features/language_selection/application/learning_preferences.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';

import 'package:language_platform/features/learning_track/application/track_providers.dart';

import '../fakes/five_stage_fakes.dart';
import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

void main() {
  group('screen 1: splash', () {
    testWidgets('only the centered logo; no buttons or sections', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 800);
      // A real hold so the splash stays on screen long enough to inspect.
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.splash,
        splashHold: const Duration(seconds: 2),
        settle: false,
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(LogoMark), findsOneWidget);
      expect(find.text('LanguagePlatform'), findsOneWidget);
      expect(find.text('DİL ÖĞRENME PLATFORMU'), findsOneWidget);
      for (final type in [
        FilledButton,
        OutlinedButton,
        TextButton,
        IconButton,
        InkWell,
      ]) {
        expect(find.byType(type), findsNothing, reason: '$type');
      }
      // The logo is horizontally centered.
      final center = tester.getCenter(find.byType(LogoMark));
      expect(center.dx, closeTo(200, 1));
      await tester.pump(const Duration(seconds: 3)); // let the hold finish
      await tester.pumpAndSettle();
    });

    testWidgets('continues after the hold, not before', (tester) async {
      final c = await pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
        splashHold: const Duration(seconds: 1),
        settle: false,
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(currentPath(c), AppRoutes.splash);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.menu);
    });
  });

  group('screen 2: app language', () {
    testWidgets('three options in the drawn order, current language chosen', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 900);
      await pumpApp(
        tester,
        language: null, // first launch: follows the device (English in tests)
        initialLocation: AppRoutes.appLanguage,
      );
      expect(find.text('Which language should the app use?'), findsOneWidget);
      expect(
        find.text('Choose the app\'s interface language.'),
        findsOneWidget,
      );
      final tr = tester.getTopLeft(_key('app-language:tr')).dy;
      final en = tester.getTopLeft(_key('app-language:en')).dy;
      final ar = tester.getTopLeft(_key('app-language:ar')).dy;
      expect(tr, lessThan(en));
      expect(en, lessThan(ar));
      // Native names, never translated.
      expect(find.text('Türkçe'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      // The device language (English) starts highlighted.
      expect(
        find.descendant(
          of: _key('app-language:en'),
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('choosing previews the language; saving happens on continue', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 900);
      final c = await pumpApp(
        tester,
        language: null,
        initialLocation: AppRoutes.appLanguage,
      );
      await tester.tap(_key('app-language:tr'));
      await tester.pumpAndSettle();
      // The screen itself switches to Turkish right away...
      expect(find.text('Uygulama hangi dilde çalışsın?'), findsOneWidget);
      // ...but nothing is saved yet.
      expect(c.read(appLanguageProvider), isNull);

      await tester.tap(_key('app-language-continue'));
      await tester.pumpAndSettle();
      expect(c.read(appLanguageProvider), AppLanguage.tr); // saved
      expect(currentPath(c), AppRoutes.menu);
      expect(find.text('Dil Öğren'), findsOneWidget);
    });

    testWidgets('Arabic previews right-to-left and is saved', (tester) async {
      useScreen(tester, width: 400, height: 900);
      final c = await pumpApp(
        tester,
        language: null,
        initialLocation: AppRoutes.appLanguage,
      );
      await tester.tap(_key('app-language:ar'));
      await tester.pumpAndSettle();
      expect(find.text('بأي لغة يعمل التطبيق؟'), findsOneWidget);
      expect(currentDirection(tester), TextDirection.rtl);
      await tester.tap(_key('app-language-continue'));
      await tester.pumpAndSettle();
      expect(c.read(appLanguageProvider), AppLanguage.ar);
      expect(currentDirection(tester), TextDirection.rtl);
      expect(find.text('تعلّم لغة'), findsOneWidget);
    });

    testWidgets('options are accessible: labelled, selected state announced', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      useScreen(tester, width: 400, height: 900);
      await pumpApp(
        tester,
        language: null,
        initialLocation: AppRoutes.appLanguage,
      );
      final node = tester.getSemantics(_key('app-language:en'));
      expect(node.label, 'English');
      expect(node.flagsCollection.isSelected, Tristate.isTrue);
      handle.dispose();
    });
  });

  group('screen 3: main menu', () {
    testWidgets('exactly two entries, in the drawn order', (tester) async {
      useScreen(tester, width: 400, height: 900);
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.menu,
      );
      expect(find.text('Dil Öğren'), findsOneWidget);
      expect(find.text('Tüm Dillerde Çeviri'), findsOneWidget);
      expect(find.text('LanguagePlatform'), findsOneWidget);
      expect(
        tester.getTopLeft(_key('menu-learn')).dy,
        lessThan(tester.getTopLeft(_key('menu-translate')).dy),
      );
      // Nothing else is interactive: no extra cards, stats or buttons.
      expect(find.byType(InkWell), findsNWidgets(2));
      for (final type in [FilledButton, OutlinedButton, TextButton]) {
        expect(find.byType(type), findsNothing);
      }
    });

    testWidgets('Dil Öğren opens the language pair screen (4)', (tester) async {
      final c = await pumpApp(tester, initialLocation: AppRoutes.menu);
      await tester.tap(_key('menu-learn'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.languagePair);
    });

    testWidgets('translation is not built: a message, no new screen', (
      tester,
    ) async {
      final c = await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.menu,
      );
      await tester.tap(_key('menu-translate'));
      await tester.pump();
      expect(find.text('Çeviri yakında geliyor.'), findsOneWidget);
      expect(currentPath(c), AppRoutes.menu);
    });

    testWidgets('Arabic: right-to-left with a mirrored chevron', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 900);
      await pumpApp(
        tester,
        language: AppLanguage.ar,
        initialLocation: AppRoutes.menu,
      );
      expect(currentDirection(tester), TextDirection.rtl);
      expect(find.text('تعلّم لغة'), findsOneWidget);
      expect(find.text('الترجمة بجميع اللغات'), findsOneWidget);
      // The icon sits on the right (start side), the chevron on the left.
      final icon = tester.getCenter(find.byIcon(Icons.school_rounded)).dx;
      final chevron = tester
          .getCenter(
            find.descendant(
              of: _key('menu-learn'),
              matching: find.byIcon(Icons.chevron_right),
            ),
          )
          .dx;
      expect(icon, greaterThan(chevron));
    });

    testWidgets('cards are labelled for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.menu,
      );
      expect(find.bySemanticsLabel('Dil Öğren'), findsOneWidget);
      expect(find.bySemanticsLabel('Tüm Dillerde Çeviri'), findsOneWidget);
      handle.dispose();
    });
  });

  group('screen 4: language pair', () {
    testWidgets('exactly two fixed fields and a continue button', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 900);
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.languagePair,
      );
      expect(find.text('Dil Seçimi'), findsOneWidget);
      expect(find.text('Bildiğin Dil'), findsOneWidget);
      expect(find.text('Öğreneceğin Dil'), findsOneWidget);
      expect(
        find.descendant(of: _key('pair-known'), matching: find.text('Türkçe')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _key('pair-target'), matching: find.text('Arapça')),
        findsOneWidget,
      );
      expect(find.text('Devam Et'), findsOneWidget);
      expect(_key('pair-continue'), findsOneWidget);
      // Only the continue button and the back button are interactive.
      expect(find.byType(FilledButton), findsOneWidget);
      // Dropdown-style fields, each holding exactly the one valid choice.
      expect(find.byType(PopupMenuButton<LearningLanguage>), findsNWidgets(2));
      expect(
        tester.getTopLeft(_key('pair-known')).dy,
        lessThan(tester.getTopLeft(_key('pair-target')).dy),
      );
    });

    testWidgets('3 -> 4 -> 5, and the pair is stored', (tester) async {
      useScreen(tester, width: 400, height: 900);
      final c = await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.menu,
      );
      await tester.tap(_key('menu-learn'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.languagePair);
      await tester.tap(_key('pair-continue'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.arabicSections);
      final prefs = c.read(learningPreferencesProvider);
      expect(prefs.knownLanguage?.code, 'tr');
      expect(prefs.targetLanguage?.code, 'ar');
    });

    testWidgets('independent from the interface language of screen 2', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 900);
      final c = await pumpApp(
        tester,
        language: AppLanguage.en,
        initialLocation: AppRoutes.languagePair,
      );
      // English interface, yet the pair is still Turkish -> Arabic.
      expect(find.text('Language you know'), findsOneWidget);
      expect(
        find.descendant(of: _key('pair-known'), matching: find.text('Turkish')),
        findsOneWidget,
      );
      await tester.tap(_key('pair-continue'));
      await tester.pumpAndSettle();
      expect(c.read(appLanguageProvider), AppLanguage.en); // unchanged
      expect(currentDirection(tester), TextDirection.ltr);
    });

    testWidgets('back returns to the menu', (tester) async {
      final c = await pumpApp(tester, initialLocation: AppRoutes.menu);
      await tester.tap(_key('menu-learn'));
      await tester.pumpAndSettle();
      await tester.tap(_key('brand-back'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.menu);
    });
  });

  group('screen 5: Arabic sections', () {
    const order = [
      ('learn-arabic', 'Arapça Öğren'),
      ('reading-writing', 'Okuma Yazma Öğren'),
      ('quran', 'Kur\'an-ı Kerim'),
      ('exams', 'YDS / YDT / YÖKDİL'),
      ('ai-practice', 'AI ile Pratik Yap'),
    ];

    testWidgets('five entries in the drawn order, nothing else', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 900);
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.arabicSections,
      );
      double? last;
      for (final (id, title) in order) {
        expect(find.text(title), findsOneWidget, reason: title);
        final y = tester.getTopLeft(_key('section:$id')).dy;
        if (last != null) expect(y, greaterThan(last));
        last = y;
      }
      expect(find.byType(InkWell), findsNWidgets(order.length + 1)); // + back
    });

    testWidgets('only Arapça Öğren opens (screen 6)', (tester) async {
      useScreen(tester, width: 400, height: 900);
      final c = await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.arabicSections,
      );
      await tester.tap(_key('section:learn-arabic'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/track/tr-ar');
      expect(find.text('Seviye Seçimi'), findsOneWidget);
    });

    testWidgets('unavailable entries stay put and claim no feature', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 900);
      final c = await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.arabicSections,
      );
      for (final (id, _) in order.skip(1)) {
        await tester.tap(_key('section:$id'));
        await tester.pump();
        expect(currentPath(c), AppRoutes.arabicSections, reason: id);
        expect(find.text('Bu bölüm henüz kullanıma açılmadı.'), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
      // They look like the others (as drawn); no visible tag is added.
      expect(find.text('Yakında'), findsNothing);
    });
  });

  group('screen 6: level selection', () {
    testWidgets('seven entries in the drawn order, nothing else', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 1400);
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: '/track/tr-ar',
      );
      expect(find.text('Seviye Seçimi'), findsOneWidget);
      expect(find.text('Sıfırdan Öğren'), findsOneWidget);
      double? last;
      for (final id in ['scratch', 'a1', 'a2', 'b1', 'b2', 'c1', 'c2']) {
        final y = tester.getTopLeft(_key('level-card:$id')).dy;
        if (last != null) expect(y, greaterThan(last), reason: id);
        last = y;
      }
      for (final code in ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
        expect(find.text('\u2066$code\u2069'), findsOneWidget);
      }
      expect(_key('level-card:c3'), findsNothing); // no seventh CEFR level
      // No names, counts, demo badge or descriptions.
      for (final text in ['Başlangıç', 'Demo içerik']) {
        expect(find.text(text), findsNothing, reason: text);
      }
      expect(find.textContaining('yayında'), findsNothing);
    });

    testWidgets('Sıfırdan Öğren is visible but opens nothing', (tester) async {
      useScreen(tester, width: 400, height: 1400);
      final c = await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: '/track/tr-ar',
      );
      await tester.tap(_key('level-card:scratch'));
      await tester.pump();
      expect(currentPath(c), '/track/tr-ar');
      expect(find.text('Bu bölüm henüz kullanıma açılmadı.'), findsOneWidget);
    });

    testWidgets('a level opens screen 7 directly (no lesson list between)', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 1400);
      final c = await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: '/track/tr-ar',
      );
      await tester.tap(_key('level-card:a1'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/track/tr-ar/level/a1');
      expect(find.text('Arapça Dersleri'), findsOneWidget);
      expect(_key('position:1'), findsNothing); // no old lesson list
    });
  });

  group('screen 7: lesson menu', () {
    const screen = '/track/tr-ar/level/a1';
    const stages = [
      'stage-card:reading',
      'stage-card:listening',
      'stage-card:translation',
      'stage-card:writing',
      'stage-card:speaking',
      'mode-test',
    ];

    testWidgets('exactly six cards in two columns, in the drawn order', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 1200);
      await pumpApp(tester, language: AppLanguage.tr, initialLocation: screen);
      final pos = [for (final id in stages) tester.getTopLeft(_key(id))];
      // Row 1: Okuma | Dinleme, Row 2: Tercüme | Yazma, Row 3: Konuşma | Test
      for (var row = 0; row < 3; row++) {
        final left = pos[row * 2];
        final right = pos[row * 2 + 1];
        expect(left.dy, closeTo(right.dy, 0.5), reason: 'row $row');
        expect(left.dx, lessThan(right.dx), reason: 'row $row');
        if (row > 0) expect(left.dy, greaterThan(pos[row * 2 - 2].dy));
      }
      expect(pos[0].dx, closeTo(pos[2].dx, 0.5)); // same column
      expect(pos[1].dx, closeTo(pos[5].dx, 0.5));
      for (final name in [
        'Okuma',
        'Dinleme',
        'Tercüme',
        'Yazma',
        'Konuşma',
        'Test',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      expect(find.byKey(const ValueKey('stage-card:test')), findsNothing);
    });

    testWidgets('fixed heading; no lesson title, panel, score or progress', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 1200);
      await pumpApp(tester, language: AppLanguage.tr, initialLocation: screen);
      expect(find.text('Arapça Dersleri'), findsOneWidget);
      expect(find.text('Öğrenme modunu seç.'), findsOneWidget);
      expect(_key('overall-panel'), findsNothing);
      expect(_key('sign-in-prompt'), findsNothing);
    });

    testWidgets('no lesson is selected: every card is safely unavailable', (
      tester,
    ) async {
      useScreen(tester, width: 400, height: 1200);
      final c = await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: screen,
      );
      for (final id in stages) {
        await tester.tap(_key(id));
        await tester.pump();
        expect(currentPath(c), screen, reason: id); // nothing opened
        expect(
          find.text('Bu bölüm henüz kullanıma açılmadı.'),
          findsOneWidget,
          reason: id,
        );
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
    });

    testWidgets('cards are announced as unavailable to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      useScreen(tester, width: 400, height: 1200);
      await pumpApp(tester, language: AppLanguage.tr, initialLocation: screen);
      expect(find.bySemanticsLabel('Okuma, Yakında'), findsOneWidget);
      expect(find.bySemanticsLabel('Test, Yakında'), findsOneWidget);
      handle.dispose();
    });
  });

  group('no legacy or demo content', () {
    testWidgets('screens 3-7 never ask a content source for lessons', (
      tester,
    ) async {
      final repo = FakeFiveStageRepository();
      useScreen(tester, width: 400, height: 1400);
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: AppRoutes.menu,
        overrides: [fiveStageRepositoryProvider.overrideWithValue(repo)],
      );
      for (final key in [
        'menu-learn',
        'pair-continue',
        'section:learn-arabic',
      ]) {
        await tester.tap(_key(key));
        await tester.pumpAndSettle();
      }
      await tester.tap(_key('level-card:a1'));
      await tester.pumpAndSettle();
      expect(find.text('Arapça Dersleri'), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('the screens show no sample lesson text', (tester) async {
      useScreen(tester, width: 400, height: 1400);
      await pumpApp(
        tester,
        language: AppLanguage.tr,
        initialLocation: '/track/tr-ar/level/a1',
      );
      for (final text in [
        'Selamlaşma',
        'Merhaba',
        'مرحبا',
        'Demo içerik',
        'Ders 1',
      ]) {
        expect(find.textContaining(text), findsNothing, reason: text);
      }
    });
  });

  group('robustness', () {
    for (final lang in AppLanguage.values) {
      for (final scale in [1.0, 2.0]) {
        for (final route in [
          AppRoutes.appLanguage,
          AppRoutes.menu,
          AppRoutes.languagePair,
          AppRoutes.arabicSections,
          '/track/tr-ar',
          '/track/tr-ar/level/a1',
        ]) {
          testWidgets('$route / ${lang.code} / x$scale on a 320x568 phone', (
            tester,
          ) async {
            useScreen(tester, width: 320, height: 568);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            await pumpApp(tester, language: lang, initialLocation: route);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }

    testWidgets('the logo mark paints at every size without errors', (
      tester,
    ) async {
      for (final size in [16.0, 48.0, 120.0, 512.0]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: LogoMark(size: size)),
          ),
        );
        expect(tester.takeException(), isNull, reason: 'size $size');
      }
    });
  });
}
