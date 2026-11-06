import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/design_system/widgets/stat_tile.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../courses/application/course_providers.dart';
import '../../application/progress_providers.dart';
import '../../domain/learning_progress.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/course_progress_tile.dart';

/// Yerel DEMO ilerleme özeti: tamamlanan dersler, quiz ortalaması, günlük
/// hedef ve kurs ilerlemesi. Hesaba bağlı kalıcı ilerleme DEĞİLDİR.
class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    final courses = ref.watch(targetCoursesProvider);
    final now = ref.watch(clockProvider)();
    final today = progress.completedOn(now);
    final average = progress.averageQuizScore;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              NoticeBanner(message: l10n.progressDemoNotice),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: Icons.task_alt,
                      value: '${progress.completedCount}',
                      label: l10n.progressCompletedLessons,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatTile(
                      icon: Icons.emoji_events_outlined,
                      value: average == null ? '–' : '$average%'.isolateLtr,
                      label: average == null
                          ? l10n.progressNoQuizYet
                          : l10n.progressAverageScore,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(height: AppSpacing.lg),
              const VocabularySummaryRow(),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.weeklyActivityTitle),
              const WeeklyActivityCard(),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.progressDailyGoalTitle),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeDailyGoalProgress(
                        today,
                        progress.dailyGoalLessons,
                      ),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppProgressBar(value: progress.dailyGoalFraction(now)),
                    const SizedBox(height: AppSpacing.lg),
                    ChoiceGroup<int>(
                      groupId: 'daily-goal',
                      selected: progress.dailyGoalLessons,
                      onSelected: ref
                          .read(progressProvider.notifier)
                          .setDailyGoal,
                      options: [
                        for (final goal in LearningProgress.dailyGoalOptions)
                          ChoiceOption(
                            id: '$goal',
                            value: goal,
                            label: l10n.dailyGoalOption(goal),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.progressCoursesTitle),
              if (progress.completedCount == 0)
                AppCard(
                  child: Column(
                    children: [
                      Text(
                        l10n.progressEmptyTitle,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.progressEmptyMessage,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton(
                        onPressed: () => context.go(AppRoutes.courses),
                        child: Text(l10n.browseCourses),
                      ),
                    ],
                  ),
                )
              else
                AsyncValueView(
                  value: courses,
                  compact: true,
                  onRetry: () => ref.invalidate(coursesProvider),
                  data: (list) => Column(
                    children: [
                      for (final course in list)
                        if (course.lessonCount > 0)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: CourseProgressTile(course: course),
                          ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
