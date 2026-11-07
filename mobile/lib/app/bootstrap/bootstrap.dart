import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/network/token_store.dart';
import '../../core/security/platform_secret_store.dart';
import '../../core/storage/key_value_store.dart';
import '../../features/authentication/application/auth_providers.dart';

/// Restores a previously stored session from the platform secret store.
/// Without a configured backend, or without a secret store in this build,
/// the session is memory-only.
Future<TokenStore> _openTokenStore() async {
  if (!ApiConfig.isConfigured) return InMemoryTokenStore();
  final secrets = await openSecretStore();
  if (secrets == null) return InMemoryTokenStore();
  final store = SecureTokenStore(secrets);
  await store.load();
  return store;
}

/// App startup: binding, error hooks, local storage and the Riverpod scope.
///
/// Error details are printed only in debug; no user data or sensitive
/// content is logged in production. A crash-reporting integration (if any)
/// will be attached here.
Future<void> bootstrap(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  // Safe: falls back to in-memory storage if the platform store fails.
  final store = await openKeyValueStore();
  final tokens = await _openTokenStore();
  runApp(
    ProviderScope(
      // Riverpod 3 retries failed providers by default. Errors are shown to
      // the user with a manual "Try again", so automatic retry is disabled.
      retry: (retryCount, error) => null,
      overrides: [
        keyValueStoreProvider.overrideWithValue(GuardedKeyValueStore(store)),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
      child: app,
    ),
  );
}
