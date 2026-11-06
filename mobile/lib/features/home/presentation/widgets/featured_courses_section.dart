import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../courses/application/course_providers.dart';
import '../../../courses/domain/course.dart';
import '../../../courses/presentation/widgets/course_card.dart';

/// Öğrenilen dildeki kurslar: yatay, lazy kaydırılan liste.
class FeaturedCoursesSection extends ConsumerWidget {
  const FeaturedCoursesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final courses = ref.watch(targetCoursesProvider);
    // Büyük yazı boyutunda kartlar taşmasın diye yükseklik ölçeklenir.
    final height = MediaQuery.textScalerOf(context).scale(232);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.homeFeaturedCourses,
          actionLabel: l10n.viewAll,
          onAction: () => context.go(AppRoutes.courses),
        ),
        AsyncValueView<List<Course>>(
          value: courses,
          compact: true,
          onRetry: () => ref.invalidate(coursesProvider),
          isEmpty: (list) => list.isEmpty,
          emptyBuilder: (context) => Text(l10n.noCoursesTitle),
          data: (list) => SizedBox(
            height: height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, i) => SizedBox(
                width: AppSizes.courseCardWidth,
                child: CourseCard(course: list[i], compact: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
