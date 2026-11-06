import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_router.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/utils/bidi.dart';
import 'package:language_platform/features/assessment/application/quiz_providers.dart';
import 'package:language_platform/features/assessment/domain/quiz.dart';
import 'package:language_platform/features/courses/application/course_providers.dart';
import 'package:language_platform/features/courses/data/demo_course_repository.dart';
import 'package:language_platform/features/courses/domain/course.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/progress/domain/learning_progress.dart';
import 'package:language_platform/features/vocabulary/application/vocabulary_providers.dart';
import 'package:language_platform/features/vocabulary/domain/vocabulary_item.dart';
import 'package:language_platform/features/vocabulary/domain/vocabulary_record.dart';

import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

void main() {
  group('ana sayfa', () {
    testWidgets('bölümler öğrenilen dile göre gelir', (tester) async {
      useScreen(tester);
      await pumpApp(
        tester,
        initialLocation: AppRoutes.home,
        overrides: [trToArPreferences, fixedClock],
      );
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Learning: العربية'), findsOneWidget);
      expect(find.text('0 of 1 lessons today'), findsWidgets);
      expect(find.text('Start your first lesson'), findsOneWidget);
      expect(_key('continue-card'), findsOneWidget);
      expect(_key('next-lesson-card'), findsOneWidget);
      expect(find.text('Featured courses'), findsOneWidget);
      expect(_key('course-card:ar-a1-basics'), findsOneWidget);
      expect(_key('course-card:en-a1-everyday'), findsNothing);
      expect(_key('practice-vocabulary'), findsOneWidget);
      expect(_key('practice-quiz'), findsOneWidget);
      expect(
        find.text('Demo data. Nothing is saved to a server.'),
        findsOneWidget,
      );
    });

    testWidgets('günlük hedef tamamlanınca kutlama durumu', (tester) async {
      useScreen(tester);
      await pumpApp(
        tester,
        initialLocation: AppRoutes.home,
        overrides: [
          trToArPreferences,
          fixedClock,
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                completedLessons: {'ar-a1-l1': DateTime(2026, 11, 6, 8)},
              ),
            ),
          ),
        ],
      );
      expect(find.text("You reached today's goal!"), findsOneWidget);
      expect(find.text('1 of 1 lessons today'), findsWidgets);
      // Devam et kartı sıradaki dersi gösterir.
      expect(find.text('Continue learning'), findsOneWidget);
    });

    testWidgets('dil seçilmediyse ipucu ve tüm kurslar', (tester) async {
      useScreen(tester);
      await pumpApp(tester, initialLocation: AppRoutes.home);
      expect(
        find.text('Choose the language you want to learn in Settings.'),
        findsOneWidget,
      );
      expect(_key('course-card:en-a1-everyday'), findsOneWidget);
    });

    testWidgets('Başla dersi açar; sekmeler arası gezinme çalışır', (
      tester,
    ) async {
      useScreen(tester);
      final c = await pumpApp(
        tester,
        initialLocation: AppRoutes.home,
        overrides: [trToArPreferences, fixedClock],
      );
      await tester.tap(find.text('Start lesson'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/lesson/ar-a1-l1');
      c.read(routerProvider).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Courses').last);
      await tester.pumpAndSettle();
      expect(find.text('Search courses'), findsOneWidget);
      expect(currentPath(c), AppRoutes.courses);
    });
  });

  group('katalog', () {
    Future<ProviderContainer> open(WidgetTester tester) {
      useScreen(tester);
      return pumpApp(tester, initialLocation: AppRoutes.courses);
    }

    testWidgets('tüm kurslar listelenir', (tester) async {
      await open(tester);
      for (final course in demoCourses) {
        expect(_key('course-card:${course.id}'), findsOneWidget);
      }
    });

    testWidgets('seviye filtresi', (tester) async {
      await open(tester);
      await tester.tap(_key('catalog-level:a2'));
      await tester.pumpAndSettle();
      expect(_key('course-card:en-a2-travel'), findsOneWidget);
      expect(_key('course-card:ar-a1-basics'), findsNothing);
    });

    testWidgets('dil filtresi', (tester) async {
      await open(tester);
      await tester.tap(_key('catalog-language:ar'));
      await tester.pumpAndSettle();
      expect(_key('course-card:ar-a1-basics'), findsOneWidget);
      expect(_key('course-card:en-a1-everyday'), findsNothing);
    });

    testWidgets('arama ve boş sonuç + filtreleri temizle', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), 'travel');
      await tester.pumpAndSettle();
      expect(_key('course-card:en-a2-travel'), findsOneWidget);
      expect(_key('course-card:tr-a1-start'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No courses found'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();
      expect(_key('course-card:tr-a1-start'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('hata durumu ve tekrar dene', (tester) async {
      useScreen(tester);
      var attempts = 0;
      await pumpApp(
        tester,
        initialLocation: AppRoutes.courses,
        overrides: [
          coursesProvider.overrideWith((ref) async {
            attempts++;
            if (attempts == 1) throw Exception('boom');
            return demoCourses;
          }),
        ],
      );
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(_key('course-card:ar-a1-basics'), findsOneWidget);
    });

    testWidgets('yükleniyor durumu', (tester) async {
      useScreen(tester);
      final completer = Completer<List<Course>>();
      await pumpApp(
        tester,
        initialLocation: AppRoutes.courses,
        settle: false,
        overrides: [coursesProvider.overrideWith((ref) => completer.future)],
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      completer.complete(demoCourses);
      await tester.pumpAndSettle();
      expect(_key('course-card:ar-a1-basics'), findsOneWidget);
    });
  });

  group('kurs detayı', () {
    testWidgets('karttan açılır; ders listesi ve başlat', (tester) async {
      useScreen(tester);
      final c = await pumpApp(tester, initialLocation: AppRoutes.courses);
      await tester.tap(_key('course-card:ar-a1-basics'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/course/ar-a1-basics');
      expect(find.text('Arabic A1: First Steps'), findsWidgets);
      expect(find.text('0/3 lessons'), findsOneWidget);
      for (final id in ['ar-a1-l1', 'ar-a1-l2', 'ar-a1-l3']) {
        expect(_key('lesson-tile:$id'), findsOneWidget);
      }
      await tester.tap(find.text('Start course'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/lesson/ar-a1-l1');
    });

    testWidgets('ilerleme varsa Devam et ve sıradaki ders', (tester) async {
      useScreen(tester);
      final c = await pumpApp(
        tester,
        initialLocation: '/course/ar-a1-basics',
        overrides: [
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                completedLessons: {'ar-a1-l1': DateTime(2026, 11, 6)},
              ),
            ),
          ),
        ],
      );
      expect(find.text('1/3 lessons'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/lesson/ar-a1-l2');
    });

    testWidgets('dersi olmayan kurs boş durum gösterir', (tester) async {
      useScreen(tester);
      await pumpApp(tester, initialLocation: '/course/en-b1-work');
      expect(find.text('Lessons are coming soon'), findsOneWidget);
      expect(find.text('Start course'), findsNothing);
    });

    testWidgets('olmayan kurs: bulunamadı', (tester) async {
      await pumpApp(tester, initialLocation: '/course/yok');
      expect(
        find.text("We couldn't find what you were looking for."),
        findsOneWidget,
      );
    });
  });

  group('ders ekranı', () {
    Future<ProviderContainer> open(WidgetTester tester, String id) {
      useScreen(tester);
      return pumpApp(
        tester,
        initialLocation: '/lesson/$id',
        overrides: [trToArPreferences, fixedClock],
      );
    }

    testWidgets('tüm içerik türleri çizilir', (tester) async {
      await open(tester, 'ar-a1-l1');
      expect(find.text('Selam ver ve karşılık ver'), findsOneWidget); // başlık
      expect(
        find.textContaining('Bu derste Arapçada'),
        findsOneWidget,
      ); // metin
      expect(find.text('Dialogue'), findsOneWidget);
      expect(find.text('مرحبًا!'), findsOneWidget);
      expect(find.text('Merhaba!'), findsOneWidget); // çeviri bilinen dilde
      expect(find.text('Vocabulary'), findsOneWidget);
      expect(_key('lesson-word:ar-shukran'), findsOneWidget);
      expect(find.text('Example'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
    });

    testWidgets('gramer bloğu', (tester) async {
      await open(tester, 'ar-a1-l2');
      expect(find.text('Grammar'), findsOneWidget);
      expect(find.text('Adını söyleme'), findsOneWidget);
    });

    testWidgets('alıştırma: yanlış, tekrar dene, doğru', (tester) async {
      await open(tester, 'ar-a1-l1');
      await tester.tap(_key('option:b'));
      await tester.pump();
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      expect(find.text('Not quite.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(_key('answer-feedback'), findsNothing);
      await tester.tap(_key('option:a'));
      await tester.pump();
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('tamamlandı olarak işaretle', (tester) async {
      final c = await open(tester, 'ar-a1-l1');
      await tester.tap(find.text('Mark as complete'));
      await tester.pumpAndSettle();
      expect(c.read(progressProvider).isCompleted('ar-a1-l1'), isTrue);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('önceki/sonraki ders gezintisi', (tester) async {
      final c = await open(tester, 'ar-a1-l1');
      expect(find.text('Previous lesson'), findsNothing);
      await tester.tap(find.text('Next lesson'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/lesson/ar-a1-l2');
      expect(find.text('Previous lesson'), findsOneWidget);
      expect(find.text('Next lesson'), findsOneWidget);
    });

    testWidgets('quiz\'e gider', (tester) async {
      final c = await open(tester, 'ar-a1-l1');
      await tester.tap(find.text('Take the quiz'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/quiz/ar-a1-l1');
      expect(find.text('Question 1 of 6'), findsOneWidget);
    });

    testWidgets('olmayan ders: bulunamadı', (tester) async {
      await pumpApp(tester, initialLocation: '/lesson/yok');
      expect(
        find.text("We couldn't find what you were looking for."),
        findsOneWidget,
      );
    });
  });

  group('quiz', () {
    const lessonId = 'ar-a1-l1';

    Future<ProviderContainer> open(WidgetTester tester) {
      useScreen(tester, height: 1200);
      return pumpApp(
        tester,
        initialLocation: '/quiz/$lessonId',
        overrides: [trToArPreferences, fixedClock],
      );
    }

    /// Geçerli soruyu cevaplar, kontrol eder ve ilerler.
    Future<void> answer(
      WidgetTester tester,
      ProviderContainer c, {
      required bool correct,
    }) async {
      final question = c
          .read(quizControllerProvider(lessonId))
          .requireValue
          .current;
      final id = switch (question) {
        MultipleChoiceQuestion q =>
          correct
              ? q.correctOptionId
              : q.options.firstWhere((o) => o.id != q.correctOptionId).id,
        TrueFalseQuestion q => (q.correctAnswer == correct).toString(),
      };
      await tester.tap(_key('option:$id'));
      await tester.pump();
      await tester.tap(find.text('Check answer'));
      await tester.pump();
      expect(_key('answer-feedback'), findsOneWidget);
      final last = c.read(quizControllerProvider(lessonId)).requireValue.isLast;
      await tester.tap(find.text(last ? 'See results' : 'Next question'));
      await tester.pumpAndSettle();
    }

    testWidgets('seçim yapılmadan kontrol edilemez', (tester) async {
      await open(tester);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Check answer'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('hepsi doğru: %100, başarılı, ilerlemeye yazılır', (
      tester,
    ) async {
      final c = await open(tester);
      for (var i = 0; i < 6; i++) {
        await answer(tester, c, correct: true);
      }
      expect(find.text('100%'.isolateLtr), findsOneWidget);
      expect(find.text('Great job!'), findsOneWidget);
      expect(find.text('6 of 6 correct'), findsOneWidget);
      expect(c.read(progressProvider).quizScores[lessonId], 100);
      expect(c.read(progressProvider).isCompleted(lessonId), isTrue);
      expect(find.textContaining('only on this device'), findsOneWidget);
    });

    testWidgets('hepsi yanlış: %0, tekrar dene baştan başlatır', (
      tester,
    ) async {
      final c = await open(tester);
      for (var i = 0; i < 6; i++) {
        await answer(tester, c, correct: false);
      }
      expect(find.text('0%'.isolateLtr), findsOneWidget);
      expect(find.text('Keep practicing.'), findsOneWidget);
      expect(c.read(progressProvider).isCompleted(lessonId), isFalse);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 6'), findsOneWidget);
    });

    testWidgets('Bitti ana sayfaya döner (geri yığın yoksa)', (tester) async {
      final c = await open(tester);
      for (var i = 0; i < 6; i++) {
        await answer(tester, c, correct: true);
      }
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.home);
    });
  });

  group('ilerleme', () {
    testWidgets('boş durum ve kurslara göz at', (tester) async {
      useScreen(tester);
      final c = await pumpApp(tester, initialLocation: AppRoutes.progress);
      expect(find.text('No progress yet'), findsOneWidget);
      expect(find.text('No quizzes yet'), findsOneWidget);
      await tester.tap(find.text('Browse courses'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.courses);
    });

    testWidgets('ilerlemeyle istatistik ve kurs kartı', (tester) async {
      useScreen(tester);
      await pumpApp(
        tester,
        initialLocation: AppRoutes.progress,
        overrides: [
          trToArPreferences,
          fixedClock,
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                completedLessons: {'ar-a1-l1': DateTime(2026, 11, 6, 8)},
                quizScores: const {'ar-a1-l1': 80},
              ),
            ),
          ),
        ],
      );
      expect(find.text('80%'.isolateLtr), findsOneWidget);
      expect(find.text('Average quiz score'), findsOneWidget);
      expect(_key('course-progress:ar-a1-basics'), findsOneWidget);
      expect(find.text('1/3 lessons'), findsOneWidget);
    });

    testWidgets('günlük hedef değiştirilir', (tester) async {
      useScreen(tester);
      final c = await pumpApp(tester, initialLocation: AppRoutes.progress);
      await tester.tap(_key('daily-goal:3'));
      await tester.pumpAndSettle();
      expect(c.read(progressProvider).dailyGoalLessons, 3);
      expect(find.textContaining('of 3 lessons today'), findsOneWidget);
    });
  });

  group('kelimeler', () {
    testWidgets('liste, detay kartı ve durum değiştirme', (tester) async {
      useScreen(tester);
      final c = await pumpApp(
        tester,
        initialLocation: AppRoutes.vocabulary,
        overrides: [trToArPreferences],
      );
      expect(_key('word:ar-marhaba'), findsOneWidget);
      expect(_key('word:en-hello'), findsNothing); // yalnızca öğrenilen dil

      await tester.tap(_key('word:ar-marhaba'));
      await tester.pumpAndSettle();
      expect(find.text('Meaning'), findsOneWidget);
      expect(find.text('Learning status'), findsOneWidget);
      expect(find.text('marḥaban'.isolateLtr), findsWidgets);

      await tester.tap(_key('word-status:learned'));
      await tester.pumpAndSettle();
      expect(
        c.read(vocabularyRecordsProvider)['ar-marhaba']?.status,
        VocabularyStatus.learned,
      );
    });

    testWidgets('duruma göre filtre ve boş durum', (tester) async {
      useScreen(tester);
      await pumpApp(
        tester,
        initialLocation: AppRoutes.vocabulary,
        overrides: [
          trToArPreferences,
          vocabularyRecordsProvider.overrideWith(
            () => VocabularyRecordsNotifier({
              'ar-marhaba': const VocabularyRecord(
                status: VocabularyStatus.learned,
              ),
            }),
          ),
        ],
      );
      await tester.tap(_key('vocabulary-filter:learned'));
      await tester.pumpAndSettle();
      expect(_key('word:ar-marhaba'), findsOneWidget);
      expect(_key('word:ar-ahlan'), findsNothing);

      await tester.tap(_key('vocabulary-filter:learning'));
      await tester.pumpAndSettle();
      expect(find.text('No words found'), findsOneWidget);
    });
  });
}
