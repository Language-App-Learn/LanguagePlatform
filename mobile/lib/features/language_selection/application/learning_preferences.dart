import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_preferences.dart';
import '../domain/learning_language.dart';

/// Learning preferences: known language and target language.
/// (The interface language is separate: `appLanguageProvider`.)
@immutable
class LearningPreferences {
  const LearningPreferences({this.knownLanguage, this.targetLanguage});

  final LearningLanguage? knownLanguage;
  final LearningLanguage? targetLanguage;

  /// Both chosen and different from each other.
  bool get isComplete =>
      knownLanguage != null &&
      targetLanguage != null &&
      knownLanguage != targetLanguage;
}

/// Persisted locally. An explicit initial value (tests) wins over storage.
class LearningPreferencesNotifier extends Notifier<LearningPreferences> {
  LearningPreferencesNotifier([this._initial]);

  final LearningPreferences? _initial;

  @override
  LearningPreferences build() {
    if (_initial != null) return _initial;
    final stored = ref.read(appPreferencesRepositoryProvider).load();
    final known = LearningLanguage.fromCode(stored.knownLanguage);
    var target = LearningLanguage.fromCode(stored.targetLanguage);
    if (known != null && known == target) target = null; // corrupted pair
    return LearningPreferences(knownLanguage: known, targetLanguage: target);
  }

  /// The same language as the target cannot be chosen; the call is ignored.
  void selectKnown(LearningLanguage language) {
    if (state.targetLanguage == language) return;
    state = LearningPreferences(
      knownLanguage: language,
      targetLanguage: state.targetLanguage,
    );
    _persist();
  }

  /// The same language as the known language cannot be chosen; ignored.
  void selectTarget(LearningLanguage language) {
    if (state.knownLanguage == language) return;
    state = LearningPreferences(
      knownLanguage: state.knownLanguage,
      targetLanguage: language,
    );
    _persist();
  }

  /// Sets both languages at once (the language-pair screen). Ignored when
  /// they are the same language.
  void setPair(LearningLanguage known, LearningLanguage target) {
    if (known == target) return;
    state = LearningPreferences(knownLanguage: known, targetLanguage: target);
    _persist();
  }

  void _persist() {
    ref
        .read(appPreferencesRepositoryProvider)
        .update(
          (p) => p.copyWith(
            knownLanguage: () => state.knownLanguage?.code,
            targetLanguage: () => state.targetLanguage?.code,
          ),
        );
  }
}

final learningPreferencesProvider =
    NotifierProvider<LearningPreferencesNotifier, LearningPreferences>(
      LearningPreferencesNotifier.new,
    );
