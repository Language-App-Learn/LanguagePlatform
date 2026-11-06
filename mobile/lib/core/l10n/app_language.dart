import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_preferences.dart';

/// Uygulama ARAYÜZ dili. "Bildiğim dil" ve "öğrendiğim dil"den ayrı bir
/// kavramdır (bkz. `LearningLanguage`).
///
/// Sıra önemlidir: cihaz dili desteklenmiyorsa Flutter ilk elemana
/// (İngilizce) düşer. Yeni dil eklerken ARB dosyası da eklenmelidir.
enum AppLanguage {
  en('en', 'English', TextDirection.ltr),
  tr('tr', 'Türkçe', TextDirection.ltr),
  ar('ar', 'العربية', TextDirection.rtl);

  const AppLanguage(this.code, this.nativeName, this.textDirection);

  final String code;

  /// Dil adı, kullanıcının tanıyabilmesi için kendi dilinde yazılır ve
  /// çevrilmez (dil seçicilerde yaygın uygulama).
  final String nativeName;
  final TextDirection textDirection;

  Locale get locale => Locale(code);

  static List<Locale> get supportedLocales => [
    for (final language in values) language.locale,
  ];

  static AppLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }
}

/// Selected interface language; `null` follows the device language.
/// An explicit [initial] (tests) wins; otherwise the persisted value is used.
class AppLanguageNotifier extends Notifier<AppLanguage?> {
  AppLanguageNotifier([this._initial]);

  final AppLanguage? _initial;

  @override
  AppLanguage? build() =>
      _initial ??
      AppLanguage.fromCode(
        ref.read(appPreferencesRepositoryProvider).load().interfaceLanguage,
      );

  void select(AppLanguage? language) {
    state = language;
    ref
        .read(appPreferencesRepositoryProvider)
        .update((p) => p.copyWith(interfaceLanguage: () => language?.code));
  }
}

final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage?>(
  AppLanguageNotifier.new,
);

/// İçerik dilinin yazı yönü (bilinmeyen dil için LTR).
TextDirection textDirectionForLanguage(String languageCode) =>
    AppLanguage.fromCode(languageCode)?.textDirection ?? TextDirection.ltr;
