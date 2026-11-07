import 'package:flutter/foundation.dart';

import 'review_scheduler.dart';
import 'vocabulary_item.dart';

/// The learner's LOCAL state for one word (status, favorite, review state).
@immutable
class VocabularyRecord {
  const VocabularyRecord({
    this.status = VocabularyStatus.fresh,
    this.favorite = false,
    this.review = const ReviewState(),
  });

  final VocabularyStatus status;
  final bool favorite;
  final ReviewState review;

  VocabularyRecord copyWith({
    VocabularyStatus? status,
    bool? favorite,
    ReviewState? review,
  }) => VocabularyRecord(
    status: status ?? this.status,
    favorite: favorite ?? this.favorite,
    review: review ?? this.review,
  );
}
