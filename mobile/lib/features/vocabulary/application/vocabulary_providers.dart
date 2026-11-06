import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../language_selection/application/content_language.dart';
import '../data/demo_vocabulary_repository.dart';
import '../domain/vocabulary_item.dart';
import '../domain/vocabulary_repository.dart';

final vocabularyRepositoryProvider = Provider<VocabularyRepository>(
  (ref) => const DemoVocabularyRepository(),
);

final vocabularyProvider = FutureProvider<List<VocabularyItem>>(
  (ref) => ref.watch(vocabularyRepositoryProvider).getAll(),
);

/// Öğrenilen dildeki kelimeler (dil seçilmediyse hepsi).
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

/// Kelime öğrenme durumları (yerel demo; kalıcı değil).
class VocabularyStatusNotifier extends Notifier<Map<String, VocabularyStatus>> {
  VocabularyStatusNotifier([this._initial = const {}]);

  final Map<String, VocabularyStatus> _initial;

  @override
  Map<String, VocabularyStatus> build() => _initial;

  void setStatus(String itemId, VocabularyStatus status) {
    state = {...state, itemId: status};
  }
}

final vocabularyStatusProvider =
    NotifierProvider<VocabularyStatusNotifier, Map<String, VocabularyStatus>>(
      VocabularyStatusNotifier.new,
    );

extension VocabularyStatusLookup on Map<String, VocabularyStatus> {
  VocabularyStatus statusOf(String itemId) =>
      this[itemId] ?? VocabularyStatus.fresh;
}
