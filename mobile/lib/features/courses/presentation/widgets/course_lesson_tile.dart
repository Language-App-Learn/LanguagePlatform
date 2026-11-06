import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../lessons/domain/lesson.dart';
import '../../../progress/application/progress_providers.dart';

/// Kurs detayındaki ders satırı: sıra/tamamlandı işareti, ad, süre, quiz.
class CourseLessonTile extends ConsumerWidget {
  const CourseLessonTile({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final done = ref.watch(
      progressProvider.select((p) => p.isCompleted(lesson.id)),
    );
    final score = ref.watch(
      progressProvider.select((p) => p.quizScores[lesson.id]),
    );
    final success = context.semanticColors.success;

    return AppCard(
      key: ValueKey('lesson-tile:${lesson.id}'),
      onTap: () => context.push(AppRoutes.lessonOf(lesson.id)),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: done
                ? context.semanticColors.successContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: done
                ? Icon(Icons.check, color: success)
                : Text('${lesson.order}'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title.resolve(context.languageCode),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  [
                    l10n.lessonMinutes(lesson.estimatedMinutes),
                    if (score != null) l10n.quizBestScore('$score%'.isolateLtr),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
