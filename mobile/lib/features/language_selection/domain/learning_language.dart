import 'package:flutter/widgets.dart';

import '../../../core/l10n/app_language.dart';

/// Öğrencinin bildiği veya öğrenmek istediği dil.
///
/// Arayüz dilinden ([AppLanguage]) bağımsız bir kavramdır; şimdilik aynı üç
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

  static final List<LearningLanguage> supported = List.unmodifiable([
    for (final language in AppLanguage.values)
      LearningLanguage(
        code: language.code,
        nativeName: language.nativeName,
        textDirection: language.textDirection,
      ),
  ]);

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
