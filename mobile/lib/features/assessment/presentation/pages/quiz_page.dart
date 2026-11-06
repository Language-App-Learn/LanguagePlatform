import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../language_selection/application/content_language.dart';
import '../../application/quiz_providers.dart';
import '../../domain/quiz.dart';
import '../widgets/question_view.dart';
import '../widgets/quiz_result_view.dart';

/// Quiz: soru → kontrol → sonraki → sonuç → tekrar dene.
class QuizPage extends ConsumerWidget {
  const QuizPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quizControllerProvider(lessonId);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.quizTitle)),
      body: SafeArea(
        child: AsyncValueView<QuizState>(
          value: ref.watch(provider),
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
                              onDone: () => _close(context),
                            )
                          : _QuestionStep(lessonId: lessonId, state: state),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
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
