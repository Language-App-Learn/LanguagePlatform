// REAL END-TO-END JOURNEY against a locally running LanguagePlatform API and
// a disposable PostgreSQL database. It uses the app's own transport,
// repositories and token store over real HTTP (no mocked responses).
//
// It is SKIPPED unless `E2E_DIR` points at a prepared environment directory
// (accounts.json + answerkey.json + eval-speaking.ps1, produced by the
// teacher-side setup scripts). Nothing here talks to a production service.
//
//   $env:E2E_DIR = '<scratch dir>'; flutter test test/e2e/real_backend_journey_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/config/api_config.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/authenticated_api_client.dart';
import 'package:language_platform/core/network/http_api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/core/security/platform_secret_store.dart';
import 'package:language_platform/core/security/session_bootstrap.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/authentication/data/remote_auth_repository.dart';
import 'package:language_platform/features/courses/domain/course.dart';
import 'package:language_platform/features/learning_track/data/api_five_stage_repository.dart';
import 'package:language_platform/features/learning_track/domain/lesson_stage.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

final String? _dir = Platform.environment['E2E_DIR'];

late Uri _base;
late Map<String, dynamic> _accounts;
late Map<String, dynamic> _keyFile;
late List<Map<String, dynamic>> _key;
late String _courseId;

class _Session {
  _Session(this.tokens)
    : http = HttpApiClient(
        baseUri: _base,
        timeout: const Duration(seconds: 30),
      ) {
    api = AuthenticatedApiClient(inner: http, tokens: tokens);
    repo = ApiFiveStageRepository(api);
    auth = RemoteAuthRepository(api, tokens);
  }

  final TokenStore tokens;
  final HttpApiClient http;
  late final AuthenticatedApiClient api;
  late final ApiFiveStageRepository repo;
  late final RemoteAuthRepository auth;
}

Map<String, dynamic> _readJson(String name) =>
    jsonDecode(File('$_dir/$name').readAsStringSync()) as Map<String, dynamic>;

/// Latest captured email of [kind] for [email] (the scratch mail sink).
Future<Map<String, dynamic>> _outbox(String kind, String email) async {
  final file = File('$_dir/outbox.jsonl');
  for (var i = 0; i < 20; i++) {
    if (file.existsSync()) {
      final hits = file
          .readAsLinesSync()
          .where((l) => l.trim().isNotEmpty)
          .map((l) => jsonDecode(l) as Map<String, dynamic>)
          .where((e) => e['kind'] == kind && e['email'] == email)
          .toList();
      if (hits.isNotEmpty) return hits.last;
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
  throw StateError('no $kind mail for $email');
}

Future<void> _teacherEvaluates({
  required String lessonId,
  required String assessmentId,
  required String attemptId,
  required num score,
}) async {
  final r = await Process.run('powershell', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-File',
    '$_dir/eval-speaking.ps1',
    '-CourseId',
    _courseId,
    '-LessonId',
    lessonId,
    '-AssessmentId',
    assessmentId,
    '-AttemptId',
    attemptId,
    '-Score',
    '$score',
  ]);
  expect(r.exitCode, 0, reason: 'teacher evaluation failed: ${r.stderr}');
}

/// Answers [attempt] with the first [correct] questions right and the rest
/// deliberately wrong. The key is the teacher's authoring input; the SERVER
/// still does all grading.
List<RemoteAnswer> _answers(
  RemoteAttempt attempt,
  int lessonNo,
  String stage,
  int correct,
) {
  final out = <RemoteAnswer>[];
  for (final (i, q) in attempt.questions.indexed) {
    final k = _key.firstWhere(
      (e) =>
          e['lesson'] == lessonNo &&
          e['stage'] == stage &&
          e['prompt'] == q.prompt,
      orElse: () => throw StateError('no key for "${q.prompt}"'),
    );
    final right = i < correct;
    switch (q.type) {
      case RemoteQuestionKind.trueFalse:
        final v = k['value'] as bool;
        out.add(RemoteAnswer(questionId: q.id, value: right ? v : !v));
      case RemoteQuestionKind.multipleChoice || RemoteQuestionKind.wordBank:
        final correctText = k['optionText'] as String;
        final opt = q.options.firstWhere(
          (o) => right ? o.text == correctText : o.text != correctText,
        );
        out.add(RemoteAnswer(questionId: q.id, optionId: opt.id));
      case RemoteQuestionKind.fillBlank || RemoteQuestionKind.exactText:
        out.add(
          RemoteAnswer(
            questionId: q.id,
            text: right ? k['text'] as String : 'خَطَأٌ',
          ),
        );
      case RemoteQuestionKind.wordOrder:
        final texts = (k['orderTexts'] as List).cast<String>();
        final ordered = [
          for (final t in right ? texts : texts.reversed)
            q.options.firstWhere((o) => o.text == t).id,
        ];
        out.add(RemoteAnswer(questionId: q.id, orderedOptionIds: ordered));
      case RemoteQuestionKind.unknown:
        throw StateError('unknown kind ${q.kind}');
    }
  }
  return out;
}

void main() {
  if (_dir == null) {
    test(
      'real backend journey',
      () {},
      skip: 'Set E2E_DIR to a prepared end-to-end environment to run this.',
    );
    return;
  }

  setUpAll(() {
    _base = ApiConfig.parse('http://127.0.0.1:5199')!;
    _accounts = _readJson('accounts.json');
    _keyFile = _readJson('answerkey.json');
    _key = (_keyFile['key'] as List).cast<Map<String, dynamic>>();
    _courseId = _keyFile['courseId'] as String;
    FlutterSecureStorage.setMockInitialValues({});
  });

  const longTimeout = Timeout(Duration(minutes: 12));
  late _Session student;
  late MemoryKeyValueStore prefs;
  late RemoteLesson lesson1;
  late String lesson1Id;
  late String lesson2Id;
  final attemptIds = <String, String>{};

  String assessmentOf(LessonStage s) => lesson1.stageOf(s)!.assessmentId!;

  Future<RemoteAttempt> start(LessonStage s, String key) =>
      student.repo.startAttempt(
        courseId: _courseId,
        lessonId: lesson1Id,
        assessmentId: assessmentOf(s),
        idempotencyKey: key,
      );

  Future<RemoteAssessmentResult> submit(
    LessonStage s,
    RemoteAttempt a,
    int correct,
  ) => student.repo.submitAttempt(
    courseId: _courseId,
    lessonId: lesson1Id,
    assessmentId: assessmentOf(s),
    attemptId: a.id,
    answers: _answers(a, 1, s.name, correct),
  );

  Future<void> speak(String key, num score) async {
    final a = await start(LessonStage.speaking, key);
    expect(a.questions, isEmpty, reason: 'speaking has no objective questions');
    expect(await student.repo.getAttemptResult(a.id), isNull); // pending
    await _teacherEvaluates(
      lessonId: lesson1Id,
      assessmentId: assessmentOf(LessonStage.speaking),
      attemptId: a.id,
      score: score,
    );
    final r = await student.repo.getAttemptResult(a.id);
    expect(r, isNotNull, reason: 'evaluator score must appear');
    expect(r!.score, closeTo(score.toDouble(), 1e-6));
    attemptIds['speaking-$key'] = a.id;
  }

  group('A. connection, session and catalog', () {
    test('1. the app reaches the local API and it is ready', () async {
      final http = HttpApiClient(baseUri: _base);
      addTearDown(http.close);
      final live = await http.send(const ApiRequest(HttpMethod.get, '/health'));
      final ready = await http.send(
        const ApiRequest(HttpMethod.get, '/health/ready'),
      );
      expect(live.statusCode, 200);
      expect(ready.statusCode, 200);
    });

    test('2. login stores the pair in the secure store; /me works', () async {
      prefs = MemoryKeyValueStore();
      final tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      student = _Session(tokens);
      final acc = _accounts['student'] as Map<String, dynamic>;
      await student.auth.signIn(
        email: acc['email'] as String,
        password: acc['password'] as String,
      );
      expect(tokens.read(), isNotNull);
      final me = await student.auth.currentAccount();
      expect(me.email, acc['email']);
    }, timeout: longTimeout);

    test('3. Turkish->Arabic course appears with the server id', () async {
      final course = await student.repo.findTrackCourse();
      expect(course, isNotNull);
      expect(course!.id, _courseId);
      expect(course.title, contains('Modern Arap'));
    });

    test('4. six CEFR levels and twenty positions for A1', () async {
      final levels = await student.repo.getLevels(_courseId);
      expect(levels.map((l) => l.level), CourseLevel.values);
      expect(levels.every((l) => l.capacity == 20), isTrue);
      final a1 = levels.first;
      final slots = await student.repo.getSlots(_courseId, a1.id);
      expect(slots, hasLength(20));
      expect(slots.map((s) => s.position), List.generate(20, (i) => i + 1));
      final published = slots.where((s) => s.isPublished).toList();
      expect(published.map((s) => s.position), [1, 2]);
      lesson1Id = slots[0].lessonId!;
      lesson2Id = slots[1].lessonId!;
      expect(slots[2].lessonId, isNull); // empty slots stay empty
      // Other levels have no lessons yet.
      final a2 = await student.repo.getSlots(_courseId, levels[1].id);
      expect(a2.where((s) => s.isPublished), isEmpty);
    });

    test('5. published lesson 1 loads with its five ordered stages', () async {
      lesson1 = await student.repo.getLesson(_courseId, lesson1Id);
      expect(lesson1.stages.map((s) => s.kind), LessonStage.values);
      expect(lesson1.passingScore, 60);
      expect(lesson1.stages.map((s) => s.weight), [
        30,
        20,
        20,
        15,
        15,
      ], reason: 'weights are the teacher-approved ones, not invented');
      expect(lesson1.stages.every((s) => s.assessmentId != null), isTrue);
      expect(
        lesson1.stageOf(LessonStage.reading)!.texts['ar'],
        contains('مَرْحَبًا'),
      );
    });
  });

  group('B. authorization is enforced by the server', () {
    test('20a. no token -> 401, nothing about other learners', () async {
      final anon = _Session(InMemoryTokenStore());
      await expectLater(
        anon.repo.getProgress(_courseId, lesson1Id),
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('20b. a forged token is rejected and cleared', () async {
      final forged = InMemoryTokenStore();
      await forged.save(
        const TokenPair(
          accessToken: 'forged.token.value',
          refreshToken: 'forged',
        ),
      );
      var expired = 0;
      final s = _Session(forged);
      final client = AuthenticatedApiClient(
        inner: s.http,
        tokens: forged,
        onSessionExpired: () => expired++,
      );
      final repo = ApiFiveStageRepository(client);
      await expectLater(
        repo.getProgress(_courseId, lesson1Id),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(forged.read(), isNull);
      expect(expired, 1);
    });

    test('20c. a student cannot use teacher/admin routes (403)', () async {
      final r = await student.api.send(
        const ApiRequest(
          HttpMethod.post,
          '/api/v1/admin/five-stage/courses',
          requiresAuth: true,
          body: {'slug': 'nope', 'title': 'x', 'description': null},
        ),
      );
      expect(r.statusCode, 403);
    });

    test('learner routes need enrollment (404 before enrolling)', () async {
      await expectLater(
        student.repo.getProgress(_courseId, lesson1Id),
        throwsA(isA<NotFoundFailure>()),
      );
      expect(
        await student.repo.getReadingMaterial(_courseId, lesson1Id),
        isNull,
      );
    });
  });

  group('C. lesson 1, first (failing) pass: 50/100', () {
    test('6. enrol and start: only reading is available', () async {
      await student.repo.enroll(_courseId);
      await student.repo.startLesson(_courseId, lesson1Id);
      final p = await student.repo.getProgress(_courseId, lesson1Id);
      expect(p.stages.map((s) => s.kind), LessonStage.values);
      expect(
        p.stageOf(LessonStage.reading)!.status,
        RemoteStageStatus.available,
      );
      expect([
        for (final s in LessonStage.values.skip(1)) p.stageOf(s)!.status,
      ], everyElement(RemoteStageStatus.locked));
      expect(p.finalScore, isNull);
      expect(p.passed, isFalse);
      expect(p.passingScore, 60);
    });

    test('7/8. approved Arabic lines and the original PDF', () async {
      final m = await student.repo.getReadingMaterial(_courseId, lesson1Id);
      expect(m, isNotNull);
      expect(m!.lines.map((l) => l.text), [
        'مَرْحَبًا، أَنَا طَالِبٌ.',
        'هَذَا كِتَابٌ.',
        'هَذَا قَلَمٌ.',
      ]); // diacritics intact, teacher order
      expect(m.lines.map((l) => l.order), [1, 2, 3]);
      expect(m.lines.every((l) => l.id.isNotEmpty), isTrue);
      expect(m.hasOriginalPdf, isTrue);
      final Uint8List pdf = await student.repo.downloadReadingPdf(
        _courseId,
        lesson1Id,
      );
      expect(String.fromCharCodes(pdf.sublist(0, 5)), '%PDF-');
      expect(String.fromCharCodes(pdf.sublist(pdf.length - 6)).trim(), '%%EOF');
    });

    test('media metadata honours the server status', () async {
      final media = await student.repo.getStageMedia(
        _courseId,
        lesson1Id,
        lesson1.stageOf(LessonStage.reading)!.id,
      );
      expect(media, isNotNull);
      if (media!.status == 'available') {
        expect(media.videoUrl?.scheme, 'https');
      } else {
        // `unavailable` / `unconfigured`: no link may be exposed.
        expect(media.hasVideo || media.hasAudio, isFalse);
      }
    });

    test(
      '9. ten reading questions: idempotent start, server grades 5/10',
      () async {
        final a = await start(LessonStage.reading, 'e2e-reading-1');
        expect(a.questions, hasLength(10));
        // Same key (e.g. after a timeout) returns the SAME attempt.
        final again = await start(LessonStage.reading, 'e2e-reading-1');
        expect(again.id, a.id);
        expect(again.questions.map((q) => q.id), a.questions.map((q) => q.id));
        final r = await submit(LessonStage.reading, a, 5);
        expect(r.score, 5);
        expect(r.maximumScore, 10);
        final p = await student.repo.getProgress(_courseId, lesson1Id);
        expect(
          p.stageOf(LessonStage.reading)!.status,
          RemoteStageStatus.completed,
        );
        expect(p.stageOf(LessonStage.reading)!.score, closeTo(50, 1e-6));
        expect(
          p.stageOf(LessonStage.speaking)!.status,
          RemoteStageStatus.available,
        );
      },
    );

    test('a later stage cannot be started out of order (409)', () async {
      await expectLater(
        start(LessonStage.listening, 'e2e-listening-early'),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('10/11. speaking: pending, then the teacher score arrives', () async {
      await speak('e2e-speaking-1', 40);
      final p = await student.repo.getProgress(_courseId, lesson1Id);
      expect(p.stageOf(LessonStage.speaking)!.score, closeTo(40, 1e-6));
      expect(
        p.stageOf(LessonStage.listening)!.status,
        RemoteStageStatus.available,
      );
    }, timeout: longTimeout);

    test(
      '12-14. listening, writing and translation are graded by the server',
      () async {
        final l = await submit(
          LessonStage.listening,
          await start(LessonStage.listening, 'e2e-listening-1'),
          3,
        );
        expect([l.score, l.maximumScore], [3, 5]);
        final w = await submit(
          LessonStage.writing,
          await start(LessonStage.writing, 'e2e-writing-1'),
          2,
        );
        expect([w.score, w.maximumScore], [2, 5]);
        final t = await submit(
          LessonStage.translation,
          await start(LessonStage.translation, 'e2e-translation-1'),
          3,
        );
        expect([t.score, t.maximumScore], [3, 5]);
      },
    );

    test(
      '15/16. the official score is the server weighted sum: 50 FAILS',
      () async {
        final p = await student.repo.getProgress(_courseId, lesson1Id);
        expect(p.finalScore, isNotNull);
        expect(p.finalScore!, closeTo(50, 1e-6));
        expect(p.passed, isFalse);
        expect(p.nextLessonId, isNull);
        // 15 + 8 + 12 + 6 + 9 with the teacher weights 30/20/20/15/15.
        expect(p.stages.map((s) => s.score), [
          closeTo(50, 1e-6),
          closeTo(40, 1e-6),
          closeTo(60, 1e-6),
          closeTo(40, 1e-6),
          closeTo(60, 1e-6),
        ]);
        // The next lesson stays locked.
        await expectLater(
          student.repo.startLesson(_courseId, lesson2Id),
          throwsA(isA<ValidationFailure>()),
        );
        expect(await student.repo.getPassedLessonIds(_courseId), isEmpty);
      },
    );

    test(
      '18. results survive an app restart (secure store reloaded)',
      () async {
        final restartedTokens = await loadTokenStore(
          secrets: PlatformSecretStore(),
          preferences: prefs,
        );
        expect(restartedTokens.read(), isNotNull);
        final restarted = _Session(restartedTokens);
        final p = await restarted.repo.getProgress(_courseId, lesson1Id);
        expect(p.finalScore!, closeTo(50, 1e-6));
        expect(p.passed, isFalse);
        student = restarted; // continue as the restarted app
      },
    );

    test(
      'refresh: expired access token + 3 concurrent calls -> ONE refresh',
      () async {
        final before = student.tokens.read()!;
        await student.tokens.save(
          TokenPair(
            accessToken: 'expired.access.token',
            refreshToken: before.refreshToken,
          ),
        );
        final results = await Future.wait([
          for (var i = 0; i < 3; i++)
            student.repo.getProgress(_courseId, lesson1Id),
        ]);
        expect(results.every((p) => p.finalScore != null), isTrue);
        final after = student.tokens.read()!;
        expect(after.refreshToken, isNot(before.refreshToken)); // rotated
        expect(after.accessToken, isNot('expired.access.token'));
        // The consumed refresh ticket cannot be replayed.
        final replay = await student.http.send(
          ApiRequest(
            HttpMethod.post,
            AuthenticatedApiClient.refreshPath,
            body: {'refreshToken': before.refreshToken},
          ),
        );
        expect(replay.statusCode, anyOf(401, 409));
        // And the rotated pair was persisted atomically.
        final reloaded = await loadTokenStore(
          secrets: PlatformSecretStore(),
          preferences: prefs,
        );
        expect(reloaded.read()?.refreshToken, after.refreshToken);
      },
    );
  });

  group('D. retake to exactly 60/100 passes and unlocks lesson 2', () {
    test(
      '17. all stages at 60% -> final 60.0, passed, next lesson open',
      () async {
        // Deliberate retakes use NEW idempotency keys.
        await submit(
          LessonStage.reading,
          await start(LessonStage.reading, 'e2e-reading-2'),
          6,
        );
        await speak('e2e-speaking-2', 60);
        await submit(
          LessonStage.listening,
          await start(LessonStage.listening, 'e2e-listening-2'),
          3,
        );
        await submit(
          LessonStage.writing,
          await start(LessonStage.writing, 'e2e-writing-2'),
          3,
        );
        await submit(
          LessonStage.translation,
          await start(LessonStage.translation, 'e2e-translation-2'),
          3,
        );
        final p = await student.repo.getProgress(_courseId, lesson1Id);
        expect(p.finalScore!, closeTo(60, 1e-6));
        expect(p.passed, isTrue, reason: 'exactly 60 passes (server decision)');
        expect(p.nextLessonId, lesson2Id);
        expect(await student.repo.getPassedLessonIds(_courseId), {lesson1Id});

        // Lesson 2 is now open; its first stage is available.
        await student.repo.startLesson(_courseId, lesson2Id);
        final p2 = await student.repo.getProgress(_courseId, lesson2Id);
        expect(
          p2.stageOf(LessonStage.reading)!.status,
          RemoteStageStatus.available,
        );
        expect(p2.finalScore, isNull);
      },
      timeout: longTimeout,
    );

    test('the earlier failed result stays recorded as history', () async {
      final r = await student.repo.getAttemptResult(
        attemptIds['speaking-e2e-speaking-1']!,
      );
      expect(r!.score, closeTo(40, 1e-6));
    });
  });

  group('E. second account and cross-account isolation', () {
    late _Session other;

    test(
      '19. another student sees none of the first student\'s data',
      () async {
        final acc = _accounts['student2'] as Map<String, dynamic>;
        other = _Session(InMemoryTokenStore());
        await other.auth.signIn(
          email: acc['email'] as String,
          password: acc['password'] as String,
        );
        await expectLater(
          other.repo.getProgress(_courseId, lesson1Id),
          throwsA(isA<NotFoundFailure>()),
        );
        expect(
          await other.repo.getReadingMaterial(_courseId, lesson1Id),
          isNull,
        );
        expect(
          await other.repo.getAttemptResult(
            attemptIds['speaking-e2e-speaking-1']!,
          ),
          isNull,
          reason: 'another learner\'s attempt result is not readable',
        );
        await expectLater(
          other.repo.getPassedLessonIds(_courseId),
          throwsA(isA<NotFoundFailure>()),
        );
        // Public catalog data is the same for everyone.
        expect((await other.repo.findTrackCourse())!.id, _courseId);
      },
    );

    test('logout revokes the server session (token and refresh)', () async {
      final pair = other.tokens.read()!;
      await other.auth.signOut();
      expect(other.tokens.read(), isNull);
      final stale = await other.http.send(
        ApiRequest(
          HttpMethod.get,
          '/api/v1/me',
          headers: {'Authorization': 'Bearer ${pair.accessToken}'},
        ),
      );
      expect(stale.statusCode, 401, reason: 'revoked access token');
      final refresh = await other.http.send(
        ApiRequest(
          HttpMethod.post,
          AuthenticatedApiClient.refreshPath,
          body: {'refreshToken': pair.refreshToken},
        ),
      );
      expect(refresh.statusCode, anyOf(401, 409), reason: 'revoked refresh');
    });
  });

  group('F. account lifecycle: register, confirm, delete', () {
    test('register -> email -> confirm -> sign in -> deletion request', () async {
      final email =
          'e2e.lifecycle.${DateTime.now().millisecondsSinceEpoch}@lp-e2e2.invalid';
      const password = 'Lifecycle-Pass-9!x';
      final s = _Session(InMemoryTokenStore());

      // Unconfirmed accounts cannot sign in.
      await s.auth.register(name: '', email: email, password: password);
      await expectLater(
        s.auth.signIn(email: email, password: password),
        throwsA(isA<UnauthorizedFailure>()),
      );
      final mail = await _outbox('confirm', email);
      await s.auth.confirmEmail(
        userId: mail['userId'] as String,
        code: mail['code'] as String,
      );
      await s.auth.signIn(email: email, password: password);
      expect((await s.auth.currentAccount()).email, email);

      // Wrong password: the request is refused and nothing changes.
      await expectLater(
        s.auth.requestAccountDeletion(password: 'Wrong-Password-1!'),
        throwsA(anyOf(isA<ValidationFailure>(), isA<UnauthorizedFailure>())),
      );
      expect((await s.auth.currentAccount()).email, email);

      // Correct password: 202, local tokens cleared, sessions invalidated.
      final staleAccess = s.tokens.read()!.accessToken;
      await s.auth.requestAccountDeletion(password: password);
      expect(s.tokens.read(), isNull);
      final stale = await s.http.send(
        ApiRequest(
          HttpMethod.get,
          '/api/v1/me',
          headers: {'Authorization': 'Bearer $staleAccess'},
        ),
      );
      expect(stale.statusCode, 401);
      await expectLater(
        s.auth.signIn(email: email, password: password),
        throwsA(isA<UnauthorizedFailure>()),
        reason: 'a deactivated account cannot sign in again',
      );
    }, timeout: longTimeout);

    test('weak new password is rejected by the server policy', () async {
      final s = _Session(InMemoryTokenStore());
      await expectLater(
        s.auth.register(
          name: '',
          email:
              'weak.${DateTime.now().millisecondsSinceEpoch}@lp-e2e2.invalid',
          password: 'short',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
