const String _leftToRightIsolate = '\u{2066}';
const String _popDirectionalIsolate = '\u{2069}';

/// Çift yönlü (bidi) metinde teknik değerlerin (e-posta, sayı, kod, "A1")
/// RTL cümle içinde ters görünmesini önler.
extension BidiText on String {
  /// Metni soldan sağa "izole" eder; hizalama paragraf yönünü izlemeye
  /// devam eder (Unicode LRI + PDI).
  String get isolateLtr => '$_leftToRightIsolate$this$_popDirectionalIsolate';
}
