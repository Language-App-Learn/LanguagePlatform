import 'quiz.dart';

abstract interface class QuizRepository {
  /// Dersin quiz soruları. Ders yoksa `NotFoundException` fırlatır.
  Future<List<QuizQuestion>> getQuestions(String lessonId);
}
