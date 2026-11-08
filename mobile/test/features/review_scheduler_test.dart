import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/localized_text.dart';
import 'package:language_platform/features/vocabulary/domain/review_queue.dart';
import 'package:language_platform/features/vocabulary/domain/review_scheduler.dart';
import 'package:language_platform/features/vocabulary/domain/vocabulary_item.dart';
import 'package:language_platform/features/vocabulary/domain/vocabulary_record.dart';

void main() {
  final now = DateTime(2026, 11, 6, 12);

  group('ReviewScheduler', () {
    test('new word: good → box 1, due in 1 day', () {
      final s = ReviewScheduler.next(
        const ReviewState(),
        ReviewRating.good,
        now,
      );
      expect(s.box, 1);
      expect(s.dueAt, now.add(const Duration(days: 1)));
      expect(s.reviews, 1);
      expect(s.lapses, 0);
      expect(s.lastReviewedAt, now);
    });

    test('easy jumps two boxes; box is capped at 5 (35 days)', () {
      var s = ReviewScheduler.next(const ReviewState(), ReviewRating.easy, now);
      expect(s.box, 2);
      for (var i = 0; i < 6; i++) {
        s = ReviewScheduler.next(s, ReviewRating.easy, now);
      }
      expect(s.box, ReviewScheduler.maxBox);
      expect(s.dueAt, now.add(const Duration(days: 35)));
    });

    test('again resets to box 0, due in 10 minutes, counts a lapse', () {
      const s = ReviewState(box: 3, reviews: 4);
      final r = ReviewScheduler.next(s, ReviewRating.again, now);
      expect(r.box, 0);
      expect(r.dueAt, now.add(const Duration(minutes: 10)));
      expect(r.lapses, 1);
      expect(r.reviews, 5);
    });

    test('hard goes one box down but never below 1', () {
      expect(
        ReviewScheduler.next(
          const ReviewState(box: 3),
          ReviewRating.hard,
          now,
        ).box,
        2,
      );
      expect(
        ReviewScheduler.next(const ReviewState(), ReviewRating.hard, now).box,
        1,
      );
    });

    test('deterministic: same input, same output', () {
      final a = ReviewScheduler.next(
        const ReviewState(box: 2),
        ReviewRating.good,
        now,
      );
      final b = ReviewScheduler.next(
        const ReviewState(box: 2),
        ReviewRating.good,
        now,
      );
      expect(a.box, b.box);
      expect(a.dueAt, b.dueAt);
    });

    test('isNew / isDue boundaries', () {
      expect(const ReviewState().isNew, isTrue);
      expect(const ReviewState().isDue(now), isFalse);
      final s = ReviewState(box: 1, dueAt: now);
      expect(s.isDue(now), isTrue); // due exactly now
      expect(s.isDue(now.subtract(const Duration(seconds: 1))), isFalse);
    });
  });

  group('review queue', () {
    VocabularyItem item(String id) => VocabularyItem(
      id: id,
      languageCode: 'ar',
      term: id,
      meaning: LocalizedText.plain(id),
    );

    test('due first (most overdue first), then limited new words', () {
      final items = [
        for (final id in ['a', 'b', 'c', 'd', 'e', 'f']) item(id),
      ];
      final records = {
        'b': VocabularyRecord(
          review: ReviewState(
            box: 1,
            dueAt: now.subtract(const Duration(days: 1)),
          ),
        ),
        'c': VocabularyRecord(
          review: ReviewState(
            box: 1,
            dueAt: now.subtract(const Duration(days: 3)),
          ),
        ),
        'd': VocabularyRecord(
          review: ReviewState(box: 1, dueAt: now.add(const Duration(days: 2))),
        ),
      };
      final queue = buildReviewQueue(items, records, now, newLimit: 2);
      // due: c (3d overdue), b (1d). d is not due. new: a, e (limit 2).
      expect(queue.map((i) => i.id), ['c', 'b', 'a', 'e']);
      expect(dueItems(items, records, now).map((i) => i.id), ['c', 'b']);
    });

    test('nothing to review when everything is scheduled in the future', () {
      final items = [item('a')];
      final records = {
        'a': VocabularyRecord(
          review: ReviewState(box: 2, dueAt: now.add(const Duration(days: 3))),
        ),
      };
      expect(buildReviewQueue(items, records, now), isEmpty);
    });
  });
}
