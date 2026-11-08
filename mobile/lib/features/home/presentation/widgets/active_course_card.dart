import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../courses/application/course_providers.dart';
import '../../../courses/domain/course.dart';
import '../../../courses/presentation/widgets/level_badge.dart';
import '../../../progress/application/progress_providers.dart';

/// The learner's current course with its CEFR level and real progress.
/// Derived from the last opened lesson, else the next course on the
/// learning path; an honest empty state when nothing applies.
class ActiveCourseCard extends ConsumerWidget {
  const ActiveCourseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.activeCourseTitle),
        AsyncValueView<Course?>(
          value: ref.watch(activeCourseProvider),
          compact: true,
          onRetry: () => ref.invalidate(coursesProvider),
          data: (course) => course == null
              ? const _EmptyActiveCourse()
              : _ActiveCourse(course: course),
        ),
      ],
    );
  }
}

class _ActiveCourse extends ConsumerWidget {
  const _ActiveCourse({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final completed = ref.watch(
      progressProvider.select((p) => p.completedIn(course.lessonIds)),
    );
    final label = l10n.courseProgressLabel(completed, course.lessonCount);

    return AppCard(
      key: const ValueKey('active-course'),
      onTap: () => context.push(AppRoutes.courseOf(course.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LevelBadge(level: course.level),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  course.title.resolve(context.languageCode),
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          AppProgressBar(
            value: course.lessonCount == 0 ? 0 : completed / course.lessonCount,
            semanticLabel: label,
          ),
        ],
      ),
    );
  }
}

class _EmptyActiveCourse extends StatelessWidget {
  const _EmptyActiveCourse();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AppCard(
      key: const ValueKey('active-course-empty'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.activeCourseEmptyTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.activeCourseEmptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.courses),
            child: Text(l10n.browseCourses),
          ),
        ],
      ),
    );
  }
}
