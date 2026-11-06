import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../lessons/application/lesson_providers.dart';
import '../../progress/application/progress_providers.dart';
import '../../vocabulary/application/vocabulary_providers.dart';
import '../data/demo_quiz_repository.dart';
import '../domain/quiz.dart';
import '../domain/quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => DemoQuizRepository(
    lessons: ref.watch(lessonRepositoryProvider),
    vocabulary: ref.watch(vocabularyRepositoryProvider),
  ),
);

final quizQuestionsProvider = FutureProvider.family<List<QuizQuestion>, String>(
  (ref, lessonId) => ref.watch(quizRepositoryProvider).getQuestions(lessonId),
);

/// Bir quiz oturumunun anlık durumu.
@immutable
class QuizState {
  const QuizState({
    required this.lessonId,
    required this.questions,
    this.index = 0,
    this.selected,
    this.checked = false,
    this.answers = const [],
    this.result,
  });

  final String lessonId;
  final List<QuizQuestion> questions;
  final int index;

  /// Henüz kontrol edilmemiş seçim.
  final QuizAnswer? selected;
  final bool checked;

  /// Kontrol edilmiş cevaplar (soru sırasıyla).
  final List<QuizAnswer> answers;
  final QuizResult? result;

  bool get isEmpty => questions.isEmpty;
  QuizQuestion get current => questions[index];
  bool get isLast => index == questions.length - 1;
  bool get isFinished => result != null;
  bool get isCurrentCorrect =>
      checked && selected != null && current.isCorrect(selected!);

  QuizState copyWith({
    int? index,
    QuizAnswer? selected,
    bool clearSelected = false,
    bool? checked,
    List<QuizAnswer>? answers,
    QuizResult? result,
  }) {
    return QuizState(
      lessonId: lessonId,
      questions: questions,
      index: index ?? this.index,
      selected: clearSelected ? null : (selected ?? this.selected),
      checked: checked ?? this.checked,
      answers: answers ?? this.answers,
      result: result ?? this.result,
    );
  }
}

/// Quiz motoru: soru türünden bağımsızdır (`QuizQuestion.isCorrect`).
/// Sonuç yalnızca yerel demo ilerlemesine yazılır; sunucuya kaydedilmez.
class QuizController extends AsyncNotifier<QuizState> {
  QuizController(this.lessonId);

  final String lessonId;

  @override
  Future<QuizState> build() async {
    // Malformed questions fail safe: they are dropped, never presented.
    final questions = [
      for (final q in await ref.watch(quizQuestionsProvider(lessonId).future))
        if (q.isValid) q,
    ];
    return QuizState(lessonId: lessonId, questions: questions);
  }

  QuizState? get _current => state.value;

  void select(QuizAnswer answer) {
    final s = _current;
    if (s == null || s.checked || s.isFinished || s.isEmpty) return;
    state = AsyncData(s.copyWith(selected: answer));
  }

  /// Seçimi kontrol eder; sonuç `isCurrentCorrect` ile okunur.
  void check() {
    final s = _current;
    if (s == null || s.checked || s.selected == null || s.isEmpty) return;
    state = AsyncData(
      s.copyWith(checked: true, answers: [...s.answers, s.selected!]),
    );
  }

  /// Sonraki soruya geçer; son soruysa sonucu hesaplar ve ilerlemeye yazar.
  void next() {
    final s = _current;
    if (s == null || !s.checked || s.isFinished) return;
    if (!s.isLast) {
      state = AsyncData(
        s.copyWith(index: s.index + 1, clearSelected: true, checked: false),
      );
      return;
    }
    final byId = {for (final q in s.questions) q.id: q};
    final correct = s.answers
        .where((a) => byId[a.questionId]?.isCorrect(a) ?? false)
        .length;
    final result = QuizResult(
      lessonId: lessonId,
      totalQuestions: s.questions.length,
      correctAnswers: correct,
    );
    final progress = ref.read(progressProvider.notifier);
    progress.recordQuizScore(lessonId, result.percentage);
    if (result.passed) progress.completeLesson(lessonId, logActivity: false);
    state = AsyncData(s.copyWith(result: result));
  }

  void restart() {
    final s = _current;
    if (s == null) return;
    state = AsyncData(QuizState(lessonId: lessonId, questions: s.questions));
  }
}

final quizControllerProvider = AsyncNotifierProvider.autoDispose
    .family<QuizController, QuizState, String>(QuizController.new);
