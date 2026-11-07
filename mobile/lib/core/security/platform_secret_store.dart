import '../network/token_store.dart';

/// Opens the platform secret store (Android Keystore / iOS Keychain), or
/// returns `null` when none is available in this build.
///
/// STATUS: no secure-storage package is installed yet (CLAUDE.md requires
/// approval for new dependencies). Until it is approved this returns `null`
/// and the session stays in memory only - it ends when the app is closed.
/// Nothing sensitive is ever written to SharedPreferences as a fallback.
///
/// Wiring once approved (the ONLY file that changes besides `pubspec.yaml`):
/// implement [SecretStore] with `flutter_secure_storage`
/// (`AndroidOptions(encryptedSharedPreferences: true)`,
/// `IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device)`)
/// and return it here.
Future<SecretStore?> openSecretStore() async => null;
