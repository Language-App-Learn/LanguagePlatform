import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/localized_text.dart';
import 'package:language_platform/features/assessment/application/quiz_providers.dart';
import 'package:language_platform/features/assessment/data/demo_quiz_repository.dart';
import 'package:language_platform/features/assessment/domain/quiz.dart';
import 'package:language_platform/features/authentication/domain/auth_validators.dart';
import 'package:language_platform/features/catalog/application/catalog_filter.dart';
import 'package:language_platform/features/courses/data/demo_course_repository.dart';
import 'package:language_platform/features/courses/domain/course.dart';
import 'package:language_platform/features/lessons/data/demo_lesson_data.dart';
import 'package:language_platform/features/lessons/data/demo_lesson_repository.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/progress/domain/learning_progress.dart';
import 'package:language_platform/features/vocabulary/data/demo_vocabulary_data.dart';
import 'package:language_platform/features/vocabulary/data/demo_vocabulary_repository.dart';

import '../helpers/pump_app.dart';

void main() {
  group('LearningProgress', () {
    final today = DateTime(2026, 11, 6, 9);

    test('bugün tamamlananları ve günlük hedef oranını hesaplar', () {
      final p = LearningProgress(
        completedLessons: {
          'a': DateTime(2026, 11, 6, 8),
          'b': DateTime(2026, 11, 5, 23),
        },
        dailyGoalLessons: 2,
      );
      expect(p.completedOn(today), 1);
      expect(p.dailyGoalFraction(today), 0.5);
      expect(p.completedCount, 2);
    });

    test('hedef aşılırsa oran 1 ile sınırlanır', () {
      final p = LearningProgress(
        completedLessons: {'a': today, 'b': today, 'c': today},
      );
      expect(p.dailyGoalFraction(today), 1.0);
    });

    test('kurs oranı ve quiz ortalaması', () {
      final p = LearningProgress(
        completedLessons: {'a': today},
        quizScores: const {'a': 100, 'b': 50},
      );
      expect(p.fractionIn(['a', 'b']), 0.5);
      expect(p.fractionIn([]), 0);
      expect(p.averageQuizScore, 75);
      expect(const LearningProgress().averageQuizScore, isNull);
    });
  });

  group('Quiz modeli', () {
    const question = MultipleChoiceQuestion(
      id: 'q',
      prompt: LocalizedText.plain('?'),
      options: [],
      correctOptionId: 'a',
    );

    test('doğru, yanlış ve başka soruya ait cevap', () {
      expect(question.isCorrect(const MultipleChoiceAnswer('q', 'a')), isTrue);
      expect(question.isCorrect(const MultipleChoiceAnswer('q', 'b')), isFalse);
      expect(question.isCorrect(const MultipleChoiceAnswer('x', 'a')), isFalse);
    });

    test('yüzde yuvarlama ve başarı eşiği (%70)', () {
      QuizResult r(int c, int t) =>
          QuizResult(lessonId: 'l', totalQuestions: t, correctAnswers: c);
      expect(r(7, 10).percentage, 70);
      expect(r(7, 10).passed, isTrue);
      expect(r(2, 3).percentage, 67);
      expect(r(2, 3).passed, isFalse);
      expect(r(0, 0).percentage, 0);
    });
  });

  group('ProgressNotifier', () {
    ProviderContainer container() =>
        ProviderContainer.test(overrides: [fixedClock]);

    test('ders tamamlama tekrar çağrılınca değişmez', () {
      final c = container();
      final n = c.read(progressProvider.notifier);
      n.completeLesson('l1');
      final first = c.read(progressProvider).completedLessons['l1'];
      n.completeLesson('l1');
      expect(c.read(progressProvider).completedCount, 1);
      expect(c.read(progressProvider).completedLessons['l1'], first);
      expect(first, DateTime(2026, 11, 6, 12));
    });

    test('quiz için en iyi sonuç saklanır', () {
      final c = container();
      final n = c.read(progressProvider.notifier);
      n.recordQuizScore('l1', 60);
      n.recordQuizScore('l1', 40);
      n.recordQuizScore('l1', 80);
      expect(c.read(progressProvider).quizScores['l1'], 80);
    });

    test('günlük hedef 1\'in altına inemez', () {
      final c = container();
      final n = c.read(progressProvider.notifier);
      n.setDailyGoal(0);
      expect(c.read(progressProvider).dailyGoalLessons, 1);
      n.setDailyGoal(3);
      expect(c.read(progressProvider).dailyGoalLessons, 3);
    });
  });

  group('CatalogFilter', () {
    final ar = demoCourses.firstWhere((c) => c.id == 'ar-a1-basics');
    final travel = demoCourses.firstWhere((c) => c.id == 'en-a2-travel');

    test('boş filtre hepsini kabul eder', () {
      expect(const CatalogFilter().accepts(ar), isTrue);
      expect(const CatalogFilter().isActive, isFalse);
    });

    test('dil ve seviye', () {
      expect(const CatalogFilter(languageCode: 'ar').accepts(travel), isFalse);
      expect(const CatalogFilter(level: CourseLevel.a2).accepts(ar), isFalse);
      expect(
        const CatalogFilter(level: CourseLevel.a2).accepts(travel),
        isTrue,
      );
    });

    test('arama başlıkta (her dilde), açıklamada ve seviye kodunda', () {
      expect(const CatalogFilter(query: 'seyahat').accepts(travel), isTrue);
      expect(const CatalogFilter(query: 'السفر').accepts(travel), isTrue);
      expect(const CatalogFilter(query: 'a2').accepts(travel), isTrue);
      expect(const CatalogFilter(query: 'zzz').accepts(travel), isFalse);
    });
  });

  group('AuthValidators', () {
    test('e-posta', () {
      expect(AuthValidators.email(''), AuthFieldError.required);
      expect(AuthValidators.email('abc'), AuthFieldError.invalidEmail);
      expect(AuthValidators.email('a@b'), AuthFieldError.invalidEmail);
      expect(AuthValidators.email(' user@mail.com '), isNull);
    });

    test('şifre ve tekrar', () {
      expect(AuthValidators.password(null), AuthFieldError.required);
      expect(
        AuthValidators.password('1234567'),
        AuthFieldError.passwordTooShort,
      );
      expect(AuthValidators.password('12345678'), isNull);
      expect(AuthValidators.confirmPassword('', 'x'), AuthFieldError.required);
      expect(AuthValidators.confirmPassword('a', 'b'), AuthFieldError.mismatch);
      expect(AuthValidators.confirmPassword('a', 'a'), isNull);
    });
  });

  group('Demo içerik bütünlüğü', () {
    const lessons = DemoLessonRepository();
    final vocab = {for (final v in demoVocabulary) v.id: v};

    test('kurs ders kimlikleri gerçek derslere işaret eder', () {
      for (final course in demoCourses) {
        for (final id in course.lessonIds) {
          final lesson = demoLessons.firstWhere(
            (l) => l.id == id,
            orElse: () => throw StateError('eksik ders: $id'),
          );
          expect(lesson.courseId, course.id);
          expect(lesson.languageCode, course.languageCode);
        }
      }
    });

    test('ders kelimeleri mevcut ve dersle aynı dilde', () {
      for (final lesson in demoLessons) {
        for (final id in lesson.vocabularyIds) {
          expect(vocab[id], isNotNull, reason: id);
          expect(vocab[id]!.languageCode, lesson.languageCode, reason: id);
        }
      }
    });

    test('her dersin quiz\'i geçerli sorular üretir', () async {
      const repo = DemoQuizRepository(
        lessons: lessons,
        vocabulary: DemoVocabularyRepository(),
      );
      for (final lesson in demoLessons) {
        final questions = await repo.getQuestions(lesson.id);
        expect(questions, isNotEmpty, reason: lesson.id);
        for (final q in questions.whereType<MultipleChoiceQuestion>()) {
          final ids = q.options.map((o) => o.id).toList();
          expect(ids.toSet(), hasLength(ids.length), reason: q.id);
          expect(ids, contains(q.correctOptionId), reason: q.id);
          expect(ids.length, greaterThanOrEqualTo(2), reason: q.id);
        }
      }
    });

    test('kelime sorusunda 3 şık var ve doğru şık konumu döner', () async {
      const repo = DemoQuizRepository(
        lessons: lessons,
        vocabulary: DemoVocabularyRepository(),
      );
      final qs = (await repo.getQuestions('ar-a1-l1'))
          .whereType<MultipleChoiceQuestion>()
          .where((q) => q.id.startsWith('meaning-'))
          .toList();
      expect(qs, hasLength(4));
      expect(qs.every((q) => q.options.length == 3), isTrue);
      final positions = qs
          .map((q) => q.options.indexWhere((o) => o.id == q.correctOptionId))
          .toSet();
      expect(positions.length, greaterThan(1));
    });

    test('olmayan ders için NotFound', () async {
      expect(() => lessons.getLesson('yok'), throwsA(isA<Exception>()));
    });
  });

  group('learningPathProvider', () {
    test(
      'öğrenilen dildeki dersleri sırayla verir; başlanmış kurs öne geçer',
      () async {
        final c = ProviderContainer.test(
          overrides: [trToArPreferences, fixedClock],
        );
        var path = await c.read(learningPathProvider.future);
        expect(path.map((s) => s.lesson.id), [
          'ar-a1-l1',
          'ar-a1-l2',
          'ar-a1-l3',
        ]);
        expect(path.first.courseStarted, isFalse);

        c.read(progressProvider.notifier).completeLesson('ar-a1-l1');
        path = await c.read(learningPathProvider.future);
        expect(path.first.lesson.id, 'ar-a1-l2');
        expect(path.first.courseStarted, isTrue);
      },
    );

    test(
      'dil seçilmediyse tüm dillerden; dersi olmayan kurs atlanır',
      () async {
        final c = ProviderContainer.test(overrides: [fixedClock]);
        final path = await c.read(learningPathProvider.future);
        expect(
          path.map((s) => s.course.id).toSet(),
          isNot(contains('en-b1-work')),
        );
        expect(path.length, 3 + 3 + 2 + 1);
      },
    );
  });

  group('QuizController', () {
    test(
      'tam akış: seç, kontrol et, ilerle, sonuç ve ilerlemeye yazma',
      () async {
        final c = ProviderContainer.test(overrides: [fixedClock]);
        final sub = c.listen(quizControllerProvider('tr-a1-l1'), (_, _) {});
        addTearDown(sub.close);
        var state = await c.read(quizControllerProvider('tr-a1-l1').future);
        final ctl = c.read(quizControllerProvider('tr-a1-l1').notifier);
        final total = state.questions.length;

        for (var i = 0; i < total; i++) {
          state = c.read(quizControllerProvider('tr-a1-l1')).requireValue;
          final q = state.current as MultipleChoiceQuestion;
          ctl.check(); // seçim yokken etkisiz
          expect(
            c.read(quizControllerProvider('tr-a1-l1')).requireValue.checked,
            isFalse,
          );
          ctl.select(MultipleChoiceAnswer(q.id, q.correctOptionId));
          ctl.check();
          ctl.next();
        }
        final done = c.read(quizControllerProvider('tr-a1-l1')).requireValue;
        expect(done.isFinished, isTrue);
        expect(done.result!.percentage, 100);
        expect(c.read(progressProvider).quizScores['tr-a1-l1'], 100);
        expect(c.read(progressProvider).isCompleted('tr-a1-l1'), isTrue);

        ctl.restart();
        final again = c.read(quizControllerProvider('tr-a1-l1')).requireValue;
        expect(again.index, 0);
        expect(again.result, isNull);
      },
    );
  });
}
