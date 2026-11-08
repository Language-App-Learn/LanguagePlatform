import '../domain/vocabulary_item.dart';
import '../domain/vocabulary_repository.dart';
import 'demo_vocabulary_data.dart';

/// Yerel DEMO verisi. Gerçek sözlük/backend uygulaması aynı arayüzü
/// uygulayıp provider'da bunun yerine geçecek.
class DemoVocabularyRepository implements VocabularyRepository {
  const DemoVocabularyRepository();

  @override
  Future<List<VocabularyItem>> getAll() async => demoVocabulary;
}
