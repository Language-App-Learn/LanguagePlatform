import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../vocabulary/domain/vocabulary_item.dart';
import '../../domain/example_sentence.dart';
import '../../domain/lesson.dart';

/// Bölüm başlığı (ikon + etiket).
class LessonSectionLabel extends StatelessWidget {
  const LessonSectionLabel({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconMd, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Diyalog: konuşmacıya göre sola/sağa (başlangıç/bitiş) hizalı balonlar.
class DialogueView extends StatelessWidget {
  const DialogueView({
    super.key,
    required this.content,
    required this.contentLanguage,
    required this.targetLanguage,
  });

  final DialogueContent content;

  /// Çevirilerin dili (öğrencinin bildiği dil).
  final String contentLanguage;

  /// Diyalog metninin dili (öğrenilen dil).
  final String targetLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final speakers = <String>[];
    for (final line in content.lines) {
      if (!speakers.contains(line.speaker)) speakers.add(line.speaker);
    }
    return Column(
      children: [
        LessonSectionLabel(
          icon: Icons.forum_outlined,
          label: context.l10n.lessonDialogue,
        ),
        for (final line in content.lines)
          Align(
            alignment: speakers.indexOf(line.speaker).isEven
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: Container(
              margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.8,
              ),
              decoration: BoxDecoration(
                color: speakers.indexOf(line.speaker).isEven
                    ? scheme.surfaceContainerHigh
                    : scheme.primaryContainer,
                borderRadius: AppRadius.lgAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.speaker, style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  ContentText(
                    line.text,
                    languageCode: targetLanguage,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    line.translation.resolve(contentLanguage),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Dersin kelime listesi.
class LessonVocabularyView extends StatelessWidget {
  const LessonVocabularyView({
    super.key,
    required this.items,
    required this.contentLanguage,
  });

  final List<VocabularyItem> items;
  final String contentLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        LessonSectionLabel(
          icon: Icons.translate,
          label: context.l10n.lessonVocabulary,
        ),
        for (final item in items)
          Card(
            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: ListTile(
              key: ValueKey('lesson-word:${item.id}'),
              title: ContentText(
                item.term,
                languageCode: item.languageCode,
                style: theme.textTheme.titleLarge,
              ),
              subtitle: item.transliteration == null
                  ? null
                  : Text(item.transliteration!.isolateLtr),
              trailing: Text(
                item.meaning.resolve(contentLanguage),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
      ],
    );
  }
}

/// Dilbilgisi açıklaması + örnekler.
class GrammarView extends StatelessWidget {
  const GrammarView({
    super.key,
    required this.content,
    required this.contentLanguage,
    required this.targetLanguage,
  });

  final GrammarContent content;
  final String contentLanguage;
  final String targetLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LessonSectionLabel(
              icon: Icons.menu_book_outlined,
              label: context.l10n.lessonGrammar,
            ),
            Text(
              content.title.resolve(contentLanguage),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              content.explanation.resolve(contentLanguage),
              style: theme.textTheme.bodyLarge,
            ),
            for (final example in content.examples) ...[
              const SizedBox(height: AppSpacing.md),
              ExampleSentenceView(
                example: example,
                contentLanguage: contentLanguage,
                targetLanguage: targetLanguage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Örnek cümle + çevirisi.
class ExampleSentenceView extends StatelessWidget {
  const ExampleSentenceView({
    super.key,
    required this.example,
    required this.contentLanguage,
    required this.targetLanguage,
  });

  final ExampleSentence example;
  final String contentLanguage;
  final String targetLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentText(
            example.text,
            languageCode: targetLanguage,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            example.translation.resolve(contentLanguage),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Neutral placeholder for a block type this app version cannot render.
class UnsupportedContentView extends StatelessWidget {
  const UnsupportedContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return NoticeBanner(
      key: const ValueKey('unsupported-content'),
      message: context.l10n.unsupportedContent,
    );
  }
}
