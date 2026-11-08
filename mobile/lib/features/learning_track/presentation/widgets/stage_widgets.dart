import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../courses/domain/course.dart';
import '../../domain/lesson_outcome.dart';
import '../../domain/lesson_stage.dart';
import '../../domain/stage_grading.dart';

/// Localized names for stages, levels and statuses.
extension StageL10n on AppLocalizations {
  String stageName(LessonStage s) => switch (s) {
    LessonStage.reading => stageReading,
    LessonStage.speaking => stageSpeaking,
    LessonStage.listening => stageListening,
    LessonStage.writing => stageWriting,
    LessonStage.translation => stageTranslation,
  };

  String stageDescription(LessonStage s) => switch (s) {
    LessonStage.reading => stageReadingDesc,
    LessonStage.speaking => stageSpeakingDesc,
    LessonStage.listening => stageListeningDesc,
    LessonStage.writing => stageWritingDesc,
    LessonStage.translation => stageTranslationDesc,
  };

  String statusName(StageStatus s) => switch (s) {
    StageStatus.available => stageStatusAvailable,
    StageStatus.inProgress => stageStatusInProgress,
    StageStatus.completed => stageStatusCompleted,
    StageStatus.locked => stageStatusLocked,
    StageStatus.unavailable => stageStatusUnavailable,
  };

  String levelName(CourseLevel l) => switch (l) {
    CourseLevel.a1 => levelNameA1,
    CourseLevel.a2 => levelNameA2,
    CourseLevel.b1 => levelNameB1,
    CourseLevel.b2 => levelNameB2,
    CourseLevel.c1 => levelNameC1,
    CourseLevel.c2 => levelNameC2,
  };

  String outcomeName(LessonOutcomeStatus s) => switch (s) {
    LessonOutcomeStatus.notStarted => lessonStatusNotStarted,
    LessonOutcomeStatus.inProgress => lessonStatusInProgress,
    LessonOutcomeStatus.awaitingAssessment => lessonStatusAwaiting,
    LessonOutcomeStatus.passed => lessonStatusPassed,
    LessonOutcomeStatus.failed => lessonStatusFailed,
  };
}

IconData stageIcon(LessonStage s) => switch (s) {
  LessonStage.reading => Icons.menu_book_outlined,
  LessonStage.speaking => Icons.record_voice_over_outlined,
  LessonStage.listening => Icons.headphones_outlined,
  LessonStage.writing => Icons.edit_outlined,
  LessonStage.translation => Icons.translate,
};

/// Small badge marking content that is local demo data.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: semantic.accentContainer,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        context.l10n.demoContentBadge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: semantic.onAccentContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// One of the five large stage cards of the lesson overview.
class StageCard extends StatelessWidget {
  const StageCard({
    super.key,
    required this.stage,
    required this.status,
    required this.record,
    this.officialScore,
    required this.onOpen,
  });

  final LessonStage stage;
  final StageStatus status;
  final StageRecord? record;

  /// OFFICIAL server score (0..100) for this stage; takes precedence over
  /// any local practice score.
  final double? officialScore;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = context.semanticColors;
    final enabled = onOpen != null;
    final (statusColor, statusIcon) = switch (status) {
      StageStatus.completed => (semantic.success, Icons.check_circle),
      StageStatus.inProgress => (scheme.primary, Icons.timelapse),
      StageStatus.available => (scheme.primary, Icons.play_circle_outline),
      StageStatus.locked => (scheme.outline, Icons.lock_outline),
      StageStatus.unavailable => (scheme.outline, Icons.hourglass_empty),
    };
    final number = (stage.index + 1).toString().padLeft(2, '0');

    return Opacity(
      opacity: enabled ? 1 : 0.75,
      child: AppCard(
        key: ValueKey('stage-card:${stage.name}'),
        onTap: onOpen,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(
                stageIcon(stage),
                color: scheme.onPrimaryContainer,
                size: AppSizes.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${number.isolateLtr}  ${l10n.stageName(stage)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.stageDescription(stage),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        statusIcon,
                        size: AppSizes.iconSm,
                        color: statusColor,
                      ),
                      Text(
                        l10n.statusName(status),
                        key: ValueKey('stage-status:${stage.name}'),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: statusColor,
                        ),
                      ),
                      if (officialScore != null)
                        Text(
                          l10n.officialResultScore(
                            formatScore(officialScore!).isolateLtr,
                            '100'.isolateLtr,
                          ),
                          style: theme.textTheme.bodySmall,
                        )
                      else if (record?.score != null)
                        Text(
                          l10n.stageScoreLabel('${record!.score}'.isolateLtr),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (enabled) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// Shown on every demo practice result: not an official score.
class DemoScoreNotice extends StatelessWidget {
  const DemoScoreNotice({super.key});

  @override
  Widget build(BuildContext context) =>
      NoticeBanner(message: context.l10n.demoScoreNotice);
}

/// Shared "result + finish" block of every stage. Shows the demo practice
/// score with the notice that it is not an official result.
class PracticeResult extends StatelessWidget {
  const PracticeResult({
    super.key,
    required this.correct,
    required this.total,
    required this.onFinish,
  });

  final int correct;
  final int total;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('practice-result'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.resultCorrect(correct, total),
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          l10n.stageScoreLabel('${percentOf(correct, total)}%'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        const DemoScoreNotice(),
        const SizedBox(height: AppSpacing.lg),
        AppPrimaryButton(
          label: l10n.finishPractice,
          icon: Icons.check,
          onPressed: onFinish,
        ),
      ],
    );
  }
}
