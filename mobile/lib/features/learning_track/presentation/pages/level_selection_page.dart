import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/brand_illustrations.dart';
import '../../../../core/design_system/widgets/brand_list_card.dart';
import '../../../../core/design_system/widgets/brand_screen_header.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../courses/domain/course.dart';
import '../../domain/learning_track.dart';

/// Screen 6: level selection of a learning track, exactly the seven drawn
/// options: "Sıfırdan Öğren" (visible, not available: there is no such
/// content) and the six CEFR levels A1-C2. A level opens screen 7. Nothing is
/// read from a server or a demo source here.
class LevelSelectionPage extends StatelessWidget {
  const LevelSelectionPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final known = LearningTracks.byId(trackId) != null;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BrandWaves(bottomHeight: 96, soft: true),
          SafeArea(
            child: ContentWidth(
              child: Column(
                children: [
                  const BrandScreenHeader(),
                  Expanded(
                    child: !known
                        ? Center(child: Text(l10n.errorNotFound))
                        : ListView(
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
                              for (final level in CourseLevel.values) ...[
                                const SizedBox(height: AppSpacing.sm),
                                BrandListCard(
                                  key: ValueKey('level-card:${level.name}'),
                                  // The CEFR code, always left-to-right.
                                  title: level.code.isolateLtr,
                                  icon: Icons.signal_cellular_alt_rounded,
                                  minHeight: 54,
                                  onTap: () => context.push(
                                    AppRoutes.levelOf(trackId, level.name),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
