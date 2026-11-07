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

  /// Problems that make this question unusable (empty = valid). Malformed
  /// questions must be dropped by repositories/controllers, never shown.
  List<String> get validationIssues;

  bool get isValid => validationIssues.isEmpty;
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

  @override
  List<String> get validationIssues {
    final ids = options.map((o) => o.id).toList();
    return [
      if (id.isEmpty) 'empty id',
      if (options.length < 2) 'fewer than 2 options',
      if (ids.toSet().length != ids.length) 'duplicate option ids',
      if (!ids.contains(correctOptionId)) 'correct option missing',
    ];
  }
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

/// Statement the learner marks as true or false. Scoring: all-or-nothing.
final class TrueFalseQuestion extends QuizQuestion {
  const TrueFalseQuestion({
    required super.id,
    required super.prompt,
    required this.correctAnswer,
    this.explanation,
  });

  final bool correctAnswer;
  final LocalizedText? explanation;

  @override
  bool isCorrect(QuizAnswer answer) =>
      answer is TrueFalseAnswer &&
      answer.questionId == id &&
      answer.value == correctAnswer;

  @override
  List<String> get validationIssues => [if (id.isEmpty) 'empty id'];

  /// The same question as two choices (`true` / `false`), so one choice UI
  /// serves both types. Labels are supplied by the UI layer (localized).
  MultipleChoiceQuestion asChoices({
    required LocalizedText trueLabel,
    required LocalizedText falseLabel,
  }) => MultipleChoiceQuestion(
    id: id,
    prompt: prompt,
    options: [
      QuizOption(id: 'true', text: trueLabel),
      QuizOption(id: 'false', text: falseLabel),
    ],
    correctOptionId: correctAnswer ? 'true' : 'false',
    explanation: explanation,
  );
}

final class TrueFalseAnswer extends QuizAnswer {
  const TrueFalseAnswer(super.questionId, this.value);

  final bool value;
}
