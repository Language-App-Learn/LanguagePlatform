import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kullanıcının tema tercihi. Henüz kalıcı değil (yerel depolama bekliyor).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  ThemeModeNotifier([this._initial = ThemeMode.system]);

  final ThemeMode _initial;

  @override
  ThemeMode build() => _initial;

  void select(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
