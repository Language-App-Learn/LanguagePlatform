import '../../../core/storage/key_value_store.dart';
import '../domain/review_scheduler.dart';
import '../domain/vocabulary_item.dart';
import '../domain/vocabulary_record.dart';

/// Persists per-word learner state as one versioned JSON document.
/// Corrupted or unknown-version data yields an empty map; bad entries are
/// skipped individually.
class LocalVocabularyStore {
  LocalVocabularyStore(this._store);

  final KeyValueStore _store;

  static const storageKey = 'lp.vocabulary';
  static const schemaVersion = 1;

  Map<String, VocabularyRecord> load() {
    final json = readJsonObject(_store, storageKey);
    if (json == null) return const {};
    final version = json['v'];
    if (version is int && version > schemaVersion) return const {};
    final items = json['items'];
    if (items is! Map) return const {};
    final result = <String, VocabularyRecord>{};
    for (final entry in items.entries) {
      final value = entry.value;
      if (entry.key is! String || value is! Map) continue;
      final status = VocabularyStatus.values.asNameMap()[value['status']];
      final review = value['review'];
      result[entry.key as String] = VocabularyRecord(
        status: status ?? VocabularyStatus.fresh,
        favorite: value['favorite'] == true,
        review: review is Map ? _review(review) : const ReviewState(),
      );
    }
    return result;
  }

  Future<void> save(Map<String, VocabularyRecord> records) => writeJsonObject(
    _store,
    storageKey,
    {
      'v': schemaVersion,
      'items': {
        for (final e in records.entries)
          e.key: {
            'status': e.value.status.name,
            'favorite': e.value.favorite,
            'review': {
              'box': e.value.review.box,
              'due': e.value.review.dueAt?.toUtc().toIso8601String(),
              'last': e.value.review.lastReviewedAt?.toUtc().toIso8601String(),
              'n': e.value.review.reviews,
              'lapses': e.value.review.lapses,
            },
          },
      },
    },
  );

  static ReviewState _review(Map<Object?, Object?> m) {
    DateTime? date(Object? v) =>
        v is String ? DateTime.tryParse(v)?.toLocal() : null;
    int count(Object? v) => v is int && v >= 0 ? v : 0;
    final box = m['box'];
    return ReviewState(
      box: box is int ? box.clamp(0, ReviewScheduler.maxBox) : 0,
      dueAt: date(m['due']),
      lastReviewedAt: date(m['last']),
      reviews: count(m['n']),
      lapses: count(m['lapses']),
    );
  }
}
