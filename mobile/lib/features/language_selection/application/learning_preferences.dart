import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/learning_language.dart';

/// Öğrenme tercihleri: bildiği dil ve öğrenmek istediği dil.
/// (Arayüz dili ayrıdır: `appLanguageProvider`.)
@immutable
class LearningPreferences {
  const LearningPreferences({this.knownLanguage, this.targetLanguage});

  final LearningLanguage? knownLanguage;
  final LearningLanguage? targetLanguage;

  /// İki dil seçilmiş ve birbirinden farklı.
  bool get isComplete =>
      knownLanguage != null &&
      targetLanguage != null &&
      knownLanguage != targetLanguage;
}

/// Tercihler henüz kalıcı değil (yerel depolama kararı bekliyor).
class LearningPreferencesNotifier extends Notifier<LearningPreferences> {
  LearningPreferencesNotifier([this._initial = const LearningPreferences()]);

  final LearningPreferences _initial;

  @override
  LearningPreferences build() => _initial;

  /// Hedef dille aynı dil seçilemez; çağrı yok sayılır.
  void selectKnown(LearningLanguage language) {
    if (state.targetLanguage == language) return;
    state = LearningPreferences(
      knownLanguage: language,
      targetLanguage: state.targetLanguage,
    );
  }

  /// Bilinen dille aynı dil seçilemez; çağrı yok sayılır.
  void selectTarget(LearningLanguage language) {
    if (state.knownLanguage == language) return;
    state = LearningPreferences(
      knownLanguage: state.knownLanguage,
      targetLanguage: language,
    );
  }
}

final learningPreferencesProvider =
    NotifierProvider<LearningPreferencesNotifier, LearningPreferences>(
      LearningPreferencesNotifier.new,
    );
