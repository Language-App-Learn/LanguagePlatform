import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/quiz.dart';

/// Çoktan seçmeli soru görünümü (quiz ve ders içi alıştırma paylaşır).
///
/// Durumsuzdur: seçim ve kontrol durumu çağıran tarafından yönetilir.
class QuestionView extends StatelessWidget {
  const QuestionView({
    super.key,
    required this.question,
    required this.languageCode,
    required this.selectedOptionId,
    required this.checked,
    required this.onSelect,
  });

  final MultipleChoiceQuestion question;

  /// Soru/şık çevirilerinin gösterileceği dil (öğrencinin bildiği dil).
  final String languageCode;
  final String? selectedOptionId;
  final bool checked;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final correct = checked && selectedOptionId == question.correctOptionId;
    final explanation = question.explanation?.resolve(languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            question.prompt.resolve(languageCode),
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final option in question.options)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: _OptionTile(
              key: ValueKey('option:${option.id}'),
              label: option.text.resolve(languageCode),
              state: _stateOf(option.id),
              onTap: checked ? null : () => onSelect(option.id),
            ),
          ),
        if (checked) ...[
          const SizedBox(height: AppSpacing.sm),
          _Feedback(
            correct: correct,
            title: correct ? l10n.answerCorrect : l10n.answerIncorrect,
            explanation: explanation,
          ),
        ],
      ],
    );
  }

  _OptionState _stateOf(String optionId) {
    if (!checked) {
      return optionId == selectedOptionId
          ? _OptionState.selected
          : _OptionState.idle;
    }
    if (optionId == question.correctOptionId) return _OptionState.correct;
    if (optionId == selectedOptionId) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final (border, background, icon, iconColor) = switch (state) {
      _OptionState.idle => (
        scheme.outlineVariant,
        null,
        Icons.radio_button_unchecked,
        scheme.outline,
      ),
      _OptionState.selected => (
        scheme.primary,
        scheme.primaryContainer,
        Icons.radio_button_checked,
        scheme.primary,
      ),
      _OptionState.correct => (
        semantic.success,
        semantic.successContainer,
        Icons.check_circle,
        semantic.success,
      ),
      _OptionState.wrong => (
        scheme.error,
        scheme.errorContainer,
        Icons.cancel,
        scheme.error,
      ),
    };
    return Semantics(
      button: true,
      selected: state == _OptionState.selected || state == _OptionState.correct,
      child: Card(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: border,
            width: state == _OptionState.idle ? 1 : 2,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          minVerticalPadding: AppSpacing.md,
          title: Text(label),
          trailing: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.correct,
    required this.title,
    required this.explanation,
  });

  final bool correct;
  final String title;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final background = correct
        ? semantic.successContainer
        : scheme.errorContainer;
    final foreground = correct
        ? semantic.onSuccessContainer
        : scheme.onErrorContainer;
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('answer-feedback'),
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
            if (explanation != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(explanation!, style: TextStyle(color: foreground)),
            ],
          ],
        ),
      ),
    );
  }
}
