import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../application/vocabulary_providers.dart';
import '../../domain/vocabulary_item.dart';
import 'word_tile.dart';

/// Kelime detay kartı: anlam, örnek cümle ve öğrenme durumu seçimi.
class WordDetailSheet extends ConsumerWidget {
  const WordDetailSheet({
    super.key,
    required this.item,
    required this.contentLanguage,
  });

  final VocabularyItem item;
  final String contentLanguage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final status = ref.watch(
      vocabularyRecordsProvider.select((m) => m.statusOf(item.id)),
    );
    final favorite = ref.watch(
      vocabularyRecordsProvider.select((m) => m.recordOf(item.id).favorite),
    );
    final example = item.example;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ContentText(
                    item.term,
                    languageCode: item.languageCode,
                    style: theme.textTheme.displaySmall,
                  ),
                ),
                IconButton(
                  key: const ValueKey('detail-favorite'),
                  tooltip: favorite ? l10n.favoriteRemove : l10n.favoriteAdd,
                  onPressed: () => ref
                      .read(vocabularyRecordsProvider.notifier)
                      .toggleFavorite(item.id),
                  icon: Icon(favorite ? Icons.star : Icons.star_border),
                ),
              ],
            ),
            if (item.transliteration != null)
              Text(
                item.transliteration!.isolateLtr,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.wordMeaning, style: theme.textTheme.labelLarge),
            Text(
              item.meaning.resolve(contentLanguage),
              style: theme.textTheme.titleLarge,
            ),
            if (example != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.lessonExample, style: theme.textTheme.labelLarge),
              ContentText(
                example.text,
                languageCode: item.languageCode,
                style: theme.textTheme.titleMedium,
              ),
              Text(
                example.translation.resolve(contentLanguage),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            ChoiceGroup<VocabularyStatus>(
              groupId: 'word-status',
              title: l10n.wordStatusTitle,
              selected: status,
              onSelected: (value) => ref
                  .read(vocabularyRecordsProvider.notifier)
                  .setStatus(item.id, value),
              options: [
                for (final value in VocabularyStatus.values)
                  ChoiceOption(
                    id: value.name,
                    value: value,
                    label: value.label(l10n),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
