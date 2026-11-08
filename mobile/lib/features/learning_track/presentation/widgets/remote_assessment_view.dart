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
import 'remote_question_widgets.dart';

enum _Phase { idle, loading, answering, submitting, done }

/// Failures after which retrying the SAME request makes no sense: the server
/// gave a definitive answer, so the pending idempotency key is released.
bool _isDefinitive(Object error) => switch (failureOf(error)) {
  ConflictFailure() ||
  ValidationFailure() ||
  NotFoundFailure() ||
  ForbiddenFailure() ||
  UnauthorizedFailure() => true,
  _ => false,
};

/// Objective, server-graded activity of a stage (multiple choice, true/false,
/// word bank, fill-in, word order, exact text). Questions arrive WITHOUT
/// answer keys; the server grades and the result is displayed exactly as
/// returned (score, maximum, threshold and the server's pass decision).
///
/// Attempt lifecycle: the idempotency key of a started attempt is kept (also
/// across app restarts) until it is submitted, so an ambiguous failure never
/// produces a second attempt; only a deliberate retake gets a new key.
class RemoteAssessmentView extends ConsumerStatefulWidget {
  const RemoteAssessmentView({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.assessmentId,
  });

  final String courseId;
  final String lessonId;
  final String assessmentId;

  @override
  ConsumerState<RemoteAssessmentView> createState() =>
      _RemoteAssessmentViewState();
}

class _RemoteAssessmentViewState extends ConsumerState<RemoteAssessmentView> {
  _Phase _phase = _Phase.idle;
  RemoteAttempt? _attempt;
  final Map<String, RemoteAnswer> _answers = {};
  RemoteAssessmentResult? _result;
  Object? _error;
  bool _submitUnsure = false;
  bool _resumed = false;

  FiveStageRepository get _repo => ref.read(fiveStageRepositoryProvider);
  PendingAttemptStore get _keys => ref.read(pendingAttemptStoreProvider);

  Future<void> _start({bool retake = false}) async {
    final hadPending = !retake && _keys.pending(widget.assessmentId) != null;
    setState(() {
      _phase = _Phase.loading;
      _error = null;
      _submitUnsure = false;
      _answers.clear();
      _result = null;
      _resumed = hadPending;
    });
    try {
      // Enrollment and lesson start are idempotent prerequisites.
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
        _attempt = attempt;
        _phase = _Phase.answering;
      });
    } on Object catch (error) {
      // Ambiguous failures (timeout, network, 5xx) keep the key so a retry
      // reuses it; a definitive rejection releases it.
      if (_isDefinitive(error)) await _keys.complete(widget.assessmentId);
      if (!mounted) return;
      setState(() {
        _error = error;
        _phase = _Phase.idle;
      });
    }
  }

  bool get _canSubmit {
    final attempt = _attempt;
    if (attempt == null || attempt.questions.isEmpty) return false;
    return attempt.questions.every(
      (q) => q.isSupported && isAnswerComplete(q, _answers[q.id]),
    );
  }

  Future<void> _submit() async {
    final attempt = _attempt!;
    setState(() {
      _phase = _Phase.submitting;
      _error = null;
      _submitUnsure = false;
    });
    try {
      final result = await _repo.submitAttempt(
        courseId: widget.courseId,
        lessonId: widget.lessonId,
        assessmentId: widget.assessmentId,
        attemptId: attempt.id,
        answers: [for (final q in attempt.questions) _answers[q.id]!],
      );
      await _keys.complete(widget.assessmentId);
      // Official state changed on the server: reload what depends on it.
      ref
        ..invalidate(remoteProgressProvider(widget.lessonId))
        ..invalidate(passedLessonIdsProvider);
      if (!mounted) return;
      setState(() {
        _result = result;
        _phase = _Phase.done;
      });
    } on Object catch (error) {
      final failure = failureOf(error);
      final ambiguous =
          failure is NetworkUnavailableFailure || failure is TimeoutFailure;
      if (_isDefinitive(error)) {
        // E.g. 409: attempt closed or past its deadline. Nothing to resume.
        await _keys.complete(widget.assessmentId);
      }
      if (!mounted) return;
      setState(() {
        _error = error;
        // The submit may or may not have reached the server. Resubmitting is
        // safe (the server returns the first recorded grade); the answers
        // stay on screen.
        _submitUnsure = ambiguous;
        _phase = _isDefinitive(error) ? _Phase.idle : _Phase.answering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: NoticeBanner(
              key: const ValueKey('assessment-error'),
              message: _submitUnsure
                  ? l10n.attemptSubmitUnsure
                  : failureOf(_error).message(l10n),
            ),
          ),
        if (_resumed && _phase == _Phase.answering)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: NoticeBanner(
              key: const ValueKey('attempt-restored'),
              message: l10n.attemptRestored,
            ),
          ),
        switch (_phase) {
          _Phase.idle => AppPrimaryButton(
            key: const ValueKey('start-assessment'),
            label: l10n.startAssessment,
            icon: Icons.play_arrow,
            onPressed: _start,
          ),
          _Phase.loading => const Center(child: CircularProgressIndicator()),
          _Phase.answering || _Phase.submitting => _questions(context),
          _Phase.done => _resultCard(context),
        },
      ],
    );
  }

  Widget _questions(BuildContext context) {
    final l10n = context.l10n;
    final attempt = _attempt!;
    final submitting = _phase == _Phase.submitting;
    if (attempt.questions.isEmpty) {
      return NoticeBanner(message: l10n.rqNoQuestions);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final q in attempt.questions)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
            child: q.isSupported
                ? RemoteQuestionCard(
                    key: ValueKey('rq:${q.id}'),
                    question: q,
                    answer: _answers[q.id],
                    enabled: !submitting,
                    onChanged: (a) => setState(() {
                      if (a == null) {
                        _answers.remove(q.id);
                      } else {
                        _answers[q.id] = a;
                      }
                    }),
                  )
                : NoticeBanner(message: l10n.unsupportedQuestion),
          ),
        AppPrimaryButton(
          key: const ValueKey('submit-answers'),
          label: l10n.submitAnswers,
          isLoading: submitting,
          onPressed: _canSubmit ? _submit : null,
        ),
      ],
    );
  }

  Widget _resultCard(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final r = _result!;
    return AppCard(
      key: const ValueKey('assessment-result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.officialResultTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.officialResultScore(
              formatScore(r.score).isolateLtr,
              formatScore(r.maximumScore).isolateLtr,
            ),
            style: theme.textTheme.headlineSmall,
          ),
          // No pass/fail here on purpose: the objective result's `passed`
          // uses an assessment threshold of zero. The lesson verdict comes
          // only from the curriculum progress shown on the lesson page.
          Text(
            l10n.attemptRecorded,
            key: const ValueKey('attempt-recorded'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            key: const ValueKey('retry-assessment'),
            onPressed: () => _start(retake: true),
            child: Text(l10n.stageRetry),
          ),
        ],
      ),
    );
  }
}
