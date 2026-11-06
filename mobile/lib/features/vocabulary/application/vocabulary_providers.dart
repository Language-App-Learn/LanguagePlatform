import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../language_selection/application/content_language.dart';
import '../data/demo_vocabulary_repository.dart';
import '../data/local_vocabulary_store.dart';
import '../domain/review_scheduler.dart';
import '../domain/vocabulary_item.dart';
import '../domain/vocabulary_record.dart';
import '../domain/vocabulary_repository.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>(
  (ref) => const DemoVocabularyRepository(),
);

final vocabularyProvider = FutureProvider<List<VocabularyItem>>(
  (ref) => ref.watch(vocabularyRepositoryProvider).getAll(),
);

/// Words in the target language (all words when no target is chosen).
final targetVocabularyProvider = Provider<AsyncValue<List<VocabularyItem>>>((
  ref,
) {
  final target = ref.watch(targetLanguageCodeProvider);
  return ref.watch(vocabularyProvider).whenData((items) {
    return [
      for (final item in items)
        if (target == null || item.languageCode == target) item,
    ];
  });
});

final vocabularyStoreProvider = Provider<LocalVocabularyStore>(
  (ref) => LocalVocabularyStore(ref.watch(keyValueStoreProvider)),
);

/// Per-word LOCAL learner state, persisted on this device.
/// An explicit [initial] (tests) wins over the persisted value.
class VocabularyRecordsNotifier
    extends Notifier<Map<String, VocabularyRecord>> {
  VocabularyRecordsNotifier([this._initial]);

  final Map<String, VocabularyRecord>? _initial;

  @override
  Map<String, VocabularyRecord> build() =>
      _initial ?? ref.read(vocabularyStoreProvider).load();

  void _set(Map<String, VocabularyRecord> next) {
    state = next;
    ref.read(vocabularyStoreProvider).save(next);
  }

  VocabularyRecord _of(String id) => state[id] ?? const VocabularyRecord();

  void setStatus(String itemId, VocabularyStatus status) =>
      _set({...state, itemId: _of(itemId).copyWith(status: status)});

  void toggleFavorite(String itemId) => _set({
    ...state,
    itemId: _of(itemId).copyWith(favorite: !_of(itemId).favorite),
  });

  /// Applies a review rating at [now]; a new word becomes "learning" and a
  /// word reaching box 4+ is marked "learned".
  void applyReview(String itemId, ReviewRating rating, DateTime now) {
    final current = _of(itemId);
    final review = ReviewScheduler.next(current.review, rating, now);
    var status = current.status;
    if (status == VocabularyStatus.fresh) status = VocabularyStatus.learning;
    if (review.box >= 4) status = VocabularyStatus.learned;
    _set({...state, itemId: current.copyWith(status: status, review: review)});
  }
}

final vocabularyRecordsProvider =
    NotifierProvider<VocabularyRecordsNotifier, Map<String, VocabularyRecord>>(
      VocabularyRecordsNotifier.new,
    );

extension VocabularyRecordLookup on Map<String, VocabularyRecord> {
  VocabularyRecord recordOf(String itemId) =>
      this[itemId] ?? const VocabularyRecord();

  VocabularyStatus statusOf(String itemId) => recordOf(itemId).status;
}
