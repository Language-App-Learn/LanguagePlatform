import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class ChoiceOption<T> {
  const ChoiceOption({
    required this.id,
    required this.value,
    required this.label,
    this.enabled = true,
    this.leading,
  });

  /// Test ve erişilebilirlik anahtarı için kararlı kimlik.
  final String id;
  final T value;
  final String label;
  final bool enabled;

  /// Optional leading widget (list layout only), e.g. a language badge.
  final Widget? leading;
}

enum ChoiceGroupLayout { chips, list }

/// Başlıklı tek seçimli grup (dil, tema, seviye vb. için ortak bileşen).
/// Anahtar biçimi: `ValueKey('<groupId>:<option.id>')`.
class ChoiceGroup<T> extends StatelessWidget {
  const ChoiceGroup({
    super.key,
    required this.groupId,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.title,
    this.layout = ChoiceGroupLayout.chips,
  });

  final String groupId;
  final String? title;
  final List<ChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final ChoiceGroupLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Semantics(
            header: true,
            child: Text(title!, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (layout == ChoiceGroupLayout.chips)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final option in options) _chip(option)],
          )
        else
          Column(
            children: [
              for (final option in options)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.sm,
                  ),
                  child: _tile(context, option),
                ),
            ],
          ),
      ],
    );
  }

  Widget _chip(ChoiceOption<T> option) {
    return ChoiceChip(
      key: ValueKey('$groupId:${option.id}'),
      label: Text(option.label),
      selected: option.value == selected,
      onSelected: option.enabled ? (_) => onSelected(option.value) : null,
    );
  }

  Widget _tile(BuildContext context, ChoiceOption<T> option) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = option.value == selected;
    return Semantics(
      selected: isSelected,
      button: true,
      enabled: option.enabled,
      child: Card(
        key: ValueKey('$groupId:${option.id}'),
        color: isSelected ? scheme.primaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          enabled: option.enabled,
          minVerticalPadding: AppSpacing.md,
          leading: option.leading,
          title: Text(option.label),
          trailing: Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? scheme.primary : scheme.outline,
          ),
          onTap: option.enabled ? () => onSelected(option.value) : null,
        ),
      ),
    );
  }
}
