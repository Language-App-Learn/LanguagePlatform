import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../progress/application/progress_providers.dart';

/// Günlük hedef: bugün tamamlanan ders / hedef.
class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final now = ref.watch(clockProvider)();
    final progress = ref.watch(progressProvider);
    final done = progress.completedOn(now);
    final goal = progress.dailyGoalLessons;
    final reached = done >= goal;

    return AppCard(
      color: reached ? semantic.successContainer : semantic.accentContainer,
      child: Row(
        children: [
          Icon(
            reached ? Icons.emoji_events : Icons.flag_outlined,
            color: reached ? semantic.success : semantic.onAccentContainer,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reached ? l10n.homeGoalReached : l10n.homeDailyGoalTitle,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  l10n.homeDailyGoalProgress(done, goal),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppProgressBar(
                  value: progress.dailyGoalFraction(now),
                  color: reached ? semantic.success : semantic.accent,
                  semanticLabel: l10n.homeDailyGoalProgress(done, goal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
