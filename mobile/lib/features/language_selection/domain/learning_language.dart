import 'package:flutter/widgets.dart';

/// Öğrencinin bildiği veya öğrenmek istediği dil.
///
/// Arayüz dilinden (`AppLanguage`) bağımsız bir kavramdır; şimdilik aynı üç
/// dil sunulur, ancak liste ileride (de, fr, es ...) backend'den gelen
/// katalogla genişleyecektir. Backend sözleşmesi netleşince buradaki alanlar
/// (ör. ISO kodu, yerel ad, yazı yönü) DTO ile eşlenecektir.
@immutable
class LearningLanguage {
  const LearningLanguage({
    required this.code,
    required this.nativeName,
    required this.textDirection,
  });

  /// ISO 639-1 kodu.
  final String code;
  final String nativeName;
  final TextDirection textDirection;

  /// Languages offered for learning and as "known language". This list is
  /// independent of the interface languages (`AppLanguage`): a language can
  /// become learnable (e.g. German) before the app UI is translated into it.
  /// Course content and translations are keyed by these same ISO codes.
  static const List<LearningLanguage> supported = [
    LearningLanguage(
      code: 'en',
      nativeName: 'English',
      textDirection: TextDirection.ltr,
    ),
    LearningLanguage(
      code: 'tr',
      nativeName: 'Türkçe',
      textDirection: TextDirection.ltr,
    ),
    LearningLanguage(
      code: 'ar',
      nativeName: 'العربية',
      textDirection: TextDirection.rtl,
    ),
  ];

  static LearningLanguage? fromCode(String? code) {
    for (final language in supported) {
      if (language.code == code) return language;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is LearningLanguage && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'LearningLanguage($code)';
}
