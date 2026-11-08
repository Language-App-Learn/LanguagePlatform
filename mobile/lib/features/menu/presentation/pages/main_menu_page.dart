import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_logo.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Screen 3: the main menu. Exactly two entries, as drawn:
/// "Dil Öğren" (learn a language) and "Tüm Dillerde Çeviri" (translation in
/// all languages). The first opens the language-pair screen (4); the
/// translation service does not exist yet, so its entry only tells the user
/// it is coming (no placeholder screen).
class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BrandWaves(bottomHeight: 110),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                // Breathing room that follows the screen height, so the cards
                // sit in the visual middle on tall phones and the page still
                // scrolls on short ones.
                final top = math.max(AppSpacing.xxxl, box.maxHeight * 0.09);
                final gap = math.max(AppSpacing.xxl, box.maxHeight * 0.08);
                return ContentWidth(
                  child: ListView(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.xl,
                      top,
                      AppSpacing.xl,
                      AppSpacing.xxxl,
                    ),
                    children: [
                      const Center(child: LogoWordmark(fontSize: 32)),
                      SizedBox(height: gap),
                      _MenuCard(
                        key: const ValueKey('menu-learn'),
                        icon: Icons.school_rounded,
                        iconColor: AppColors.brand,
                        title: l10n.menuLearn,
                        onTap: () => context.push(AppRoutes.languagePair),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _MenuCard(
                        key: const ValueKey('menu-translate'),
                        icon: Icons.translate_rounded,
                        iconColor: AppColors.brandMid,
                        title: l10n.menuTranslate,
                        onTap: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text(l10n.menuTranslateSoon)),
                            );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(28);
    return Semantics(
      button: true,
      label: title,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: AppColors.brandLight, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 128),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Icon(icon, size: 56, color: iconColor),
                      ),
                      Container(
                        width: 1.4,
                        height: 64,
                        margin: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        color: AppColors.brandLight,
                      ),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.brandDeep,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.chevron_right,
                        size: 32,
                        color: AppColors.brand,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
