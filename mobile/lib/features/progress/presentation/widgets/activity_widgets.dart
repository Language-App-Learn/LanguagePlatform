import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/mini_bar_chart.dart';
import '../../../../core/design_system/widgets/stat_tile.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../vocabulary/application/review_session.dart';
import '../../../vocabulary/application/vocabulary_providers.dart';
import '../../../vocabulary/domain/vocabulary_item.dart';
import '../../application/progress_providers.dart';

/// Last 7 days of RECORDED activity (lessons, quizzes, reviews) and streak.
/// Empty until the learner actually does something.
class WeeklyActivityCard extends ConsumerWidget {
  const WeeklyActivityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final progress = ref.watch(progressProvider);
    final counts = progress.dailyActivity(now);
    final streak = progress.currentStreak(now);
    final weekdays = MaterialLocalizations.of(context).narrowWeekdays;
    // DateTime.weekday: Monday=1..Sunday=7; narrowWeekdays is Sunday-first.
    final labels = [
      for (var i = 6; i >= 0; i--)
        weekdays[now.subtract(Duration(days: i)).weekday % 7],
    ];
    final total = counts.fold<int>(0, (a, b) => a + b);

    return AppCard(
      key: const ValueKey('weekly-activity'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.weeklyActivityTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (streak > 0)
                Chip(
                  key: const ValueKey('streak'),
                  avatar: const Icon(
                    Icons.local_fire_department_outlined,
                    size: AppSizes.iconSm,
                  ),
                  label: Text(l10n.activityStreak(streak)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (total == 0)
            Text(
              l10n.activityNone,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            MiniBarChart(
              values: counts,
              labels: labels,
              semanticLabel: l10n.weeklyActivityTitle,
            ),
        ],
      ),
    );
  }
}

/// Learned / learning / due-for-review totals from the persisted records.
class VocabularySummaryRow extends ConsumerWidget {
  const VocabularySummaryRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final records = ref.watch(vocabularyRecordsProvider);
    final due = ref.watch(dueReviewCountProvider);
    int count(VocabularyStatus s) =>
        records.values.where((r) => r.status == s).length;

    return Row(
      key: const ValueKey('vocabulary-summary'),
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.check_circle_outline,
            value: '${count(VocabularyStatus.learned)}',
            label: l10n.statWordsLearned,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatTile(
            icon: Icons.autorenew,
            value: '${count(VocabularyStatus.learning)}',
            label: l10n.statWordsLearning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatTile(
            icon: Icons.schedule,
            value: '$due',
            label: l10n.statReviewsDue,
          ),
        ),
      ],
    );
  }
}
