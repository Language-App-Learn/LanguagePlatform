import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_preferences.dart';

/// User theme preference (system/light/dark), persisted locally.
/// An explicit [initial] (tests) wins over the persisted value.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  ThemeModeNotifier([this._initial]);

  final ThemeMode? _initial;

  @override
  ThemeMode build() {
    if (_initial != null) return _initial;
    final stored = ref.read(appPreferencesRepositoryProvider).load().themeMode;
    return ThemeMode.values.asNameMap()[stored] ?? ThemeMode.system;
  }

  void select(ThemeMode mode) {
    state = mode;
    ref
        .read(appPreferencesRepositoryProvider)
        .update((p) => p.copyWith(themeMode: () => mode.name));
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
