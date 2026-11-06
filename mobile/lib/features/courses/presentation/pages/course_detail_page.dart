import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../lessons/application/lesson_providers.dart';
import '../../../lessons/domain/lesson.dart';
import '../../../progress/application/progress_providers.dart';
import '../../application/course_providers.dart';
import '../../domain/course.dart';
import '../widgets/course_lesson_tile.dart';
import '../widgets/level_badge.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(courseProvider(courseId));
    return Scaffold(
      appBar: AppBar(
        title: Text(course.value?.title.resolve(context.languageCode) ?? ''),
      ),
      body: AsyncValueView<Course>(
        value: course,
        onRetry: () => ref.invalidate(courseProvider(courseId)),
        data: (course) => _CourseDetailBody(course: course),
      ),
    );
  }
}

class _CourseDetailBody extends ConsumerWidget {
  const _CourseDetailBody({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lessons = ref.watch(lessonsForCourseProvider(course.id));
    final progress = ref.watch(progressProvider);
    final completed = progress.completedIn(course.lessonIds);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ContentWidth(
              child: ListView(
                padding: AppSpacing.page,
                children: [
                  Row(
                    children: [
                      LevelBadge(level: course.level),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.lessonCount(course.lessonCount),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    course.title.resolve(context.languageCode),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    course.description.resolve(context.languageCode),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (course.lessonCount > 0) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.courseProgressLabel(completed, course.lessonCount),
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppProgressBar(
                      value: progress.fractionIn(course.lessonIds),
                      semanticLabel: l10n.courseProgressLabel(
                        completed,
                        course.lessonCount,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: l10n.courseLessonsTitle),
                  AsyncValueView<List<Lesson>>(
                    value: lessons,
                    compact: true,
                    onRetry: () =>
                        ref.invalidate(lessonsForCourseProvider(course.id)),
                    isEmpty: (list) => list.isEmpty,
                    emptyBuilder: (context) => Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: AppSizes.iconXl,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            l10n.noLessonsTitle,
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.noLessonsMessage,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (list) => Column(
                      children: [
                        for (final lesson in list)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: CourseLessonTile(lesson: lesson),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (lessons.value?.isNotEmpty ?? false)
            ContentWidth(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                child: AppPrimaryButton(
                  label: completed == 0
                      ? l10n.startCourse
                      : completed < course.lessonCount
                      ? l10n.continueCourse
                      : l10n.reviewCourse,
                  icon: Icons.play_arrow,
                  onPressed: () {
                    final list = lessons.value!;
                    final target = list.firstWhere(
                      (l) => !progress.isCompleted(l.id),
                      orElse: () => list.first,
                    );
                    context.push(AppRoutes.lessonOf(target.id));
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
