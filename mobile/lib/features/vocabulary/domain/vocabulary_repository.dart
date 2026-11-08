import 'vocabulary_item.dart';

abstract interface class VocabularyRepository {
  Future<List<VocabularyItem>> getAll();
}
