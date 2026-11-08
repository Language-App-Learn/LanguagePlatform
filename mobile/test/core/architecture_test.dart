import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/errors/app_exceptions.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/assessment/application/quiz_providers.dart';
import 'package:language_platform/features/assessment/domain/quiz.dart';
import 'package:language_platform/features/assessment/domain/quiz_repository.dart';
import 'package:language_platform/features/courses/data/demo_course_repository.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';
import 'package:language_platform/features/lessons/data/demo_lesson_data.dart';
import 'package:language_platform/features/lessons/domain/lesson.dart';
import 'package:language_platform/features/lessons/domain/lesson_validator.dart';
import 'package:language_platform/features/lessons/presentation/widgets/lesson_content_view.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/progress/domain/learning_progress.dart';
import 'package:language_platform/features/vocabulary/data/demo_vocabulary_data.dart';
import 'package:language_platform/features/vocabulary/data/local_vocabulary_store.dart';
import 'package:language_platform/features/vocabulary/domain/vocabulary_record.dart';

import '../fakes/fakes.dart';
import '../helpers/persistent_app.dart';
import '../helpers/pump_app.dart';

void main() {
  group('GuardedKeyValueStore', () {
    test('read-your-writes before the write is flushed', () async {
      final inner = ControllableStore()..gated = true;
      final store = GuardedKeyValueStore(inner);
      final done = store.write('k', 'v1');
      expect(store.read('k'), 'v1'); // visible immediately
      expect(inner.read('k'), isNull); // not yet on "disk"
      await Future<void>.delayed(Duration.zero);
      inner.gates.single.complete();
      await done;
      expect(inner.read('k'), 'v1');
    });

    test('rapid writes to one key are ordered and coalesced', () async {
      final inner = ControllableStore();
      final store = GuardedKeyValueStore(inner);
      final futures = [
        store.write('k', 'a'),
        store.write('k', 'b'),
        store.write('k', 'c'),
      ];
      await Future.wait(futures);
      await store.flush();
      expect(inner.read('k'), 'c'); // newest wins, nothing lost
      expect(inner.writes.last, 'c');
      expect(inner.writes.length, lessThanOrEqualTo(3));
    });

    test(
      'failed writes do not throw, are counted and never look saved',
      () async {
        final inner = ControllableStore(failWrites: true);
        final store = GuardedKeyValueStore(inner);
        await store.write('k', 'v'); // must not throw
        expect(store.failedWrites.value, 1);
        expect(inner.read('k'), isNull); // really not persisted
        expect(store.read('k'), 'v'); // still usable in this session

        inner.failWrites = false;
        await store.write('k', 'v2'); // next write retries
        expect(inner.read('k'), 'v2');
        expect(store.failedWrites.value, 1);
      },
    );

    test('clearAll waits for pending writes, then clears', () async {
      final inner = ControllableStore();
      final store = GuardedKeyValueStore(inner);
      unawaited(store.write('lp.a', '1'));
      await store.clearAll();
      expect(store.read('lp.a'), isNull);
      expect(inner.read('lp.a'), isNull);
    });

    test('failure count is exposed through a provider', () async {
      final store = GuardedKeyValueStore(ControllableStore(failWrites: true));
      final c = ProviderContainer.test(
        overrides: [keyValueStoreProvider.overrideWithValue(store)],
      );
      expect(c.read(persistenceFailuresProvider), 0);
      await store.write('k', 'v');
      expect(c.read(persistenceFailuresProvider), 1);
    });
  });

  group('failure model', () {
    test('exceptions map to typed failures', () {
      expect(failureOf(const NotFoundException('x')), isA<NotFoundFailure>());
      expect(
        failureOf(const ServiceUnavailableException('x')),
        isA<ServiceUnavailableFailure>(),
      );
      expect(failureOf(TimeoutException('t')), isA<TimeoutFailure>());
      expect(
        failureOf(const SocketException('down')),
        isA<NetworkUnavailableFailure>(),
      );
      expect(
        failureOf(const FormatException('bad')),
        isA<UnexpectedResponseFailure>(),
      );
      expect(failureOf(StateError('boom')), isA<UnknownFailure>());
      expect(failureOf(const ForbiddenFailure()), isA<ForbiddenFailure>());
    });

    test('only transient failures offer retry', () {
      expect(const NetworkUnavailableFailure().isRecoverable, isTrue);
      expect(const ServerFailure().isRecoverable, isTrue);
      expect(const NotFoundFailure().isRecoverable, isFalse);
      expect(const UnauthorizedFailure().isRecoverable, isFalse);
      expect(const ServiceUnavailableFailure().isRecoverable, isFalse);
    });

    test('HTTP status codes map to failures', () {
      expect(failureForStatus(401), isA<UnauthorizedFailure>());
      expect(failureForStatus(403), isA<ForbiddenFailure>());
      expect(failureForStatus(404), isA<NotFoundFailure>());
      expect(failureForStatus(422), isA<ValidationFailure>());
      expect(failureForStatus(504), isA<TimeoutFailure>());
      expect(failureForStatus(503), isA<ServerFailure>());
      expect(failureForStatus(302), isA<UnexpectedResponseFailure>());
    });
  });

  group('ApiClient boundary (fake transport)', () {
    test('2xx body is parsed; bad shape becomes UnexpectedResponse', () async {
      final api = FakeApiClient([
        const ApiResponse(200, {'name': 'x'}),
        const ApiResponse(200, 'not a map'),
        const ApiResponse(500),
        TimeoutException('slow'),
      ]);
      const req = ApiRequest(HttpMethod.get, '/placeholder');
      final ok = (await api.send(req))
          .unwrap((j) => (j! as Map<String, Object?>)['name']! as String);
      expect(ok, 'x');

      final bad = await api.send(req);
      expect(
        () => bad.unwrap((j) => (j! as Map<String, Object?>)['name']),
        throwsA(isA<UnexpectedResponseFailure>()),
      );

      final server = await api.send(req);
      expect(() => server.unwrap((j) => j), throwsA(isA<ServerFailure>()));

      await expectLater(api.send(req), throwsA(isA<TimeoutException>()));
      expect(api.requests, hasLength(4));
    });
  });

  group('assessment engine', () {
    test('true/false evaluation and conversion to choices', () {
      const q = TrueFalseQuestion(
        id: 'tf1',
        prompt: LocalizedText.plain('2 + 2 = 4'),
        correctAnswer: true,
      );
      expect(q.isCorrect(const TrueFalseAnswer('tf1', true)), isTrue);
      expect(q.isCorrect(const TrueFalseAnswer('tf1', false)), isFalse);
      expect(q.isCorrect(const TrueFalseAnswer('other', true)), isFalse);
      expect(q.isCorrect(const MultipleChoiceAnswer('tf1', 'true')), isFalse);
      final choices = q.asChoices(
        trueLabel: const LocalizedText.plain('T'),
        falseLabel: const LocalizedText.plain('F'),
      );
      expect(choices.correctOptionId, 'true');
      expect(choices.isValid, isTrue);
    });

    test('malformed questions are reported invalid', () {
      MultipleChoiceQuestion mc({
        String id = 'q',
        List<String> options = const ['a', 'b'],
        String correct = 'a',
      }) => MultipleChoiceQuestion(
        id: id,
        prompt: const LocalizedText.plain('?'),
        options: [
          for (final o in options)
            QuizOption(id: o, text: LocalizedText.plain(o)),
        ],
        correctOptionId: correct,
      );
      expect(mc().isValid, isTrue);
      expect(mc(id: '').isValid, isFalse);
      expect(mc(options: ['a']).isValid, isFalse);
      expect(mc(options: ['a', 'a']).isValid, isFalse);
      expect(mc(correct: 'zzz').isValid, isFalse);
    });

    test('QuizController drops malformed questions and still works', () async {
      final c = ProviderContainer.test(
        overrides: [
          quizRepositoryProvider.overrideWithValue(_FixedQuiz()),
          fixedClock,
        ],
      );
      final sub = c.listen(quizControllerProvider('x'), (_, _) {});
      addTearDown(sub.close);
      final state = await c.read(quizControllerProvider('x').future);
      expect(state.questions.map((q) => q.id), ['good']);
    });

    test(
      'passed quiz completes the lesson without double-counting activity',
      () async {
        final c = ProviderContainer.test(overrides: [fixedClock]);
        c.read(progressProvider.notifier)
          ..recordQuizScore('l1', 100)
          ..completeLesson('l1', logActivity: false);
        final types = c.read(progressProvider).activity.map((e) => e.type);
        expect(types, [ActivityType.quizCompleted]);
        expect(c.read(progressProvider).isCompleted('l1'), isTrue);

        c.read(progressProvider.notifier).completeLesson('l2');
        expect(
          c
              .read(progressProvider)
              .activity
              .where((e) => e.type == ActivityType.lessonCompleted),
          hasLength(1),
        );
      },
    );
  });

  group('lesson engine', () {
    test('all demo lessons are structurally valid', () {
      for (final lesson in demoLessons) {
        expect(LessonValidator.validate(lesson), isEmpty, reason: lesson.id);
      }
    });

    test('validator reports malformed and unknown blocks', () {
      const bad = Lesson(
        id: 'x',
        courseId: 'c',
        languageCode: 'en',
        title: LocalizedText.plain('t'),
        order: 0,
        estimatedMinutes: 0,
        contents: [
          VocabularyContent([]),
          DialogueContent([]),
          UnknownContent('video'),
        ],
      );
      final issues = LessonValidator.validate(bad);
      expect(issues, hasLength(greaterThanOrEqualTo(5)));
      expect(
        issues.any((i) => i.contains('unknown block type "video"')),
        isTrue,
      );
    });

    testWidgets('unknown block renders a neutral notice instead of crashing', (
      tester,
    ) async {
      const lesson = Lesson(
        id: 'x',
        courseId: 'c',
        languageCode: 'en',
        title: LocalizedText.plain('t'),
        order: 1,
        estimatedMinutes: 1,
        contents: [UnknownContent('video')],
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLanguage.supportedLocales,
            home: Scaffold(
              body: LessonContentView(
                lesson: lesson,
                content: lesson.contents.single,
                contentLanguage: 'en',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('unsupported-content')), findsOneWidget);
      expect(
        find.text('This content is not supported in this version of the app.'),
        findsOneWidget,
      );
    });
  });

  group('multilingual content', () {
    test('learning languages are independent of interface languages', () {
      expect(
        LearningLanguage.supported.map((l) => l.code),
        containsAll(AppLanguage.values.map((l) => l.code)),
      );
      expect(LearningLanguage.fromCode('ar')!.textDirection, TextDirection.rtl);
      expect(LearningLanguage.fromCode('de'), isNull); // not offered yet
    });

    test(
      'every course has title and description in all interface languages',
      () {
        for (final course in demoCourses) {
          for (final language in AppLanguage.values) {
            expect(
              course.title.hasTranslation(language.code),
              isTrue,
              reason: '${course.id} title ${language.code}',
            );
            expect(
              course.description.hasTranslation(language.code),
              isTrue,
              reason: '${course.id} description ${language.code}',
            );
          }
        }
      },
    );

    test('Arabic diacritics survive content, JSON and storage round trips', () {
      final marhaba = demoVocabulary.firstWhere((v) => v.id == 'ar-marhaba');
      expect(marhaba.term, contains('ً')); // fathatan is present
      expect(jsonDecode(jsonEncode(marhaba.term)), marhaba.term);

      final store = MemoryKeyValueStore();
      final local = LocalVocabularyStore(store);
      local.save({marhaba.id: const VocabularyRecord(favorite: true)});
      expect(local.load()[marhaba.id]!.favorite, isTrue);
      expect(
        const LocalizedText({'ar': 'مَرْحَبًا'}).resolve('ar'),
        'مَرْحَبًا', // not normalised or stripped
      );
    });

    test('fallback order: requested → English → first available', () {
      const t = LocalizedText({'tr': 'Selam'});
      expect(t.hasTranslation('tr'), isTrue);
      expect(t.hasTranslation('ar'), isFalse);
      expect(t.resolve('ar'), 'Selam');
    });
  });

  group('navigation resilience', () {
    testWidgets('unknown route shows a localized not-found page', (
      tester,
    ) async {
      final c = await launchApp(
        tester,
        MemoryKeyValueStore(),
        initialLocation: '/no/such/page',
      );
      expect(find.text('Page not found'), findsOneWidget);
      await tester.tap(find.text('Go to home'));
      await tester.pumpAndSettle();
      expect(currentPath(c), isNot('/no/such/page'));
    });

    testWidgets('missing lesson / course ids degrade to a not-found state', (
      tester,
    ) async {
      await launchApp(
        tester,
        MemoryKeyValueStore(),
        initialLocation: '/lesson/does-not-exist',
      );
      expect(
        find.text("We couldn't find what you were looking for."),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsNothing); // not recoverable
    });
  });

  group('persistence failure is visible to the user', () {
    testWidgets('settings shows a warning when local writes fail', (
      tester,
    ) async {
      useScreen(tester, height: 3000);
      final store = GuardedKeyValueStore(ControllableStore(failWrites: true));
      await launchApp(tester, store, initialLocation: AppRoutes.settings);
      expect(find.textContaining('could not be saved'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('theme-mode:dark')));
      await tester.pumpAndSettle();
      expect(find.textContaining('could not be saved'), findsOneWidget);
      // The setting still applies for the current session.
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
    });
  });
}

class _FixedQuiz implements QuizRepository {
  @override
  Future<List<QuizQuestion>> getQuestions(String lessonId) async => [
    const MultipleChoiceQuestion(
      id: 'bad',
      prompt: LocalizedText.plain('?'),
      options: [QuizOption(id: 'a', text: LocalizedText.plain('a'))],
      correctOptionId: 'a',
    ),
    const MultipleChoiceQuestion(
      id: 'good',
      prompt: LocalizedText.plain('?'),
      options: [
        QuizOption(id: 'a', text: LocalizedText.plain('a')),
        QuizOption(id: 'b', text: LocalizedText.plain('b')),
      ],
      correctOptionId: 'a',
    ),
  ];
}
