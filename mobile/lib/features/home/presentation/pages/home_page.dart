import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../learning_track/application/track_providers.dart';
import '../../../progress/presentation/widgets/activity_widgets.dart';
import '../widgets/active_course_card.dart';
import '../widgets/continue_learning_section.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/featured_courses_section.dart';
import '../widgets/home_header.dart';
import '../widgets/track_card.dart';
import '../widgets/practice_section.dart';
import '../widgets/progress_summary_card.dart';

/// Home.
///
/// Demo mode: welcome, daily goal, continue, featured courses, practice and
/// a short progress summary, all from DEMO repositories.
///
/// Real account: only the header and the Turkish -> Arabic track entry. The
/// other sections are computed from on-device demo data and would mix two
/// kinds of learner records, so they stay hidden until they are backed by
/// the account.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(contentModeProvider) == ContentMode.remote;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: AppSpacing.page,
            children: remote
                ? [
                    const HomeHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    const TrackCard(),
                    const SizedBox(height: AppSpacing.xl),
                    NoticeBanner(
                      key: const ValueKey('home-remote-notice'),
                      message: context.l10n.homeRemoteNotice,
                    ),
                  ]
                : [
                    const HomeHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    const TrackCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const DailyGoalCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const WeeklyActivityCard(),
                    const SizedBox(height: AppSpacing.xl),
                    const ActiveCourseCard(),
                    const SizedBox(height: AppSpacing.xl),
                    const ContinueLearningSection(),
                    const SizedBox(height: AppSpacing.xl),
                    const FeaturedCoursesSection(),
                    const SizedBox(height: AppSpacing.xl),
                    const PracticeSection(),
                    const SizedBox(height: AppSpacing.xl),
                    const VocabularySummaryRow(),
                    const SizedBox(height: AppSpacing.xl),
                    const ProgressSummaryCard(),
                    const SizedBox(height: AppSpacing.xl),
                    NoticeBanner(message: context.l10n.demoNotice),
                  ],
          ),
        ),
      ),
    );
  }
}
