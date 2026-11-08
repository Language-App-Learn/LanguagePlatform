import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../assessment/presentation/widgets/question_view.dart';
import '../../../language_selection/application/content_language.dart';
import '../../../lessons/domain/lesson.dart';
import '../../../lessons/presentation/widgets/lesson_sections.dart';
import '../../domain/stage_content.dart';
import '../../domain/stage_grading.dart';
import 'stage_widgets.dart';

/// Unavailable-media row: a disabled control plus an honest explanation.
class UnavailableMediaCard extends StatelessWidget {
  const UnavailableMediaCard({
    super.key,
    required this.icon,
    required this.message,
    required this.keyName,
  });

  final IconData icon;
  final String message;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      key: ValueKey(keyName),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reading: server-approved logical lines with per-line audio control,
/// original PDF / teacher video slots, then the comprehension questions.
/// Audio, PDF and video are NOT connected yet and are shown as unavailable.
class ReadingStageBody extends ConsumerStatefulWidget {
  const ReadingStageBody({
    super.key,
    required this.content,
    required this.onFinish,
  });

  final ReadingContent content;
  final ValueChanged<int?> onFinish;

  @override
  ConsumerState<ReadingStageBody> createState() => _ReadingStageBodyState();
}

class _ReadingStageBodyState extends ConsumerState<ReadingStageBody> {
  final Map<String, String> _answers = {};
  bool _checked = false;

  int get _correct => widget.content.questions
      .where((q) => _answers[q.id] == q.correctOptionId)
      .length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final known = ref.watch(contentLanguageProvider);
    final questions = widget.content.questions;
    final allAnswered = questions.every((q) => _answers.containsKey(q.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.content.title.resolve(known),
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final line in widget.content.segments)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
            child: AppCard(
              key: ValueKey('segment:${line.id}'),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContentText(
                          line.arabic,
                          languageCode: 'ar',
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          line.translation.resolve(known),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Disabled until real approved audio exists.
                  IconButton(
                    key: ValueKey('play:${line.id}'),
                    tooltip: l10n.audioUnavailable,
                    onPressed: null,
                    icon: const Icon(Icons.volume_up_outlined),
                  ),
                ],
              ),
            ),
          ),
        UnavailableMediaCard(
          keyName: 'pdf-unavailable',
          icon: Icons.picture_as_pdf_outlined,
          message: l10n.pdfUnavailable,
        ),
        const SizedBox(height: AppSpacing.sm),
        UnavailableMediaCard(
          keyName: 'video-unavailable',
          icon: Icons.smart_display_outlined,
          message: l10n.videoUnavailable,
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.readingQuestionsTitle),
        for (final q in questions)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
            child: QuestionView(
              key: ValueKey(q.id),
              question: q,
              languageCode: known,
              selectedOptionId: _answers[q.id],
              checked: _checked,
              onSelect: (id) => setState(() => _answers[q.id] = id),
            ),
          ),
        if (!_checked)
          AppPrimaryButton(
            label: l10n.checkStage,
            onPressed: allAnswered
                ? () => setState(() => _checked = true)
                : null,
          )
        else
          PracticeResult(
            correct: _correct,
            total: questions.length,
            onFinish: () =>
                widget.onFinish(percentOf(_correct, questions.length)),
          ),
      ],
    );
  }
}

/// Speaking: structured dialogue (speaker bubbles, RTL Arabic) plus an
/// honest "not connected" block for audio, video and AI conversation
/// practice. No microphone permission is requested and nothing is recorded.
class SpeakingStageBody extends ConsumerWidget {
  const SpeakingStageBody({
    super.key,
    required this.lesson,
    required this.onFinish,
  });

  final Lesson lesson;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final known = ref.watch(contentLanguageProvider);
    final dialogue = lesson.contents.whereType<DialogueContent>().first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogueView(
          content: dialogue,
          contentLanguage: known,
          targetLanguage: lesson.languageCode,
        ),
        const SizedBox(height: AppSpacing.lg),
        UnavailableMediaCard(
          keyName: 'audio-unavailable',
          icon: Icons.volume_off_outlined,
          message: l10n.audioUnavailable,
        ),
        const SizedBox(height: AppSpacing.sm),
        UnavailableMediaCard(
          keyName: 'video-unavailable',
          icon: Icons.smart_display_outlined,
          message: l10n.videoUnavailable,
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.aiPracticeTitle),
        NoticeBanner(
          key: const ValueKey('ai-unavailable'),
          message: l10n.aiPracticeUnavailable,
        ),
        const SizedBox(height: AppSpacing.md),
        // Disabled microphone: real recording needs an approved plugin and a
        // configured backend provider.
        const Center(
          child: IconButton.filledTonal(
            key: ValueKey('mic-button'),
            onPressed: null,
            iconSize: 40,
            icon: Icon(Icons.mic_off_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: l10n.finishPractice,
          icon: Icons.check,
          onPressed: onFinish,
        ),
      ],
    );
  }
}
