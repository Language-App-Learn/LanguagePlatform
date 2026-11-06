import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';

/// Quiz soru modeli. Yeni soru türü eklemek için [QuizQuestion] ve
/// [QuizAnswer] alt sınıfları eklenir; değerlendirme sorunun kendisindedir
/// (`isCorrect`), böylece quiz motoru türden bağımsız kalır.
///
/// Backend sözleşmesi netleşince soru/cevap DTO eşlemesi `data/` içinde
/// yapılacaktır (soru türü ayırt edici alanı henüz bilinmiyor).
@immutable
sealed class QuizQuestion {
  const QuizQuestion({required this.id, required this.prompt});

  final String id;
  final LocalizedText prompt;

  bool isCorrect(QuizAnswer answer);
}

@immutable
class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final LocalizedText text;
}

/// Çoktan seçmeli, tek doğru cevaplı soru.
final class MultipleChoiceQuestion extends QuizQuestion {
  const MultipleChoiceQuestion({
    required super.id,
    required super.prompt,
    required this.options,
    required this.correctOptionId,
    this.explanation,
  });

  final List<QuizOption> options;
  final String correctOptionId;

  /// Cevap kontrolünden sonra gösterilen kısa açıklama.
  final LocalizedText? explanation;

  @override
  bool isCorrect(QuizAnswer answer) =>
      answer is MultipleChoiceAnswer &&
      answer.questionId == id &&
      answer.optionId == correctOptionId;
}

@immutable
sealed class QuizAnswer {
  const QuizAnswer(this.questionId);

  final String questionId;
}

final class MultipleChoiceAnswer extends QuizAnswer {
  const MultipleChoiceAnswer(super.questionId, this.optionId);

  final String optionId;
}

/// Tamamlanan bir quiz'in özeti. Yalnızca yerel demo verisidir; sunucuya
/// kaydedilmez.
@immutable
class QuizResult {
  const QuizResult({
    required this.lessonId,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  /// Başarı için gereken yüzde.
  static const int passingPercentage = 70;

  final String lessonId;
  final int totalQuestions;
  final int correctAnswers;

  int get percentage =>
      totalQuestions == 0 ? 0 : (correctAnswers * 100 / totalQuestions).round();

  bool get passed => percentage >= passingPercentage;
}
