const String _leftToRightIsolate = '\u{2066}';
const String _popDirectionalIsolate = '\u{2069}';

/// Çift yönlü (bidi) metinde teknik değerlerin (e-posta, sayı, kod, "A1")
/// RTL cümle içinde ters görünmesini önler.
extension BidiText on String {
  /// Metni soldan sağa "izole" eder; hizalama paragraf yönünü izlemeye
  /// devam eder (Unicode LRI + PDI).
  String get isolateLtr => '$_leftToRightIsolate$this$_popDirectionalIsolate';
}

/// `'ar'` when [text] contains Arabic-script letters, otherwise [fallback].
/// Used to pick the reading direction of server-authored exercise text whose
/// language the API does not tag.
String contentLanguageOf(String text, {required String fallback}) {
  for (final unit in text.runes) {
    if ((unit >= 0x0600 && unit <= 0x06FF) ||
        (unit >= 0x0750 && unit <= 0x077F) ||
        (unit >= 0xFB50 && unit <= 0xFDFF) ||
        (unit >= 0xFE70 && unit <= 0xFEFF)) {
      return 'ar';
    }
  }
  return fallback;
}
