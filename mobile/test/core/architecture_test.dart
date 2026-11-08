import 'package:flutter/painting.dart' show TextDirection;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/errors/app_exceptions.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/l10n/app_language.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/storage/key_value_store.dart';
import 'package:language_platform/features/language_selection/domain/learning_language.dart';

import '../fakes/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  group('GuardedKeyValueStore', () {
    test('read-your-writes before the write is flushed', () async {
      final inner = ControllableStore()..gated = true;
      final store = GuardedKeyValueStore(inner);
      final done = store.write('k', 'v1');
      expect(store.read('k'), 'v1'); // visible immediately
      expect(inner.read('k'), isNull); // not yet on "disk"
      await Future<void>.delayed(Duration.zero);
      inner.gates.single.complete();
      await done;
      expect(inner.read('k'), 'v1');
    });

    test('rapid writes to one key are ordered and coalesced', () async {
      final inner = ControllableStore();
      final store = GuardedKeyValueStore(inner);
      final futures = [
        store.write('k', 'a'),
        store.write('k', 'b'),
        store.write('k', 'c'),
      ];
      await Future.wait(futures);
      await store.flush();
      expect(inner.read('k'), 'c'); // newest wins, nothing lost
      expect(inner.writes.last, 'c');
      expect(inner.writes.length, lessThanOrEqualTo(3));
    });

    test(
      'failed writes do not throw, are counted and never look saved',
      () async {
        final inner = ControllableStore(failWrites: true);
        final store = GuardedKeyValueStore(inner);
        await store.write('k', 'v'); // must not throw
        expect(store.failedWrites.value, 1);
        expect(inner.read('k'), isNull); // really not persisted
        expect(store.read('k'), 'v'); // still usable in this session

        inner.failWrites = false;
        await store.write('k', 'v2'); // next write retries
        expect(inner.read('k'), 'v2');
        expect(store.failedWrites.value, 1);
      },
    );

    test('clearAll waits for pending writes, then clears', () async {
      final inner = ControllableStore();
      final store = GuardedKeyValueStore(inner);
      unawaited(store.write('lp.a', '1'));
      await store.clearAll();
      expect(store.read('lp.a'), isNull);
      expect(inner.read('lp.a'), isNull);
    });

    test('failure count is exposed through a provider', () async {
      final store = GuardedKeyValueStore(ControllableStore(failWrites: true));
      final c = ProviderContainer.test(
        overrides: [keyValueStoreProvider.overrideWithValue(store)],
      );
      expect(c.read(persistenceFailuresProvider), 0);
      await store.write('k', 'v');
      expect(c.read(persistenceFailuresProvider), 1);
    });
  });

  group('failure model', () {
    test('exceptions map to typed failures', () {
      expect(failureOf(const NotFoundException('x')), isA<NotFoundFailure>());
      expect(
        failureOf(const ServiceUnavailableException('x')),
        isA<ServiceUnavailableFailure>(),
      );
      expect(failureOf(TimeoutException('t')), isA<TimeoutFailure>());
      expect(
        failureOf(const SocketException('down')),
        isA<NetworkUnavailableFailure>(),
      );
      expect(
        failureOf(const FormatException('bad')),
        isA<UnexpectedResponseFailure>(),
      );
      expect(failureOf(StateError('boom')), isA<UnknownFailure>());
      expect(failureOf(const ForbiddenFailure()), isA<ForbiddenFailure>());
    });

    test('only transient failures offer retry', () {
      expect(const NetworkUnavailableFailure().isRecoverable, isTrue);
      expect(const ServerFailure().isRecoverable, isTrue);
      expect(const NotFoundFailure().isRecoverable, isFalse);
      expect(const UnauthorizedFailure().isRecoverable, isFalse);
      expect(const ServiceUnavailableFailure().isRecoverable, isFalse);
    });

    test('HTTP status codes map to failures', () {
      expect(failureForStatus(401), isA<UnauthorizedFailure>());
      expect(failureForStatus(403), isA<ForbiddenFailure>());
      expect(failureForStatus(404), isA<NotFoundFailure>());
      expect(failureForStatus(422), isA<ValidationFailure>());
      expect(failureForStatus(504), isA<TimeoutFailure>());
      expect(failureForStatus(503), isA<ServerFailure>());
      expect(failureForStatus(302), isA<UnexpectedResponseFailure>());
    });
  });

  group('ApiClient boundary (fake transport)', () {
    test('2xx body is parsed; bad shape becomes UnexpectedResponse', () async {
      final api = FakeApiClient([
        const ApiResponse(200, {'name': 'x'}),
        const ApiResponse(200, 'not a map'),
        const ApiResponse(500),
        TimeoutException('slow'),
      ]);
      const req = ApiRequest(HttpMethod.get, '/placeholder');
      final ok = (await api.send(req))
          .unwrap((j) => (j! as Map<String, Object?>)['name']! as String);
      expect(ok, 'x');

      final bad = await api.send(req);
      expect(
        () => bad.unwrap((j) => (j! as Map<String, Object?>)['name']),
        throwsA(isA<UnexpectedResponseFailure>()),
      );

      final server = await api.send(req);
      expect(() => server.unwrap((j) => j), throwsA(isA<ServerFailure>()));

      await expectLater(api.send(req), throwsA(isA<TimeoutException>()));
      expect(api.requests, hasLength(4));
    });
  });

  group('multilingual content', () {
    test('learning languages are independent of interface languages', () {
      expect(
        LearningLanguage.supported.map((l) => l.code),
        containsAll(AppLanguage.values.map((l) => l.code)),
      );
      expect(LearningLanguage.fromCode('ar')!.textDirection, TextDirection.rtl);
      expect(LearningLanguage.fromCode('de'), isNull); // not offered yet
    });
  });

  group('navigation resilience', () {
    testWidgets('unknown route shows a localized not-found page', (
      tester,
    ) async {
      final c = await pumpApp(tester, initialLocation: '/no/such/page');
      expect(find.text('Page not found'), findsOneWidget);
      await tester.tap(find.text('Go to home'));
      await tester.pumpAndSettle();
      expect(currentPath(c), isNot('/no/such/page'));
    });
  });
}
