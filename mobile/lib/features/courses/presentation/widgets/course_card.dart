import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../progress/application/progress_providers.dart';
import '../../domain/course.dart';
import 'level_badge.dart';

/// Kurs kartı (katalog ve ana sayfa). Dokununca kurs detayına gider.
class CourseCard extends ConsumerWidget {
  const CourseCard({super.key, required this.course, this.compact = false});

  final Course course;

  /// Yatay listelerde daha kısa açıklama gösterir.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final code = context.languageCode;
    // Yalnızca bu kursun tamamlanan ders sayısı değişince yeniden çizilir.
    final completed = ref.watch(
      progressProvider.select((p) => p.completedIn(course.lessonIds)),
    );

    return AppCard(
      key: ValueKey('course-card:${course.id}'),
      onTap: () => context.push(AppRoutes.courseOf(course.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LanguageTile(languageCode: course.languageCode),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  course.title.resolve(code),
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            course.description.resolve(code),
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LevelBadge(level: course.level),
              Text(
                l10n.lessonCount(course.lessonCount),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (completed > 0) ...[
            const SizedBox(height: AppSpacing.md),
            AppProgressBar(
              value: completed / course.lessonCount,
              semanticLabel: l10n.courseProgressLabel(
                completed,
                course.lessonCount,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.languageCode});

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: AppSizes.minTouchTarget,
        height: AppSizes.minTouchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: AppRadius.mdAll,
        ),
        child: Text(
          languageCode.toUpperCase().isolateLtr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
