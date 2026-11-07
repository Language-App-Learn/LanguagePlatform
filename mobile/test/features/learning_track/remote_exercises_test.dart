import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/core/utils/bidi.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';
import 'package:language_platform/features/learning_track/application/track_providers.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/pdf_delivery.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

import '../../fakes/five_stage_fakes.dart';
import '../../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

const lesson = Json.lessonId;

List<Override> _remote(
  FakeFiveStageRepository repo, {
  KeyValueStore? store,
  PdfDelivery? delivery,
}) => [
  apiBaseUriProvider.overrideWithValue(Uri.parse('http://localhost:5000')),
  fiveStageRepositoryProvider.overrideWithValue(repo),
  sessionProvider.overrideWith(
    () => SessionNotifier(SessionStatus.authenticated),
  ),
  if (store != null) keyValueStoreProvider.overrideWithValue(store),
  if (delivery != null) pdfDeliveryProvider.overrideWithValue(delivery),
];

final _allOpen = progressOf(
  statuses: List.filled(5, RemoteStageStatus.available),
);

RemoteOption _o(String id, String text) => RemoteOption(id: id, text: text);

FakeFiveStageRepository _repoFor(
  LessonStage stage,
  List<RemoteQuestion> questions,
) {
  final repo = FakeFiveStageRepository(
    assessmentId: stage == LessonStage.reading ? 'assess-1' : null,
    initialProgress: _allOpen,
  )..questions = questions;
  if (stage != LessonStage.reading) {
    repo.stageAssessments = {stage: 'assess-$stage'};
  }
  return repo;
}

Future<void> _start(WidgetTester tester) async {
  await tester.ensureVisible(_key('start-assessment'));
  await tester.tap(_key('start-assessment'));
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.ensureVisible(_key('submit-answers'));
  await tester.tap(_key('submit-answers'));
  await tester.pumpAndSettle();
}

bool _submitEnabled(WidgetTester tester) =>
    tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Submit answers'),
        )
        .onPressed !=
    null;

void main() {
  group('listening: WordBank (one blank per question)', () {
    final questions = [
      RemoteQuestion(
        id: 'b1',
        kind: 'WordBank',
        prompt: 'ذَهَبَ {{blank}} إلى المدرسة',
        maximumScore: 1,
        options: [_o('w1', 'الوَلَدُ'), _o('w2', 'البَيْتُ')],
      ),
      RemoteQuestion(
        id: 'b2',
        kind: 'WordBank',
        prompt: 'هذا {{blank}} كبير',
        maximumScore: 1,
        options: [_o('w3', 'كِتَابٌ'), _o('w4', 'قَلَمٌ')],
      ),
    ];

    testWidgets('each blank is a separate question; ids are submitted', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.listening, questions);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/listening',
        overrides: _remote(repo),
      );
      await _start(tester);
      expect(_key('remote-question:b1'), findsOneWidget);
      expect(_key('remote-question:b2'), findsOneWidget);
      // Arabic with diacritics is rendered untouched.
      expect(find.text('الوَلَدُ'), findsOneWidget);
      expect(_submitEnabled(tester), isFalse);

      await tester.tap(_key('option:w1'));
      await tester.pump();
      expect(_submitEnabled(tester), isFalse); // second blank still empty
      await tester.tap(_key('option:w4'));
      await tester.pump();
      expect(_submitEnabled(tester), isTrue);

      await _submit(tester);
      expect(repo.submitted.map((a) => a.questionId), ['b1', 'b2']);
      expect(repo.submitted.map((a) => a.optionId), ['w1', 'w4']);
      expect(repo.submitted.every((a) => a.text == null), isTrue);
    });

    testWidgets('the blank shows the chosen word and can be changed', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.listening, [questions.first]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/listening',
        overrides: _remote(repo),
      );
      await _start(tester);
      await tester.tap(_key('option:w1'));
      await tester.pump();
      await tester.tap(_key('option:w2'));
      await tester.pump();
      await _submit(tester);
      expect(repo.submitted.single.optionId, 'w2');
    });
  });

  group('writing: FillBlank and WordOrder', () {
    testWidgets('typed Arabic is sent exactly as entered', (tester) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.writing, [
        const RemoteQuestion(
          id: 'f1',
          kind: 'FillBlank',
          prompt: 'كَتَبَ الطَّالِبُ {{blank}}',
          maximumScore: 1,
        ),
      ]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/writing',
        overrides: _remote(repo),
      );
      await _start(tester);
      expect(_submitEnabled(tester), isFalse);
      const typed = 'الدَّرْسَ ';
      await tester.enterText(_key('text-answer:f1'), typed);
      await tester.pump();
      expect(_submitEnabled(tester), isTrue);
      await _submit(tester);
      // No trimming, no diacritic stripping, no normalization.
      expect(repo.submitted.single.text, typed);
      expect(repo.submitted.single.optionId, isNull);
    });

    testWidgets('whitespace alone is not an answer', (tester) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.writing, [
        const RemoteQuestion(
          id: 'f1',
          kind: 'FillBlank',
          prompt: '{{blank}}',
          maximumScore: 1,
        ),
      ]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/writing',
        overrides: _remote(repo),
      );
      await _start(tester);
      await tester.enterText(_key('text-answer:f1'), '   ');
      await tester.pump();
      expect(_submitEnabled(tester), isFalse);
    });

    final order = RemoteQuestion(
      id: 'o1',
      kind: 'WordOrder',
      prompt: 'رَتِّبِ الجُمْلَةَ',
      maximumScore: 1,
      // "the boy sees the boy": a repeated word has distinct token ids.
      options: [
        _o('t1', 'الوَلَدُ'),
        _o('t2', 'يَرَى'),
        _o('t3', 'الوَلَدَ'),
        _o('t4', 'الوَلَدُ'),
      ],
    );

    testWidgets('tokens keep their ids, repeated words included', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.writing, [order]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/writing',
        overrides: _remote(repo),
      );
      await _start(tester);
      for (final id in ['t4', 't2', 't3']) {
        await tester.tap(_key('token:$id'));
        await tester.pump();
      }
      expect(_submitEnabled(tester), isFalse); // one token still unplaced
      await tester.tap(_key('token:t1'));
      await tester.pump();
      expect(_submitEnabled(tester), isTrue);
      await _submit(tester);
      // Logical order, ids (never display text).
      expect(repo.submitted.single.orderedOptionIds, ['t4', 't2', 't3', 't1']);
      expect(repo.submitted.single.text, isNull);
    });

    testWidgets('undo, reset and tap-to-remove', (tester) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.writing, [order]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/writing',
        overrides: _remote(repo),
      );
      await _start(tester);
      for (final id in ['t1', 't2', 't3']) {
        await tester.tap(_key('token:$id'));
        await tester.pump();
      }
      expect(_key('placed:t3'), findsOneWidget);
      await tester.tap(_key('order-undo'));
      await tester.pump();
      expect(_key('placed:t3'), findsNothing);
      expect(_key('token:t3'), findsOneWidget); // back in the bank
      await tester.tap(_key('placed:t1')); // remove from the middle
      await tester.pump();
      expect(_key('placed:t1'), findsNothing);
      expect(_key('placed:t2'), findsOneWidget);
      await tester.tap(_key('order-reset'));
      await tester.pump();
      expect(_key('order-reset'), findsOneWidget);
      for (final id in ['t1', 't2', 't3', 't4']) {
        expect(_key('token:$id'), findsOneWidget);
      }
    });

    testWidgets('dragging a token onto the answer area places it', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.writing, [order]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/writing',
        overrides: _remote(repo),
      );
      await _start(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(_key('token:t2')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(tester.getCenter(_key('order-answer')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_key('placed:t2'), findsOneWidget);
    });
  });

  group('translation: MultipleChoice and ExactText', () {
    testWidgets('Turkish prompt, Arabic input, exact text submitted', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.translation, [
        const RemoteQuestion(
          id: 'x1',
          kind: 'ExactText',
          prompt: 'Merhaba, nasılsın?',
          maximumScore: 2,
        ),
        RemoteQuestion(
          id: 'x2',
          kind: 'MultipleChoice',
          prompt: 'Teşekkür ederim',
          maximumScore: 1,
          options: [_o('m1', 'شُكْرًا'), _o('m2', 'عَفْوًا')],
        ),
      ]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/translation',
        overrides: _remote(repo),
      );
      await _start(tester);
      expect(find.text('Merhaba, nasılsın?'), findsOneWidget);
      await tester.enterText(
        _key('text-answer:x1'),
        'مَرْحَبًا، كَيْفَ حَالُكَ؟',
      );
      await tester.tap(_key('option:m1'));
      await tester.pump();
      await _submit(tester);
      expect(repo.submitted[0].text, 'مَرْحَبًا، كَيْفَ حَالُكَ؟');
      expect(repo.submitted[1].optionId, 'm1');
    });
  });

  group('unsupported kinds are never guessed', () {
    testWidgets('unknown kind: notice, no submit', (tester) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.translation, [
        const RemoteQuestion(
          id: 'u1',
          kind: 'Matching',
          prompt: 'x',
          maximumScore: 1,
        ),
      ]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/translation',
        overrides: _remote(repo),
      );
      await _start(tester);
      expect(find.textContaining('not supported'), findsOneWidget);
      expect(_submitEnabled(tester), isFalse);
    });
  });

  group('attempt lifecycle and idempotency', () {
    testWidgets('an ambiguous start failure is retried with the SAME key', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [])
        ..startErrors.add(const TimeoutFailure());
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await _start(tester);
      expect(_key('assessment-error'), findsOneWidget);
      await _start(tester); // retry after the timeout
      expect(repo.startKeys, hasLength(2));
      expect(repo.startKeys[0], repo.startKeys[1]);
      expect(repo.startKeys[0], hasLength(32)); // 128-bit hex
    });

    testWidgets('a definitive rejection releases the key', (tester) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [])
        ..startErrors.add(const ConflictFailure());
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await _start(tester);
      expect(find.textContaining('attempt limit'), findsOneWidget);
      await _start(tester);
      expect(repo.startKeys[0], isNot(repo.startKeys[1]));
    });

    testWidgets('a deliberate retake after submit gets a NEW key', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [
        const RemoteQuestion(
          id: 'q',
          kind: 'TrueFalse',
          prompt: 'p',
          maximumScore: 1,
        ),
      ]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await _start(tester);
      await tester.tap(_key('option:true'));
      await tester.pump();
      await _submit(tester);
      await tester.ensureVisible(_key('retry-assessment'));
      await tester.tap(_key('retry-assessment'));
      await tester.pumpAndSettle();
      expect(repo.startKeys, hasLength(2));
      expect(repo.startKeys[0], isNot(repo.startKeys[1]));
    });

    testWidgets('after an app restart the pending key is reused', (
      tester,
    ) async {
      useScreen(tester);
      // The previous process had started an attempt and was killed.
      final store = MemoryKeyValueStore({
        'lp.attempts': jsonEncode({'assess-1': 'surviving-key'}),
      });
      final repo = _repoFor(LessonStage.reading, [
        const RemoteQuestion(
          id: 'q',
          kind: 'TrueFalse',
          prompt: 'p',
          maximumScore: 1,
        ),
      ]);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo, store: store),
      );
      await _start(tester);
      expect(repo.startKeys, ['surviving-key']);
      expect(_key('attempt-restored'), findsOneWidget);
      // Submitting forgets the key for good.
      await tester.tap(_key('option:false'));
      await tester.pump();
      await _submit(tester);
      expect(store.read('lp.attempts'), isNull);
    });

    testWidgets('an unconfirmed submit keeps the answers and can be resent', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [
        const RemoteQuestion(
          id: 'q',
          kind: 'TrueFalse',
          prompt: 'p',
          maximumScore: 1,
        ),
      ])..submitErrors.add(const NetworkUnavailableFailure());
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await _start(tester);
      await tester.tap(_key('option:true'));
      await tester.pump();
      await _submit(tester);
      expect(find.textContaining("couldn't confirm"), findsOneWidget);
      expect(_submitEnabled(tester), isTrue); // answers kept
      await _submit(tester);
      expect(_key('assessment-result'), findsOneWidget);
      expect(repo.calls.where((c) => c == 'submit'), hasLength(2));
      expect(repo.startKeys, hasLength(1)); // never a second attempt
    });

    testWidgets('a closed attempt (409) is explained and not resumable', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [
        const RemoteQuestion(
          id: 'q',
          kind: 'TrueFalse',
          prompt: 'p',
          maximumScore: 1,
        ),
      ])..submitErrors.add(const ConflictFailure());
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await _start(tester);
      await tester.tap(_key('option:true'));
      await tester.pump();
      await _submit(tester);
      expect(find.textContaining('attempt limit'), findsOneWidget);
      expect(_key('start-assessment'), findsOneWidget);
    });
  });

  group('speaking: authorized evaluator, never self-completed', () {
    FakeFiveStageRepository speakingRepo() =>
        FakeFiveStageRepository(initialProgress: _allOpen)
          ..stageAssessments = {LessonStage.speaking: 'sp-1'};

    testWidgets('start, wait, still pending, then the evaluator score', (
      tester,
    ) async {
      useScreen(tester);
      final repo = speakingRepo();
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/speaking',
        overrides: _remote(repo),
      );
      // No way to finish by tapping, no microphone control, AI is honest.
      expect(find.text('Finish'), findsNothing);
      expect(_key('speaking-ai-unavailable'), findsOneWidget);
      expect(_key('submit-answers'), findsNothing);

      await tester.tap(_key('speaking-start'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['enroll', 'start', 'attempt']);
      expect(_key('speaking-waiting'), findsOneWidget);

      await tester.tap(_key('speaking-check'));
      await tester.pumpAndSettle();
      expect(repo.resultCalls, 1);
      expect(_key('speaking-still-pending'), findsOneWidget);
      expect(_key('speaking-result'), findsNothing);

      repo.attemptResult = const RemoteAssessmentResult(
        attemptId: 'attempt-1',
        score: 72.5,
        maximumScore: 100,
        percentage: 72.5,
        passingScore: 0,
        passed: true,
      );
      final before = repo.progressCalls;
      await tester.tap(_key('speaking-check'));
      await tester.pumpAndSettle();
      expect(_key('speaking-result'), findsOneWidget);
      expect(
        find.text('${'72.5'.isolateLtr} of ${'100'.isolateLtr}'),
        findsWidgets,
      );
      expect(find.text('Passed'), findsNothing); // verdict lives on the lesson
      expect(repo.progressCalls, greaterThan(before));
    });
  });

  group('reading material, original PDF and media', () {
    ReadingMaterial material({bool pdf = true}) => ReadingMaterial(
      hasOriginalPdf: pdf,
      lines: const [
        ReadingLine(id: 'l1', page: 1, order: 1, text: 'أَوَّلًا: مَرْحَبًا'),
        ReadingLine(
          id: 'l2',
          page: 1,
          order: 2,
          text: 'ثَانِيًا: أَنَا طَالِبٌ',
        ),
        ReadingLine(id: 'l3', page: 2, order: 1, text: 'ثَالِثًا'),
      ],
    );

    testWidgets('approved lines: server order, ids, diacritics kept', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [])..reading = material();
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      expect(find.text('أَوَّلًا: مَرْحَبًا'), findsOneWidget);
      final y1 = tester.getTopLeft(_key('reading-line:l1')).dy;
      final y2 = tester.getTopLeft(_key('reading-line:l2')).dy;
      final y3 = tester.getTopLeft(_key('reading-line:l3')).dy;
      expect(y1, lessThan(y2));
      expect(y2, lessThan(y3)); // page 2 after page 1
      expect(_key('reading-fallback'), findsNothing);
    });

    testWidgets('no approved lines: the authored stage text is the fallback', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [])
        ..reading = const ReadingMaterial(lines: [], hasOriginalPdf: false);
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      expect(_key('reading-fallback'), findsOneWidget);
      expect(_key('pdf-download'), findsNothing); // no PDF, no button
    });

    testWidgets('PDF is downloaded with the session and handed over', (
      tester,
    ) async {
      useScreen(tester);
      final delivered = <String>[];
      final repo = _repoFor(LessonStage.reading, [])
        ..reading = material()
        ..pdfBytes = Uint8List.fromList(utf8.encode('%PDF-1.7 demo'));
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo, delivery: _Recorder(delivered)),
      );
      await tester.ensureVisible(_key('pdf-download'));
      await tester.tap(_key('pdf-download'));
      await tester.pumpAndSettle();
      expect(repo.pdfCalls, 1);
      expect(delivered, ['lesson-222222222222.pdf']); // safe, derived name
      expect(find.textContaining('PDF downloaded'), findsOneWidget);
      expect(find.textContaining('cannot save or open'), findsNothing);
    });

    testWidgets('without a hand-over component the UI says so honestly', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [])
        ..reading = material()
        ..pdfBytes = Uint8List.fromList(utf8.encode('%PDF-1.7 demo'));
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await tester.ensureVisible(_key('pdf-download'));
      await tester.tap(_key('pdf-download'));
      await tester.pumpAndSettle();
      expect(find.textContaining('cannot save or open'), findsOneWidget);
    });

    testWidgets('download failures are typed (expired session / missing)', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [])
        ..reading = material()
        ..pdfError = const UnauthorizedFailure();
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await tester.ensureVisible(_key('pdf-download'));
      await tester.tap(_key('pdf-download'));
      await tester.pumpAndSettle();
      expect(find.text('Please sign in to continue.'), findsOneWidget);
      repo.pdfError = const NotFoundFailure();
      await tester.tap(_key('pdf-download'));
      await tester.pumpAndSettle();
      expect(find.textContaining("couldn't find"), findsOneWidget);
    });

    testWidgets('media is shown as availability, never as a fake player', (
      tester,
    ) async {
      useScreen(tester);
      final repo = _repoFor(LessonStage.reading, [])
        ..reading = material(pdf: false)
        ..media = StageMedia(
          audioUrl: Uri.parse('https://cdn.example.com/secret/a.mp3?sig=abc'),
          videoUrl: Uri.parse('https://cdn.example.com/secret/v.mp4?sig=abc'),
          videoTitle: 'Dersin özeti',
        );
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      expect(_key('media-panel'), findsOneWidget);
      expect(find.text('Teacher video: Dersin özeti'), findsOneWidget);
      expect(_key('media-playback-unavailable'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('media-panel'),
          matching: find.byIcon(Icons.play_arrow),
        ),
        findsNothing,
      );
      // Signed URLs are never displayed.
      expect(find.textContaining('cdn.example.com'), findsNothing);
      expect(find.textContaining('sig='), findsNothing);
    });
  });

  group('direct URL access to locked stages', () {
    testWidgets('remote: a locked stage opens nothing and writes nothing', (
      tester,
    ) async {
      useScreen(tester);
      final repo = FakeFiveStageRepository(initialProgress: progressOf());
      final c = await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/writing',
        overrides: _remote(repo),
      );
      expect(find.text('Not yet accessible'), findsOneWidget);
      expect(repo.calls, isEmpty); // no enroll / start / attempt
      expect(c.read(stageRecordsProvider), isEmpty); // no local record
    });

    testWidgets('demo: a locked stage no longer records "started"', (
      tester,
    ) async {
      useScreen(tester);
      final c = await pumpApp(
        tester,
        initialLocation: '/stages/ar-a1-l1/listening',
        overrides: [trToArPreferences],
      );
      expect(find.text('Not yet accessible'), findsOneWidget);
      expect(c.read(stageRecordsProvider), isEmpty);
    });
  });

  group('account switching', () {
    testWidgets('A\'s cached progress is never shown to B', (tester) async {
      useScreen(tester);
      final repo = FakeFiveStageRepository(
        initialProgress: progressOf(
          statuses: List.filled(5, RemoteStageStatus.completed),
          scores: [90, 90, 90, 90, 90],
          finalScore: 90,
          passed: true,
        ),
      );
      final c = await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo),
      );
      expect(find.text('Passed'), findsOneWidget); // account A

      // A signs out: nothing of A remains on screen, no learner request.
      final before = repo.progressCalls;
      c.read(sessionProvider.notifier).signOut();
      await tester.pumpAndSettle();
      expect(find.text('Passed'), findsNothing);
      expect(_key('sign-in-prompt'), findsOneWidget);
      expect(repo.progressCalls, before);

      // B signs in (a new account with no progress yet).
      repo.progress = null;
      c.read(sessionProvider.notifier).authenticated();
      await tester.pumpAndSettle();
      expect(repo.progressCalls, greaterThan(before)); // refetched, not cached
      expect(find.text('Passed'), findsNothing);
      expect(_key('begin-lesson'), findsOneWidget);
    });

    testWidgets('signing in over a live session also drops the old cache', (
      tester,
    ) async {
      useScreen(tester);
      final repo = FakeFiveStageRepository(
        initialProgress: progressOf(
          statuses: List.filled(5, RemoteStageStatus.completed),
          scores: [90, 90, 90, 90, 90],
          finalScore: 90,
          passed: true,
        ),
      );
      final c = await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo),
      );
      expect(find.text('Passed'), findsOneWidget);
      repo.progress = progressOf(); // account B
      c.read(sessionProvider.notifier).authenticated(); // no sign-out first
      await tester.pumpAndSettle();
      expect(find.text('Passed'), findsNothing);
    });

    testWidgets('identity change clears pending attempt keys', (tester) async {
      useScreen(tester);
      final store = MemoryKeyValueStore({
        'lp.attempts': jsonEncode({'assess-1': 'a-key'}),
      });
      final repo = _repoFor(LessonStage.reading, []);
      final c = await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo, store: store),
      );
      c.read(sessionProvider.notifier).signOut();
      await tester.pumpAndSettle();
      expect(store.read('lp.attempts'), isNull);
    });
  });
}

class _Recorder implements PdfDelivery {
  _Recorder(this.names);

  final List<String> names;

  @override
  Future<PdfDeliveryOutcome> deliver(
    Uint8List bytes, {
    required String fileName,
  }) async {
    names.add(fileName);
    return PdfDeliveryOutcome.delivered;
  }
}
