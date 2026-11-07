import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../learning_track/domain/learning_track.dart';

/// The active learning track (Turkish -> Arabic): entry to the CEFR levels.
class TrackCard extends StatelessWidget {
  const TrackCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      key: const ValueKey('track-card'),
      color: scheme.primaryContainer,
      onTap: () =>
          context.push(AppRoutes.trackOf(LearningTracks.turkishToArabic.id)),
      child: Row(
        children: [
          Icon(
            Icons.translate,
            color: scheme.onPrimaryContainer,
            size: AppSizes.iconMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trackTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  l10n.trackSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
        ],
      ),
    );
  }
}
