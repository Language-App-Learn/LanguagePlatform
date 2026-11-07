import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/stage_content.dart';
import '../../domain/stage_grading.dart';
import 'stage_widgets.dart';

/// Arabic is laid out right-to-left inside any UI language, so blanks and
/// tokens keep their logical (reading) order.
Widget _rtl(Widget child) =>
    Directionality(textDirection: TextDirection.rtl, child: child);

// ---------------------------------------------------------------- Listening

/// Listening: shuffled word bank + sentences with blanks. Words can be
/// dragged OR placed by tapping (accessible alternative). Every bank entry
/// is a separate instance, so repeated words work. Audio is not connected.
class ListeningStageBody extends StatefulWidget {
  const ListeningStageBody({
    super.key,
    required this.content,
    required this.onFinish,
  });

  final ListeningContent content;
  final ValueChanged<int?> onFinish;

  @override
  State<ListeningStageBody> createState() => _ListeningStageBodyState();
}

class _ListeningStageBodyState extends State<ListeningStageBody> {
  late List<int?> _placed = List.filled(widget.content.blankCount, null);
  int? _selectedBank;
  bool _checked = false;

  bool _isUsed(int bankIndex) => _placed.contains(bankIndex);

  void _place(int blank, int bankIndex) {
    if (_checked) return;
    setState(() {
      final previous = _placed.indexOf(bankIndex);
      if (previous >= 0) _placed[previous] = null;
      _placed[blank] = bankIndex;
      _selectedBank = null;
    });
  }

  void _tapBlank(int blank) {
    if (_checked) return;
    if (_selectedBank != null) {
      _place(blank, _selectedBank!);
    } else if (_placed[blank] != null) {
      setState(() => _placed[blank] = null); // return the word to the bank
    }
  }

  void _reset() => setState(() {
    _placed = List.filled(widget.content.blankCount, null);
    _selectedBank = null;
    _checked = false;
  });

  List<String?> get _words => [
    for (final i in _placed) i == null ? null : widget.content.wordBank[i],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = widget.content;
    final correct = gradeBlanks(_words, c.answers);
    var blankNumber = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NoticeBanner(
          key: const ValueKey('listening-note'),
          message: l10n.listeningInstruction,
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: l10n.wordBank),
        _rtl(
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < c.wordBank.length; i++)
                _isUsed(i)
                    ? const SizedBox.shrink()
                    : Draggable<int>(
                        data: i,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Chip(label: Text(c.wordBank[i])),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: Chip(label: Text(c.wordBank[i])),
                        ),
                        child: ChoiceChip(
                          key: ValueKey('bank:$i'),
                          label: Text(
                            c.wordBank[i],
                            style: theme.textTheme.titleLarge,
                          ),
                          selected: _selectedBank == i,
                          onSelected: _checked
                              ? null
                              : (_) => setState(
                                  () => _selectedBank = _selectedBank == i
                                      ? null
                                      : i,
                                ),
                        ),
                      ),
            ],
          ),
        ),
        Text(l10n.tapToPlace, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.lg),
        for (final sentence in c.sentences)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: _rtl(
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final part in sentence.parts)
                    if (part != null)
                      Text(part, style: theme.textTheme.headlineSmall)
                    else
                      Builder(
                        builder: (context) {
                          final blank = blankNumber++;
                          return _BlankTarget(
                            index: blank,
                            word: _placed[blank] == null
                                ? null
                                : c.wordBank[_placed[blank]!],
                            correct: !_checked
                                ? null
                                : _words[blank] == c.answers[blank],
                            semanticsLabel: l10n.blankLabel(blank + 1),
                            onAccept: (bank) => _place(blank, bank),
                            onTap: () => _tapBlank(blank),
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        if (!_checked)
          Row(
            children: [
              OutlinedButton(
                key: const ValueKey('reset'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(88, AppSizes.buttonHeight),
                ),
                onPressed: _reset,
                child: Text(l10n.resetStage),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppPrimaryButton(
                  label: l10n.checkStage,
                  onPressed: _placed.every((p) => p != null)
                      ? () => setState(() => _checked = true)
                      : null,
                ),
              ),
            ],
          )
        else
          PracticeResult(
            correct: correct,
            total: c.blankCount,
            onFinish: () => widget.onFinish(percentOf(correct, c.blankCount)),
          ),
      ],
    );
  }
}

class _BlankTarget extends StatelessWidget {
  const _BlankTarget({
    required this.index,
    required this.word,
    required this.correct,
    required this.semanticsLabel,
    required this.onAccept,
    required this.onTap,
  });

  final int index;
  final String? word;
  final bool? correct;
  final String semanticsLabel;
  final ValueChanged<int> onAccept;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DragTarget<int>(
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidates, _) {
        final highlight = candidates.isNotEmpty;
        final color = correct == null
            ? (highlight ? scheme.primary : scheme.outline)
            : (correct! ? Colors.green : scheme.error);
        return Semantics(
          button: true,
          label: semanticsLabel,
          value: word,
          child: InkWell(
            key: ValueKey('blank:$index'),
            onTap: onTap,
            borderRadius: AppRadius.smAll,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 88,
                minHeight: AppSizes.minTouchTarget,
              ),
              margin: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xs,
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                word ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------ Writing

/// Writing: type the missing word, and build a sentence from a shuffled
/// word bank by tapping (duplicates supported, undo/reset available).
class WritingStageBody extends StatefulWidget {
  const WritingStageBody({
    super.key,
    required this.content,
    required this.onFinish,
  });

  final WritingContent content;
  final ValueChanged<int?> onFinish;

  @override
  State<WritingStageBody> createState() => _WritingStageBodyState();
}

class _WritingStageBodyState extends State<WritingStageBody> {
  late final List<TextEditingController> _fills = [
    for (final _ in widget.content.fillBlanks) TextEditingController(),
  ];
  late final List<List<int>> _picked = [
    for (final _ in widget.content.arrange) <int>[],
  ];
  bool _checked = false;

  @override
  void dispose() {
    for (final c in _fills) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _tokens(int item) {
    final a = widget.content.arrange[item];
    return [for (final i in _picked[item]) a.correctOrder[a.shownOrder[i]]];
  }

  bool _fillOk(int i) =>
      gradeText(_fills[i].text, widget.content.fillBlanks[i].accepted);

  bool _arrangeOk(int i) =>
      gradeArrangement(_tokens(i), widget.content.arrange[i].correctOrder);

  int get _correct => [
    for (var i = 0; i < _fills.length; i++) _fillOk(i),
    for (var i = 0; i < _picked.length; i++) _arrangeOk(i),
  ].where((ok) => ok).length;

  int get _total => _fills.length + _picked.length;

  bool get _complete =>
      _fills.every((c) => c.text.trim().isNotEmpty) &&
      List.generate(_picked.length, (i) => i).every(
        (i) =>
            _picked[i].length == widget.content.arrange[i].correctOrder.length,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = widget.content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.writingFillTitle),
        for (var i = 0; i < c.fillBlanks.length; i++)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: _rtl(
              Row(
                children: [
                  Text(
                    c.fillBlanks[i].before,
                    style: theme.textTheme.titleLarge,
                  ),
                  Expanded(
                    child: TextField(
                      key: ValueKey('fill:$i'),
                      controller: _fills[i],
                      enabled: !_checked,
                      textDirection: TextDirection.rtl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(labelText: l10n.yourAnswer),
                    ),
                  ),
                  Text(
                    c.fillBlanks[i].after,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: l10n.writingArrangeTitle),
        for (var i = 0; i < c.arrange.length; i++) ...[
          Text(l10n.wordBank, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          _rtl(
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var j = 0; j < c.arrange[i].shownOrder.length; j++)
                  _picked[i].contains(j)
                      ? const SizedBox.shrink()
                      : ActionChip(
                          key: ValueKey('arrange-bank:$i:$j'),
                          label: Text(
                            c.arrange[i].correctOrder[c
                                .arrange[i]
                                .shownOrder[j]],
                            style: theme.textTheme.titleLarge,
                          ),
                          onPressed: _checked
                              ? null
                              : () => setState(() => _picked[i].add(j)),
                        ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            key: ValueKey('arrange-answer:$i'),
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: AppRadius.mdAll,
            ),
            child: _rtl(
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final (k, token) in _tokens(i).indexed)
                    InputChip(
                      key: ValueKey('arrange-token:$i:$k'),
                      label: Text(token, style: theme.textTheme.titleLarge),
                      onDeleted: _checked
                          ? null
                          : () => setState(() => _picked[i].removeAt(k)),
                    ),
                ],
              ),
            ),
          ),
          if (!_checked)
            Row(
              children: [
                TextButton(
                  key: ValueKey('arrange-undo:$i'),
                  onPressed: _picked[i].isEmpty
                      ? null
                      : () => setState(() => _picked[i].removeLast()),
                  child: Text(l10n.undoStep),
                ),
                TextButton(
                  key: ValueKey('arrange-reset:$i'),
                  onPressed: _picked[i].isEmpty
                      ? null
                      : () => setState(() => _picked[i].clear()),
                  child: Text(l10n.resetStage),
                ),
              ],
            ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (!_checked)
          AppPrimaryButton(
            label: l10n.checkStage,
            onPressed: _complete ? () => setState(() => _checked = true) : null,
          )
        else
          PracticeResult(
            correct: _correct,
            total: _total,
            onFinish: () => widget.onFinish(percentOf(_correct, _total)),
          ),
      ],
    );
  }
}

// -------------------------------------------------------------- Translation

/// Translation Turkish -> Arabic: choose the right Arabic option, or write
/// the Arabic translation. Accepted alternatives come from the content.
class TranslationStageBody extends StatefulWidget {
  const TranslationStageBody({
    super.key,
    required this.content,
    required this.onFinish,
  });

  final TranslationContent content;
  final ValueChanged<int?> onFinish;

  @override
  State<TranslationStageBody> createState() => _TranslationStageBodyState();
}

class _TranslationStageBodyState extends State<TranslationStageBody> {
  late final List<int?> _choices = List.filled(
    widget.content.choice.length,
    null,
  );
  late final List<TextEditingController> _texts = [
    for (final _ in widget.content.write) TextEditingController(),
  ];
  bool _checked = false;

  @override
  void dispose() {
    for (final c in _texts) {
      c.dispose();
    }
    super.dispose();
  }

  int get _total => _choices.length + _texts.length;

  int get _correct => [
    for (var i = 0; i < _choices.length; i++)
      _choices[i] == widget.content.choice[i].correctIndex,
    for (var i = 0; i < _texts.length; i++)
      gradeText(_texts[i].text, widget.content.write[i].accepted),
  ].where((ok) => ok).length;

  bool get _complete =>
      _choices.every((c) => c != null) &&
      _texts.every((c) => c.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = widget.content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.translationChoiceTitle),
        for (var i = 0; i < c.choice.length; i++) ...[
          Text(c.choice[i].turkish, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ChoiceGroup<int>(
            groupId: 'translation-choice-$i',
            layout: ChoiceGroupLayout.list,
            selected: _choices[i],
            onSelected: (v) {
              if (!_checked) setState(() => _choices[i] = v);
            },
            options: [
              for (var j = 0; j < c.choice[i].options.length; j++)
                ChoiceOption(
                  id: '$j',
                  value: j,
                  label: c.choice[i].options[j],
                  enabled: !_checked,
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: l10n.translationWriteTitle),
        for (var i = 0; i < c.write.length; i++) ...[
          Text(c.write[i].turkish, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: ValueKey('translate:$i'),
            controller: _texts[i],
            enabled: !_checked,
            textDirection: TextDirection.rtl,
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.yourAnswer),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (!_checked)
          AppPrimaryButton(
            label: l10n.checkStage,
            onPressed: _complete ? () => setState(() => _checked = true) : null,
          )
        else
          PracticeResult(
            correct: _correct,
            total: _total,
            onFinish: () => widget.onFinish(percentOf(_correct, _total)),
          ),
      ],
    );
  }
}
