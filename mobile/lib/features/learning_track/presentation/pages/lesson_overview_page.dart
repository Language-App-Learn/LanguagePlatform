import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../lessons/application/lesson_providers.dart';
import '../../../lessons/domain/lesson.dart';
import '../../application/track_providers.dart';
import '../../domain/lesson_outcome.dart';
import '../../domain/lesson_stage.dart';
import '../widgets/lesson_mode_grid.dart';
import '../widgets/stage_widgets.dart';
import 'remote_lesson_pages.dart';

/// The five-stage overview of a lesson plus the overall lesson status.
///
/// The overall result is shown only when the backend provides it; a local
/// average is never presented as a pass/fail decision.
class LessonOverviewPage extends ConsumerWidget {
  const LessonOverviewPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(contentModeProvider) == ContentMode.remote) {
      return RemoteLessonOverviewPage(lessonId: lessonId);
    }
    final lesson = ref.watch(lessonProvider(lessonId));
    return LessonMenuFrame(
      child: AsyncValueView<Lesson>(
        value: lesson,
        onRetry: () => ref.invalidate(lessonProvider(lessonId)),
        data: (lesson) => _Body(lesson: lesson),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final records = ref.watch(
      stageRecordsProvider.select((m) => m[lesson.id] ?? const {}),
    );
    final content = ref.watch(stageContentProvider(lesson.id));
    final server = ref.watch(serverLessonResultProvider(lesson.id));
    final outcome = lessonOutcome(records: records, serverResult: server);
    final hasDemoScore = records.values.any((r) => r.score != null);

    return ListView(
      padding: lessonMenuPadding,
      children: [
        const LessonMenuIntro(),
        LessonModeGrid(
          cardFor: (stage) {
            final status = stageStatus(
              stage: stage,
              records: records,
              hasContent: (s) => stageHasContent(lesson, content, s),
            );
            final open =
                status == StageStatus.available ||
                status == StageStatus.inProgress ||
                status == StageStatus.completed;
            return LessonModeCard(
              stage: stage,
              status: status,
              record: records[stage],
              onOpen: open
                  ? () => context.push(AppRoutes.stageOf(lesson.id, stage.name))
                  : null,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        OverallPanel(
          outcome: outcome,
          server: server,
          hasDemoScore: hasDemoScore,
          l10n: l10n,
        ),
      ],
    );
  }
}

class OverallPanel extends StatelessWidget {
  const OverallPanel({
    super.key,
    required this.outcome,
    required this.server,
    required this.hasDemoScore,
    required this.l10n,
  });

  final LessonOutcomeStatus outcome;
  final ServerLessonResult? server;
  final bool hasDemoScore;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      key: const ValueKey('overall-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.outcomeName(outcome),
            key: const ValueKey('overall-status'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            server == null
                ? l10n.overallScoreNone
                : '${formatScore(server!.finalScore)}/100'.isolateLtr,
            key: const ValueKey('overall-score'),
            style: theme.textTheme.titleMedium,
          ),
          Text(
            l10n.passMarkInfo(overallPassMark),
            style: theme.textTheme.bodyMedium,
          ),
          if (server?.weights == null) ...[
            const SizedBox(height: AppSpacing.md),
            NoticeBanner(message: l10n.scoringPolicyMissing),
          ],
          if (hasDemoScore) ...[
            const SizedBox(height: AppSpacing.md),
            const DemoScoreNotice(),
          ],
        ],
      ),
    );
  }
}
