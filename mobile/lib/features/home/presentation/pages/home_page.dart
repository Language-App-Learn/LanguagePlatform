import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../widgets/continue_learning_section.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/featured_courses_section.dart';
import '../widgets/home_header.dart';
import '../widgets/practice_section.dart';
import '../widgets/progress_summary_card.dart';

/// Ana sayfa: karşılama, günlük hedef, devam et, öne çıkan kurslar,
/// sıradaki ders, önerilen pratik ve kısa ilerleme.
/// Veriler DEMO repository'lerden gelir; hesaba bağlı değildir.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              const HomeHeader(),
              const SizedBox(height: AppSpacing.lg),
              const DailyGoalCard(),
              const SizedBox(height: AppSpacing.xl),
              const ContinueLearningSection(),
              const SizedBox(height: AppSpacing.xl),
              const FeaturedCoursesSection(),
              const SizedBox(height: AppSpacing.xl),
              const PracticeSection(),
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
