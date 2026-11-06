import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';

/// Bir tanıtım adımının içeriği.
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
  const OnboardingStepView({super.key, required this.data});

  final OnboardingStepData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer,
              ),
              child: Icon(
                data.icon,
                size: 72,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
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
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
