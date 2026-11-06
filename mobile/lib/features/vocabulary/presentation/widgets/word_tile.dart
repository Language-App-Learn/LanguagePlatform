import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../domain/vocabulary_item.dart';
import '../../domain/vocabulary_record.dart';

extension VocabularyStatusLabel on VocabularyStatus {
  String label(AppLocalizations l10n) => switch (this) {
    VocabularyStatus.fresh => l10n.vocabularyStatusNew,
    VocabularyStatus.learning => l10n.vocabularyStatusLearning,
    VocabularyStatus.learned => l10n.vocabularyStatusLearned,
  };
}

/// Word list row: word, transliteration, meaning, status and favorite toggle.
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.item,
    required this.record,
    required this.contentLanguage,
    required this.onTap,
    required this.onToggleFavorite,
    required this.isDue,
  });

  final VocabularyItem item;
  final VocabularyRecord record;
  final String contentLanguage;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isDue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AppCard(
      key: ValueKey('word:${item.id}'),
      onTap: onTap,
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContentText(
                  item.term,
                  languageCode: item.languageCode,
                  style: theme.textTheme.titleLarge,
                ),
                if (item.transliteration != null)
                  Text(
                    item.transliteration!.isolateLtr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.meaning.resolve(contentLanguage),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isDue)
            Tooltip(
              message: l10n.reviewDueBadge,
              child: Icon(
                Icons.schedule,
                size: AppSizes.iconSm,
                color: context.semanticColors.accent,
              ),
            ),
          _StatusDot(status: record.status),
          IconButton(
            key: ValueKey('favorite:${item.id}'),
            tooltip: record.favorite ? l10n.favoriteRemove : l10n.favoriteAdd,
            onPressed: onToggleFavorite,
            icon: Icon(
              record.favorite ? Icons.star : Icons.star_border,
              color: record.favorite ? context.semanticColors.accent : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final VocabularyStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final (icon, color) = switch (status) {
      VocabularyStatus.fresh => (Icons.fiber_new_outlined, scheme.outline),
      VocabularyStatus.learning => (Icons.autorenew, semantic.accent),
      VocabularyStatus.learned => (Icons.check_circle, semantic.success),
    };
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs),
      child: Tooltip(
        message: status.label(context.l10n),
        child: Icon(icon, color: color),
      ),
    );
  }
}
