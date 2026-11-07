import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../courses/domain/course.dart';
import '../../../language_selection/domain/learning_language.dart';
import '../../application/catalog_filter.dart';

/// Arama kutusu + dil filtresi + seviye filtresi.
class CatalogFilters extends ConsumerStatefulWidget {
  const CatalogFilters({super.key});

  @override
  ConsumerState<CatalogFilters> createState() => _CatalogFiltersState();
}

class _CatalogFiltersState extends ConsumerState<CatalogFilters> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(catalogFilterProvider).query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filter = ref.watch(catalogFilterProvider);
    final notifier = ref.read(catalogFilterProvider.notifier);

    // Filtre dışarıdan sıfırlanırsa (Filtreleri temizle) kutuyu da boşalt.
    if (filter.query != _controller.text) {
      _controller.text = filter.query;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: notifier.setQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchCoursesHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: filter.query.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.clearSearch,
                    icon: const Icon(Icons.close),
                    onPressed: () => notifier.setQuery(''),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ChoiceGroup<String?>(
          groupId: 'catalog-language',
          title: l10n.filterLanguageTitle,
          selected: filter.languageCode,
          onSelected: notifier.setLanguage,
          options: [
            ChoiceOption(id: 'all', value: null, label: l10n.filterAll),
            for (final language in LearningLanguage.supported)
              ChoiceOption(
                id: language.code,
                value: language.code,
                label: language.nativeName,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ChoiceGroup<CourseLevel?>(
          groupId: 'catalog-level',
          title: l10n.filterLevelTitle,
          selected: filter.level,
          onSelected: notifier.setLevel,
          options: [
            ChoiceOption(id: 'all', value: null, label: l10n.filterAll),
            for (final level in CourseLevel.values)
              ChoiceOption(id: level.name, value: level, label: level.code),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
