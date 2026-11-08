import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'app_logo.dart';

/// Top of the learning-path screens (4-7), as in the design: a plain back
/// arrow at the start side and the small logo centered. The arrow mirrors in
/// RTL.
class BrandScreenHeader extends StatelessWidget {
  const BrandScreenHeader({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            const AppLogo(markSize: 52, wordSize: 20),
            PositionedDirectional(
              start: 0,
              top: 0,
              child: Semantics(
                button: true,
                label: context.l10n.back,
                excludeSemantics: true,
                onTap: () => _back(context),
                child: SizedBox(
                  width: AppSizes.minTouchTarget,
                  height: AppSizes.minTouchTarget,
                  child: InkWell(
                    key: const ValueKey('brand-back'),
                    customBorder: const CircleBorder(),
                    onTap: () => _back(context),
                    // Icons.arrow_back mirrors itself in RTL.
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.brandDeep,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered title with an optional subtitle, under a hero illustration.
class BrandTitleBlock extends StatelessWidget {
  const BrandTitleBlock({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.brandDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}
