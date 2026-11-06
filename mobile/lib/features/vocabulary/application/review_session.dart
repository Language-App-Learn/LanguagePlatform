import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../language_selection/application/content_language.dart';
import '../../progress/application/progress_providers.dart';
import '../domain/review_queue.dart';
import '../domain/review_scheduler.dart';
import '../domain/vocabulary_item.dart';
import 'vocabulary_providers.dart';

/// Number of target-language words due right now (new words not counted).
final dueReviewCountProvider = Provider<int>((ref) {
  final words = ref.watch(targetVocabularyProvider).value ?? const [];
  final records = ref.watch(vocabularyRecordsProvider);
  return dueItems(words, records, ref.watch(clockProvider)()).length;
});

@immutable
class ReviewSessionState {
  const ReviewSessionState({
    required this.queue,
    this.index = 0,
    this.revealed = false,
    this.ratings = const {},
  });

  final List<VocabularyItem> queue;
  final int index;

  /// Whether the back of the current card is visible.
  final bool revealed;
  final Map<ReviewRating, int> ratings;

  bool get isFinished => index >= queue.length;
  VocabularyItem get current => queue[index];
  int get reviewed => ratings.values.fold(0, (a, b) => a + b);

  ReviewSessionState copyWith({
    int? index,
    bool? revealed,
    Map<ReviewRating, int>? ratings,
  }) => ReviewSessionState(
    queue: queue,
    index: index ?? this.index,
    revealed: revealed ?? this.revealed,
    ratings: ratings ?? this.ratings,
  );
}

/// Flashcard review session. The queue is a snapshot taken when the session
/// starts, so ratings do not reshuffle the cards mid-session.
class ReviewSessionController extends AsyncNotifier<ReviewSessionState> {
  @override
  Future<ReviewSessionState> build() async {
    final all = await ref.watch(vocabularyProvider.future);
    final target = ref.read(targetLanguageCodeProvider);
    final words = [
      for (final item in all)
        if (target == null || item.languageCode == target) item,
    ];
    return ReviewSessionState(
      queue: buildReviewQueue(
        words,
        ref.read(vocabularyRecordsProvider),
        ref.read(clockProvider)(),
      ),
    );
  }

  void reveal() {
    final s = state.value;
    if (s == null || s.isFinished || s.revealed) return;
    state = AsyncData(s.copyWith(revealed: true));
  }

  /// Rates the current card (only after it was revealed), persists the new
  /// schedule and records a vocabulary activity event.
  void rate(ReviewRating rating) {
    final s = state.value;
    if (s == null || s.isFinished || !s.revealed) return;
    final id = s.current.id;
    ref
        .read(vocabularyRecordsProvider.notifier)
        .applyReview(id, rating, ref.read(clockProvider)());
    ref.read(progressProvider.notifier).recordReview(id, rating.index);
    state = AsyncData(
      s.copyWith(
        index: s.index + 1,
        revealed: false,
        ratings: {...s.ratings, rating: (s.ratings[rating] ?? 0) + 1},
      ),
    );
  }
}

final reviewSessionProvider =
    AsyncNotifierProvider.autoDispose<
      ReviewSessionController,
      ReviewSessionState
    >(ReviewSessionController.new);
