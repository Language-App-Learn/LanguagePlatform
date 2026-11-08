import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/storage/app_preferences.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/language_selection/application/learning_preferences.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/progress/domain/learning_progress.dart';
import 'package:language_platform/features/vocabulary/application/vocabulary_providers.dart';
import 'package:language_platform/features/vocabulary/domain/review_scheduler.dart';
import 'package:language_platform/features/vocabulary/domain/vocabulary_item.dart';

import '../helpers/persistent_app.dart';
import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

Future<MemoryKeyValueStore> _seededStore() async {
  final store = MemoryKeyValueStore();
  await AppPreferencesRepository(store).save(
    const AppPreferences(
      interfaceLanguage: 'ar',
      knownLanguage: 'tr',
      targetLanguage: 'ar',
      themeMode: 'dark',
      onboardingCompleted: true,
    ),
  );
  return store;
}

void main() {
  group('cold start / restart', () {
    testWidgets('first launch asks for the app language (once)', (
      tester,
    ) async {
      final c = await launchApp(tester, MemoryKeyValueStore());
      expect(currentPath(c), AppRoutes.appLanguage);
    });

    testWidgets(
      'returning user goes straight to the menu; language and theme restored',
      (tester) async {
        useScreen(tester);
        final store = await _seededStore();
        final c = await launchApp(tester, store);
        expect(currentPath(c), AppRoutes.menu);
        expect(currentDirection(tester), TextDirection.rtl); // Arabic restored
        final theme = Theme.of(tester.element(find.byType(Scaffold).first));
        expect(theme.brightness, Brightness.dark);
        // Dil Öğren (Arabic UI: تعلّم لغة) opens the language pair screen.
        await tester.tap(find.byKey(const ValueKey('menu-learn')));
        await tester.pumpAndSettle();
        expect(currentPath(c), AppRoutes.languagePair);
        expect(currentDirection(tester), TextDirection.rtl);
      },
    );

    testWidgets('choices made in the app survive a restart', (tester) async {
      useScreen(tester);
      final store = MemoryKeyValueStore();
      var c = await launchApp(
        tester,
        store,
        initialLocation: AppRoutes.settings,
      );
      await tester.tap(_key('interface-language:tr'));
      await tester.pumpAndSettle();
      await tester.tap(_key('theme-mode:dark'));
      await tester.pumpAndSettle();
      await tester.tap(_key('settings-daily-goal:3'));
      await tester.pumpAndSettle();

      c = await launchApp(tester, store, initialLocation: AppRoutes.settings);
      expect(find.text('Uygulama dili'), findsOneWidget); // Turkish restored
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
      expect(c.read(progressProvider).dailyGoalLessons, 3);
    });

    testWidgets('app language is asked once; the language pair is saved', (
      tester,
    ) async {
      useScreen(tester);
      final store = MemoryKeyValueStore();
      var c = await launchApp(tester, store);
      // First launch: the one-time app-language choice, then the menu.
      expect(currentPath(c), AppRoutes.appLanguage);
      await tester.tap(find.byKey(const ValueKey('app-language-continue')));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.menu);
      // Dil Öğren -> language pair (screen 4) -> Devam Et saves tr -> ar.
      await tester.tap(find.byKey(const ValueKey('menu-learn')));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.languagePair);
      await tester.tap(find.byKey(const ValueKey('pair-continue')));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.arabicSections);

      c = await launchApp(tester, store);
      // The app language is saved: no question again, straight to the menu.
      expect(currentPath(c), AppRoutes.menu);
      final prefs = c.read(learningPreferencesProvider);
      expect(prefs.knownLanguage?.code, 'tr');
      expect(prefs.targetLanguage?.code, 'ar');
    });

    testWidgets('lesson progress and last opened lesson survive a restart', (
      tester,
    ) async {
      useScreen(tester);
      final store = await _seededStore();
      var c = await launchApp(
        tester,
        store,
        initialLocation: '/lesson/ar-a1-l1',
      );
      expect(c.read(progressProvider).lastOpened?.lessonId, 'ar-a1-l1');
      expect(c.read(progressProvider).completedCount, 0); // opened ≠ completed
      await tester.tap(find.text('وضع علامة مكتمل'));
      await tester.pumpAndSettle();

      c = await launchApp(tester, store, initialLocation: AppRoutes.home);
      expect(c.read(progressProvider).isCompleted('ar-a1-l1'), isTrue);
      expect(find.text('Resume your lesson'), findsNothing); // l1 is completed
    });
  });

  group('reset local data', () {
    testWidgets('cancel keeps data; confirm wipes it and restarts onboarding', (
      tester,
    ) async {
      useScreen(tester, height: 3600);
      final store = await _seededStore();
      final c = await launchApp(
        tester,
        store,
        initialLocation: AppRoutes.settings,
      );
      c.read(progressProvider.notifier).completeLesson('ar-a1-l1');
      await tester.pump();

      await tester.ensureVisible(_key('reset-local-data'));
      await tester.tap(_key('reset-local-data'));
      await tester.pumpAndSettle();
      expect(find.text('Reset local data?'), findsNothing); // Arabic UI text
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(c.read(progressProvider).completedCount, 1);

      await tester.ensureVisible(_key('reset-local-data'));
      await tester.tap(_key('reset-local-data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إعادة تعيين').last);
      await tester.pumpAndSettle();

      // Everything is gone, including the saved app language: the app asks
      // for it again (device language is English here).
      expect(currentPath(c), AppRoutes.appLanguage);
      expect(c.read(progressProvider).completedCount, 0);
      expect(store.read(AppPreferencesRepository.storageKey), isNull);
      expect(find.text('Which language should the app use?'), findsOneWidget);
    });
  });

  group('flashcards', () {
    final clock = DateTime(2026, 11, 6, 12);

    Future<(MemoryKeyValueStore, dynamic)> open(WidgetTester tester) async {
      useScreen(tester, height: 1400);
      final store = await _seededStore();
      final c = await launchApp(
        tester,
        store,
        initialLocation: AppRoutes.review,
        overrides: [clockProvider.overrideWithValue(() => clock)],
      );
      return (store, c);
    }

    testWidgets('card flips, rating schedules the word and logs activity', (
      tester,
    ) async {
      final (_, c) = await open(tester);
      expect(find.text('Kart 1 / 5'), findsNothing); // UI is Arabic
      expect(find.text('البطاقة 1 من 5'), findsOneWidget);
      expect(
        tester
            .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
            .crossFadeState,
        CrossFadeState.showFirst,
      );
      expect(_key('rate:good'), findsNothing); // cannot rate before reveal

      await tester.tap(find.text('إظهار الإجابة').last);
      await tester.pumpAndSettle();
      expect(find.text('Merhaba'), findsOneWidget); // meaning in known lang

      await tester.tap(_key('rate:good'));
      await tester.pumpAndSettle();
      final records = c.read(vocabularyRecordsProvider);
      final first = records['ar-marhaba']!;
      expect(first.review.box, 1);
      expect(first.review.dueAt, clock.add(const Duration(days: 1)));
      expect(first.status, VocabularyStatus.learning);
      expect(
        c.read(progressProvider).activity.single.type,
        ActivityType.vocabularyReviewed,
      );
      expect(find.text('البطاقة 2 من 5'), findsOneWidget);
    });

    testWidgets('completing the session shows a summary and due count', (
      tester,
    ) async {
      final (_, c) = await open(tester);
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('إظهار الإجابة').last);
        await tester.pumpAndSettle();
        await tester.tap(_key('rate:${i == 0 ? 'again' : 'easy'}'));
        await tester.pumpAndSettle();
      }
      expect(find.text('اكتملت الجلسة'), findsOneWidget);
      expect(c.read(progressProvider).activity, hasLength(5));
      expect(c.read(vocabularyRecordsProvider)['ar-marhaba']!.review.lapses, 1);
    });
  });

  group('vocabulary list', () {
    testWidgets('favorites and search', (tester) async {
      useScreen(tester, height: 2400);
      final c = await launchApp(
        tester,
        await _seededStore(),
        initialLocation: AppRoutes.vocabulary,
      );
      await tester.tap(_key('favorite:ar-shukran'));
      await tester.pumpAndSettle();
      expect(c.read(vocabularyRecordsProvider)['ar-shukran']!.favorite, isTrue);

      await tester.tap(_key('vocabulary-filter:favorites'));
      await tester.pumpAndSettle();
      expect(_key('word:ar-shukran'), findsOneWidget);
      expect(_key('word:ar-marhaba'), findsNothing);

      await tester.tap(_key('vocabulary-filter:all'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'kitap');
      await tester.pumpAndSettle();
      expect(_key('word:ar-kitab'), findsOneWidget);
      expect(_key('word:ar-marhaba'), findsNothing);
    });

    testWidgets('due badge appears when a review is due', (tester) async {
      useScreen(tester, height: 2400);
      final store = await _seededStore();
      final now = DateTime(2026, 11, 6, 12);
      await LocalVocabularyStoreFacade.save(store, 'ar-marhaba', now);
      await launchApp(
        tester,
        store,
        initialLocation: AppRoutes.vocabulary,
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      expect(find.byTooltip('حان وقت المراجعة'), findsOneWidget);
    });
  });

  group('dashboard from persisted activity', () {
    final clock = DateTime(2026, 11, 6, 12);

    testWidgets('empty: honest empty state and no streak', (tester) async {
      useScreen(tester);
      await launchApp(
        tester,
        MemoryKeyValueStore(),
        initialLocation: AppRoutes.home,
        overrides: [fixedClock],
      );
      expect(find.textContaining('No activity recorded yet'), findsOneWidget);
      expect(_key('streak'), findsNothing);
    });

    testWidgets('recorded activity yields chart and streak', (tester) async {
      useScreen(tester);
      await launchApp(
        tester,
        MemoryKeyValueStore(),
        initialLocation: AppRoutes.home,
        overrides: [
          fixedClock,
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                activity: [
                  ActivityEvent(
                    type: ActivityType.lessonCompleted,
                    refId: 'a',
                    at: DateTime(2026, 11, 5, 10),
                  ),
                  ActivityEvent(
                    type: ActivityType.quizCompleted,
                    refId: 'a',
                    at: clock,
                    score: 90,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      expect(find.text('2-day streak'), findsOneWidget);
      expect(find.textContaining('No activity recorded yet'), findsNothing);
    });

    testWidgets('resumes the last opened, unfinished lesson first', (
      tester,
    ) async {
      useScreen(tester);
      await launchApp(
        tester,
        MemoryKeyValueStore(),
        initialLocation: AppRoutes.home,
        overrides: [
          fixedClock,
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                lastOpened: LastOpened(
                  courseId: 'ar-a1-basics',
                  lessonId: 'ar-a1-l2',
                  at: clock,
                ),
              ),
            ),
          ),
        ],
      );
      expect(find.text('Resume your lesson'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('continue-card'),
          matching: find.text('Introducing yourself'),
        ),
        findsOneWidget,
      );
    });
  });
}

/// Test helper: writes one reviewed word straight into the store.
abstract final class LocalVocabularyStoreFacade {
  static Future<void> save(
    MemoryKeyValueStore store,
    String id,
    DateTime reviewedAt,
  ) async {
    final past = reviewedAt.subtract(const Duration(days: 2));
    final state = ReviewScheduler.next(
      const ReviewState(),
      ReviewRating.good,
      past,
    );
    await store.write(
      'lp.vocabulary',
      '{"v":1,"items":{"$id":{"status":"learning","favorite":false,'
          '"review":{"box":${state.box},"due":"${state.dueAt!.toUtc().toIso8601String()}",'
          '"last":"${past.toUtc().toIso8601String()}","n":1,"lapses":0}}}}',
    );
  }
}
