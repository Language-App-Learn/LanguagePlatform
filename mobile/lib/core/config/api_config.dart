/// Backend connection settings, supplied at build/run time:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000   # Android emulator -> host PC
/// flutter run --dart-define=API_BASE_URL=http://localhost:5000  # iOS Simulator on the same Mac
/// ```
///
/// Nothing is hardcoded and no secret belongs here. Without a value the app
/// stays in local demo mode (no network calls).
abstract final class ApiConfig {
  static const String _fromEnvironment = String.fromEnvironment('API_BASE_URL');

  static Uri? get baseUri => parse(_fromEnvironment);

  static bool get isConfigured => baseUri != null;

  /// Returns a usable base URI or `null`. Plain HTTP is accepted only for
  /// local development hosts; real credentials require HTTPS.
  static Uri? parse(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
    if (uri.scheme == 'https') return uri;
    if (uri.scheme == 'http' && _isDevelopmentHost(uri.host)) return uri;
    return null;
  }

  static bool _isDevelopmentHost(String host) {
    if (host == 'localhost' || host == '10.0.2.2' || host == '127.0.0.1') {
      return true;
    }
    return RegExp(r'^(10\.|192\.168\.|172\.(1[6-9]|2\d|3[01])\.)')
        .hasMatch(host);
  }
}
