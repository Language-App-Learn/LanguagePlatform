import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/app.dart';
import 'package:language_platform/app/router/app_router.dart';
import 'package:language_platform/core/storage/key_value_store.dart';

/// Launches the REAL app wiring (no notifier overrides) on top of [store],
/// like a cold start. Call again with the same store to simulate a restart.
Future<ProviderContainer> launchApp(
  WidgetTester tester,
  KeyValueStore store, {
  String? initialLocation,
  List<Override> overrides = const [],
}) async {
  // Dispose any previous app first so providers are really rebuilt.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        if (initialLocation != null)
          initialLocationProvider.overrideWithValue(initialLocation),
        ...overrides,
      ],
      child: const LanguagePlatformApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(
    tester.element(find.byType(LanguagePlatformApp)),
  );
}
