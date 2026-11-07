import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../assessment/domain/quiz.dart';
import '../../../assessment/presentation/widgets/question_view.dart';
import '../../domain/remote_models.dart';

/// Server placeholder for the position of a blank inside a prompt.
const blankMarker = '{{blank}}';

/// Renders one server question by its REAL kind. The widgets hold no answer
/// key (the API never sends one) and report answers as ids / exact text, the
/// same shapes the submit endpoint expects.
class RemoteQuestionCard extends StatelessWidget {
  const RemoteQuestionCard({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
    this.enabled = true,
  });

  final RemoteQuestion question;
  final RemoteAnswer? answer;
  final ValueChanged<RemoteAnswer?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (question.type) {
      RemoteQuestionKind.multipleChoice ||
      RemoteQuestionKind.trueFalse => _choice(context),
      RemoteQuestionKind.wordBank => WordBankQuestionView(
        question: question,
        selectedOptionId: answer?.optionId,
        enabled: enabled,
        onSelect: (id) =>
            onChanged(RemoteAnswer(questionId: question.id, optionId: id)),
      ),
      RemoteQuestionKind.fillBlank ||
      RemoteQuestionKind.exactText => TextAnswerQuestionView(
        question: question,
        enabled: enabled,
        initialText: answer?.text ?? '',
        onChanged: (text) => onChanged(
          text.isEmpty
              ? null
              : RemoteAnswer(questionId: question.id, text: text),
        ),
      ),
      RemoteQuestionKind.wordOrder => WordOrderQuestionView(
        question: question,
        order: answer?.orderedOptionIds ?? const [],
        enabled: enabled,
        onChanged: (ids) => onChanged(
          ids.isEmpty
              ? null
              : RemoteAnswer(questionId: question.id, orderedOptionIds: ids),
        ),
      ),
      RemoteQuestionKind.unknown => Text(l10n.unsupportedQuestion),
    };
  }

  /// MultipleChoice / TrueFalse reuse the shared quiz view in its
  /// "unchecked" state (the server does not reveal answers).
  Widget _choice(BuildContext context) {
    final l10n = context.l10n;
    final options = question.isTrueFalse
        ? [
            QuizOption(id: 'true', text: LocalizedText.plain(l10n.answerTrue)),
            QuizOption(
              id: 'false',
              text: LocalizedText.plain(l10n.answerFalse),
            ),
          ]
        : [
            for (final o in question.options)
              QuizOption(id: o.id, text: LocalizedText.plain(o.text)),
          ];
    final selected = question.isTrueFalse
        ? answer?.value?.toString()
        : answer?.optionId;
    return QuestionView(
      key: ValueKey('remote-question:${question.id}'),
      question: MultipleChoiceQuestion(
        id: question.id,
        prompt: LocalizedText.plain(question.prompt),
        options: options,
        correctOptionId: '', // no key exists on the client
      ),
      languageCode: context.languageCode,
      selectedOptionId: selected,
      checked: false,
      onSelect: enabled
          ? (id) => onChanged(
              question.isTrueFalse
                  ? RemoteAnswer(questionId: question.id, value: id == 'true')
                  : RemoteAnswer(questionId: question.id, optionId: id),
            )
          : (_) {},
    );
  }
}

/// Prompt with `{{blank}}` rendered as an inline box (optionally filled).
class _BlankPrompt extends StatelessWidget {
  const _BlankPrompt({
    required this.prompt,
    required this.fill,
    this.dropTarget,
  });

  final String prompt;
  final String? fill;
  final ValueChanged<String>? dropTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final lang = contentLanguageOf(prompt, fallback: context.languageCode);
    final parts = prompt.split(blankMarker);

    Widget blank() {
      final box = Container(
        key: const ValueKey('blank-slot'),
        constraints: const BoxConstraints(minWidth: 72, minHeight: 40),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        ),
        child: fill == null
            ? Text(
                l10n.rqBlank,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            : ContentText(
                fill!,
                languageCode: contentLanguageOf(fill!, fallback: lang),
                style: theme.textTheme.titleLarge,
              ),
      );
      return Semantics(
        label: fill ?? l10n.rqBlank,
        child: dropTarget == null
            ? box
            : DragTarget<String>(
                onAcceptWithDetails: (d) => dropTarget!(d.data),
                builder: (_, _, _) => box,
              ),
      );
    }

    return Directionality(
      textDirection: textDirectionForLanguage(lang),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: AppSpacing.sm,
        children: [
          for (var i = 0; i < parts.length; i++) ...[
            if (parts[i].isNotEmpty)
              ContentText(
                parts[i],
                languageCode: lang,
                style: theme.textTheme.titleLarge,
              ),
            if (i < parts.length - 1) blank(),
          ],
        ],
      ),
    );
  }
}

/// WordBank: pick the word for the blank. Tapping a word fills the blank
/// (the accessible path); words can also be dragged onto it.
class WordBankQuestionView extends StatelessWidget {
  const WordBankQuestionView({
    super.key,
    required this.question,
    required this.selectedOptionId,
    required this.onSelect,
    this.enabled = true,
  });

  final RemoteQuestion question;
  final String? selectedOptionId;
  final ValueChanged<String> onSelect;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selected = question.options
        .where((o) => o.id == selectedOptionId)
        .map((o) => o.text)
        .firstOrNull;
    return Column(
      key: ValueKey('remote-question:${question.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.rqChooseWord, style: theme.textTheme.titleSmall),
        ),
        const SizedBox(height: AppSpacing.sm),
        _BlankPrompt(
          prompt: question.prompt.contains(blankMarker)
              ? question.prompt
              : '${question.prompt} $blankMarker',
          fill: selected,
          dropTarget: enabled ? onSelect : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.rqWordBank, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final o in question.options)
              _WordChip(
                key: ValueKey('option:${o.id}'),
                id: o.id,
                text: o.text,
                selected: o.id == selectedOptionId,
                onTap: enabled ? () => onSelect(o.id) : null,
                draggable: enabled,
              ),
          ],
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    super.key,
    required this.id,
    required this.text,
    required this.onTap,
    this.selected = false,
    this.draggable = false,
  });

  final String id;
  final String text;
  final bool selected;
  final bool draggable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lang = contentLanguageOf(text, fallback: context.languageCode);
    final label = ContentText(
      text,
      languageCode: lang,
      style: Theme.of(context).textTheme.titleMedium,
    );
    final chip = ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
    if (!draggable) return chip;
    return Draggable<String>(
      data: id,
      feedback: Material(
        color: Colors.transparent,
        child: ChoiceChip(label: label, selected: true, onSelected: (_) {}),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: chip),
      child: chip,
    );
  }
}

/// FillBlank / ExactText: the learner types the Arabic answer. The text is
/// reported EXACTLY as typed (diacritics and spacing intact); the server
/// does the comparison.
class TextAnswerQuestionView extends StatefulWidget {
  const TextAnswerQuestionView({
    super.key,
    required this.question,
    required this.initialText,
    required this.onChanged,
    this.enabled = true,
  });

  final RemoteQuestion question;
  final String initialText;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<TextAnswerQuestionView> createState() => _TextAnswerQuestionViewState();
}

class _TextAnswerQuestionViewState extends State<TextAnswerQuestionView> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final q = widget.question;
    return Column(
      key: ValueKey('remote-question:${q.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: q.prompt.contains(blankMarker)
              ? _BlankPrompt(prompt: q.prompt, fill: null)
              : ContentText(
                  q.prompt,
                  languageCode: contentLanguageOf(
                    q.prompt,
                    fallback: context.languageCode,
                  ),
                  style: theme.textTheme.titleLarge,
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          key: ValueKey('text-answer:${q.id}'),
          controller: _controller,
          enabled: widget.enabled,
          // The expected answer is Arabic: right-to-left entry.
          textDirection: TextDirection.rtl,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          style: theme.textTheme.titleLarge,
          decoration: InputDecoration(
            labelText: l10n.rqTypeAnswer,
            hintText: l10n.rqArabicHint,
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

/// WordOrder: build the sentence from tokens. Each token keeps its own id
/// (repeated words are distinct tokens) and the answer is the id sequence in
/// logical order. Tap to place / remove; tokens can also be dragged onto the
/// answer area.
class WordOrderQuestionView extends StatelessWidget {
  const WordOrderQuestionView({
    super.key,
    required this.question,
    required this.order,
    required this.onChanged,
    this.enabled = true,
  });

  final RemoteQuestion question;
  final List<String> order;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  RemoteOption? _option(String id) =>
      question.options.where((o) => o.id == id).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final placed = order.toSet();
    final bank = [
      for (final o in question.options)
        if (!placed.contains(o.id)) o,
    ];
    final promptLang = contentLanguageOf(
      question.prompt,
      fallback: context.languageCode,
    );
    final answerText = order.map((id) => _option(id)?.text ?? '').join(' ');
    final answerLang = contentLanguageOf(
      question.options.map((o) => o.text).join(' '),
      fallback: promptLang,
    );
    return Column(
      key: ValueKey('remote-question:${question.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: ContentText(
            question.prompt,
            languageCode: promptLang,
            style: theme.textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.rqYourOrder, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        DragTarget<String>(
          onAcceptWithDetails: (d) {
            if (enabled && !placed.contains(d.data)) {
              onChanged([...order, d.data]);
            }
          },
          builder: (_, _, _) => Semantics(
            label: answerText,
            child: Container(
              key: const ValueKey('order-answer'),
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Directionality(
                textDirection: textDirectionForLanguage(answerLang),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final id in order)
                      _WordChip(
                        key: ValueKey('placed:$id'),
                        id: id,
                        text: _option(id)?.text ?? '',
                        selected: true,
                        onTap: enabled
                            ? () => onChanged([...order]..remove(id))
                            : null,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l10n.rqWordBank, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Directionality(
          textDirection: textDirectionForLanguage(answerLang),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final o in bank)
                _WordChip(
                  key: ValueKey('token:${o.id}'),
                  id: o.id,
                  text: o.text,
                  draggable: enabled,
                  onTap: enabled ? () => onChanged([...order, o.id]) : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            TextButton.icon(
              key: const ValueKey('order-undo'),
              onPressed: enabled && order.isNotEmpty
                  ? () => onChanged(order.sublist(0, order.length - 1))
                  : null,
              icon: const Icon(Icons.undo),
              label: Text(l10n.rqUndo),
            ),
            TextButton.icon(
              key: const ValueKey('order-reset'),
              onPressed: enabled && order.isNotEmpty
                  ? () => onChanged(const [])
                  : null,
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.rqReset),
            ),
          ],
        ),
      ],
    );
  }
}
