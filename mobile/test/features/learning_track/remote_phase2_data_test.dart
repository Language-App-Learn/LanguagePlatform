import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/features/authentication/data/remote_auth_repository.dart';
import 'package:language_platform/features/learning_track/data/api_five_stage_repository.dart';
import 'package:language_platform/features/learning_track/data/five_stage_dto.dart';
import 'package:language_platform/features/learning_track/domain/lesson_outcome.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/pdf_delivery.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

import '../../fakes/five_stage_fakes.dart';

void main() {
  group('fractional scores (server display is truncated, never rounded)', () {
    test('formatScore never rounds a failing score up to 60', () {
      expect(formatScore(60), '60');
      expect(formatScore(59.99), '59.99');
      expect(formatScore(59.999), '59.99');
      expect(formatScore(59.9999999), '59.99');
      expect(formatScore(59.5), '59.5');
      expect(formatScore(66.666), '66.66');
      expect(formatScore(100), '100');
      expect(formatScore(0), '0');
      expect(formatScore(7.05), '7.05');
      expect(formatScore(80.5), '80.5');
    });

    test('progress keeps decimals, nulls and the server decision', () {
      final p = progressFrom(
        Json.progress(
          statuses: List.filled(5, 'completed'),
          scores: [90.25, 61.5, 59.99, null, 100],
          finalScore: 59.999,
          passed: false,
          next: Json.nextLessonId,
        ),
      );
      expect(p.finalScore, 59.999);
      expect(p.passed, isFalse); // never recomputed from 59.999 vs 60
      expect(p.stageOf(LessonStage.writing), isNotNull);
      expect(p.stages.map((s) => s.score), [90.25, 61.5, 59.99, null, 100]);
      expect(p.passingScore, 60);
    });

    test('exactly 60 as sent by the server is passed; the flag decides', () {
      final p = progressFrom(
        Json.progress(
          statuses: List.filled(5, 'completed'),
          scores: [60, 60, 60, 60, 60],
          finalScore: 60,
          passed: true,
        ),
      );
      expect(p.passed, isTrue);
      // A final score >= 60 with passed=false is displayed as the server says.
      final q = progressFrom(
        Json.progress(finalScore: 61, passed: false, next: Json.nextLessonId),
      );
      expect(q.passed, isFalse);
    });

    test('a pending evaluation has no final score at all', () {
      final p = progressFrom(Json.progress());
      expect(p.finalScore, isNull);
      expect(p.stages.every((s) => s.score == null), isTrue);
    });
  });

  group('question kinds and answers', () {
    test('all server kinds are recognised; unknown ones are flagged', () {
      for (final (kind, type) in [
        ('MultipleChoice', RemoteQuestionKind.multipleChoice),
        ('TrueFalse', RemoteQuestionKind.trueFalse),
        ('WordBank', RemoteQuestionKind.wordBank),
        ('FillBlank', RemoteQuestionKind.fillBlank),
        ('WordOrder', RemoteQuestionKind.wordOrder),
        ('ExactText', RemoteQuestionKind.exactText),
        ('Matching', RemoteQuestionKind.unknown),
        ('', RemoteQuestionKind.unknown),
      ]) {
        expect(questionKindFrom(kind), type, reason: kind);
      }
    });

    test('answer JSON carries exactly the field of its kind', () {
      expect(answerToJson(const RemoteAnswer(questionId: 'q', optionId: 'o')), {
        'questionId': 'q',
        'optionId': 'o',
      });
      expect(answerToJson(const RemoteAnswer(questionId: 'q', value: false)), {
        'questionId': 'q',
        'value': false, // false is still sent
      });
      expect(
        answerToJson(const RemoteAnswer(questionId: 'q', text: 'مَرْحَبًا ')),
        {'questionId': 'q', 'text': 'مَرْحَبًا '},
      );
      expect(
        answerToJson(
          const RemoteAnswer(
            questionId: 'q',
            orderedOptionIds: ['b', 'a', 'b2'],
          ),
        ),
        {
          'questionId': 'q',
          'orderedOptionIds': ['b', 'a', 'b2'],
        },
      );
    });

    test('the Arabic answer survives a JSON round trip byte for byte', () {
      const typed = 'الكِتَابُ  جَمِيلٌ'; // double space + diacritics
      final json = jsonEncode(
        answerToJson(const RemoteAnswer(questionId: 'q', text: typed)),
      );
      expect((jsonDecode(json) as Map)['text'], typed);
    });

    test('completeness per kind', () {
      const wo = RemoteQuestion(
        id: 'q',
        kind: 'WordOrder',
        prompt: '',
        maximumScore: 1,
        options: [
          RemoteOption(id: 'a', text: 'x'),
          RemoteOption(id: 'b', text: 'x'),
        ],
      );
      expect(isAnswerComplete(wo, null), isFalse);
      expect(
        isAnswerComplete(
          wo,
          const RemoteAnswer(questionId: 'q', orderedOptionIds: ['a']),
        ),
        isFalse,
      );
      expect(
        isAnswerComplete(
          wo,
          const RemoteAnswer(questionId: 'q', orderedOptionIds: ['b', 'a']),
        ),
        isTrue,
      );
      const fb = RemoteQuestion(
        id: 'f',
        kind: 'FillBlank',
        prompt: '',
        maximumScore: 1,
      );
      expect(
        isAnswerComplete(fb, const RemoteAnswer(questionId: 'f', text: ' ')),
        isFalse,
      );
      expect(
        isAnswerComplete(fb, const RemoteAnswer(questionId: 'f', text: 'ب')),
        isTrue,
      );
    });

    test('attempt mapping: deadline, kinds, options; no answer key fields', () {
      final a = attemptFrom({
        ...Json.attempt(),
        'deadlineUtc': '2026-11-06T10:30:00Z',
        'questions': [
          {
            'id': 'q9',
            'kind': 'WordOrder',
            'prompt': 'p',
            'maximumScore': 2.5,
            'options': [
              {'id': 'a', 'text': 'x'},
              {'id': 'b', 'text': 'y'},
            ],
            // A hostile/buggy payload must not leak into the model.
            'correctOrder': [1, 0],
            'acceptedAnswers': ['secret'],
          },
        ],
      });
      expect(a.deadlineUtc, DateTime.utc(2026, 11, 6, 10, 30));
      expect(a.questions.single.type, RemoteQuestionKind.wordOrder);
      expect(a.questions.single.maximumScore, 2.5);
      expect(a.questions.single.options, hasLength(2));
    });
  });

  group('reading material and media DTOs', () {
    test('lines are ordered by page then order; text is untouched', () {
      final m = readingMaterialFrom({
        'hasOriginalPdf': true,
        'lines': [
          {'id': 'c', 'page': 2, 'order': 1, 'text': 'ج'},
          {'id': 'b', 'page': 1, 'order': 2, 'text': 'ب  َ'},
          {'id': 'a', 'page': 1, 'order': 1, 'text': 'أَ'},
        ],
      });
      expect(m.lines.map((l) => l.id), ['a', 'b', 'c']);
      expect(m.lines[1].text, 'ب  َ');
      expect(m.hasOriginalPdf, isTrue);
    });

    test('missing lines list means text-only authoring', () {
      final m = readingMaterialFrom({'hasOriginalPdf': false});
      expect(m.lines, isEmpty);
      expect(m.hasOriginalPdf, isFalse);
    });

    test('a line without text is a malformed payload', () {
      expect(
        () => readingMaterialFrom({
          'lines': [
            {'id': 'a', 'order': 1},
          ],
        }),
        throwsFormatException,
      );
    });

    test('only absolute https URLs without credentials are accepted', () {
      for (final bad in [
        'http://cdn.example.com/a.mp3',
        'ftp://cdn.example.com/a.mp3',
        'https://user:pw@cdn.example.com/a.mp3',
        'javascript:alert(1)',
        'file:///etc/passwd',
        '/relative/path.mp3',
        '',
      ]) {
        expect(safeMediaUri(bad), isNull, reason: bad);
      }
      expect(safeMediaUri(null), isNull);
      expect(safeMediaUri(42), isNull);
      expect(
        safeMediaUri('https://cdn.example.com/a.mp3?x=1')?.host,
        'cdn.example.com',
      );
    });

    test('stage media maps audio and teacher video', () {
      final m = stageMediaFrom({
        'audioUrl': 'https://cdn.example.com/a.mp3',
        'teacherVideo': {'url': 'https://cdn.example.com/v.mp4', 'title': 'T'},
      });
      expect(m.hasAudio && m.hasVideo, isTrue);
      expect(m.videoTitle, 'T');
      final none = stageMediaFrom({'audioUrl': null, 'teacherVideo': null});
      expect(none.isEmpty, isTrue);
      final unsafe = stageMediaFrom({
        'audioUrl': 'http://insecure.example.com/a.mp3',
      });
      expect(unsafe.isEmpty, isTrue);
    });

    test('PDF file names are derived, never taken from the server', () {
      expect(safePdfFileName(Json.lessonId), 'lesson-222222222222.pdf');
      expect(safePdfFileName('../../etc/passwd'), isNot(contains('/')));
      expect(
        safePdfFileName('../../x'),
        matches(RegExp(r'^lesson-[a-z0-9]+\.pdf$')),
      );
      expect(safePdfFileName(''), 'lesson-reading.pdf');
    });
  });

  group('ApiFiveStageRepository: reading, PDF, media, results', () {
    ApiFiveStageRepository repoFor(HandlerApiClient api) =>
        ApiFiveStageRepository(api);

    test('reading material route; 404 becomes null', () async {
      final api = HandlerApiClient(
        (r) async => r.path.endsWith('/reading-material')
            ? const ApiResponse(404)
            : const ApiResponse(500),
      );
      expect(await repoFor(api).getReadingMaterial('c', 'l'), isNull);
      expect(
        api.requests.single.path,
        '/api/v1/me/courses/c/lessons/l/reading-material',
      );
      expect(api.requests.single.requiresAuth, isTrue);
    });

    test('PDF download: authenticated, typed as application/pdf', () async {
      final bytes = Uint8List.fromList(utf8.encode('%PDF-1.7 x'));
      final api = HandlerApiClient(
        (r) async => ApiResponse(200, null, const {}, bytes),
      );
      final got = await repoFor(api).downloadReadingPdf('c', 'l');
      expect(got, bytes);
      final sent = api.requests.single;
      expect(
        sent.path,
        '/api/v1/me/courses/c/lessons/l/reading-material/original',
      );
      expect(sent.expectedMime, 'application/pdf');
      expect(sent.requiresAuth, isTrue);
    });

    test('a body that is not a PDF is rejected even with a 200', () async {
      final api = HandlerApiClient(
        (r) async => ApiResponse(
          200,
          null,
          const {},
          Uint8List.fromList(utf8.encode('{"ok":true}')),
        ),
      );
      await expectLater(
        repoFor(api).downloadReadingPdf('c', 'l'),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
    });

    test('PDF download failures keep their kind', () async {
      for (final (status, matcher) in [
        (401, isA<UnauthorizedFailure>()),
        (404, isA<NotFoundFailure>()),
        (413, isA<PayloadTooLargeFailure>()),
        (415, isA<UnsupportedMediaFailure>()),
        (429, isA<RateLimitedFailure>()),
        (503, isA<ServerFailure>()),
      ]) {
        final api = HandlerApiClient((_) async => ApiResponse(status));
        await expectLater(
          repoFor(api).downloadReadingPdf('c', 'l'),
          throwsA(matcher),
          reason: '$status',
        );
      }
    });

    test('stage media route; 404 is null', () async {
      final api = HandlerApiClient((_) async => const ApiResponse(404));
      expect(await repoFor(api).getStageMedia('c', 'l', 's'), isNull);
      expect(
        api.requests.single.path,
        '/api/v1/me/courses/c/lessons/l/stages/s/media',
      );
    });

    test('attempt result: pending is null, ready is mapped', () async {
      var ready = false;
      final api = HandlerApiClient(
        (_) async => ready
            ? ApiResponse(200, Json.assessmentResult(score: 72.5))
            : const ApiResponse(404),
      );
      final repo = repoFor(api);
      expect(await repo.getAttemptResult('a1'), isNull);
      ready = true;
      final r = await repo.getAttemptResult('a1');
      expect(r?.score, 72.5);
      expect(
        api.requests.first.path,
        '/api/v1/me/assessment-attempts/a1/result',
      );
    });

    test(
      'submit sends the answer shapes of every kind, nothing else',
      () async {
        final api = HandlerApiClient(
          (_) async => ApiResponse(200, Json.assessmentResult()),
        );
        await repoFor(api).submitAttempt(
          courseId: 'c',
          lessonId: 'l',
          assessmentId: 'a',
          attemptId: 't',
          answers: const [
            RemoteAnswer(questionId: '1', optionId: 'o'),
            RemoteAnswer(questionId: '2', value: true),
            RemoteAnswer(questionId: '3', text: 'ب'),
            RemoteAnswer(questionId: '4', orderedOptionIds: ['x', 'y']),
          ],
        );
        final body = api.requests.single.body! as Map;
        expect(body.keys, ['answers']);
        expect((body['answers'] as List).map((a) => (a as Map).keys.toList()), [
          ['questionId', 'optionId'],
          ['questionId', 'value'],
          ['questionId', 'text'],
          ['questionId', 'orderedOptionIds'],
        ]);
      },
    );
  });

  group('RemoteAuthRepository: the rest of the account contract', () {
    test(
      'confirm email, resend, reset confirm and /me use the routes',
      () async {
        final api = HandlerApiClient((r) async {
          if (r.path == '/api/v1/me') {
            return const ApiResponse(200, {
              'id': 'u1',
              'email': 'a@b.co',
              'displayName': null,
            });
          }
          return const ApiResponse(204);
        });
        final repo = RemoteAuthRepository(api, InMemoryTokenStore());
        await repo.confirmEmail(userId: 'u1', code: 'c');
        await repo.resendConfirmation(email: 'a@b.co');
        await repo.confirmPasswordReset(
          email: 'a@b.co',
          code: '123',
          newPassword: 'Str0ng!Passw0rd',
        );
        final me = await repo.currentAccount();
        expect(api.requests.map((r) => r.path), [
          '/api/v1/auth/confirm-email',
          '/api/v1/auth/confirm-email/resend',
          '/api/v1/auth/password-reset/confirm',
          '/api/v1/me',
        ]);
        expect(api.requests.last.requiresAuth, isTrue);
        expect(api.requests.first.body, {'userId': 'u1', 'code': 'c'});
        expect(api.requests[2].body, {
          'email': 'a@b.co',
          'code': '123',
          'newPassword': 'Str0ng!Passw0rd',
        });
        expect(me.displayName, isNull); // nullable on the server
        expect(me.email, 'a@b.co');
      },
    );

    test(
      'resend without email delivery is "unavailable", not success',
      () async {
        final repo = RemoteAuthRepository(
          HandlerApiClient((_) async => const ApiResponse(503)),
          InMemoryTokenStore(),
        );
        await expectLater(
          repo.resendConfirmation(email: 'a@b.co'),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('invalid confirmation code is a validation failure', () async {
      final repo = RemoteAuthRepository(
        HandlerApiClient((_) async => const ApiResponse(400)),
        InMemoryTokenStore(),
      );
      await expectLater(
        repo.confirmEmail(userId: 'u', code: 'bad'),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
