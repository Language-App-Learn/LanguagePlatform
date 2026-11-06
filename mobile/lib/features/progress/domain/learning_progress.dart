import 'package:flutter/foundation.dart';

/// Öğrencinin YEREL demo ilerlemesi. Hesaba bağlı kalıcı ilerleme değildir:
/// backend yok, uygulama kapanınca sıfırlanır.
///
/// Backend sözleşmesi bilinmiyor: ilerleme olaylarının (ders tamamlama,
/// quiz sonucu) hangi uçlara nasıl gönderileceği netleşince
/// `ProgressRepository` ile eşlenecek.
@immutable
class LearningProgress {
  const LearningProgress({
    this.completedLessons = const {},
    this.quizScores = const {},
    this.dailyGoalLessons = defaultDailyGoal,
  });

  static const int defaultDailyGoal = 1;
  static const List<int> dailyGoalOptions = [1, 2, 3, 5];

  /// Ders kimliği → tamamlanma zamanı.
  final Map<String, DateTime> completedLessons;

  /// Ders kimliği → en iyi quiz yüzdesi.
  final Map<String, int> quizScores;

  /// Günlük hedef (ders sayısı).
  final int dailyGoalLessons;

  bool isCompleted(String lessonId) => completedLessons.containsKey(lessonId);

  int get completedCount => completedLessons.length;

  /// Verilen derslerden kaçı tamamlandı.
  int completedIn(Iterable<String> lessonIds) =>
      lessonIds.where(isCompleted).length;

  /// Verilen derslerin tamamlanma oranı (0..1). Ders yoksa 0.
  double fractionIn(List<String> lessonIds) =>
      lessonIds.isEmpty ? 0 : completedIn(lessonIds) / lessonIds.length;

  /// [now] gününde tamamlanan ders sayısı.
  int completedOn(DateTime now) => completedLessons.values
      .where(
        (d) => d.year == now.year && d.month == now.month && d.day == now.day,
      )
      .length;

  /// Günlük hedefe oran (0..1, üst sınır 1).
  double dailyGoalFraction(DateTime now) =>
      (completedOn(now) / dailyGoalLessons).clamp(0.0, 1.0);

  /// Quiz yapılmış derslerin ortalama yüzdesi; hiç yoksa `null`.
  int? get averageQuizScore {
    if (quizScores.isEmpty) return null;
    final total = quizScores.values.fold<int>(0, (a, b) => a + b);
    return (total / quizScores.length).round();
  }

  LearningProgress copyWith({
    Map<String, DateTime>? completedLessons,
    Map<String, int>? quizScores,
    int? dailyGoalLessons,
  }) {
    return LearningProgress(
      completedLessons: completedLessons ?? this.completedLessons,
      quizScores: quizScores ?? this.quizScores,
      dailyGoalLessons: dailyGoalLessons ?? this.dailyGoalLessons,
    );
  }
}
