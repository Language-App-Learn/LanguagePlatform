import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/brand_illustrations.dart';
import '../../../../core/design_system/widgets/brand_list_card.dart';
import '../../../../core/design_system/widgets/brand_screen_header.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../application/track_providers.dart';
import '../../domain/learning_track.dart';
import '../../domain/level_overview.dart';
import '../widgets/stage_widgets.dart';

/// Screen 6: level selection of a learning track, exactly the seven drawn
/// options: "Sıfırdan Öğren" (visible, not available: there is no such
/// content) and A1-C2. A level opens the existing list of its 20 lesson
/// positions. The server's lesson counts and progress still drive that list;
/// they are not written on these cards.
class LevelSelectionPage extends ConsumerWidget {
  const LevelSelectionPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final track = LearningTracks.byId(trackId);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BrandWaves(bottomHeight: 96, soft: true),
          SafeArea(
            child: ContentWidth(
              child: track == null
                  ? Column(
                      children: [
                        const BrandScreenHeader(),
                        Expanded(
                          child: Center(child: Text(l10n.errorNotFound)),
                        ),
                      ],
                    )
                  : AsyncValueView<List<LevelOverview>>(
                      value: ref.watch(levelOverviewsProvider),
                      onRetry: () => reloadTrackCatalog(ref),
                      data: (levels) => _LevelList(
                        trackId: trackId,
                        levels: levels,
                        demo:
                            ref.watch(contentModeProvider) == ContentMode.demo,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelList extends StatelessWidget {
  const _LevelList({
    required this.trackId,
    required this.levels,
    required this.demo,
  });

  final String trackId;
  final List<LevelOverview> levels;
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const BrandScreenHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            children: [
              const Center(child: LevelsHero()),
              const SizedBox(height: AppSpacing.sm),
              BrandTitleBlock(
                title: l10n.levelPickerTitle,
                subtitle: l10n.levelPickerSubtitle,
              ),
              if (demo)
                const Padding(
                  padding: EdgeInsetsDirectional.only(top: AppSpacing.md),
                  child: Center(child: DemoBadge()),
                ),
              const SizedBox(height: AppSpacing.lg),
              BrandListCard(
                key: const ValueKey('level-card:scratch'),
                title: l10n.levelFromScratch,
                icon: Icons.signal_cellular_alt_rounded,
                style: BrandCardStyle.outlined,
                available: false,
                minHeight: 54,
                onTap: () => showUnavailable(context),
              ),
              for (final level in levels) ...[
                const SizedBox(height: AppSpacing.sm),
                BrandListCard(
                  key: ValueKey('level-card:${level.level.name}'),
                  // The CEFR code, always left-to-right.
                  title: level.level.code.isolateLtr,
                  icon: Icons.signal_cellular_alt_rounded,
                  minHeight: 54,
                  onTap: () => context.push(
                    AppRoutes.levelOf(trackId, level.level.name),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
