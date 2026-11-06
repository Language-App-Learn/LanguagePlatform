import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';

/// CEFR seviyeleri.
enum CourseLevel {
  a1,
  a2,
  b1,
  b2,
  c1,
  c2;

  /// "A1", "B2" ...
  String get code => name.toUpperCase();
}

/// Öğrenilen dil için bir kurs.
///
/// Backend sözleşmesi bilinmiyor: kimlik türü (int/guid/string), ders
/// listesinin kurs yanıtında gömülü mü ayrı uçtan mı geleceği ve çok dilli
/// alanların biçimi netleşince `data/` katmanında DTO ile eşlenecek.
@immutable
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.languageCode,
    required this.level,
    required this.lessonIds,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText description;

  /// Öğrenilen dil (ISO 639-1).
  final String languageCode;
  final CourseLevel level;

  /// Sıralı ders kimlikleri.
  final List<String> lessonIds;

  int get lessonCount => lessonIds.length;
}
