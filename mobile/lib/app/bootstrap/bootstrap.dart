import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/key_value_store.dart';

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
  runApp(
    ProviderScope(
      // Riverpod 3 retries failed providers by default. Errors are shown to
      // the user with a manual "Try again", so automatic retry is disabled.
      retry: (retryCount, error) => null,
      overrides: [
        keyValueStoreProvider.overrideWithValue(GuardedKeyValueStore(store)),
      ],
      child: app,
    ),
  );
}
