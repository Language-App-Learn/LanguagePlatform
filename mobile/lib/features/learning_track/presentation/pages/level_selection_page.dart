import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../application/track_providers.dart';
import '../../domain/learning_track.dart';
import '../../domain/level_overview.dart';
import '../widgets/stage_widgets.dart';

/// CEFR level selection (A1-C2) of a learning track with real counts.
class LevelSelectionPage extends ConsumerWidget {
  const LevelSelectionPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final track = LearningTracks.byId(trackId);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackTitle)),
      body: SafeArea(
        child: track == null
            ? Center(child: Text(l10n.errorNotFound))
            : AsyncValueView<List<LevelOverview>>(
                value: ref.watch(levelOverviewsProvider),
                onRetry: () => reloadTrackCatalog(ref),
                data: (levels) => ContentWidth(
                  child: ListView(
                    padding: AppSpacing.page,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.trackSubtitle,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (ref.watch(contentModeProvider) ==
                              ContentMode.demo)
                            const DemoBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final level in levels)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            bottom: AppSpacing.md,
                          ),
                          child: _LevelCard(trackId: trackId, overview: level),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.trackId, required this.overview});

  final String trackId;
  final LevelOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasLessons = overview.publishedLessons > 0;
    return AppCard(
      key: ValueKey('level-card:${overview.level.name}'),
      onTap: () =>
          context.push(AppRoutes.levelOf(trackId, overview.level.name)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                overview.level.code.isolateLtr,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.levelName(overview.level),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasLessons
                ? l10n.levelPublishedCount(
                    overview.publishedLessons,
                    overview.capacity,
                  )
                : l10n.levelNoLessons,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasLessons) ...[
            const SizedBox(height: AppSpacing.sm),
            AppProgressBar(
              value: overview.progress,
              semanticLabel: l10n.levelCompletedCount(
                overview.completedLessons,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.levelCompletedCount(overview.completedLessons),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
