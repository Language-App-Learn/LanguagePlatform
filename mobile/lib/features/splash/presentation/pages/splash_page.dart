import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/widgets/app_logo.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/startup_route.dart';

/// Screen 1: the splash. Only the centered logo (mark, word mark and its
/// one-line tagline) on a clean lavender-white background with soft waves; no
/// buttons or sections. It shows for a short hold, then continues to the
/// one-time app-language choice or the main menu.
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: startup.hasError
          ? ErrorStateView(
              error: startup.error,
              onRetry: () => ref.invalidate(startupRouteProvider),
            )
          : DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, AppColors.brandMist],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const BrandWaves(bottomHeight: 190, topCorner: true),
                  SafeArea(
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: AppMotion.normal * 2,
                        curve: AppMotion.curve,
                        builder: (context, t, child) => Opacity(
                          opacity: t,
                          child: Transform.scale(
                            scale: 0.94 + 0.06 * t,
                            child: child,
                          ),
                        ),
                        child: AppLogo(
                          markSize: 168,
                          wordSize: 34,
                          tagline: context.l10n.brandTagline,
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
