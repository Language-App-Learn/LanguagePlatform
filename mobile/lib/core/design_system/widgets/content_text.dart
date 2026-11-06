import 'package:flutter/material.dart';

import '../../l10n/app_language.dart';

/// Öğrenilen dildeki metin (kelime, cümle, diyalog satırı). Yazı yönü
/// arayüz dilinden değil içeriğin dilinden gelir; böylece Arapça içerik
/// LTR arayüzde de, İngilizce içerik RTL arayüzde de doğru görünür.
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

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      textDirection: textDirectionForLanguage(languageCode),
    );
  }
}
