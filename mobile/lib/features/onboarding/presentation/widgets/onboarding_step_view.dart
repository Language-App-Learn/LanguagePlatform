import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Content of one onboarding step.
class OnboardingStepData {
  const OnboardingStepData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  static List<OnboardingStepData> all(AppLocalizations l10n) => [
    OnboardingStepData(
      icon: Icons.public,
      title: l10n.onboarding1Title,
      body: l10n.onboarding1Body,
    ),
    OnboardingStepData(
      icon: Icons.school_outlined,
      title: l10n.onboarding2Title,
      body: l10n.onboarding2Body,
    ),
    OnboardingStepData(
      icon: Icons.style_outlined,
      title: l10n.onboarding3Title,
      body: l10n.onboarding3Body,
    ),
    OnboardingStepData(
      icon: Icons.insights_outlined,
      title: l10n.onboarding4Title,
      body: l10n.onboarding4Body,
    ),
  ];
}

class OnboardingStepView extends StatelessWidget {
  const OnboardingStepView({
    super.key,
    required this.data,
    required this.index,
  });

  final OnboardingStepData data;

  /// Step number; picks the illustration color role.
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StepIllustration(icon: data.icon, index: index),
          const SizedBox(height: AppSpacing.xxl),
          Semantics(
            header: true,
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Native-shape illustration (no image assets): a soft disc, an offset
/// secondary disc, a small accent dot and a rounded icon tile. Decorative,
/// so it is excluded from semantics; its color role changes per step.
class StepIllustration extends StatelessWidget {
  const StepIllustration({super.key, required this.icon, required this.index});

  final IconData icon;
  final int index;

  static const double size = 168;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final (soft, strong, onStrong) = switch (index % 4) {
      0 => (scheme.primaryContainer, scheme.primary, scheme.onPrimary),
      1 => (scheme.tertiaryContainer, scheme.tertiary, scheme.onTertiary),
      2 => (semantic.accentContainer, semantic.accent, scheme.onSurface),
      _ => (semantic.successContainer, semantic.success, scheme.surface),
    };
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(index),
        tween: Tween(begin: 0.85, end: 1),
        duration: AppMotion.normal,
        curve: AppMotion.curve,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(shape: BoxShape.circle, color: soft),
              ),
              PositionedDirectional(
                top: 6,
                end: 8,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: strong.withValues(alpha: 0.25),
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 14,
                start: 10,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: strong.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.xlAll,
                  color: strong,
                ),
                child: Icon(icon, size: 44, color: onStrong),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
