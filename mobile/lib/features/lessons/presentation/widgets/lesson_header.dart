import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../courses/application/course_providers.dart';
import '../../../progress/application/progress_providers.dart';
import '../../application/lesson_providers.dart';
import '../../domain/lesson.dart';

/// Context at the top of a lesson: course, position in the course,
/// duration, completion state and the course progress. All values come from
/// the real course/progress records; nothing is shown when data is missing.
class LessonHeader extends ConsumerWidget {
  const LessonHeader({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final course = ref.watch(courseProvider(lesson.courseId)).value;
    final siblings =
        ref.watch(lessonsForCourseProvider(lesson.courseId)).value ?? const [];
    final position = siblings.indexWhere((l) => l.id == lesson.id) + 1;
    final progress = ref.watch(progressProvider);
    final done = progress.isCompleted(lesson.id);
    final courseDone = course == null
        ? 0
        : progress.completedIn(course.lessonIds);

    return Column(
      key: const ValueKey('lesson-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (course != null)
          Text(
            course.title.resolve(context.languageCode),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (position > 0)
              Text(
                l10n.lessonPosition(position, siblings.length),
                style: theme.textTheme.bodyMedium,
              ),
            Text(
              l10n.lessonMinutes(lesson.estimatedMinutes),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (done)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: AppSizes.iconSm,
                    color: context.semanticColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(l10n.lessonCompleted, style: theme.textTheme.bodyMedium),
                ],
              ),
          ],
        ),
        if (course != null && course.lessonCount > 0) ...[
          const SizedBox(height: AppSpacing.md),
          AppProgressBar(
            value: courseDone / course.lessonCount,
            semanticLabel: l10n.courseProgressLabel(
              courseDone,
              course.lessonCount,
            ),
          ),
        ],
      ],
    );
  }
}
