import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../authentication/application/auth_providers.dart';
import '../../application/track_providers.dart';
import '../../domain/lesson_outcome.dart';
import '../../domain/lesson_stage.dart';
import '../../domain/remote_models.dart';
import '../widgets/lesson_mode_grid.dart';
import '../widgets/remote_assessment_view.dart';
import '../widgets/reading_material_view.dart';
import '../widgets/remote_speaking_view.dart';
import '../widgets/stage_media_panel.dart';
import '../widgets/stage_widgets.dart';
import 'lesson_overview_page.dart';

StageStatus _statusOf(RemoteStageStatus s, RemoteStageProgress p) =>
    switch (s) {
      RemoteStageStatus.completed => StageStatus.completed,
      RemoteStageStatus.inProgress => StageStatus.inProgress,
      RemoteStageStatus.available =>
        p.attempts > 0 ? StageStatus.inProgress : StageStatus.available,
      RemoteStageStatus.locked => StageStatus.locked,
    };

/// Five-stage overview of a REAL lesson. Stage states and scores come only
/// from the server; nothing is computed locally.
class RemoteLessonOverviewPage extends ConsumerWidget {
  const RemoteLessonOverviewPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(remoteLessonProvider(lessonId));
    return LessonMenuFrame(
      child: AsyncValueView<RemoteLesson>(
        value: lesson,
        onRetry: () => ref.invalidate(remoteLessonProvider(lessonId)),
        data: (lesson) => _RemoteOverviewBody(lesson: lesson),
      ),
    );
  }
}

class _RemoteOverviewBody extends ConsumerStatefulWidget {
  const _RemoteOverviewBody({required this.lesson});

  final RemoteLesson lesson;

  @override
  ConsumerState<_RemoteOverviewBody> createState() =>
      _RemoteOverviewBodyState();
}

class _RemoteOverviewBodyState extends ConsumerState<_RemoteOverviewBody> {
  bool _beginning = false;
  Object? _beginError;

  /// Enrolls (idempotent) and starts the lesson, then reloads the progress.
  Future<void> _begin() async {
    setState(() {
      _beginning = true;
      _beginError = null;
    });
    try {
      final repo = ref.read(fiveStageRepositoryProvider);
      final lesson = widget.lesson;
      await repo.enroll(lesson.courseId);
      await repo.startLesson(lesson.courseId, lesson.id);
      ref.invalidate(remoteProgressProvider(lesson.id));
    } on Object catch (error) {
      _beginError = error;
    } finally {
      if (mounted) setState(() => _beginning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lesson = widget.lesson;
    final signedIn = ref.watch(sessionProvider) == SessionStatus.authenticated;
    final progressAsync = ref.watch(remoteProgressProvider(lesson.id));
    final progress = progressAsync.value;
    final server = ref.watch(serverLessonResultProvider(lesson.id));

    final allCompleted =
        progress != null &&
        LessonStage.values.every(
          (k) => progress.stageOf(k)?.status == RemoteStageStatus.completed,
        );
    final outcome = server != null
        ? (server.passed
              ? LessonOutcomeStatus.passed
              : LessonOutcomeStatus.failed)
        : progress == null
        ? LessonOutcomeStatus.notStarted
        : allCompleted
        ? LessonOutcomeStatus.awaitingAssessment
        : progress.stages.any((s) => s.attempts > 0 || s.score != null)
        ? LessonOutcomeStatus.inProgress
        : LessonOutcomeStatus.notStarted;

    return ListView(
      padding: lessonMenuPadding,
      children: [
        const LessonMenuIntro(),
        if (!signedIn) ...[
          NoticeBanner(
            key: const ValueKey('sign-in-prompt'),
            message: l10n.remoteSignInPrompt,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: Text(l10n.loginButton),
          ),
          const SizedBox(height: AppSpacing.lg),
        ] else if (progress == null &&
            !progressAsync.isLoading &&
            !progressAsync.hasError) ...[
          AppPrimaryButton(
            key: const ValueKey('begin-lesson'),
            label: l10n.remoteBeginLesson,
            icon: Icons.play_arrow,
            isLoading: _beginning,
            onPressed: _begin,
          ),
          if (_beginError != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
              child: Text(failureOf(_beginError).message(l10n)),
            ),
          const SizedBox(height: AppSpacing.lg),
        ] else if (progressAsync.hasError) ...[
          InlineErrorCard(
            error: progressAsync.error,
            onRetry: () => ref.invalidate(remoteProgressProvider(lesson.id)),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        LessonModeGrid(
          cardFor: (kind) {
            final sp = progress?.stageOf(kind);
            final status = sp == null
                ? StageStatus.locked
                : _statusOf(sp.status, sp);
            final open =
                status == StageStatus.available ||
                status == StageStatus.inProgress ||
                status == StageStatus.completed;
            return LessonModeCard(
              stage: kind,
              status: status,
              officialScore: sp?.score,
              onOpen: open
                  ? () => context.push(AppRoutes.stageOf(lesson.id, kind.name))
                  : null,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        OverallPanel(
          outcome: outcome,
          server: server,
          hasDemoScore: false,
          l10n: l10n,
        ),
        if (server?.passed == true && server?.nextLessonId != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            key: const ValueKey('next-lesson'),
            label: l10n.nextLessonAction,
            icon: Icons.arrow_forward,
            onPressed: () => context.pushReplacement(
              AppRoutes.stagesOf(server!.nextLessonId!),
            ),
          ),
        ],
      ],
    );
  }
}

/// One stage of a REAL lesson: published text (Arabic keeps its own
/// direction), honest "not available" notes for media/AI, and the graded
/// activity when the server published one.
class RemoteStagePage extends ConsumerWidget {
  const RemoteStagePage({
    super.key,
    required this.lessonId,
    required this.stage,
  });

  final String lessonId;
  final String stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kind = LessonStage.values.asNameMap()[stage];
    final lesson = ref.watch(remoteLessonProvider(lessonId));
    return Scaffold(
      appBar: AppBar(title: Text(kind == null ? '' : l10n.stageName(kind))),
      body: SafeArea(
        child: kind == null
            ? EmptyStateView(icon: Icons.search_off, title: l10n.errorNotFound)
            : AsyncValueView<RemoteLesson>(
                value: lesson,
                onRetry: () => ref.invalidate(remoteLessonProvider(lessonId)),
                data: (lesson) => _StageBody(lesson: lesson, kind: kind),
              ),
      ),
    );
  }
}

class _StageBody extends ConsumerWidget {
  const _StageBody({required this.lesson, required this.kind});

  final RemoteLesson lesson;
  final LessonStage kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final stage = lesson.stageOf(kind);
    final progress = ref.watch(remoteProgressProvider(lesson.id)).value;
    final sp = progress?.stageOf(kind);
    final accessible = sp != null && sp.status != RemoteStageStatus.locked;
    if (stage == null || !accessible) {
      return EmptyStateView(
        icon: Icons.lock_outline,
        title: l10n.stageStatusLocked,
        message: stage == null ? l10n.stageContentMissing : null,
      );
    }

    return ContentWidth(
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Text(l10n.stageDescription(kind), style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            children: [
              if (stage.weight != null)
                Text(
                  l10n.stageWeight(formatScore(stage.weight!).isolateLtr),
                  style: theme.textTheme.bodySmall,
                ),
              Text(
                l10n.stageAttempts(sp.attempts),
                style: theme.textTheme.bodySmall,
              ),
              if (sp.score != null)
                Text(
                  l10n.officialResultScore(
                    formatScore(sp.score!).isolateLtr,
                    '100'.isolateLtr,
                  ),
                  key: const ValueKey('stage-official-score'),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          if (kind == LessonStage.reading) ...[
            const SizedBox(height: AppSpacing.lg),
            // Approved lines (with stable ids) and the original PDF; the
            // authored Arabic stage text is only the fallback.
            ReadingMaterialView(
              courseId: lesson.courseId,
              lessonId: lesson.id,
              fallbackText: stage.texts['ar'],
            ),
          ],
          // Remaining published texts (for reading, the Arabic one is shown
          // above).
          if (stage.texts.keys.any(
            (k) => !(kind == LessonStage.reading && k == 'ar'),
          )) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.remoteStageTextTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final entry in stage.texts.entries)
              if (!(kind == LessonStage.reading && entry.key == 'ar'))
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.md,
                  ),
                  child: AppCard(
                    key: ValueKey('stage-text:${entry.key}'),
                    child: ContentText(
                      entry.value,
                      languageCode: entry.key,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ),
          ],
          const SizedBox(height: AppSpacing.md),
          StageMediaPanel(
            lessonId: lesson.id,
            stageId: stage.id,
            expectsMedia:
                kind == LessonStage.reading || kind == LessonStage.listening,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (stage.assessmentId == null)
            NoticeBanner(message: l10n.remoteStageNoAssessment)
          else if (kind == LessonStage.speaking)
            RemoteSpeakingView(
              key: ValueKey('speaking:${stage.assessmentId}'),
              courseId: lesson.courseId,
              lessonId: lesson.id,
              assessmentId: stage.assessmentId!,
            )
          else
            RemoteAssessmentView(
              key: ValueKey('assessment:${stage.assessmentId}'),
              courseId: lesson.courseId,
              lessonId: lesson.id,
              assessmentId: stage.assessmentId!,
            ),
        ],
      ),
    );
  }
}
