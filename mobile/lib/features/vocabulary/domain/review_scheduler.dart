import 'package:flutter/foundation.dart';

/// How well the learner recalled a word.
enum ReviewRating { again, hard, good, easy }

/// Spaced-repetition state of one word.
@immutable
class ReviewState {
  const ReviewState({
    this.box = 0,
    this.dueAt,
    this.lastReviewedAt,
    this.reviews = 0,
    this.lapses = 0,
  });

  /// Leitner box, 0..[ReviewScheduler.maxBox].
  final int box;

  /// When the word should be reviewed next; `null` = never reviewed (new).
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;
  final int reviews;

  /// Times the word was forgotten (rated `again`).
  final int lapses;

  bool get isNew => dueAt == null;

  bool isDue(DateTime now) => dueAt != null && !dueAt!.isAfter(now);
}

/// Deterministic Leitner-style scheduler (no randomness, no hidden clock).
///
/// Boxes 0..5 with fixed intervals: 10 min, 1 d, 3 d, 7 d, 16 d, 35 d.
/// - `again`: back to box 0, due in 10 minutes, lapse counted.
/// - `hard` : one box down (but at least box 1), so it returns sooner.
/// - `good` : one box up.
/// - `easy` : two boxes up.
/// The next due time is `now + interval(newBox)`. Time is always passed in,
/// so behaviour is fully testable.
abstract final class ReviewScheduler {
  static const int maxBox = 5;

  static const List<Duration> intervals = [
    Duration(minutes: 10),
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 16),
    Duration(days: 35),
  ];

  static ReviewState next(
    ReviewState current,
    ReviewRating rating,
    DateTime now,
  ) {
    final box = switch (rating) {
      ReviewRating.again => 0,
      ReviewRating.hard => (current.box - 1).clamp(1, maxBox),
      ReviewRating.good => (current.box + 1).clamp(0, maxBox),
      ReviewRating.easy => (current.box + 2).clamp(0, maxBox),
    };
    return ReviewState(
      box: box,
      dueAt: now.add(intervals[box]),
      lastReviewedAt: now,
      reviews: current.reviews + 1,
      lapses: current.lapses + (rating == ReviewRating.again ? 1 : 0),
    );
  }
}
