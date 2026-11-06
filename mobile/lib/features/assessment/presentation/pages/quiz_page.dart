import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/confirm_dialog.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../language_selection/application/content_language.dart';
import '../../application/quiz_providers.dart';
import '../../domain/quiz.dart';
import '../widgets/question_view.dart';
import '../widgets/quiz_result_view.dart';

/// Quiz: question -> check -> next -> result -> retry. Leaving in the middle
/// of an attempt asks for confirmation (the attempt is not saved).
class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  bool _confirmedLeave = false;

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await showConfirmDialog(
      context,
      title: l10n.leaveQuizTitle,
      message: l10n.leaveQuizMessage,
      confirmLabel: l10n.leaveQuizConfirm,
      destructive: true,
    );
    if (leave != true || !mounted) return;
    setState(() => _confirmedLeave = true);
    // Pop after the rebuild that allows it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _close();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = quizControllerProvider(widget.lessonId);
    final value = ref.watch(provider);
    final state = value.value;
    final inProgress =
        state != null &&
        !state.isEmpty &&
        !state.isFinished &&
        (state.answers.isNotEmpty || state.selected != null);

    return PopScope(
      canPop: !inProgress || _confirmedLeave,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.quizTitle)),
        body: SafeArea(
          child: AsyncValueView<QuizState>(
            value: value,
            onRetry: () => ref.invalidate(provider),
            data: (state) => state.isEmpty
                ? EmptyStateView(
                    icon: Icons.quiz_outlined,
                    title: context.l10n.quizEmptyTitle,
                  )
                : ContentWidth(
                    child: ListView(
                      padding: AppSpacing.page,
                      children: [
                        state.isFinished
                            ? QuizResultView(
                                result: state.result!,
                                onRetry: ref.read(provider.notifier).restart,
                                onDone: _close,
                              )
                            : _QuestionStep(
                                lessonId: widget.lessonId,
                                state: state,
                              ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _QuestionStep extends ConsumerWidget {
  const _QuestionStep({required this.lessonId, required this.state});

  final String lessonId;
  final QuizState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(quizControllerProvider(lessonId).notifier);
    final question = state.current;
    final selectedId = switch (state.selected) {
      MultipleChoiceAnswer(:final optionId) => optionId,
      TrueFalseAnswer(:final value) => value.toString(),
      null => null,
    };
    // Every supported question type is presented as choices.
    final choices = switch (question) {
      MultipleChoiceQuestion() => question,
      TrueFalseQuestion() => question.asChoices(
        trueLabel: LocalizedText.plain(l10n.answerTrue),
        falseLabel: LocalizedText.plain(l10n.answerFalse),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quizQuestionOf(state.index + 1, state.questions.length),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppProgressBar(
          value: state.index / state.questions.length,
          semanticLabel: l10n.quizQuestionOf(
            state.index + 1,
            state.questions.length,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Yeni soruya geçerken durum sıfırlansın diye soru kimliği anahtar.
        QuestionView(
          key: ValueKey(question.id),
          question: choices,
          languageCode: ref.watch(contentLanguageProvider),
          selectedOptionId: selectedId,
          checked: state.checked,
          onSelect: (id) => controller.select(
            question is TrueFalseQuestion
                ? TrueFalseAnswer(question.id, id == 'true')
                : MultipleChoiceAnswer(question.id, id),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (!state.checked)
          AppPrimaryButton(
            label: l10n.checkAnswer,
            onPressed: state.selected == null ? null : controller.check,
          )
        else
          AppPrimaryButton(
            label: state.isLast ? l10n.quizFinish : l10n.quizNext,
            icon: state.isLast ? Icons.flag_outlined : Icons.arrow_forward,
            onPressed: controller.next,
          ),
      ],
    );
  }
}
