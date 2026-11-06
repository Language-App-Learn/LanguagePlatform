import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../progress/application/progress_providers.dart';

/// "Devam et" kartı ve "Sıradaki ders" satırı (öğrenme yolundan).
class ContinueLearningSection extends ConsumerWidget {
  const ContinueLearningSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final code = context.languageCode;
    final path = ref.watch(learningPathProvider);

    return AsyncValueView<List<LearningStep>>(
      value: path,
      compact: true,
      onRetry: () => ref.invalidate(learningPathProvider),
      isEmpty: (steps) => steps.isEmpty,
      emptyBuilder: (context) => AppCard(
        child: Text(l10n.homeAllDone, style: theme.textTheme.titleSmall),
      ),
      data: (steps) {
        final current = steps.first;
        final upcoming = steps.length > 1 ? steps[1] : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: current.courseStarted
                  ? l10n.homeContinueTitle
                  : l10n.homeStartTitle,
            ),
            AppCard(
              key: const ValueKey('continue-card'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.course.title.resolve(code),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    current.lesson.title.resolve(code),
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    l10n.lessonMinutes(current.lesson.estimatedMinutes),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    label: current.courseStarted
                        ? l10n.continueCourse
                        : l10n.startLesson,
                    icon: Icons.play_arrow,
                    onPressed: () =>
                        context.push(AppRoutes.lessonOf(current.lesson.id)),
                  ),
                ],
              ),
            ),
            if (upcoming != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                key: const ValueKey('next-lesson-card'),
                onTap: () =>
                    context.push(AppRoutes.lessonOf(upcoming.lesson.id)),
                child: Row(
                  children: [
                    const Icon(Icons.skip_next_outlined),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeNextLessonTitle,
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(
                            upcoming.lesson.title.resolve(code),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
