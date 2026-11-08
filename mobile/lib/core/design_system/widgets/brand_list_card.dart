import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

/// Look of a [BrandListCard], following the design: [filled] is the strong
/// purple card, [outlined] the lavender card with a purple border, [plain]
/// the white card with a soft border.
enum BrandCardStyle { plain, filled, outlined }

/// Row card of the learning-path screens (5 and 6): icon, title, chevron.
///
/// An [available] == false card looks like the others (as drawn) but only
/// reports that the feature is not available when pressed; screen readers
/// hear "soon". No page is opened for it.
class BrandListCard extends StatelessWidget {
  const BrandListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.style = BrandCardStyle.plain,
    this.available = true,
    this.minHeight = 64,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final BrandCardStyle style;
  final bool available;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filled = style == BrandCardStyle.filled;
    final outlined = style == BrandCardStyle.outlined;
    final radius = BorderRadius.circular(14);
    final fg = filled ? Colors.white : AppColors.brandDeep;
    final iconColor = filled ? Colors.white : AppColors.brand;
    final label = available ? title : '$title, ${context.l10n.comingSoonTag}';
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: filled
                ? const LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [AppColors.brandMid, AppColors.brand],
                  )
                : null,
            color: filled
                ? null
                : outlined
                ? AppColors.brandLight.withValues(alpha: 0.55)
                : AppColors.brandMist,
            borderRadius: radius,
            border: Border.all(
              color: outlined
                  ? AppColors.brandMid
                  : filled
                  ? AppColors.brand
                  : AppColors.brandLight,
              width: outlined ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: filled ? 0.28 : 0.08),
                blurRadius: filled ? 14 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Icon(icon, size: 30, color: iconColor),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.chevron_right, size: 28, color: fg),
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

/// Tells the user that a visible-but-unavailable feature is not open yet.
void showUnavailable(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.l10n.featureUnavailable)));
}
