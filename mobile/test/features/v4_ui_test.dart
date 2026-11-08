import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/design_system/widgets/content_text.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/features/language_selection/presentation/widgets/language_badge.dart';
import 'package:language_platform/features/onboarding/presentation/widgets/onboarding_step_view.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/splash/application/startup_route.dart';

import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

void main() {
  group('splash', () {
    testWidgets('shows brand and tagline while the route is being decided', (
      tester,
    ) async {
      final never = Completer<String>();
      await pumpApp(
        tester,
        initialLocation: AppRoutes.splash,
        settle: false,
        overrides: [startupRouteProvider.overrideWith((ref) => never.future)],
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('LanguagePlatform'), findsOneWidget);
      expect(find.text('LANGUAGE LEARNING PLATFORM'), findsOneWidget);
    });

    testWidgets('tagline follows the interface language', (tester) async {
      final never = Completer<String>();
      await pumpApp(
        tester,
        language: AppLanguage.ar,
        initialLocation: AppRoutes.splash,
        settle: false,
        overrides: [startupRouteProvider.overrideWith((ref) => never.future)],
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('منصة تعلّم اللغات'), findsOneWidget);
    });
  });

  group('onboarding illustrations', () {
    testWidgets('each step has its own illustration and stays accessible', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.onboarding);
      expect(find.byType(StepIllustration), findsOneWidget);
      final icons = <IconData>{};
      for (var i = 0; i < 4; i++) {
        icons.add(
          tester.widget<StepIllustration>(find.byType(StepIllustration)).icon,
        );
        if (i < 3) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
      }
      expect(icons, hasLength(4)); // distinct per step
      // Decorative artwork is not in the semantics tree; titles are headers.
      expect(find.text('Track your progress'), findsOneWidget);
    });
  });

  group('language selection cards', () {
    testWidgets('known and target lists show ISO badges, independent values', (
      tester,
    ) async {
      useScreen(tester, height: 2000);
      await pumpApp(tester, initialLocation: AppRoutes.languageSetup);
      // 3 (interface chips have no leading) -> known list 3 + target list 3
      expect(find.byType(LanguageBadge), findsNWidgets(6));
      expect(find.text('TR'.isolateLtrForTest), findsNWidgets(2));
    });
  });

  group('Arabic typography', () {
    testWidgets(
      'Arabic gets larger size and tall line height, text untouched',
      (tester) async {
        const word = 'مَرْحَبًا';
        await tester.pumpWidget(
          const MaterialApp(
            home: Column(
              children: [
                ContentText(
                  word,
                  languageCode: 'ar',
                  style: TextStyle(fontSize: 20),
                ),
                ContentText(
                  'hello',
                  languageCode: 'en',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        );
        final ar = tester.widget<Text>(find.text(word));
        expect(ar.data, word); // diacritics preserved exactly
        expect(
          ar.style!.fontSize,
          closeTo(20 * ContentText.arabicScale, 0.001),
        );
        expect(ar.style!.height, ContentText.arabicLineHeight);
        expect(ar.textDirection, TextDirection.rtl);
        final en = tester.widget<Text>(find.text('hello'));
        expect(en.style!.fontSize, 20);
        expect(en.style!.height, isNull);
        expect(en.textDirection, TextDirection.ltr);
      },
    );
  });

  group('lesson header', () {
    testWidgets('shows course, position, duration; opening does not complete', (
      tester,
    ) async {
      useScreen(tester, height: 3000);
      final c = await pumpApp(
        tester,
        initialLocation: '/lesson/ar-a1-l2',
        overrides: [trToArPreferences, fixedClock],
      );
      final header = _key('lesson-header');
      expect(header, findsOneWidget);
      expect(
        find.descendant(
          of: header,
          matching: find.text('Arabic A1: First Steps'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: header, matching: find.text('Lesson 2 of 3')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: header, matching: find.text('10 min')),
        findsOneWidget,
      );
      expect(c.read(progressProvider).completedCount, 0);
    });

    testWidgets('completion updates the header and shows feedback', (
      tester,
    ) async {
      useScreen(tester, height: 3000);
      final c = await pumpApp(
        tester,
        initialLocation: '/lesson/ar-a1-l1',
        overrides: [trToArPreferences, fixedClock],
      );
      await tester.tap(find.text('Mark as complete'));
      await tester.pump();
      expect(find.text('Lesson marked as complete'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: _key('lesson-header'),
          matching: find.text('Completed'),
        ),
        findsOneWidget,
      );
      expect(c.read(progressProvider).completedCount, 1);
    });
  });

  group('quiz redesign', () {
    Future<void> openQuiz(WidgetTester tester, {AppLanguage? lang}) async {
      useScreen(tester, height: 3200);
      await pumpApp(
        tester,
        language: lang ?? AppLanguage.en,
        initialLocation: '/lesson/ar-a1-l1',
        overrides: [trToArPreferences, fixedClock],
      );
      await tester.ensureVisible(find.byIcon(Icons.quiz_outlined));
      await tester.tap(find.byIcon(Icons.quiz_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'options carry letter markers (Latin / Arabic by UI language)',
      (tester) async {
        await openQuiz(tester);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      },
    );

    testWidgets('Arabic UI uses Arabic letters', (tester) async {
      await openQuiz(tester, lang: AppLanguage.ar);
      expect(find.text('أ'), findsOneWidget);
      expect(find.text('ب'), findsOneWidget);
    });

    testWidgets('leaving mid-attempt asks for confirmation; cancel stays', (
      tester,
    ) async {
      await openQuiz(tester);
      await tester.tap(_key('option:a'));
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Leave the quiz?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 6'), findsOneWidget);
    });

    testWidgets('confirming leave returns to the lesson', (tester) async {
      await openQuiz(tester);
      await tester.tap(_key('option:a'));
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 6'), findsNothing);
      expect(find.text('Take the quiz'), findsOneWidget); // back on the lesson
    });

    testWidgets('leaving before answering needs no confirmation', (
      tester,
    ) async {
      await openQuiz(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Leave the quiz?'), findsNothing);
      expect(find.text('Take the quiz'), findsOneWidget);
    });
  });
}

extension on String {
  String get isolateLtrForTest => '\u{2066}$this\u{2069}';
}
