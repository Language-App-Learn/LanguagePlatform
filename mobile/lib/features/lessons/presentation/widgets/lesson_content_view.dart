import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/lesson_providers.dart';
import '../../domain/lesson.dart';
import 'exercise_view.dart';
import 'lesson_sections.dart';

/// Tek bir [LessonContent] bloğunu türüne göre çizer. `LessonContent`
/// sealed olduğu için yeni içerik türü (ses, video, konuşma, AI ...)
/// eklendiğinde bu `switch` derlenmez ve işlenecek yer açıkça görünür.
class LessonContentView extends ConsumerWidget {
  const LessonContentView({
    super.key,
    required this.lesson,
    required this.content,
    required this.contentLanguage,
  });

  final Lesson lesson;
  final LessonContent content;

  /// Açıklama/çeviri dili (öğrencinin bildiği dil).
  final String contentLanguage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final target = lesson.languageCode;
    return switch (content) {
      HeadingContent(:final text) => Semantics(
        header: true,
        child: Text(
          text.resolve(contentLanguage),
          style: theme.textTheme.headlineSmall,
        ),
      ),
      TextContent(:final text) => Text(
        text.resolve(contentLanguage),
        style: theme.textTheme.bodyLarge,
      ),
      final DialogueContent dialogue => DialogueView(
        content: dialogue,
        contentLanguage: contentLanguage,
        targetLanguage: target,
      ),
      VocabularyContent(:final itemIds) => _VocabularySection(
        lessonId: lesson.id,
        itemIds: itemIds,
        contentLanguage: contentLanguage,
      ),
      final GrammarContent grammar => GrammarView(
        content: grammar,
        contentLanguage: contentLanguage,
        targetLanguage: target,
      ),
      ExampleContent(:final example) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LessonSectionLabel(
            icon: Icons.format_quote,
            label: context.l10n.lessonExample,
          ),
          ExampleSentenceView(
            example: example,
            contentLanguage: contentLanguage,
            targetLanguage: target,
          ),
        ],
      ),
      UnknownContent() => const UnsupportedContentView(),
      ExerciseContent(:final question) => ExerciseView(
        question: question,
        contentLanguage: contentLanguage,
      ),
    };
  }
}

class _VocabularySection extends ConsumerWidget {
  const _VocabularySection({
    required this.lessonId,
    required this.itemIds,
    required this.contentLanguage,
  });

  final String lessonId;
  final List<String> itemIds;
  final String contentLanguage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(lessonVocabularyProvider(lessonId));
    return words.when(
      loading: () => const InlineLoading(),
      error: (error, _) => InlineErrorCard(
        error: error,
        onRetry: () => ref.invalidate(lessonVocabularyProvider(lessonId)),
      ),
      data: (items) => LessonVocabularyView(
        items: [
          for (final item in items)
            if (itemIds.contains(item.id)) item,
        ],
        contentLanguage: contentLanguage,
      ),
    );
  }
}
