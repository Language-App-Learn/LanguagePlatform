import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/token_store.dart';

/// [SecretStore] backed by the platform keystore:
///
/// * Android: AES-GCM data key wrapped by an RSA key held in the Android
///   Keystore (`flutter_secure_storage` defaults). App backups are disabled
///   in the manifest, so the ciphertext is never copied off the device.
/// * iOS: Keychain, `first_unlock_this_device` (readable after the first
///   unlock, never migrated to another device or iCloud Keychain).
///
/// No custom cryptography lives in the app. Values are never logged.
class PlatformSecretStore implements SecretStore {
  PlatformSecretStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // `resetOnError` (default) wipes an unreadable store, e.g. after a
            // keystore reset; `SecureTokenStore` then reports "signed out".
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
              synchronizable: false,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Opens the platform secret store used by the app.
Future<SecretStore?> openSecretStore() async => PlatformSecretStore();
