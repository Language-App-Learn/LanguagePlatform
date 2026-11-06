import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../application/track_providers.dart';
import '../../domain/learning_track.dart';
import '../../domain/lesson_stage.dart';
import '../../domain/level_overview.dart';
import '../widgets/stage_widgets.dart';

/// The 20 lesson positions of one level. Published lessons are openable;
/// the rest are shown as "in preparation" (no fake titles or locks).
class LevelLessonsPage extends ConsumerWidget {
  const LevelLessonsPage({
    super.key,
    required this.trackId,
    required this.levelSegment,
  });

  final String trackId;
  final String levelSegment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final level = levelFromSegment(levelSegment);
    if (level == null || LearningTracks.byId(trackId) == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.errorNotFound)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('${level.code} · ${l10n.levelName(level)}')),
      body: SafeArea(
        child: AsyncValueView<List<LessonPosition>>(
          value: ref.watch(levelPositionsProvider(level)),
          onRetry: () => ref.invalidate(levelPositionsProvider(level)),
          data: (positions) => ContentWidth(
            // Lazy list of the fixed 20 positions.
            child: ListView.separated(
              padding: AppSpacing.page,
              itemCount: positions.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) =>
                  _PositionTile(position: positions[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionTile extends ConsumerWidget {
  const _PositionTile({required this.position});

  final LessonPosition position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lesson = position.lesson;
    final records = lesson == null
        ? const <LessonStage, StageRecord>{}
        : ref.watch(stageRecordsProvider.select((m) => m[lesson.id])) ??
              const {};
    final done = records.values.where((r) => r.completed).length;
    final allDone = done == LessonStage.values.length;

    return AppCard(
      key: ValueKey('position:${position.number}'),
      onTap: lesson == null
          ? null
          : () => context.push(AppRoutes.stagesOf(lesson.id)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: allDone
                ? context.semanticColors.successContainer
                : theme.colorScheme.surfaceContainerHighest,
            child: allDone
                ? Icon(Icons.check, color: context.semanticColors.success)
                : Text('${position.number}'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson == null
                      ? l10n.lessonNumber(position.number)
                      : lesson.title.resolve(context.languageCode),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  lesson == null
                      ? l10n.lessonInPreparation
                      : "$done/${LessonStage.values.length}".isolateLtr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (lesson != null)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(top: AppSpacing.xs),
                    child: DemoBadge(),
                  ),
              ],
            ),
          ),
          if (lesson != null) const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
