import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/network/token_store.dart';
import '../../core/security/platform_secret_store.dart';
import '../../core/security/session_bootstrap.dart';
import '../../core/storage/key_value_store.dart';
import '../../features/authentication/application/auth_providers.dart';
import '../../features/learning_track/data/share_pdf_delivery.dart';

/// Restores a previously stored session from the platform keystore.
/// Without a configured backend (demo build) no secret store is touched. If
/// the keystore cannot be opened the session is memory-only (never a weaker
/// fallback such as SharedPreferences).
Future<TokenStore> _openTokenStore(KeyValueStore preferences) async {
  if (!ApiConfig.isConfigured) return InMemoryTokenStore();
  try {
    return await loadTokenStore(
      secrets: await openSecretStore(),
      preferences: preferences,
    );
  } on Object {
    return InMemoryTokenStore();
  }
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
  final guarded = GuardedKeyValueStore(await openKeyValueStore());
  final tokens = await _openTokenStore(guarded);
  // PDFs shared in an earlier run must not linger in the cache.
  unawaited(SharePdfDelivery().purgeStale().catchError((Object _) {}));
  runApp(
    ProviderScope(
      // Riverpod 3 retries failed providers by default. Errors are shown to
      // the user with a manual "Try again", so automatic retry is disabled.
      retry: (retryCount, error) => null,
      overrides: [
        keyValueStoreProvider.overrideWithValue(guarded),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
      child: app,
    ),
  );
}
