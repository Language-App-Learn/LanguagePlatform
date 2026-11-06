import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../language_selection/application/content_language.dart';
import '../../application/vocabulary_providers.dart';
import '../../domain/vocabulary_item.dart';
import '../widgets/word_detail_sheet.dart';
import '../widgets/word_tile.dart';

/// Öğrenilen dildeki kelime listesi, duruma göre filtre, detay kartı.
/// İleride flashcard ve aralıklı tekrar bu ekrandan başlatılacak.
class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  /// `null`: tüm durumlar. Yalnızca bu ekranı ilgilendiren geçici UI durumu.
  VocabularyStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final words = ref.watch(targetVocabularyProvider);
    final statuses = ref.watch(vocabularyStatusProvider);
    final contentLanguage = ref.watch(contentLanguageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vocabularyTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ChoiceGroup<VocabularyStatus?>(
                    groupId: 'vocabulary-filter',
                    selected: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                    options: [
                      ChoiceOption(
                        id: 'all',
                        value: null,
                        label: l10n.filterAll,
                      ),
                      for (final status in VocabularyStatus.values)
                        ChoiceOption(
                          id: status.name,
                          value: status,
                          label: status.label(l10n),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AsyncValueView<List<VocabularyItem>>(
                  value: words.whenData(
                    (items) => [
                      for (final item in items)
                        if (_filter == null ||
                            statuses.statusOf(item.id) == _filter)
                          item,
                    ],
                  ),
                  onRetry: () => ref.invalidate(vocabularyProvider),
                  isEmpty: (items) => items.isEmpty,
                  emptyBuilder: (context) => Center(
                    child: Padding(
                      padding: AppSpacing.page,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.translate,
                            size: AppSizes.iconXl,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.vocabularyEmptyTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.vocabularyEmptyMessage,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (items) => ListView.separated(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return WordTile(
                        item: item,
                        status: statuses.statusOf(item.id),
                        contentLanguage: contentLanguage,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (_) => WordDetailSheet(
                            item: item,
                            contentLanguage: contentLanguage,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
