import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../courses/domain/course.dart';
import '../../application/progress_providers.dart';

/// Kurs ilerleme kartı: ad, "x/y ders" ve ilerleme çubuğu.
class CourseProgressTile extends ConsumerWidget {
  const CourseProgressTile({super.key, required this.course});

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
      key: ValueKey('course-progress:${course.id}'),
      onTap: () => context.push(AppRoutes.courseOf(course.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title.resolve(context.languageCode),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          AppProgressBar(
            value: completed / course.lessonCount,
            semanticLabel: label,
          ),
        ],
      ),
    );
  }
}
