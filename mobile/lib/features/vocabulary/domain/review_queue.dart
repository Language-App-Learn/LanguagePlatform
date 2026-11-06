import 'vocabulary_item.dart';
import 'vocabulary_record.dart';

/// Words due for review at [now], most overdue first.
List<VocabularyItem> dueItems(
  List<VocabularyItem> items,
  Map<String, VocabularyRecord> records,
  DateTime now,
) {
  final due = [
    for (final item in items)
      if (records[item.id]?.review.isDue(now) ?? false) item,
  ];
  due.sort(
    (a, b) =>
        records[a.id]!.review.dueAt!.compareTo(records[b.id]!.review.dueAt!),
  );
  return due;
}

/// A review session: all due words (most overdue first), then up to
/// [newLimit] never-reviewed words in their original order.
List<VocabularyItem> buildReviewQueue(
  List<VocabularyItem> items,
  Map<String, VocabularyRecord> records,
  DateTime now, {
  int newLimit = 5,
}) {
  final fresh = [
    for (final item in items)
      if (records[item.id]?.review.isNew ?? true) item,
  ].take(newLimit);
  return [...dueItems(items, records, now), ...fresh];
}
