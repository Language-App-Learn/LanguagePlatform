abstract final class AppConfig {
  static const String appName = 'LanguagePlatform';

  /// Açık geliştirme/demo modu. Gerçek kimlik doğrulamadan bağımsızdır:
  /// `--dart-define=DEMO_MODE=false` ile kapatılır. Kapalıyken "demo olarak
  /// devam et" girişi görünmez.
  static const bool demoModeEnabled = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: true,
  );
}
