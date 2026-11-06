import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../courses/application/course_providers.dart';
import '../../courses/domain/course.dart';
import '../../language_selection/application/content_language.dart';
import '../../lessons/application/lesson_providers.dart';
import '../../lessons/domain/lesson.dart';
import '../../../core/storage/key_value_store.dart';
import '../data/local_progress_repository.dart';
import '../domain/learning_progress.dart';

/// Şu anki zaman; testlerde sabitlenebilsin diye provider.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final progressRepositoryProvider = Provider<LocalProgressRepository>(
  (ref) => LocalProgressRepository(ref.watch(keyValueStoreProvider)),
);

/// LOCAL demo progress, persisted on this device (not account progress).
/// An explicit [initial] (tests) wins over the persisted value.
class ProgressNotifier extends Notifier<LearningProgress> {
  ProgressNotifier([this._initial]);

  final LearningProgress? _initial;

  @override
  LearningProgress build() =>
      _initial ?? ref.read(progressRepositoryProvider).load();

  DateTime get _now => ref.read(clockProvider)();

  void _set(LearningProgress next) {
    state = next;
    ref.read(progressRepositoryProvider).save(next);
  }

  List<ActivityEvent> _withEvent(ActivityEvent event) {
    final all = [...state.activity, event];
    final overflow = all.length - LearningProgress.maxActivityEvents;
    return overflow > 0 ? all.sublist(overflow) : all;
  }

  /// Marks a lesson completed (idempotent). Opening a lesson is NOT completion.
  /// [logActivity] is false when the completion is already represented by
  /// another recorded action (a passed quiz), so one learner action is
  /// never counted twice in the activity history.
  void completeLesson(String lessonId, {bool logActivity = true}) {
    if (state.isCompleted(lessonId)) return;
    final now = _now;
    _set(
      state.copyWith(
        completedLessons: {...state.completedLessons, lessonId: now},
        activity: !logActivity
            ? state.activity
            : _withEvent(
                ActivityEvent(
                  type: ActivityType.lessonCompleted,
                  refId: lessonId,
                  at: now,
                ),
              ),
      ),
    );
  }

  /// Keeps the best score and logs the attempt.
  void recordQuizScore(String lessonId, int percentage) {
    final best = math.max(state.quizScores[lessonId] ?? 0, percentage);
    _set(
      state.copyWith(
        quizScores: {...state.quizScores, lessonId: best},
        activity: _withEvent(
          ActivityEvent(
            type: ActivityType.quizCompleted,
            refId: lessonId,
            at: _now,
            score: percentage,
          ),
        ),
      ),
    );
  }

  /// Logs a vocabulary review (score = rating index).
  void recordReview(String itemId, int ratingIndex) {
    _set(
      state.copyWith(
        activity: _withEvent(
          ActivityEvent(
            type: ActivityType.vocabularyReviewed,
            refId: itemId,
            at: _now,
            score: ratingIndex,
          ),
        ),
      ),
    );
  }

  /// Remembers the last opened lesson for "continue" (no completion).
  void markOpened(String courseId, String lessonId) {
    final current = state.lastOpened;
    if (current != null &&
        current.courseId == courseId &&
        current.lessonId == lessonId) {
      return;
    }
    _set(
      state.copyWith(
        lastOpened: LastOpened(
          courseId: courseId,
          lessonId: lessonId,
          at: _now,
        ),
      ),
    );
  }

  void setDailyGoal(int lessons) {
    if (lessons < 1) return;
    _set(state.copyWith(dailyGoalLessons: lessons));
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, LearningProgress>(
  ProgressNotifier.new,
);

/// Öğrenme yolundaki sıradaki adım.
@immutable
class LearningStep {
  const LearningStep({
    required this.course,
    required this.lesson,
    required this.courseStarted,
  });

  final Course course;
  final Lesson lesson;

  /// Kursta daha önce en az bir ders tamamlanmış mı?
  final bool courseStarted;
}

/// Öğrenilen dildeki tamamlanmamış dersler, sırayla: önce başlanmış
/// kurslar, sonra seviye sırasıyla. İlk eleman "devam et", ikincisi
/// "sıradaki ders" olarak gösterilir.
final learningPathProvider = FutureProvider<List<LearningStep>>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  final target = ref.watch(targetLanguageCodeProvider);
  final progress = ref.watch(progressProvider);

  final candidates = [
    for (final course in courses)
      if ((target == null || course.languageCode == target) &&
          course.lessonCount > 0)
        course,
  ];
  bool started(Course c) =>
      progress.completedIn(c.lessonIds) > 0 &&
      progress.completedIn(c.lessonIds) < c.lessonCount;
  candidates.sort((a, b) {
    final byStarted = (started(b) ? 1 : 0) - (started(a) ? 1 : 0);
    return byStarted != 0 ? byStarted : a.level.index.compareTo(b.level.index);
  });

  final steps = <LearningStep>[];
  for (final course in candidates) {
    final lessons = await ref.watch(lessonsForCourseProvider(course.id).future);
    for (final lesson in lessons) {
      if (!progress.isCompleted(lesson.id)) {
        steps.add(
          LearningStep(
            course: course,
            lesson: lesson,
            courseStarted: progress.completedIn(course.lessonIds) > 0,
          ),
        );
      }
    }
  }
  return steps;
});
