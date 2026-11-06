import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';
import '../../lessons/domain/example_sentence.dart';

/// Öğrenme durumu (yerel). İleride aralıklı tekrar (spaced repetition)
/// için ek alanlar (sonraki tekrar tarihi, kutu numarası) eklenecek.
enum VocabularyStatus { fresh, learning, learned }

/// Öğrenilen dildeki bir kelime.
///
/// Backend/sözlük API'si sözleşmesi bilinmiyor: alanlar (okunuş, sözcük
/// türü, ses dosyası) netleşince genişletilecek.
@immutable
class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.languageCode,
    required this.term,
    required this.meaning,
    this.transliteration,
    this.example,
  });

  final String id;

  /// Kelimenin dili (ISO 639-1).
  final String languageCode;
  final String term;

  /// Latin harfli okunuş (özellikle Arapça için).
  final String? transliteration;

  /// Öğrencinin bildiği dile göre anlam.
  final LocalizedText meaning;
  final ExampleSentence? example;
}
