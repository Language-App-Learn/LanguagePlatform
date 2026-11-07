import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_router.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/storage/app_preferences.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/learning_track/application/track_providers.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/lesson_outcome.dart';

import '../../helpers/persistent_app.dart';
import '../../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

String _statusOf(WidgetTester tester, String stage) =>
    tester.widget<Text>(_key('stage-status:$stage')).data!;

Future<MemoryKeyValueStore> _store() async {
  final store = MemoryKeyValueStore();
  await AppPreferencesRepository(store).save(
    const AppPreferences(
      interfaceLanguage: 'en',
      knownLanguage: 'tr',
      targetLanguage: 'ar',
      onboardingCompleted: true,
    ),
  );
  return store;
}

void main() {
  group('Home -> Turkish-to-Arabic -> A1 -> Lesson 1 -> five stages', () {
    testWidgets('the whole navigation path works', (tester) async {
      useScreen(tester, height: 3200);
      final c = await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.home,
      );
      expect(find.text('Learn Arabic from Turkish'), findsWidgets);
      await tester.tap(_key('track-card'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/track/tr-ar');

      // Six CEFR levels with real counts.
      for (final level in ['a1', 'a2', 'b1', 'b2', 'c1', 'c2']) {
        expect(_key('level-card:$level'), findsOneWidget);
      }
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Proficient'), findsOneWidget);
      expect(find.text('3 of 20 lessons published'), findsOneWidget); // A1 only
      expect(find.text('No lessons published yet'), findsNWidgets(5));

      await tester.tap(_key('level-card:a1'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/track/tr-ar/level/a1');
      // Exactly 20 positions exist; 3 are published.
      expect(_key('position:1'), findsOneWidget);
      await tester.scrollUntilVisible(_key('position:20'), 300);
      expect(_key('position:20'), findsOneWidget);
      expect(find.text('In preparation'), findsWidgets);

      await tester.scrollUntilVisible(_key('position:1'), -300);
      await tester.tap(_key('position:1'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/stages/ar-a1-l1');
      for (final s in LessonStage.values) {
        expect(_key('stage-card:${s.name}'), findsOneWidget);
      }
    });

    testWidgets('overview shows honest status, no fabricated score', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      await pumpApp(
        tester,
        initialLocation: '/stages/ar-a1-l1',
        overrides: [trToArPreferences],
      );
      expect(_statusOf(tester, 'reading'), 'Available');
      expect(_statusOf(tester, 'speaking'), 'Not yet accessible');
      expect(_statusOf(tester, 'translation'), 'Not yet accessible');
      expect(find.text('Not started'), findsOneWidget);
      expect(find.text('No official score yet'), findsOneWidget);
      expect(find.text('Overall pass mark: 60 out of 100'), findsOneWidget);
      expect(
        find.textContaining('weights are set by the server'),
        findsOneWidget,
      );
    });

    testWidgets('lesson without stage content: honest unavailable state', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      await pumpApp(
        tester,
        initialLocation: '/stages/ar-a1-l2',
        overrides: [trToArPreferences],
      );
      expect(_statusOf(tester, 'reading'), 'Content not published yet');
    });

    testWidgets('direct URL to a locked stage explains instead of opening', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      await pumpApp(
        tester,
        initialLocation: '/stages/ar-a1-l1/listening',
        overrides: [trToArPreferences],
      );
      expect(find.text('Not yet accessible'), findsOneWidget);
    });
  });

  group('server result is authoritative (60/100)', () {
    Future<void> openWith(WidgetTester tester, ServerLessonResult? r) async {
      useScreen(tester, height: 3200);
      await pumpApp(
        tester,
        initialLocation: '/stages/ar-a1-l1',
        overrides: [
          trToArPreferences,
          serverLessonResultProvider('ar-a1-l1').overrideWithValue(r),
        ],
      );
    }

    testWidgets('exactly 60 passes', (tester) async {
      await openWith(
        tester,
        const ServerLessonResult(finalScore: 60, passed: true, stageScores: {}),
      );
      expect(find.text('Passed'), findsOneWidget);
      expect(find.text('60/100'.isolateLtrForTest), findsOneWidget);
    });

    testWidgets('59 does not pass', (tester) async {
      await openWith(
        tester,
        const ServerLessonResult(
          finalScore: 59,
          passed: false,
          stageScores: {},
        ),
      );
      expect(find.text('Not passed, try again'), findsOneWidget);
      expect(find.text('Passed'), findsNothing);
    });

    testWidgets('weights shown only when the server provides them', (
      tester,
    ) async {
      await openWith(
        tester,
        const ServerLessonResult(
          finalScore: 70,
          passed: true,
          stageScores: {},
          weights: {LessonStage.reading: 0.5},
        ),
      );
      expect(
        find.textContaining('weights are set by the server'),
        findsNothing,
      );
    });
  });

  group('purpose-built stage experiences (demo content)', () {
    Future<ProviderContainer0> start(WidgetTester tester, String route) async {
      useScreen(tester, height: 3200);
      final store = await _store();
      final c = await launchApp(tester, store, initialLocation: route);
      return (store: store, c: c);
    }

    testWidgets('reading: lines, unavailable audio/PDF/video, questions', (
      tester,
    ) async {
      final env = await start(tester, '/stages/ar-a1-l1/reading');
      expect(_key('segment:ar-a1-l1-r1'), findsOneWidget);
      expect(
        find.text('مَرْحَبًا! أَنَا أَحْمَدُ.'),
        findsOneWidget,
      ); // tashkeel kept
      final play = tester.widget<IconButton>(_key('play:ar-a1-l1-r1'));
      expect(play.onPressed, isNull); // never pretends to play
      expect(_key('pdf-unavailable'), findsOneWidget);
      expect(_key('video-unavailable'), findsOneWidget);

      // Cannot check before answering every question.
      final check = find.widgetWithText(FilledButton, 'Check answers');
      expect(tester.widget<FilledButton>(check).onPressed, isNull);

      await tester.tap(_key('option:a').first);
      await tester.pump();
      expect(tester.widget<FilledButton>(check).onPressed, isNull);
      expect(env.c, isNotNull);
    });

    testWidgets('full five-stage practice ends awaiting official assessment', (
      tester,
    ) async {
      final env = await start(tester, '/stages/ar-a1-l1/reading');
      Map<LessonStage, StageRecord> records() =>
          env.c.read(stageRecordsProvider)["ar-a1-l1"] ?? {};

      // 1. Reading: answer all three correctly (a, b, c).
      for (final (q, opt) in [
        ('demo-r-q1', 'a'),
        ('demo-r-q2', 'b'),
        ('demo-r-q3', 'c'),
      ]) {
        final tile = find.descendant(
          of: _key(q),
          matching: _key('option:$opt'),
        );
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pump();
      }
      await tester.ensureVisible(find.text('Check answers'));
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();
      expect(find.text('3 of 3 correct'), findsOneWidget);
      expect(find.textContaining('not an official score'), findsOneWidget);
      await tester.ensureVisible(find.text('Finish practice'));
      await tester.tap(find.text('Finish practice'));
      await tester.pumpAndSettle();
      expect(records()[LessonStage.reading]!.score, 100);

      // 2. Speaking: structured dialogue; AI/mic honestly unavailable.
      env.c.read(routerProvider).go('/stages/ar-a1-l1/speaking');
      await tester.pumpAndSettle();
      expect(_key('ai-unavailable'), findsOneWidget);
      expect(tester.widget<IconButton>(_key('mic-button')).onPressed, isNull);
      await tester.ensureVisible(find.text('Finish practice'));
      await tester.tap(find.text('Finish practice'));
      await tester.pumpAndSettle();
      expect(records()[LessonStage.speaking]!.completed, isTrue);
      expect(
        records()[LessonStage.speaking]!.score,
        isNull,
      ); // no invented grade

      // 3. Listening: tap-to-place alternative (words: 0 شُكْرًا, 1 نَعَمْ, 2 مَرْحَبًا).
      env.c.read(routerProvider).go('/stages/ar-a1-l1/listening');
      await tester.pumpAndSettle();
      await tester.tap(_key('bank:2'));
      await tester.pump();
      await tester.tap(_key('blank:0'));
      await tester.pump();
      await tester.tap(_key('bank:0'));
      await tester.pump();
      await tester.tap(_key('blank:1'));
      await tester.pump();
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 2 correct'), findsOneWidget);
      await tester.tap(find.text('Finish practice'));
      await tester.pumpAndSettle();
      expect(records()[LessonStage.listening]!.score, 100);

      // 4. Writing: fill + arrange (duplicates/undo/reset available).
      env.c.read(routerProvider).go('/stages/ar-a1-l1/writing');
      await tester.pumpAndSettle();
      await tester.enterText(_key('fill:0'), 'سارة');
      // Shown order is [2,0,3,1] -> يَا, أَهْلًا, سَارَةُ, بِكَ.
      for (final j in [1, 3, 0, 2]) {
        await tester.tap(_key('arrange-bank:0:$j'));
        await tester.pump();
      }
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 2 correct'), findsOneWidget);
      await tester.ensureVisible(find.text('Finish practice'));
      await tester.tap(find.text('Finish practice'));
      await tester.pumpAndSettle();
      expect(records()[LessonStage.writing]!.completed, isTrue);

      // 5. Translation: choose + write.
      env.c.read(routerProvider).go('/stages/ar-a1-l1/translation');
      await tester.pumpAndSettle();
      await tester.tap(_key('translation-choice-0:1'));
      await tester.pump();
      await tester.enterText(_key('translate:0'), 'شكرا');
      await tester.pump();
      await tester.ensureVisible(find.text('Check answers'));
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 2 correct'), findsOneWidget);
      await tester.ensureVisible(find.text('Finish practice'));
      await tester.tap(find.text('Finish practice'));
      await tester.pumpAndSettle();

      // Overview: all five completed, but NO pass/fail without the server.
      env.c.read(routerProvider).go('/stages/ar-a1-l1');
      await tester.pumpAndSettle();
      for (final s in LessonStage.values) {
        expect(_statusOf(tester, s.name), 'Completed');
      }
      expect(find.text('Awaiting official assessment'), findsOneWidget);
      expect(find.text('Passed'), findsNothing);
      expect(find.text('No official score yet'), findsOneWidget);

      // Restart: practice records are restored.
      final c2 = await launchApp(
        tester,
        env.store,
        initialLocation: '/stages/ar-a1-l1',
      );
      expect(c2.read(stageRecordsProvider)['ar-a1-l1']!.length, 5);
      expect(_statusOf(tester, 'translation'), 'Completed');
    });

    testWidgets('listening: wrong placement is reported; reset clears blanks', (
      tester,
    ) async {
      final env = await start(tester, '/stages/ar-a1-l1/reading');
      env.c
          .read(stageRecordsProvider.notifier)
          .complete('ar-a1-l1', LessonStage.reading, 100);
      env.c
          .read(stageRecordsProvider.notifier)
          .complete('ar-a1-l1', LessonStage.speaking, null);
      env.c.read(routerProvider).go('/stages/ar-a1-l1/listening');
      await tester.pumpAndSettle();
      // Swap the right words on purpose.
      await tester.tap(_key('bank:0'));
      await tester.pump();
      await tester.tap(_key('blank:0'));
      await tester.pump();
      await tester.tap(_key('bank:2'));
      await tester.pump();
      await tester.tap(_key('blank:1'));
      await tester.pump();
      await tester.tap(find.text('Check answers'));
      await tester.pumpAndSettle();
      expect(find.text('0 of 2 correct'), findsOneWidget);
    });

    testWidgets('listening: drag and drop places a word', (tester) async {
      final env = await start(tester, '/stages/ar-a1-l1/reading');
      env.c
          .read(stageRecordsProvider.notifier)
          .complete('ar-a1-l1', LessonStage.reading, 100);
      env.c
          .read(stageRecordsProvider.notifier)
          .complete('ar-a1-l1', LessonStage.speaking, null);
      env.c.read(routerProvider).go('/stages/ar-a1-l1/listening');
      await tester.pumpAndSettle();
      final from = tester.getCenter(_key('bank:2'));
      final to = tester.getCenter(_key('blank:0'));
      final gesture = await tester.startGesture(from);
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: _key('blank:0'), matching: find.text('مَرْحَبًا')),
        findsOneWidget,
      );
      expect(_key('bank:2'), findsNothing); // word left the bank
    });
  });
}

typedef ProviderContainer0 = ({MemoryKeyValueStore store, dynamic c});

extension on String {
  String get isolateLtrForTest => '\u{2066}$this\u{2069}';
}
