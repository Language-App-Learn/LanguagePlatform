import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';

/// Öğrenilen dilde bir örnek cümle ve çevirisi.
@immutable
class ExampleSentence {
  const ExampleSentence({required this.text, required this.translation});

  /// Öğrenilen dildeki cümle.
  final String text;

  /// Öğrencinin bildiği dile göre çözülen çeviri.
  final LocalizedText translation;
}
