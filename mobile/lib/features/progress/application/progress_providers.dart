import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../courses/application/course_providers.dart';
import '../../courses/domain/course.dart';
import '../../language_selection/application/content_language.dart';
import '../../lessons/application/lesson_providers.dart';
import '../../lessons/domain/lesson.dart';
import '../domain/learning_progress.dart';

/// Şu anki zaman; testlerde sabitlenebilsin diye provider.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Yerel DEMO ilerleme. Backend olmadan hesaba bağlı kalıcı ilerleme yoktur.
class ProgressNotifier extends Notifier<LearningProgress> {
  ProgressNotifier([this._initial = const LearningProgress()]);

  final LearningProgress _initial;

  @override
  LearningProgress build() => _initial;

  void completeLesson(String lessonId) {
    if (state.isCompleted(lessonId)) return;
    state = state.copyWith(
      completedLessons: {
        ...state.completedLessons,
        lessonId: ref.read(clockProvider)(),
      },
    );
  }

  /// En iyi sonucu saklar.
  void recordQuizScore(String lessonId, int percentage) {
    final best = math.max(state.quizScores[lessonId] ?? 0, percentage);
    state = state.copyWith(quizScores: {...state.quizScores, lessonId: best});
  }

  void setDailyGoal(int lessons) {
    if (lessons < 1) return;
    state = state.copyWith(dailyGoalLessons: lessons);
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
