import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../language_selection/application/content_language.dart';
import '../../../progress/application/progress_providers.dart';
import '../../application/review_session.dart';
import '../../application/vocabulary_providers.dart';
import '../../domain/vocabulary_item.dart';
import '../widgets/word_detail_sheet.dart';
import '../widgets/word_tile.dart';

enum _WordFilter { all, fresh, learning, learned, favorites }

/// Word list with search, status/favorite filters, detail card and the
/// entry point of the flashcard review.
class VocabularyPage extends ConsumerStatefulWidget {
  const VocabularyPage({super.key});

  @override
  ConsumerState<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends ConsumerState<VocabularyPage> {
  // Ephemeral UI state of this screen only.
  _WordFilter _filter = _WordFilter.all;
  String _query = '';

  bool _matchesQuery(VocabularyItem item) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return item.term.toLowerCase().contains(q) ||
        (item.transliteration?.toLowerCase().contains(q) ?? false) ||
        item.meaning.matches(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final words = ref.watch(targetVocabularyProvider);
    final records = ref.watch(vocabularyRecordsProvider);
    final contentLanguage = ref.watch(contentLanguageProvider);
    final now = ref.watch(clockProvider)();
    final dueCount = ref.watch(dueReviewCountProvider);

    bool passes(VocabularyItem item) {
      final record = records.recordOf(item.id);
      final byFilter = switch (_filter) {
        _WordFilter.all => true,
        _WordFilter.fresh => record.status == VocabularyStatus.fresh,
        _WordFilter.learning => record.status == VocabularyStatus.learning,
        _WordFilter.learned => record.status == VocabularyStatus.learned,
        _WordFilter.favorites => record.favorite,
      };
      return byFilter && _matchesQuery(item);
    }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      key: const ValueKey('review-card'),
                      onTap: () => context.push(AppRoutes.review),
                      child: Row(
                        children: [
                          const Icon(Icons.style_outlined),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.reviewDueBanner(dueCount),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Text(l10n.startReview),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: l10n.vocabularySearchHint,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ChoiceGroup<_WordFilter>(
                      groupId: 'vocabulary-filter',
                      selected: _filter,
                      onSelected: (value) => setState(() => _filter = value),
                      options: [
                        ChoiceOption(
                          id: 'all',
                          value: _WordFilter.all,
                          label: l10n.filterAll,
                        ),
                        ChoiceOption(
                          id: 'fresh',
                          value: _WordFilter.fresh,
                          label: l10n.vocabularyStatusNew,
                        ),
                        ChoiceOption(
                          id: 'learning',
                          value: _WordFilter.learning,
                          label: l10n.vocabularyStatusLearning,
                        ),
                        ChoiceOption(
                          id: 'learned',
                          value: _WordFilter.learned,
                          label: l10n.vocabularyStatusLearned,
                        ),
                        ChoiceOption(
                          id: 'favorites',
                          value: _WordFilter.favorites,
                          label: l10n.vocabularyFavorites,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AsyncValueView<List<VocabularyItem>>(
                  value: words.whenData(
                    (items) => [
                      for (final item in items)
                        if (passes(item)) item,
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
                      final record = records.recordOf(item.id);
                      return WordTile(
                        item: item,
                        record: record,
                        isDue: record.review.isDue(now),
                        contentLanguage: contentLanguage,
                        onToggleFavorite: () => ref
                            .read(vocabularyRecordsProvider.notifier)
                            .toggleFavorite(item.id),
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
