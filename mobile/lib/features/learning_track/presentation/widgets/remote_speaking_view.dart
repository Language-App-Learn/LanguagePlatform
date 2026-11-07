import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/storage/pending_attempt_store.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../application/track_providers.dart';
import '../../domain/five_stage_repository.dart';
import '../../domain/lesson_outcome.dart';
import '../../domain/remote_models.dart';

enum _Phase { idle, starting, waiting, checking, evaluated }

/// Speaking stage with the backend that exists today: the learner opens an
/// attempt and an AUTHORIZED EVALUATOR scores it separately. There is no
/// "finish" button that could fake completion; the stage only completes when
/// the server records a score. Automated AI conversation, microphone capture
/// and speech playback have no endpoints yet, so none of those controls
/// exist (and the microphone permission is never requested).
class RemoteSpeakingView extends ConsumerStatefulWidget {
  const RemoteSpeakingView({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.assessmentId,
  });

  final String courseId;
  final String lessonId;
  final String assessmentId;

  @override
  ConsumerState<RemoteSpeakingView> createState() => _RemoteSpeakingViewState();
}

class _RemoteSpeakingViewState extends ConsumerState<RemoteSpeakingView> {
  _Phase _phase = _Phase.idle;
  String? _attemptId;
  RemoteAssessmentResult? _result;
  Object? _error;
  bool _stillPending = false;

  FiveStageRepository get _repo => ref.read(fiveStageRepositoryProvider);
  PendingAttemptStore get _keys => ref.read(pendingAttemptStoreProvider);

  Future<void> _start({bool retake = false}) async {
    setState(() {
      _phase = _Phase.starting;
      _error = null;
      _result = null;
      _stillPending = false;
    });
    try {
      await _repo.enroll(widget.courseId);
      await _repo.startLesson(widget.courseId, widget.lessonId);
      final key = retake
          ? await _keys.renew(widget.assessmentId)
          : await _keys.keyFor(widget.assessmentId);
      final attempt = await _repo.startAttempt(
        courseId: widget.courseId,
        lessonId: widget.lessonId,
        assessmentId: widget.assessmentId,
        idempotencyKey: key,
      );
      if (!mounted) return;
      setState(() {
        _attemptId = attempt.id;
        _phase = _Phase.waiting;
      });
    } on Object catch (error) {
      final definitive = switch (failureOf(error)) {
        ConflictFailure() ||
        ValidationFailure() ||
        NotFoundFailure() ||
        ForbiddenFailure() ||
        UnauthorizedFailure() => true,
        _ => false,
      };
      if (definitive) await _keys.complete(widget.assessmentId);
      if (!mounted) return;
      setState(() {
        _error = error;
        _phase = _Phase.idle;
      });
    }
  }

  Future<void> _check() async {
    final id = _attemptId;
    if (id == null) return;
    setState(() {
      _phase = _Phase.checking;
      _error = null;
    });
    try {
      final result = await _repo.getAttemptResult(id);
      if (!mounted) return;
      if (result == null) {
        // Not evaluated yet: the honest answer is "no result yet".
        setState(() {
          _stillPending = true;
          _phase = _Phase.waiting;
        });
        return;
      }
      await _keys.complete(widget.assessmentId);
      ref
        ..invalidate(remoteProgressProvider(widget.lessonId))
        ..invalidate(passedLessonIdsProvider);
      if (!mounted) return;
      setState(() {
        _result = result;
        _phase = _Phase.evaluated;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _phase = _Phase.waiting;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NoticeBanner(
          key: const ValueKey('speaking-ai-unavailable'),
          message: l10n.speakingAiUnavailable,
        ),
        const SizedBox(height: AppSpacing.md),
        if (_error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: NoticeBanner(
              key: const ValueKey('speaking-error'),
              message: failureOf(_error).message(l10n),
            ),
          ),
        switch (_phase) {
          _Phase.idle => AppPrimaryButton(
            key: const ValueKey('speaking-start'),
            label: l10n.speakingStartAttempt,
            icon: Icons.record_voice_over_outlined,
            onPressed: _start,
          ),
          _Phase.starting ||
          _Phase.checking => const Center(child: CircularProgressIndicator()),
          _Phase.waiting => AppCard(
            key: const ValueKey('speaking-waiting'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.speakingWaitingTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.speakingWaitingBody),
                if (_stillPending) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.speakingStillPending,
                    key: const ValueKey('speaking-still-pending'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  key: const ValueKey('speaking-check'),
                  onPressed: _check,
                  child: Text(l10n.speakingCheckResult),
                ),
              ],
            ),
          ),
          _Phase.evaluated => AppCard(
            key: const ValueKey('speaking-result'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.officialResultTitle,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  l10n.officialResultScore(
                    formatScore(_result!.score).isolateLtr,
                    formatScore(_result!.maximumScore).isolateLtr,
                  ),
                  style: theme.textTheme.headlineSmall,
                ),
                Text(l10n.attemptRecorded),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  key: const ValueKey('speaking-retake'),
                  onPressed: () => _start(retake: true),
                  child: Text(l10n.stageRetry),
                ),
              ],
            ),
          ),
        },
      ],
    );
  }
}
