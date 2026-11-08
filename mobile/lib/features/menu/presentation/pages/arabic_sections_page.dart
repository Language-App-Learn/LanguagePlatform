import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/brand_illustrations.dart';
import '../../../../core/design_system/widgets/brand_list_card.dart';
import '../../../../core/design_system/widgets/brand_screen_header.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../learning_track/domain/learning_track.dart';

/// Screen 5: the sections of the Arabic offering, in the drawn order.
/// Only "Arapça Öğren" leads somewhere (the level selection of the existing
/// Turkish -> Arabic track). The others look the same but only report that
/// they are not available: no placeholder pages and no AI feature.
class ArabicSectionsPage extends StatelessWidget {
  const ArabicSectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <_Section>[
      _Section(
        'learn-arabic',
        l10n.sectionLearnArabic,
        Icons.menu_book_outlined,
        route: AppRoutes.trackOf(LearningTracks.turkishToArabic.id),
      ),
      _Section(
        'reading-writing',
        l10n.sectionReadingWriting,
        Icons.edit_outlined,
      ),
      _Section('quran', l10n.sectionQuran, Icons.auto_stories_outlined),
      _Section('exams', l10n.sectionExams, Icons.assignment_turned_in_outlined),
      _Section('ai-practice', l10n.sectionAi, Icons.smart_toy_outlined),
    ];
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
                    child: ListView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.xxxl,
                      ),
                      children: [
                        // Skyline with the title at its start side.
                        Stack(
                          alignment: AlignmentDirectional.bottomStart,
                          children: [
                            const MosqueHero(),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                bottom: AppSpacing.xs,
                              ),
                              child: Semantics(
                                header: true,
                                child: Text(
                                  l10n.languageNameAr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppColors.brandDeep,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          Builder(
                            builder: (context) {
                              final item = items[i];
                              final route = item.route;
                              return BrandListCard(
                                key: ValueKey('section:${item.id}'),
                                title: item.title,
                                icon: item.icon,
                                style: i == 0
                                    ? BrandCardStyle.filled
                                    : BrandCardStyle.plain,
                                available: route != null,
                                minHeight: 68,
                                onTap: route == null
                                    ? () => showUnavailable(context)
                                    : () => context.push(route),
                              );
                            },
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

class _Section {
  const _Section(this.id, this.title, this.icon, {this.route});

  final String id;
  final String title;
  final IconData icon;

  /// Null = not available yet.
  final String? route;
}
