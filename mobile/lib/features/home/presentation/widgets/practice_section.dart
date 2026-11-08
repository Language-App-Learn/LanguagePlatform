import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../progress/application/progress_providers.dart';

/// Önerilen pratik: kelime tekrarı ve sıradaki dersin quiz'i.
class PracticeSection extends ConsumerWidget {
  const PracticeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final nextStep = ref.watch(learningPathProvider).value?.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.homeRecommendedPractice),
        _PracticeTile(
          key: const ValueKey('practice-vocabulary'),
          icon: Icons.style_outlined,
          title: l10n.practiceVocabularyTitle,
          subtitle: l10n.practiceVocabularySubtitle,
          onTap: () => context.go(AppRoutes.vocabulary),
        ),
        if (nextStep != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _PracticeTile(
            key: const ValueKey('practice-quiz'),
            icon: Icons.quiz_outlined,
            title: l10n.practiceQuizTitle,
            subtitle: nextStep.lesson.title.resolve(context.languageCode),
            onTap: () => context.push(AppRoutes.quizOf(nextStep.lesson.id)),
          ),
        ],
      ],
    );
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
