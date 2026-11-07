import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/widgets/brand_mark.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/startup_route.dart';

/// Brand screen + startup routing. No artificial delay: the route decision
/// is applied as soon as it is available; the short fade-in is purely
/// visual and does not hold up navigation.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupRouteProvider);
    final route = startup.asData?.value;
    if (route != null) {
      // Navigation is not allowed during build; run right after the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(route);
      });
    }
    final theme = Theme.of(context);
    return Scaffold(
      body: startup.hasError
          ? ErrorStateView(
              error: startup.error,
              onRetry: () => ref.invalidate(startupRouteProvider),
            )
          : Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppMotion.normal,
                curve: AppMotion.curve,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.brandTagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
