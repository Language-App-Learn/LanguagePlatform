import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../progress/application/progress_providers.dart';
import '../../../progress/domain/learning_progress.dart';
import '../../application/vocabulary_providers.dart';
import '../../domain/review_scheduler.dart';
import '../../domain/vocabulary_item.dart';

/// Newest-first list of flashcard reviews, built only from RECORDED review
/// activity. "Next review" is the word's current schedule, so it can differ
/// from what was scheduled at the time of an older review.
class ReviewHistoryPage extends ConsumerWidget {
  const ReviewHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final events = ref.watch(
      progressProvider.select(
        (p) => [
          for (final e in p.activity.reversed)
            if (e.type == ActivityType.vocabularyReviewed) e,
        ],
      ),
    );
    final words = {
      for (final w in ref.watch(vocabularyProvider).value ?? const []) w.id: w,
    };
    final records = ref.watch(vocabularyRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewHistoryTitle)),
      body: SafeArea(
        child: events.isEmpty
            ? EmptyStateView(
                icon: Icons.history,
                title: l10n.reviewHistoryEmptyTitle,
                message: l10n.reviewHistoryEmptyMessage,
              )
            : ContentWidth(
                child: ListView.separated(
                  padding: AppSpacing.page,
                  itemCount: events.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _HistoryTile(
                    event: events[i],
                    word: words[events[i].refId],
                    nextReview: records[events[i].refId]?.review.dueAt,
                  ),
                ),
              ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.event,
    required this.word,
    required this.nextReview,
  });

  final ActivityEvent event;
  final VocabularyItem? word;
  final DateTime? nextReview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    String stamp(DateTime d) =>
        '${material.formatShortDate(d)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(d))}';

    final rating = ReviewRating.values.elementAtOrNull(event.score ?? -1);
    final ratingLabel = switch (rating) {
      ReviewRating.again => l10n.ratingAgain,
      ReviewRating.hard => l10n.ratingHard,
      ReviewRating.good => l10n.ratingGood,
      ReviewRating.easy => l10n.ratingEasy,
      null => '',
    };

    return AppCard(
      key: ValueKey(
        'history:${event.refId}:${event.at.microsecondsSinceEpoch}',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: word == null
                    ? Text(
                        l10n.historyUnknownWord,
                        style: theme.textTheme.titleSmall,
                      )
                    : ContentText(
                        word!.term,
                        languageCode: word!.languageCode,
                        style: theme.textTheme.titleLarge,
                      ),
              ),
              if (ratingLabel.isNotEmpty)
                Chip(
                  key: ValueKey('history-rating:${rating!.name}'),
                  label: Text(ratingLabel),
                ),
            ],
          ),
          Text(stamp(event.at), style: theme.textTheme.bodySmall),
          if (nextReview != null)
            Text(
              l10n.historyNextReview(stamp(nextReview!)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
