import '../../../core/l10n/localized_text.dart';
import '../../lessons/domain/lesson.dart';
import '../../lessons/domain/lesson_repository.dart';
import '../../vocabulary/domain/vocabulary_item.dart';
import '../../vocabulary/domain/vocabulary_repository.dart';
import '../domain/quiz.dart';
import '../domain/quiz_repository.dart';

/// DEMO quiz üretici: dersin alıştırma sorularına ek olarak dersin
/// kelimelerinden "Bu kelime ne anlama gelir?" soruları üretir. Soru metni
/// şablonu içerik olarak üç dilde tutulur.
class DemoQuizRepository implements QuizRepository {
  const DemoQuizRepository({
    required this.lessons,
    required this.vocabulary,
    this.maxVocabularyQuestions = 4,
  });

  final LessonRepository lessons;
  final VocabularyRepository vocabulary;
  final int maxVocabularyQuestions;

  @override
  Future<List<QuizQuestion>> getQuestions(String lessonId) async {
    final lesson = await lessons.getLesson(lessonId);
    final pool = [
      for (final item in await vocabulary.getAll())
        if (item.languageCode == lesson.languageCode) item,
    ];
    final byId = {for (final item in pool) item.id: item};
    final items = [
      for (final id in lesson.vocabularyIds)
        if (byId[id] != null) byId[id]!,
    ].take(maxVocabularyQuestions);

    return [
      for (final content in lesson.contents)
        if (content is ExerciseContent) content.question,
      for (final (index, item) in items.indexed)
        _meaningQuestion(item, pool, index),
    ];
  }

  /// "X ne demek?" sorusu. Çeldiriciler aynı dilin diğer kelimelerinden
  /// deterministik seçilir; doğru şık konumu soru sırasına göre döner.
  MultipleChoiceQuestion _meaningQuestion(
    VocabularyItem item,
    List<VocabularyItem> pool,
    int index,
  ) {
    final others = [
      for (final other in pool)
        if (other.id != item.id) other,
    ];
    final start = pool.indexWhere((e) => e.id == item.id);
    final distractors = <VocabularyItem>[
      for (var i = 0; i < others.length && i < 2; i++)
        others[(start + i) % others.length],
    ];
    final options = [
      QuizOption(id: item.id, text: item.meaning),
      for (final d in distractors) QuizOption(id: d.id, text: d.meaning),
    ];
    final shift = index % options.length;
    final rotated = [...options.sublist(shift), ...options.sublist(0, shift)];

    return MultipleChoiceQuestion(
      id: 'meaning-${item.id}',
      prompt: LocalizedText({
        'tr': '“${item.term}” ne anlama gelir?',
        'ar': 'ما معنى «${item.term}»؟',
        'en': 'What does “${item.term}” mean?',
      }),
      options: rotated,
      correctOptionId: item.id,
    );
  }
}
