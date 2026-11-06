import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../language_selection/application/learning_preferences.dart';

/// Karşılama + öğrenilen dil.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final target = ref.watch(
      learningPreferencesProvider.select((p) => p.targetLanguage),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.homeGreeting, style: theme.textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (target != null)
          Chip(
            avatar: const Icon(Icons.translate, size: AppSizes.iconSm),
            label: Text(l10n.homeLearningLabel(target.nativeName)),
          )
        else
          Text(
            l10n.homeChooseTargetHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
