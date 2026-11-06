import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_value_store.dart';

/// Non-sensitive user preferences persisted on the device.
///
/// These are LOCAL preferences only; they are not account data. When real
/// accounts exist, server-side profile settings become the source of truth
/// and this document only caches them.
@immutable
class AppPreferences {
  const AppPreferences({
    this.interfaceLanguage,
    this.knownLanguage,
    this.targetLanguage,
    this.themeMode,
    this.onboardingCompleted = false,
  });

  /// ISO language codes; `null` means "not chosen" (interface: follow device).
  final String? interfaceLanguage;
  final String? knownLanguage;
  final String? targetLanguage;

  /// 'system' | 'light' | 'dark'; `null` means default (system).
  final String? themeMode;
  final bool onboardingCompleted;

  AppPreferences copyWith({
    String? Function()? interfaceLanguage,
    String? Function()? knownLanguage,
    String? Function()? targetLanguage,
    String? Function()? themeMode,
    bool? onboardingCompleted,
  }) {
    return AppPreferences(
      interfaceLanguage: interfaceLanguage != null
          ? interfaceLanguage()
          : this.interfaceLanguage,
      knownLanguage: knownLanguage != null
          ? knownLanguage()
          : this.knownLanguage,
      targetLanguage: targetLanguage != null
          ? targetLanguage()
          : this.targetLanguage,
      themeMode: themeMode != null ? themeMode() : this.themeMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

/// Reads/writes [AppPreferences] as one versioned JSON document.
class AppPreferencesRepository {
  AppPreferencesRepository(this._store);

  final KeyValueStore _store;

  static const storageKey = 'lp.preferences';

  /// Bump when the document shape changes and extend [_migrate].
  static const schemaVersion = 1;

  AppPreferences load() {
    final json = readJsonObject(_store, storageKey);
    if (json == null) return const AppPreferences();
    final migrated = _migrate(json);
    if (migrated == null) return const AppPreferences();
    String? str(String key) {
      final v = migrated[key];
      return v is String && v.isNotEmpty ? v : null;
    }

    return AppPreferences(
      interfaceLanguage: str('interfaceLanguage'),
      knownLanguage: str('knownLanguage'),
      targetLanguage: str('targetLanguage'),
      themeMode: str('themeMode'),
      onboardingCompleted: migrated['onboardingCompleted'] == true,
    );
  }

  /// Returns the document in the current shape, or `null` if it comes from a
  /// NEWER app version (unknown shape → ignore rather than misread).
  Map<String, Object?>? _migrate(Map<String, Object?> json) {
    final version = json['v'];
    if (version is! int || version < 1) return json; // pre-versioned: as is
    if (version > schemaVersion) return null;
    return json; // v1 is current; add `if (version == 1) {...}` steps later.
  }

  Future<void> save(AppPreferences p) => writeJsonObject(_store, storageKey, {
    'v': schemaVersion,
    'interfaceLanguage': p.interfaceLanguage,
    'knownLanguage': p.knownLanguage,
    'targetLanguage': p.targetLanguage,
    'themeMode': p.themeMode,
    'onboardingCompleted': p.onboardingCompleted,
  });

  Future<void> update(AppPreferences Function(AppPreferences current) change) =>
      save(change(load()));
}

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>(
  (ref) => AppPreferencesRepository(ref.watch(keyValueStoreProvider)),
);
