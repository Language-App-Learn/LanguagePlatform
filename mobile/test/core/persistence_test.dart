import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/app_language.dart';
import 'package:language_platform/core/storage/app_preferences.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/core/theme/theme_mode_provider.dart';
import 'package:language_platform/features/language_selection/application/learning_preferences.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';
import 'package:language_platform/features/onboarding/application/onboarding_state.dart';
import 'package:language_platform/features/progress/application/progress_providers.dart';
import 'package:language_platform/features/progress/data/local_progress_repository.dart';
import 'package:language_platform/features/progress/domain/learning_progress.dart';
import 'package:language_platform/features/vocabulary/application/vocabulary_providers.dart';
import 'package:language_platform/features/vocabulary/data/local_vocabulary_store.dart';
import 'package:language_platform/features/vocabulary/domain/review_scheduler.dart';
import 'package:language_platform/features/vocabulary/domain/vocabulary_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A new container over the same store = an app restart.
ProviderContainer _launch(KeyValueStore store, [DateTime? now]) {
  final c = ProviderContainer.test(
    overrides: [
      keyValueStoreProvider.overrideWithValue(store),
      if (now != null) clockProvider.overrideWithValue(() => now),
    ],
  );
  return c;
}

void main() {
  final t0 = DateTime(2026, 11, 6, 12);

  group('KeyValueStore', () {
    test(
      'SharedPreferences store: roundtrip and clearAll only own keys',
      () async {
        SharedPreferences.setMockInitialValues({'other.key': 'keep'});
        final prefs = await SharedPreferences.getInstance();
        final store = SharedPreferencesKeyValueStore(prefs);
        await store.write('lp.a', '1');
        expect(store.read('lp.a'), '1');
        await store.clearAll();
        expect(store.read('lp.a'), isNull);
        expect(prefs.getString('other.key'), 'keep');
      },
    );

    test('corrupted JSON reads as missing', () {
      final store = MemoryKeyValueStore({'k': '{not json', 'l': '[1,2]'});
      expect(readJsonObject(store, 'k'), isNull);
      expect(readJsonObject(store, 'l'), isNull);
      expect(readJsonObject(store, 'none'), isNull);
    });
  });

  group('AppPreferencesRepository', () {
    test('roundtrip', () async {
      final repo = AppPreferencesRepository(MemoryKeyValueStore());
      await repo.save(
        const AppPreferences(
          interfaceLanguage: 'ar',
          knownLanguage: 'tr',
          targetLanguage: 'en',
          themeMode: 'dark',
          onboardingCompleted: true,
        ),
      );
      final p = repo.load();
      expect(p.interfaceLanguage, 'ar');
      expect(p.knownLanguage, 'tr');
      expect(p.targetLanguage, 'en');
      expect(p.themeMode, 'dark');
      expect(p.onboardingCompleted, isTrue);
    });

    test('corrupted or newer-version data falls back to defaults', () {
      final bad = AppPreferencesRepository(
        MemoryKeyValueStore({AppPreferencesRepository.storageKey: 'oops'}),
      );
      expect(bad.load().onboardingCompleted, isFalse);
      final future = AppPreferencesRepository(
        MemoryKeyValueStore({
          AppPreferencesRepository.storageKey:
              '{"v":99,"onboardingCompleted":true}',
        }),
      );
      expect(future.load().onboardingCompleted, isFalse);
    });

    test('wrong value types are ignored', () {
      final repo = AppPreferencesRepository(
        MemoryKeyValueStore({
          AppPreferencesRepository.storageKey: '{"v":1,"interfaceLanguage":5,"themeMode":"","onboardingCompleted":"yes"}',
        }),
      );
      final p = repo.load();
      expect(p.interfaceLanguage, isNull);
      expect(p.themeMode, isNull);
      expect(p.onboardingCompleted, isFalse);
    });
  });

  group('restart restores state', () {
    test('preferences: language, theme, learning languages, onboarding', () {
      final store = MemoryKeyValueStore();
      final a = _launch(store);
      a.read(appLanguageProvider.notifier).select(AppLanguage.ar);
      a.read(themeModeProvider.notifier).select(ThemeMode.dark);
      a
          .read(learningPreferencesProvider.notifier)
          .selectKnown(LearningLanguage.fromCode('tr')!);
      a
          .read(learningPreferencesProvider.notifier)
          .selectTarget(LearningLanguage.fromCode('ar')!);
      a.read(onboardingCompletedProvider.notifier).complete();

      final b = _launch(store); // restart
      expect(b.read(appLanguageProvider), AppLanguage.ar);
      expect(b.read(themeModeProvider), ThemeMode.dark);
      final prefs = b.read(learningPreferencesProvider);
      expect(prefs.knownLanguage?.code, 'tr');
      expect(prefs.targetLanguage?.code, 'ar');
      expect(prefs.isComplete, isTrue);
      expect(b.read(onboardingCompletedProvider), isTrue);
    });

    test('"follow device language" is persisted as null', () {
      final store = MemoryKeyValueStore();
      final a = _launch(store);
      a.read(appLanguageProvider.notifier).select(AppLanguage.tr);
      a.read(appLanguageProvider.notifier).select(null);
      expect(_launch(store).read(appLanguageProvider), isNull);
    });

    test('identical known/target pair in storage is repaired', () async {
      final store = MemoryKeyValueStore();
      await AppPreferencesRepository(
        store,
      ).save(const AppPreferences(knownLanguage: 'tr', targetLanguage: 'tr'));
      final prefs = _launch(store).read(learningPreferencesProvider);
      expect(prefs.knownLanguage?.code, 'tr');
      expect(prefs.targetLanguage, isNull);
    });

    test('progress: lessons, quiz, goal, last opened, activity', () {
      final store = MemoryKeyValueStore();
      final a = _launch(store, t0);
      final n = a.read(progressProvider.notifier);
      n.markOpened('c1', 'l1');
      n.completeLesson('l1');
      n.recordQuizScore('l1', 80);
      n.recordQuizScore('l1', 60);
      n.setDailyGoal(3);

      final p = _launch(store, t0).read(progressProvider);
      expect(p.isCompleted('l1'), isTrue);
      expect(p.completedLessons['l1'], t0);
      expect(p.quizScores['l1'], 80); // best kept
      expect(p.dailyGoalLessons, 3);
      expect(p.lastOpened?.lessonId, 'l1');
      expect(p.activity.map((e) => e.type), [
        ActivityType.lessonCompleted,
        ActivityType.quizCompleted,
        ActivityType.quizCompleted,
      ]);
      expect(p.activity.last.score, 60);
    });

    test('opening a lesson does not complete it', () {
      final c = _launch(MemoryKeyValueStore(), t0);
      c.read(progressProvider.notifier).markOpened('c1', 'l1');
      expect(c.read(progressProvider).isCompleted('l1'), isFalse);
      expect(c.read(progressProvider).activity, isEmpty);
    });

    test('vocabulary: favorite, status and review schedule', () {
      final store = MemoryKeyValueStore();
      final a = _launch(store);
      final n = a.read(vocabularyRecordsProvider.notifier);
      n.toggleFavorite('w1');
      n.applyReview('w1', ReviewRating.good, t0);
      n.setStatus('w2', VocabularyStatus.learned);

      final r = _launch(store).read(vocabularyRecordsProvider);
      expect(r['w1']!.favorite, isTrue);
      expect(r['w1']!.review.box, 1);
      expect(r['w1']!.review.dueAt, t0.add(const Duration(days: 1)));
      expect(r['w1']!.status, VocabularyStatus.learning);
      expect(r['w2']!.status, VocabularyStatus.learned);
    });

    test('empty storage gives clean defaults', () {
      final c = _launch(MemoryKeyValueStore());
      expect(c.read(onboardingCompletedProvider), isFalse);
      expect(c.read(progressProvider).completedCount, 0);
      expect(c.read(vocabularyRecordsProvider), isEmpty);
    });

    test('clearAll resets everything on next launch', () async {
      final store = MemoryKeyValueStore();
      final a = _launch(store, t0);
      a.read(onboardingCompletedProvider.notifier).complete();
      a.read(progressProvider.notifier).completeLesson('l1');
      await store.clearAll();
      final b = _launch(store, t0);
      expect(b.read(onboardingCompletedProvider), isFalse);
      expect(b.read(progressProvider).completedCount, 0);
    });
  });

  group('corrupted learning data', () {
    test('progress: garbage, bad entries and future versions', () {
      expect(
        LocalProgressRepository(
          MemoryKeyValueStore({LocalProgressRepository.storageKey: '%%%'}),
        ).load().completedCount,
        0,
      );
      final partly = LocalProgressRepository(
        MemoryKeyValueStore({
          LocalProgressRepository.storageKey:
              '{"v":1,"completedLessons":{"ok":"2026-11-06T10:00:00Z","bad":"x","n":5},'
              '"quizScores":{"a":70,"b":"x"},"dailyGoal":0,'
              '"activity":[{"t":"nope","id":"a","at":"2026-11-06T10:00:00Z"},{"t":"quizCompleted","id":"a","at":"2026-11-06T10:00:00Z","s":70},5]}',
        }),
      ).load();
      expect(partly.completedLessons.keys, ['ok']);
      expect(partly.quizScores, {'a': 70});
      expect(partly.dailyGoalLessons, 1); // invalid goal → default
      expect(partly.activity, hasLength(1));

      final future = LocalProgressRepository(
        MemoryKeyValueStore({
          LocalProgressRepository.storageKey:
              '{"v":42,"completedLessons":{"x":"2026-11-06T10:00:00Z"}}',
        }),
      ).load();
      expect(future.completedCount, 0);
    });

    test('vocabulary: bad entries skipped, values clamped', () {
      final records = LocalVocabularyStore(
        MemoryKeyValueStore({
          LocalVocabularyStore.storageKey: '{"v":1,"items":{"a":{"status":"learned","favorite":true,"review":{"box":99,"n":-3}},"b":5,"c":{"status":"zzz"}}}',
        }),
      ).load();
      expect(records.keys.toSet(), {'a', 'c'});
      expect(records['a']!.review.box, ReviewScheduler.maxBox);
      expect(records['a']!.review.reviews, 0);
      expect(records['c']!.status, VocabularyStatus.fresh);
    });
  });

  group('activity analytics', () {
    ActivityEvent e(DateTime at) =>
        ActivityEvent(type: ActivityType.lessonCompleted, refId: 'x', at: at);

    test('dailyActivity counts the last 7 days, oldest first', () {
      final p = LearningProgress(
        activity: [
          e(DateTime(2026, 11, 6, 9)),
          e(DateTime(2026, 11, 6, 20)),
          e(DateTime(2026, 11, 4)),
          e(DateTime(2026, 10, 20)), // outside window
        ],
      );
      expect(p.dailyActivity(t0), [0, 0, 0, 0, 1, 0, 2]);
    });

    test('streak: consecutive days, grace for today, broken by gaps', () {
      final p = LearningProgress(
        activity: [
          e(DateTime(2026, 11, 6)),
          e(DateTime(2026, 11, 5)),
          e(DateTime(2026, 11, 4)),
          e(DateTime(2026, 11, 1)),
        ],
      );
      expect(p.currentStreak(t0), 3);
      // No activity yet today → yesterday's streak still counts.
      expect(p.currentStreak(DateTime(2026, 11, 7, 8)), 3);
      // Two idle days → streak is over.
      expect(p.currentStreak(DateTime(2026, 11, 8, 8)), 0);
      expect(const LearningProgress().currentStreak(t0), 0);
    });

    test('activity log is capped', () {
      final c = _launch(MemoryKeyValueStore(), t0);
      final n = c.read(progressProvider.notifier);
      for (var i = 0; i < LearningProgress.maxActivityEvents + 20; i++) {
        n.recordReview('w$i', 2);
      }
      final events = c.read(progressProvider).activity;
      expect(events, hasLength(LearningProgress.maxActivityEvents));
      expect(events.last.refId, 'w${LearningProgress.maxActivityEvents + 19}');
    });
  });
}
