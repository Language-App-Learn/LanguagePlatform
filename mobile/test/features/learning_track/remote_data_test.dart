import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/errors/app_exceptions.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/features/authentication/data/remote_auth_repository.dart';
import 'package:language_platform/features/courses/domain/course.dart';
import 'package:language_platform/features/learning_track/data/api_five_stage_repository.dart';
import 'package:language_platform/features/learning_track/data/five_stage_dto.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

import '../../fakes/five_stage_fakes.dart';

void main() {
  group('DTO mapping (contract examples)', () {
    test('catalog: picks the Turkish -> Arabic course', () {
      final course = courseFromCatalogList(Json.catalogCourses());
      expect(course?.id, Json.courseId);
      expect(courseFromCatalogList(const []), isNull);
      expect(
        courseFromCatalogList([
          {'id': 'x', 'sourceLanguageCode': 'en', 'targetLanguageCode': 'tr'},
        ]),
        isNull,
      );
    });

    test('levels: six CEFR levels in order, ids kept as opaque strings', () {
      final levels = levelsFrom(Json.levels());
      expect(levels.map((l) => l.level), CourseLevel.values);
      expect(levels.first.id, 'level-A1');
      expect(levels.every((l) => l.capacity == 20), isTrue);
    });

    test('levels: unknown CEFR codes are skipped, never guessed', () {
      final levels = levelsFrom({
        'levels': [
          {'id': 'a', 'code': 'A1', 'order': 1, 'capacity': 20},
          {'id': 'z', 'code': 'Z9', 'order': 2, 'capacity': 20},
        ],
      });
      expect(levels, hasLength(1));
    });

    test('slots: 20 positions, empty ones have no lesson', () {
      final slots = slotsFrom(Json.slots(published: 2));
      expect(slots, hasLength(20));
      expect(slots.where((s) => s.isPublished), hasLength(2));
      expect(slots[2].lessonId, isNull);
      expect(slots[2].title, isNull);
      expect(slots.first.title, 'Ders 1 başlığı');
    });

    test(
      'lesson detail: stages ordered, Arabic text and weights preserved',
      () {
        final lesson = lessonFrom(Json.lessonDetail(assessmentId: 'assess-1'));
        expect(lesson.stages.map((s) => s.kind), LessonStage.values);
        expect(lesson.passingScore, 60);
        final reading = lesson.stageOf(LessonStage.reading)!;
        expect(reading.texts['ar'], 'مَرْحَبًا'); // tashkeel intact
        expect(reading.assessmentId, 'assess-1');
        expect(reading.weight, 20);
        expect(reading.estimatedSeconds, 600);
      },
    );

    test('lesson detail: an unknown stage type maps to null kind', () {
      final json = Json.lessonDetail();
      ((json['stages']! as List).first as Map)['stageType'] = 'Hologram';
      expect(lessonFrom(json).stages.first.kind, isNull);
    });

    test('progress: statuses, fractional final score and server decision', () {
      final p = progressFrom(
        Json.progress(
          statuses: [
            'completed',
            'completed',
            'completed',
            'completed',
            'completed',
          ],
          scores: [80, 70.5, 60, 66.67, 90],
          finalScore: 59.99,
          passed: false,
          next: 'next-id',
        ),
      );
      expect(p.finalScore, 59.99);
      expect(p.passed, isFalse); // not recomputed from the score
      expect(p.passingScore, 60);
      expect(p.nextLessonId, 'next-id');
      expect(p.stageOf(LessonStage.speaking)!.score, 70.5);
      expect(
        p.stageOf(LessonStage.reading)!.status,
        RemoteStageStatus.completed,
      );
    });

    test(
      'progress: no final score yet, unknown status is treated as locked',
      () {
        final p = progressFrom(
          Json.progress(
            statuses: ['available', 'weird', 'locked', 'locked', 'locked'],
          ),
        );
        expect(p.finalScore, isNull);
        expect(
          p.stageOf(LessonStage.speaking)!.status,
          RemoteStageStatus.locked,
        );
        expect(p.stageOf(LessonStage.reading)!.score, isNull);
      },
    );

    test('attempt: questions without any answer key', () {
      final a = attemptFrom(Json.attempt());
      expect(a.questions, hasLength(2));
      expect(a.questions[0].isMultipleChoice, isTrue);
      expect(a.questions[0].options.map((o) => o.id), ['o1', 'o2']);
      expect(a.questions[1].isTrueFalse, isTrue);
      expect(a.questions.every((q) => q.isSupported), isTrue);
      const unsupported = RemoteQuestion(
        id: 'm',
        kind: 'Matching',
        prompt: '',
        maximumScore: 1,
      );
      expect(unsupported.isSupported, isFalse);
    });

    test('assessment result and answer serialisation', () {
      final r = assessmentResultFrom(
        Json.assessmentResult(score: 1, passed: false),
      );
      expect(r.score, 1);
      expect(r.maximumScore, 2);
      expect(r.passed, isFalse);
      expect(answerToJson(const RemoteAnswer(questionId: 'q', optionId: 'o')), {
        'questionId': 'q',
        'optionId': 'o',
      });
      expect(answerToJson(const RemoteAnswer(questionId: 'q', value: false)), {
        'questionId': 'q',
        'value': false,
      });
    });

    test('malformed payloads throw (reported as unexpected response)', () {
      expect(() => levelsFrom('nope'), throwsFormatException);
      expect(() => lessonFrom({'id': 1}), throwsFormatException);
      expect(() => progressFrom({'stages': []}), throwsFormatException);
    });
  });

  group('ApiFiveStageRepository (routes and auth flags)', () {
    late HandlerApiClient api;
    late ApiFiveStageRepository repo;

    setUp(() {
      api = HandlerApiClient((req) async {
        final path = req.path;
        if (path.endsWith('/lessons/${Json.lessonId}')) {
          return ApiResponse(200, Json.lessonDetail());
        }
        if (path == '/api/v1/catalog/courses') {
          return ApiResponse(200, Json.catalogCourses());
        }
        if (path.endsWith("/curriculum/levels")) {
          return ApiResponse(200, Json.levels());
        }
        if (path.endsWith('/slots')) return ApiResponse(200, Json.slots());
        if (path.endsWith('/curriculum-progress')) {
          return ApiResponse(200, Json.progress());
        }
        if (path.endsWith('/lessons/progress')) {
          final offset = req.query?['offset'];
          return ApiResponse(200, {
            'items': [
              {'lessonId': offset == '0' ? 'l1' : 'l2', 'isPassed': true},
              {'lessonId': 'x', 'isPassed': false},
            ],
            'nextOffset': offset == '0' ? 100 : null,
          });
        }
        if (path.endsWith('/attempts')) return ApiResponse(200, Json.attempt());
        if (path.endsWith('/submit')) {
          return ApiResponse(200, Json.assessmentResult());
        }
        return const ApiResponse(204);
      });
      repo = ApiFiveStageRepository(api);
    });

    test(
      'public catalog reads send no auth and use the documented paths',
      () async {
        await repo.findTrackCourse(locale: 'tr');
        await repo.getLevels(Json.courseId);
        await repo.getSlots(Json.courseId, 'level-A1');
        await repo.getLesson(Json.courseId, Json.lessonId);
        expect(api.requests.every((r) => !r.requiresAuth), isTrue);
        expect(api.requests[0].query, {
          'source': 'tr',
          'target': 'ar',
          'limit': '20',
          'locale': 'tr',
        });
        expect(
          api.requests[1].path,
          '/api/v1/courses/${Json.courseId}/curriculum/levels',
        );
        expect(
          api.requests[2].path,
          '/api/v1/courses/${Json.courseId}/curriculum/levels/level-A1/slots',
        );
        expect(
          api.requests[3].path,
          '/api/v1/courses/${Json.courseId}/lessons/${Json.lessonId}',
        );
      },
    );

    test('learner routes require auth and use the documented paths', () async {
      await repo.enroll(Json.courseId);
      await repo.startLesson(Json.courseId, Json.lessonId);
      await repo.getProgress(Json.courseId, Json.lessonId);
      expect(api.requests.every((r) => r.requiresAuth), isTrue);
      expect(api.requests[0].method, HttpMethod.put);
      expect(
        api.requests[0].path,
        '/api/v1/me/courses/${Json.courseId}/enrollment',
      );
      expect(
        api.requests[1].path,
        '/api/v1/me/courses/${Json.courseId}/lessons/${Json.lessonId}/start',
      );
      expect(
        api.requests[2].path,
        '/api/v1/me/courses/${Json.courseId}/lessons/${Json.lessonId}/curriculum-progress',
      );
    });

    test('passed lessons are collected across pages', () async {
      final ids = await repo.getPassedLessonIds(Json.courseId);
      expect(ids, {'l1', 'l2'});
      expect(api.requests, hasLength(2));
      expect(api.requests.first.query?['completedOnly'], 'true');
    });

    test(
      'attempt start sends only the idempotency key; submit sends answers',
      () async {
        await repo.startAttempt(
          courseId: 'c',
          lessonId: 'l',
          assessmentId: 'a',
          idempotencyKey: 'key-1',
        );
        await repo.submitAttempt(
          courseId: 'c',
          lessonId: 'l',
          assessmentId: 'a',
          attemptId: 't',
          answers: const [
            RemoteAnswer(questionId: 'q1', optionId: 'o1'),
            RemoteAnswer(questionId: 'q2', value: true),
          ],
        );
        expect(api.requests[0].body, {'idempotencyKey': 'key-1'});
        expect(
          api.requests[0].path,
          '/api/v1/me/courses/c/lessons/l/assessments/a/attempts',
        );
        expect(api.requests[1].path, endsWith('/attempts/t/submit'));
        expect(api.requests[1].body, {
          'answers': [
            {'questionId': 'q1', 'optionId': 'o1'},
            {'questionId': 'q2', 'value': true},
          ],
        });
        // The client never sends a student id, score or completion flag.
        expect((api.requests[1].body! as Map).keys, ['answers']);
      },
    );

    test('HTTP errors become typed failures', () async {
      for (final (status, matcher) in [
        (401, isA<UnauthorizedFailure>()),
        (403, isA<ForbiddenFailure>()),
        (404, isA<NotFoundFailure>()),
        (409, isA<ConflictFailure>()),
        (500, isA<ServerFailure>()),
      ]) {
        final failing = ApiFiveStageRepository(
          HandlerApiClient((_) async => ApiResponse(status)),
        );
        await expectLater(failing.getProgress('c', 'l'), throwsA(matcher));
      }
    });

    test('wrong response shape is an UnexpectedResponseFailure', () async {
      final bad = ApiFiveStageRepository(
        HandlerApiClient((_) async => const ApiResponse(200, 'oops')),
      );
      await expectLater(
        bad.getSlots('c', 'l'),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
    });
  });

  group('RemoteAuthRepository', () {
    test('login stores tokens in the token store only', () async {
      final tokens = InMemoryTokenStore();
      final api = HandlerApiClient(
        (_) async => const ApiResponse(200, {
          'tokenType': 'Bearer',
          'accessToken': 'acc',
          'expiresIn': 600,
          'refreshToken': 'ref',
        }),
      );
      await RemoteAuthRepository(
        api,
        tokens,
      ).signIn(email: 'a@b.co', password: 'Secret123!x');
      expect(tokens.read()?.accessToken, 'acc');
      expect(tokens.read()?.refreshToken, 'ref');
      expect(api.requests.single.path, '/api/v1/auth/login');
      expect(api.requests.single.requiresAuth, isFalse);
    });

    test('rejected sign-in is Unauthorized and stores nothing', () async {
      final tokens = InMemoryTokenStore();
      final repo = RemoteAuthRepository(
        HandlerApiClient((_) async => const ApiResponse(401)),
        tokens,
      );
      await expectLater(
        repo.signIn(email: 'a@b.co', password: 'bad'),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(tokens.read(), isNull);
    });

    test('registration sends only email+password; 202 succeeds, 503 is unavailable', () async {
      final ok = HandlerApiClient((_) async => const ApiResponse(202));
      await RemoteAuthRepository(
        ok,
        InMemoryTokenStore(),
      ).register(name: 'Ayşe', email: 'a@b.co', password: 'Secret123!x');
      expect(ok.requests.single.body, {
        'email': 'a@b.co',
        'password': 'Secret123!x',
      });

      final noMail = RemoteAuthRepository(
        HandlerApiClient((_) async => const ApiResponse(503)),
        InMemoryTokenStore(),
      );
      await expectLater(
        noMail.register(name: 'x', email: 'a@b.co', password: 'p'),
        throwsA(isA<ServiceUnavailableException>()),
      );
      await expectLater(
        noMail.requestPasswordReset(email: 'a@b.co'),
        throwsA(isA<ServiceUnavailableException>()),
      );
    });

    test(
      'sign-out always clears local tokens, even if the server fails',
      () async {
        final tokens = InMemoryTokenStore();
        await tokens.save(const TokenPair(accessToken: 'a', refreshToken: 'r'));
        final repo = RemoteAuthRepository(
          HandlerApiClient(
            (_) async => throw const NetworkUnavailableFailure(),
          ),
          tokens,
        );
        // A server/network failure must not keep the learner signed in or
        // surface as an error: local tokens are gone either way.
        await repo.signOut();
        expect(tokens.read(), isNull);
      },
    );
  });
}
