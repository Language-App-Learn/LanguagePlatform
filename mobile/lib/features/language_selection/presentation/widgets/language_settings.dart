import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/learning_preferences.dart';
import '../../domain/learning_language.dart';

/// Arayüz dili seçici. Bildiğim/öğrendiğim dilden bağımsızdır.
class InterfaceLanguageSetting extends ConsumerWidget {
  const InterfaceLanguageSetting({
    super.key,
    this.layout = ChoiceGroupLayout.chips,
  });

  final ChoiceGroupLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cihaz dilini takip ederken de etkin dil seçili görünür.
    final current = AppLanguage.fromCode(context.languageCode);
    return ChoiceGroup<AppLanguage>(
      groupId: 'interface-language',
      title: context.l10n.interfaceLanguageTitle,
      layout: layout,
      selected: current,
      options: [
        for (final language in AppLanguage.values)
          ChoiceOption(
            id: language.code,
            value: language,
            label: language.nativeName,
          ),
      ],
      onSelected: ref.read(appLanguageProvider.notifier).select,
    );
  }
}

/// "Bildiğim dil" seçici; hedef dil devre dışı bırakılır.
class KnownLanguageSetting extends ConsumerWidget {
  const KnownLanguageSetting({
    super.key,
    this.layout = ChoiceGroupLayout.chips,
  });

  final ChoiceGroupLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(learningPreferencesProvider);
    return ChoiceGroup<LearningLanguage>(
      groupId: 'known-language',
      title: context.l10n.knownLanguageTitle,
      layout: layout,
      selected: prefs.knownLanguage,
      options: [
        for (final language in LearningLanguage.supported)
          ChoiceOption(
            id: language.code,
            value: language,
            label: language.nativeName,
            enabled: language != prefs.targetLanguage,
          ),
      ],
      onSelected: ref.read(learningPreferencesProvider.notifier).selectKnown,
    );
  }
}

/// "Öğrenmek istediğim dil" seçici; bilinen dil devre dışı bırakılır.
class TargetLanguageSetting extends ConsumerWidget {
  const TargetLanguageSetting({
    super.key,
    this.layout = ChoiceGroupLayout.chips,
  });

  final ChoiceGroupLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(learningPreferencesProvider);
    return ChoiceGroup<LearningLanguage>(
      groupId: 'target-language',
      title: context.l10n.targetLanguageTitle,
      layout: layout,
      selected: prefs.targetLanguage,
      options: [
        for (final language in LearningLanguage.supported)
          ChoiceOption(
            id: language.code,
            value: language,
            label: language.nativeName,
            enabled: language != prefs.knownLanguage,
          ),
      ],
      onSelected: ref.read(learningPreferencesProvider.notifier).selectTarget,
    );
  }
}
