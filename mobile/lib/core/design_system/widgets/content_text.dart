import 'package:flutter/material.dart';

import '../../l10n/app_language.dart';

/// Text in the language being learned (word, sentence, dialogue line).
/// Direction follows the CONTENT language, not the UI language, so Arabic
/// content reads correctly inside an LTR UI and English content inside an
/// RTL UI.
///
/// Arabic gets a slightly larger size and generous line height so that
/// diacritics (tashkeel) above and below the letters are never clipped or
/// crowded. Text is never normalised or stripped.
class ContentText extends StatelessWidget {
  const ContentText(
    this.text, {
    super.key,
    required this.languageCode,
    this.style,
    this.textAlign,
  });

  final String text;
  final String languageCode;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// Extra size for Arabic script relative to Latin at the same style.
  static const double arabicScale = 1.12;
  static const double arabicLineHeight = 1.9;

  @override
  Widget build(BuildContext context) {
    final isArabic = languageCode == 'ar';
    final base = style ?? DefaultTextStyle.of(context).style;
    final effective = isArabic
        ? base.copyWith(
            fontSize: (base.fontSize ?? 14) * arabicScale,
            height: arabicLineHeight,
          )
        : base;
    return Text(
      text,
      style: effective,
      textAlign: textAlign,
      textDirection: textDirectionForLanguage(languageCode),
    );
  }
}
