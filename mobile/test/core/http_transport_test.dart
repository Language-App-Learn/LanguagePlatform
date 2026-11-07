import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/http_api_client.dart';

/// Transport behaviour that matters for a real, flaky mobile network:
/// retries, redirects, binary downloads, cancellation and status mapping.
void main() {
  late HttpServer server;
  late List<HttpRequest> seen;
  late Future<void> Function(HttpRequest req, int count) respond;
  late HttpApiClient client;

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    seen = [];
    respond = (req, _) async {
      req.response.statusCode = 200;
      await req.response.close();
    };
    server.listen((req) async {
      await utf8.decoder.bind(req).join();
      seen.add(req);
      await respond(req, seen.length);
    });
    client = HttpApiClient(
      baseUri: Uri.parse('http://127.0.0.1:${server.port}'),
      timeout: const Duration(milliseconds: 800),
      retryDelay: const Duration(milliseconds: 5),
      maxBinaryBytes: 1024,
    );
  });

  tearDown(() async {
    client.close();
    await server.close(force: true);
  });

  Future<void> status(
    HttpRequest req,
    int code, {
    Map<String, String>? h,
  }) async {
    req.response.statusCode = code;
    h?.forEach(req.response.headers.set);
    await req.response.close();
  }

  group('status mapping (never one generic message)', () {
    test('409 / 413 / 415 / 429 have their own kinds', () {
      expect(failureForStatus(409), isA<ConflictFailure>());
      expect(failureForStatus(413), isA<PayloadTooLargeFailure>());
      expect(failureForStatus(415), isA<UnsupportedMediaFailure>());
      expect(failureForStatus(429), isA<RateLimitedFailure>());
      expect(failureForStatus(400), isA<ValidationFailure>());
      expect(failureForStatus(503), isA<ServerFailure>());
      expect(failureForStatus(302), isA<UnexpectedResponseFailure>());
    });

    test('Retry-After: delta seconds only, bounded', () {
      Duration? after(String? v) => (failureForStatus(
        429,
        retryAfter: v,
      ) as RateLimitedFailure).retryAfter;
      expect(after('7'), const Duration(seconds: 7));
      expect(after('99999'), const Duration(hours: 1));
      expect(after('Wed, 21 Oct 2026 07:28:00 GMT'), isNull);
      expect(after('-3'), isNull);
      expect(after(null), isNull);
    });

    test('rate limiting reaches the caller with the header value', () async {
      respond = (req, _) => status(req, 429, h: {'Retry-After': '3'});
      final r = await client.send(const ApiRequest(HttpMethod.post, '/x'));
      expect(r.failure, isA<RateLimitedFailure>());
      expect(
        (r.failure as RateLimitedFailure).retryAfter,
        const Duration(seconds: 3),
      );
    });

    test(
      'ProblemDetails is diagnostic only; user text never contains it',
      () async {
        respond = (req, _) async {
          req.response.statusCode = 400;
          req.response.headers.contentType = ContentType(
            'application',
            'problem+json',
          );
          req.response.write(
            jsonEncode({
              'type': 'urn:x',
              'title': 'SECRET stack: at Foo.bar()',
              'status': 400,
            }),
          );
          await req.response.close();
        };
        final r = await client.send(
          const ApiRequest(HttpMethod.post, '/x', body: {}),
        );
        expect(r.problem?.status, 400);
        expect(r.problem?.title, contains('SECRET'));
        expect(r.failure, isA<ValidationFailure>()); // kind only
      },
    );
  });

  group('retry policy', () {
    test('GET retries a transient 503 then succeeds', () async {
      respond = (req, n) => n < 3 ? status(req, 503) : status(req, 200);
      final r = await client.send(const ApiRequest(HttpMethod.get, '/g'));
      expect(r.statusCode, 200);
      expect(seen, hasLength(3));
    });

    test('GET gives up after the configured retries', () async {
      respond = (req, _) => status(req, 503);
      final r = await client.send(const ApiRequest(HttpMethod.get, '/g'));
      expect(r.statusCode, 503);
      expect(seen, hasLength(3)); // 1 try + 2 retries
    });

    test('POST / PUT / DELETE are never replayed by the transport', () async {
      respond = (req, _) => status(req, 503);
      for (final m in [HttpMethod.post, HttpMethod.put, HttpMethod.delete]) {
        seen.clear();
        final r = await client.send(
          ApiRequest(m, '/w', body: m == HttpMethod.post ? {} : null),
        );
        expect(r.statusCode, 503);
        expect(seen, hasLength(1), reason: '$m must not be retried');
      }
    });

    test('GET does not retry a definitive 404 or 401', () async {
      for (final code in [401, 403, 404, 409]) {
        seen.clear();
        respond = (req, _) => status(req, code);
        await client.send(const ApiRequest(HttpMethod.get, '/g'));
        expect(seen, hasLength(1), reason: '$code');
      }
    });

    test('a POST that times out is NOT retried automatically', () async {
      respond = (req, _) => Future<void>.delayed(const Duration(seconds: 2));
      await expectLater(
        client.send(const ApiRequest(HttpMethod.post, '/slow', body: {})),
        throwsA(isA<TimeoutFailure>()),
      );
      expect(seen, hasLength(1));
    });
  });

  group('redirects and headers', () {
    test(
      'a redirect is not followed (no token can reach another host)',
      () async {
        final other = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => other.close(force: true));
        var otherHits = 0;
        other.listen((r) async {
          otherHits++;
          await r.response.close();
        });
        respond = (req, _) async {
          req.response.statusCode = 302;
          req.response.headers.set(
            'Location',
            'http://127.0.0.1:${other.port}/steal',
          );
          await req.response.close();
        };
        final r = await client.send(
          const ApiRequest(
            HttpMethod.get,
            '/r',
            headers: {'Authorization': 'Bearer t'},
          ),
        );
        expect(r.statusCode, 302);
        expect(r.failure, isA<UnexpectedResponseFailure>());
        expect(otherHits, 0);
      },
    );

    test('every request has a random correlation id', () async {
      await client.send(const ApiRequest(HttpMethod.get, '/a'));
      await client.send(const ApiRequest(HttpMethod.get, '/b'));
      final ids = seen.map((r) => r.headers.value('x-correlation-id')).toList();
      expect(ids.every((i) => i != null && i.length == 24), isTrue);
      expect(ids[0], isNot(ids[1]));
    });
  });

  group('binary download', () {
    final pdf = utf8.encode('%PDF-1.7 body');

    test('PDF bytes are returned untouched when the type matches', () async {
      respond = (req, _) async {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType('application', 'pdf');
        req.response.add(pdf);
        await req.response.close();
      };
      final r = await client.send(
        const ApiRequest(
          HttpMethod.get,
          '/pdf',
          expectedMime: 'application/pdf',
        ),
      );
      expect(r.bytes, pdf);
      expect(r.json, isNull);
      expect(seen.single.headers.value('accept'), contains('application/pdf'));
    });

    test('a JSON body can never be mistaken for the file', () async {
      respond = (req, _) async {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write('{"ok":true}');
        await req.response.close();
      };
      await expectLater(
        client.send(
          const ApiRequest(
            HttpMethod.get,
            '/pdf',
            expectedMime: 'application/pdf',
          ),
        ),
        throwsA(isA<UnexpectedResponseFailure>()),
      );
    });

    test('an oversized body is rejected while streaming', () async {
      respond = (req, _) async {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType('application', 'pdf');
        req.response.add(List.filled(5000, 1));
        await req.response.close();
      };
      await expectLater(
        client.send(
          const ApiRequest(
            HttpMethod.get,
            '/pdf',
            expectedMime: 'application/pdf',
          ),
        ),
        throwsA(isA<PayloadTooLargeFailure>()),
      );
    });

    test(
      'an error status on a binary route is still a typed failure',
      () async {
        respond = (req, _) => status(req, 404);
        final r = await client.send(
          const ApiRequest(
            HttpMethod.get,
            '/pdf',
            expectedMime: 'application/pdf',
          ),
        );
        expect(r.failure, isA<NotFoundFailure>());
        expect(r.bytes, isNull);
      },
    );
  });

  group('cancellation', () {
    test('cancelling aborts an in-flight request', () async {
      final gate = Completer<void>();
      respond = (req, _) => gate.future;
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      final token = CancelToken();
      final call = client.send(
        ApiRequest(HttpMethod.get, '/slow', cancelToken: token),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      token.cancel();
      await expectLater(call, throwsA(isA<CancelledFailure>()));
    });

    test('an already cancelled token never touches the network', () async {
      final token = CancelToken()..cancel();
      await expectLater(
        client.send(ApiRequest(HttpMethod.get, '/x', cancelToken: token)),
        throwsA(isA<CancelledFailure>()),
      );
      expect(seen, isEmpty);
    });
  });
}
