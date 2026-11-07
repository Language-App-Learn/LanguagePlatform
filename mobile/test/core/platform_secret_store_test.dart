import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/network/authenticated_api_client.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/core/security/platform_secret_store.dart';
import 'package:language_platform/core/security/session_bootstrap.dart';
import 'package:language_platform/core/storage/key_value_store.dart';

import '../fakes/five_stage_fakes.dart';

const _a = TokenPair(accessToken: 'acc-1', refreshToken: 'ref-1');
const _b = TokenPair(accessToken: 'acc-2', refreshToken: 'ref-2');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlatformSecretStore (flutter_secure_storage adapter)', () {
    test('round trip, overwrite and delete go through the plugin', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final store = PlatformSecretStore();
      expect(await store.read('k'), isNull);
      await store.write('k', 'v1');
      await store.write('k', 'v2');
      expect(await store.read('k'), 'v2');
      await store.delete('k');
      expect(await store.read('k'), isNull);
    });
  });

  group('session survives an app restart (real adapter, mocked keystore)', () {
    test('save, restart, restore; refresh replaces both tokens', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = MemoryKeyValueStore();

      var tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      expect(tokens.read(), isNull); // first run
      await tokens.save(_a);

      // "Restart": a brand-new store over the same keystore/preferences.
      tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      expect(tokens.read()?.accessToken, 'acc-1');
      expect(tokens.read()?.refreshToken, 'ref-1');

      // A refresh replaces the pair; after another restart only the new
      // pair exists - never a mix.
      await tokens.save(_b);
      tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      expect(tokens.read()?.accessToken, 'acc-2');
      expect(tokens.read()?.refreshToken, 'ref-2');
    });

    test('logout removes the stored session for good', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = MemoryKeyValueStore();
      var tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      await tokens.save(_a);
      await tokens.clear();
      tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      expect(tokens.read(), isNull);
    });

    test('a corrupt stored value recovers to signed out', () async {
      FlutterSecureStorage.setMockInitialValues({
        SecureTokenStore.storageKey: '{broken',
      });
      final prefs = MemoryKeyValueStore({installMarkerKey: '1'});
      final tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      expect(tokens.read(), isNull);
      // ...and the broken entry is gone, so it cannot fail again.
      expect(
        await PlatformSecretStore().read(SecureTokenStore.storageKey),
        isNull,
      );
    });

    test(
      'reinstall: a Keychain entry without the install marker is wiped',
      () async {
        // iOS keeps Keychain items across uninstall, preferences are lost.
        FlutterSecureStorage.setMockInitialValues({
          SecureTokenStore.storageKey: '{"a":"old-acc","r":"old-ref"}',
        });
        final prefs = MemoryKeyValueStore(); // fresh install: no marker
        final tokens = await loadTokenStore(
          secrets: PlatformSecretStore(),
          preferences: prefs,
        );
        expect(tokens.read(), isNull);
        expect(
          await PlatformSecretStore().read(SecureTokenStore.storageKey),
          isNull,
        );
        expect(prefs.read(installMarkerKey), '1');
      },
    );

    test(
      'no secret store in the build: memory only, nothing persisted',
      () async {
        final prefs = MemoryKeyValueStore();
        final tokens = await loadTokenStore(secrets: null, preferences: prefs);
        await tokens.save(_a);
        expect(tokens, isA<InMemoryTokenStore>());
        // Nothing about the session reaches ordinary preferences.
        expect(prefs.read(installMarkerKey), isNull);
        expect(prefs.read(SecureTokenStore.storageKey), isNull);
      },
    );
  });

  group('refresh coordination with persistence', () {
    test(
      'three concurrent 401s -> one refresh -> one persisted pair',
      () async {
        FlutterSecureStorage.setMockInitialValues({});
        final prefs = MemoryKeyValueStore({installMarkerKey: '1'});
        final tokens = await loadTokenStore(
          secrets: PlatformSecretStore(),
          preferences: prefs,
        );
        await tokens.save(_a);
        var refreshCalls = 0;
        final inner = HandlerApiClient((req) async {
          if (req.path == AuthenticatedApiClient.refreshPath) {
            refreshCalls++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return const ApiResponse(200, {
              'accessToken': 'acc-2',
              'refreshToken': 'ref-2',
            });
          }
          return req.headers?['Authorization'] == 'Bearer acc-2'
              ? const ApiResponse(200)
              : const ApiResponse(401);
        });
        final client = AuthenticatedApiClient(inner: inner, tokens: tokens);
        final results = await Future.wait([
          for (var i = 0; i < 3; i++)
            client.send(ApiRequest(HttpMethod.get, '/x$i', requiresAuth: true)),
        ]);
        expect(results.map((r) => r.statusCode), [200, 200, 200]);
        expect(refreshCalls, 1);

        final restarted = await loadTokenStore(
          secrets: PlatformSecretStore(),
          preferences: prefs,
        );
        expect(restarted.read()?.accessToken, 'acc-2');
        expect(restarted.read()?.refreshToken, 'ref-2');
      },
    );

    test('a rejected refresh wipes the persisted session', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final prefs = MemoryKeyValueStore({installMarkerKey: '1'});
      final tokens = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      await tokens.save(_a);
      var expired = 0;
      final client = AuthenticatedApiClient(
        inner: HandlerApiClient((_) async => const ApiResponse(401)),
        tokens: tokens,
        onSessionExpired: () => expired++,
      );
      await client.send(
        const ApiRequest(HttpMethod.get, '/x', requiresAuth: true),
      );
      expect(expired, 1);
      final restarted = await loadTokenStore(
        secrets: PlatformSecretStore(),
        preferences: prefs,
      );
      expect(restarted.read(), isNull); // a revoked session is not restored
    });
  });
}
