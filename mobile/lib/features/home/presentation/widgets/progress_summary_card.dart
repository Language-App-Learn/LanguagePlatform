import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/design_system/widgets/stat_tile.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../progress/application/progress_providers.dart';

/// Kısa ilerleme görünümü; ayrıntı için İlerleme sekmesine gider.
class ProgressSummaryCard extends ConsumerWidget {
  const ProgressSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress = ref.watch(progressProvider);
    final average = progress.averageQuizScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.homeProgressTitle,
          actionLabel: l10n.viewAll,
          onAction: () => context.go(AppRoutes.progress),
        ),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.task_alt,
                value: '${progress.completedCount}',
                label: l10n.progressCompletedLessons,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                icon: Icons.emoji_events_outlined,
                value: average == null ? '–' : '$average%'.isolateLtr,
                label: average == null
                    ? l10n.progressNoQuizYet
                    : l10n.progressAverageScore,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
