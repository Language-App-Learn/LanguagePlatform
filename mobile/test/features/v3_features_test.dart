import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_router.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/storage/app_preferences.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/courses/application/course_providers.dart';
import 'package:language_platform/features/courses/data/demo_course_repository.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/progress/domain/learning_progress.dart';
import 'package:language_platform/features/vocabulary/application/vocabulary_providers.dart';

import '../helpers/persistent_app.dart';
import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

Future<MemoryKeyValueStore> _store({bool arabicUi = false}) async {
  final store = MemoryKeyValueStore();
  await AppPreferencesRepository(store).save(
    AppPreferences(
      interfaceLanguage: arabicUi ? 'ar' : 'en',
      knownLanguage: 'tr',
      targetLanguage: 'ar',
      onboardingCompleted: true,
    ),
  );
  return store;
}

void main() {
  final clock = DateTime(2026, 11, 6, 12);

  group('active course / CEFR card', () {
    testWidgets('shows the last opened course with level and real progress', (
      tester,
    ) async {
      useScreen(tester);
      final c = await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.home,
        overrides: [
          clockProvider.overrideWithValue(() => clock),
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                lastOpened: LastOpened(
                  courseId: 'ar-a1-basics',
                  lessonId: 'ar-a1-l1',
                  at: clock,
                ),
              ),
            ),
          ),
        ],
      );
      final card = _key('active-course');
      expect(card, findsOneWidget);
      expect(
        find.descendant(
          of: card,
          matching: find.text('Arabic A1: First Steps'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('A1'.isolateLtrForTest)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('0/3 lessons')),
        findsOneWidget,
      );

      // Completing a lesson updates the card immediately (single source).
      c.read(progressProvider.notifier).completeLesson('ar-a1-l1');
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: card, matching: find.text('1/3 lessons')),
        findsOneWidget,
      );
    });

    testWidgets('ignores a last-opened course of another target language', (
      tester,
    ) async {
      useScreen(tester);
      await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.home,
        overrides: [
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                lastOpened: LastOpened(
                  courseId: 'en-a1-everyday',
                  lessonId: 'en-a1-l1',
                  at: clock,
                ),
              ),
            ),
          ),
        ],
      );
      expect(
        find.descendant(
          of: _key('active-course'),
          matching: find.text('Arabic A1: First Steps'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('empty state when no course exists (no fabricated data)', (
      tester,
    ) async {
      useScreen(tester);
      await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.home,
        overrides: [coursesProvider.overrideWith((ref) async => [])],
      );
      expect(_key('active-course-empty'), findsOneWidget);
      expect(_key('active-course'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('missing (deleted) last-opened course degrades gracefully', (
      tester,
    ) async {
      useScreen(tester);
      await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.home,
        overrides: [
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                lastOpened: LastOpened(
                  courseId: 'deleted-course',
                  lessonId: 'x',
                  at: clock,
                ),
              ),
            ),
          ),
        ],
      );
      expect(tester.takeException(), isNull);
      expect(_key('active-course'), findsOneWidget); // falls back to the path
    });
  });

  group('word detail favorite', () {
    testWidgets('toggles in the detail sheet, syncs with the list, persists', (
      tester,
    ) async {
      useScreen(tester, height: 2400);
      final store = await _store();
      var c = await launchApp(
        tester,
        store,
        initialLocation: AppRoutes.vocabulary,
      );
      await tester.tap(_key('word:ar-marhaba'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Add to favorites'), findsWidgets);
      await tester.tap(_key('detail-favorite'));
      await tester.pumpAndSettle();
      expect(c.read(vocabularyRecordsProvider)['ar-marhaba']!.favorite, isTrue);

      // Close the sheet; the list row shows the same state.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      final listStar = tester.widget<IconButton>(_key('favorite:ar-marhaba'));
      expect((listStar.icon as Icon).icon, Icons.star);

      // Restart: favorite is still there.
      c = await launchApp(tester, store, initialLocation: AppRoutes.vocabulary);
      expect(c.read(vocabularyRecordsProvider)['ar-marhaba']!.favorite, isTrue);
    });
  });

  group('review history', () {
    testWidgets('empty state first', (tester) async {
      await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.reviewHistory,
      );
      expect(find.text('No reviews yet'), findsOneWidget);
    });

    testWidgets('lists real reviews newest first with rating and next review', (
      tester,
    ) async {
      useScreen(tester, height: 2000);
      var now = clock;
      final c = await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.review,
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      await tester.tap(find.text('Show answer').last);
      await tester.pumpAndSettle();
      await tester.tap(_key('rate:good'));
      await tester.pumpAndSettle();
      now = clock.add(const Duration(minutes: 5));
      await tester.tap(find.text('Show answer').last);
      await tester.pumpAndSettle();
      await tester.tap(_key('rate:again'));
      await tester.pumpAndSettle();

      c.read(routerProvider).go(AppRoutes.reviewHistory);
      await tester.pumpAndSettle();
      expect(_key('history-rating:again'), findsOneWidget);
      expect(_key('history-rating:good'), findsOneWidget);
      expect(find.textContaining('Next review:'), findsNWidgets(2));
      // Newest (again) is above the older one (good).
      final again = tester.getTopLeft(_key('history-rating:again')).dy;
      final good = tester.getTopLeft(_key('history-rating:good')).dy;
      expect(again, lessThan(good));
    });

    testWidgets('entries of removed words do not crash', (tester) async {
      useScreen(tester);
      await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.reviewHistory,
        overrides: [
          progressProvider.overrideWith(
            () => ProgressNotifier(
              LearningProgress(
                activity: [
                  ActivityEvent(
                    type: ActivityType.vocabularyReviewed,
                    refId: 'gone-word',
                    at: clock,
                    score: 2,
                  ),
                  ActivityEvent(
                    type: ActivityType.vocabularyReviewed,
                    refId: 'gone-word',
                    at: clock,
                    score: 99, // malformed rating
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      expect(find.text('Word no longer available'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('reachable from the vocabulary page', (tester) async {
      final c = await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.vocabulary,
      );
      await tester.tap(_key('open-review-history'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.reviewHistory);
    });
  });

  group('cross-screen consistency', () {
    testWidgets('one completed lesson shows the same counts everywhere', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final c = await launchApp(
        tester,
        await _store(),
        initialLocation: '/lesson/ar-a1-l1',
        overrides: [clockProvider.overrideWithValue(() => clock)],
      );
      await tester.tap(find.text('Mark as complete'));
      await tester.pumpAndSettle();

      expect(c.read(progressProvider).completedCount, 1);
      expect(c.read(progressProvider).completedOn(clock), 1);

      c.read(routerProvider).go(AppRoutes.progress);
      await tester.pumpAndSettle();
      expect(find.text('1/3 lessons'), findsOneWidget); // course progress
      expect(find.text('1 of 1 lessons today'), findsOneWidget);

      c.read(routerProvider).go('/course/ar-a1-basics');
      await tester.pumpAndSettle();
      expect(find.text('1/3 lessons'), findsOneWidget);

      c.read(routerProvider).go(AppRoutes.home);
      await tester.pumpAndSettle();
      expect(find.text('1/3 lessons'), findsWidgets);
      expect(find.text("You reached today's goal!"), findsOneWidget);
    });
  });

  group('resilience', () {
    testWidgets('invalid persisted language codes fall back safely', (
      tester,
    ) async {
      final store = MemoryKeyValueStore();
      await AppPreferencesRepository(store).save(
        const AppPreferences(
          interfaceLanguage: 'xx',
          knownLanguage: 'zz',
          targetLanguage: 'qq',
          themeMode: 'neon',
          onboardingCompleted: true,
        ),
      );
      final c = await launchApp(tester, store);
      expect(tester.takeException(), isNull);
      // Onboarding was completed, but no valid languages → language setup.
      expect(currentPath(c), AppRoutes.languageSetup);
      expect(currentDirection(tester), TextDirection.ltr);
    });

    testWidgets('empty catalog does not break catalog or home', (tester) async {
      useScreen(tester);
      final empty = coursesProvider.overrideWith((ref) async => []);
      await launchApp(
        tester,
        await _store(),
        initialLocation: AppRoutes.courses,
        overrides: [empty],
      );
      expect(find.text('No courses found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('demo catalog ids referenced by progress tests exist', () {
    expect(demoCourses.map((c) => c.id), contains('ar-a1-basics'));
  });
}

extension on String {
  /// Same isolation as production `isolateLtr` for matching badge text.
  String get isolateLtrForTest => '\u{2066}$this\u{2069}';
}
