import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/authenticated_api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/core/storage/pending_attempt_store.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';
import 'package:language_platform/features/authentication/data/remote_auth_repository.dart';
import 'package:language_platform/features/authentication/domain/auth_validators.dart';

import '../fakes/five_stage_fakes.dart';

class _FakeSecrets implements SecretStore {
  final Map<String, String> data = {};
  bool failWrites = false;
  bool failDeletes = false;
  bool failReads = false;
  int writes = 0;

  @override
  Future<String?> read(String key) async {
    if (failReads) throw StateError('keystore unavailable');
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw StateError('disk full');
    writes++;
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (failDeletes) throw StateError('locked');
    data.remove(key);
  }
}

const _pair = TokenPair(accessToken: 'acc-1', refreshToken: 'ref-1');

void main() {
  group('SecureTokenStore (Keystore / Keychain behind SecretStore)', () {
    test(
      'both tokens are persisted as ONE entry and restored on start',
      () async {
        final secrets = _FakeSecrets();
        final store = SecureTokenStore(secrets);
        await store.save(_pair);
        expect(secrets.data.keys, [SecureTokenStore.storageKey]);
        expect(secrets.writes, 1); // atomic: never access then refresh

        final restarted = SecureTokenStore(secrets);
        expect(restarted.read(), isNull); // nothing until loaded
        await restarted.load();
        expect(restarted.read()?.accessToken, 'acc-1');
        expect(restarted.read()?.refreshToken, 'ref-1');
      },
    );

    test('a refresh replaces the pair in a single write', () async {
      final secrets = _FakeSecrets();
      final store = SecureTokenStore(secrets);
      await store.save(_pair);
      await store.save(
        const TokenPair(accessToken: 'acc-2', refreshToken: 'ref-2'),
      );
      expect(secrets.writes, 2);
      final stored = jsonDecode(secrets.data[SecureTokenStore.storageKey]!);
      expect(stored, {'a': 'acc-2', 'r': 'ref-2'}); // never a mixed pair
    });

    test('clear removes the stored entry and memory', () async {
      final secrets = _FakeSecrets();
      final store = SecureTokenStore(secrets);
      await store.save(_pair);
      await store.clear();
      expect(store.read(), isNull);
      expect(secrets.data, isEmpty);
    });

    test('a corrupt entry is dropped and means signed out', () async {
      for (final bad in ['not json', '[]', '{"a":"x"}', '{"a":"","r":""}']) {
        final secrets = _FakeSecrets()..data[SecureTokenStore.storageKey] = bad;
        final store = SecureTokenStore(secrets);
        await store.load();
        expect(store.read(), isNull, reason: bad);
        expect(secrets.data, isEmpty, reason: bad);
      }
    });

    test('an unreadable keystore means signed out, not a crash', () async {
      final secrets = _FakeSecrets()..failReads = true;
      final store = SecureTokenStore(secrets);
      await store.load();
      expect(store.read(), isNull);
    });

    test('a failed write keeps the session for this run', () async {
      // A rotated refresh ticket is single-use: dropping it would log the
      // learner out for no reason.
      final secrets = _FakeSecrets()..failWrites = true;
      final store = SecureTokenStore(secrets);
      await store.save(_pair);
      expect(store.read()?.refreshToken, 'ref-1');
    });

    test('a failed delete still clears the in-memory session', () async {
      final secrets = _FakeSecrets();
      final store = SecureTokenStore(secrets);
      await store.save(_pair);
      secrets.failDeletes = true;
      await store.clear();
      expect(store.read(), isNull);
    });
  });

  group('tokens never reach ordinary preferences', () {
    test('sign-in leaves no token in the key/value store', () async {
      final prefs = MemoryKeyValueStore();
      final tokens = InMemoryTokenStore();
      final repo = RemoteAuthRepository(
        HandlerApiClient(
          (_) async => const ApiResponse(200, {
            'accessToken': 'SECRET-ACCESS',
            'refreshToken': 'SECRET-REFRESH',
          }),
        ),
        tokens,
      );
      await repo.signIn(email: 'a@b.co', password: 'pw');
      final container = ProviderContainer(
        overrides: [keyValueStoreProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await container.read(pendingAttemptStoreProvider).keyFor('a');
      final dump = StringBuffer();
      // Everything that was ever written to the preference store.
      for (final key in ['lp.attempts', 'lp.session.v1', 'lp.preferences']) {
        dump.write(prefs.read(key));
      }
      expect(dump.toString(), isNot(contains('SECRET')));
      expect(tokens.read()?.accessToken, 'SECRET-ACCESS');
    });
  });

  group('session restore and expiry', () {
    ProviderContainer containerWith({
      required TokenStore tokens,
      Uri? base,
      MemoryKeyValueStore? prefs,
    }) {
      final c = ProviderContainer(
        overrides: [
          apiBaseUriProvider.overrideWithValue(
            base ?? Uri.parse('https://api.example.com'),
          ),
          tokenStoreProvider.overrideWithValue(tokens),
          if (prefs != null) keyValueStoreProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('stored tokens restore the signed-in session on start', () async {
      final tokens = InMemoryTokenStore();
      await tokens.save(_pair);
      final c = containerWith(tokens: tokens);
      expect(c.read(sessionProvider), SessionStatus.authenticated);
    });

    test('no tokens: signed out', () {
      final c = containerWith(tokens: InMemoryTokenStore());
      expect(c.read(sessionProvider), SessionStatus.signedOut);
    });

    test('demo build (no API) never restores a session', () async {
      final tokens = InMemoryTokenStore();
      await tokens.save(_pair);
      final c = ProviderContainer(
        overrides: [
          apiBaseUriProvider.overrideWithValue(null),
          tokenStoreProvider.overrideWithValue(tokens),
        ],
      );
      addTearDown(c.dispose);
      expect(c.read(sessionProvider), SessionStatus.signedOut);
    });

    test(
      'a revoked session is rejected: refresh fails, back to signed out',
      () async {
        final tokens = InMemoryTokenStore();
        await tokens.save(_pair);
        final c = containerWith(tokens: tokens);
        expect(c.read(sessionProvider), SessionStatus.authenticated);
        final epoch = c.read(accountEpochProvider);

        final client = AuthenticatedApiClient(
          inner: HandlerApiClient((_) async => const ApiResponse(401)),
          tokens: tokens,
          onSessionExpired: () => c.read(sessionProvider.notifier).expired(),
        );
        final r = await client.send(
          const ApiRequest(HttpMethod.get, '/api/v1/me', requiresAuth: true),
        );
        expect(r.statusCode, 401);
        expect(tokens.read(), isNull); // client secrets cleared
        expect(c.read(sessionProvider), SessionStatus.signedOut);
        expect(c.read(accountEpochProvider), greaterThan(epoch));
      },
    );

    test('every identity change bumps the account epoch', () {
      final c = containerWith(tokens: InMemoryTokenStore());
      final seen = <int>[];
      c.listen(accountEpochProvider, (_, n) => seen.add(n));
      final s = c.read(sessionProvider.notifier);
      s.authenticated();
      s.signOut();
      s.authenticated();
      expect(seen, [1, 2, 3]);
    });
  });

  group('PendingAttemptStore', () {
    test('the same key until completed; renew changes it', () async {
      final prefs = MemoryKeyValueStore();
      final store = PendingAttemptStore(prefs);
      final first = await store.keyFor('a');
      expect(await store.keyFor('a'), first);
      expect(store.pending('a'), first);
      final second = await store.renew('a');
      expect(second, isNot(first));
      await store.complete('a');
      expect(store.pending('a'), isNull);
      expect(prefs.read(PendingAttemptStore.storageKey), isNull);
    });

    test(
      'keys are per assessment, long enough and within the API limit',
      () async {
        final store = PendingAttemptStore(MemoryKeyValueStore());
        final a = await store.keyFor('a');
        final b = await store.keyFor('b');
        expect(a, isNot(b));
        expect(a.length, inInclusiveRange(16, 128));
      },
    );

    test('survives a restart through the persisted store', () async {
      final prefs = MemoryKeyValueStore();
      final key = await PendingAttemptStore(prefs).keyFor('a');
      expect(PendingAttemptStore(prefs).pending('a'), key);
    });

    test('corrupt storage is ignored, not fatal', () async {
      final prefs = MemoryKeyValueStore({PendingAttemptStore.storageKey: '{{'});
      final store = PendingAttemptStore(prefs);
      expect(store.pending('a'), isNull);
      expect(await store.keyFor('a'), isNotEmpty);
    });

    test('clearAll forgets everything (account switch)', () async {
      final prefs = MemoryKeyValueStore();
      final store = PendingAttemptStore(prefs);
      await store.keyFor('a');
      await store.keyFor('b');
      await store.clearAll();
      expect(store.pending('a'), isNull);
      expect(store.pending('b'), isNull);
    });
  });

  group('password policy for NEW passwords', () {
    test('mirrors the server Identity policy', () {
      expect(AuthValidators.newPassword('Str0ng!Passw0rd'), isNull);
      expect(AuthValidators.newPassword('Short1!aA'), isNotNull); // < 12
      expect(AuthValidators.newPassword('alllowercase123!'), isNotNull);
      expect(AuthValidators.newPassword('ALLUPPERCASE123!'), isNotNull);
      expect(AuthValidators.newPassword('NoDigitsHere!!!!'), isNotNull);
      expect(AuthValidators.newPassword('NoSymbol1234abcD'), isNotNull);
      expect(AuthValidators.newPassword(''), AuthFieldError.required);
      // Turkish and Arabic letters count as letters, not symbols.
      expect(AuthValidators.newPassword('ŞifremÇokGüçlü12'), isNotNull);
      expect(AuthValidators.newPassword('ŞifremÇokGüçlü12!'), isNull);
    });

    test('sign-in keeps the lenient rule so nobody is locked out', () {
      expect(AuthValidators.password('12345678'), isNull);
      expect(AuthValidators.password('short'), isNotNull);
    });
  });
}
