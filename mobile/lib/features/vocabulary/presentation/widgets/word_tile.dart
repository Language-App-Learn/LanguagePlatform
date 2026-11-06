import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../domain/vocabulary_item.dart';

extension VocabularyStatusLabel on VocabularyStatus {
  String label(AppLocalizations l10n) => switch (this) {
    VocabularyStatus.fresh => l10n.vocabularyStatusNew,
    VocabularyStatus.learning => l10n.vocabularyStatusLearning,
    VocabularyStatus.learned => l10n.vocabularyStatusLearned,
  };
}

/// Kelime listesi satırı: kelime, okunuş, anlam ve öğrenme durumu.
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.item,
    required this.status,
    required this.contentLanguage,
    required this.onTap,
  });

  final VocabularyItem item;
  final VocabularyStatus status;
  final String contentLanguage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      key: ValueKey('word:${item.id}'),
      onTap: onTap,
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
          const SizedBox(width: AppSpacing.md),
          _StatusDot(status: status),
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
    return Tooltip(
      message: status.label(context.l10n),
      child: Icon(icon, color: color),
    );
  }
}
