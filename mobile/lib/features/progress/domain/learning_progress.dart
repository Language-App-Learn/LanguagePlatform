import 'package:flutter/foundation.dart';

enum ActivityType { lessonCompleted, quizCompleted, vocabularyReviewed }

/// One recorded learning action (local demo history).
@immutable
class ActivityEvent {
  const ActivityEvent({
    required this.type,
    required this.refId,
    required this.at,
    this.score,
  });

  final ActivityType type;

  /// Lesson id, or vocabulary item id for reviews.
  final String refId;
  final DateTime at;

  /// Quiz percentage, or review rating index; `null` when not applicable.
  final int? score;
}

@immutable
class LastOpened {
  const LastOpened({
    required this.courseId,
    required this.lessonId,
    required this.at,
  });

  final String courseId;
  final String lessonId;
  final DateTime at;
}

/// The learner's LOCAL demo progress (persisted on this device only).
///
/// It is not account progress. Backend contract unknown: how progress events
/// (lesson completion, quiz results, reviews) are sent and reconciled with a
/// server-authoritative record is undecided; see PROJECT_STATUS.md.
@immutable
class LearningProgress {
  const LearningProgress({
    this.completedLessons = const {},
    this.quizScores = const {},
    this.dailyGoalLessons = defaultDailyGoal,
    this.lastOpened,
    this.activity = const [],
  });

  static const int defaultDailyGoal = 1;
  static const List<int> dailyGoalOptions = [1, 2, 3, 5];

  /// Max stored activity events (oldest are dropped).
  static const int maxActivityEvents = 500;

  /// Lesson id → completion time.
  final Map<String, DateTime> completedLessons;

  /// Lesson id → best quiz percentage.
  final Map<String, int> quizScores;

  /// Daily goal, in completed lessons.
  final int dailyGoalLessons;

  final LastOpened? lastOpened;

  /// Chronological (oldest first).
  final List<ActivityEvent> activity;

  bool isCompleted(String lessonId) => completedLessons.containsKey(lessonId);

  int get completedCount => completedLessons.length;

  int completedIn(Iterable<String> lessonIds) =>
      lessonIds.where(isCompleted).length;

  /// Completion ratio (0..1) of the given lessons; 0 when empty.
  double fractionIn(List<String> lessonIds) =>
      lessonIds.isEmpty ? 0 : completedIn(lessonIds) / lessonIds.length;

  /// Lessons completed on the calendar day of [now].
  int completedOn(DateTime now) =>
      completedLessons.values.where((d) => _sameDay(d, now)).length;

  /// Ratio of today's goal reached (0..1, capped).
  double dailyGoalFraction(DateTime now) =>
      (completedOn(now) / dailyGoalLessons).clamp(0.0, 1.0);

  /// Average of the best quiz scores; `null` when no quiz was taken.
  int? get averageQuizScore {
    if (quizScores.isEmpty) return null;
    final total = quizScores.values.fold<int>(0, (a, b) => a + b);
    return (total / quizScores.length).round();
  }

  /// Activity counts for each of the last [days] days, oldest first; the last
  /// entry is the day of [now].
  List<int> dailyActivity(DateTime now, {int days = 7}) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = days - 1; i >= 0; i--)
        activity
            .where(
              (e) => _sameDay(
                e.at,
                DateTime(today.year, today.month, today.day - i),
              ),
            )
            .length,
    ];
  }

  /// Consecutive local days with at least one recorded activity.
  ///
  /// The streak ends today; if there is no activity yet today but there was
  /// some yesterday, it still counts until today ends. Computed only from
  /// recorded events, never invented.
  int currentStreak(DateTime now) {
    final days = {
      for (final e in activity) DateTime(e.at.year, e.at.month, e.at.day),
    };
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }

  LearningProgress copyWith({
    Map<String, DateTime>? completedLessons,
    Map<String, int>? quizScores,
    int? dailyGoalLessons,
    LastOpened? lastOpened,
    List<ActivityEvent>? activity,
  }) {
    return LearningProgress(
      completedLessons: completedLessons ?? this.completedLessons,
      quizScores: quizScores ?? this.quizScores,
      dailyGoalLessons: dailyGoalLessons ?? this.dailyGoalLessons,
      lastOpened: lastOpened ?? this.lastOpened,
      activity: activity ?? this.activity,
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
