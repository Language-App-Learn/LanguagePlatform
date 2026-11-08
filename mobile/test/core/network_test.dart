import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/config/api_config.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/authenticated_api_client.dart';
import 'package:language_platform/core/network/http_api_client.dart';
import 'package:language_platform/core/network/token_store.dart';

import '../fakes/five_stage_fakes.dart';

class _Seen {
  _Seen(this.method, this.path, this.query, this.headers, this.body);

  final String method;
  final String path;
  final Map<String, String> query;
  final HttpHeaders headers;
  final String body;
}

void main() {
  group('ApiConfig', () {
    test('https is accepted; plain http only for local development hosts', () {
      expect(
        ApiConfig.parse('https://api.example.com')?.host,
        'api.example.com',
      );
      expect(ApiConfig.parse('http://10.0.2.2:5000'), isNotNull);
      expect(ApiConfig.parse('http://localhost:5000'), isNotNull);
      expect(ApiConfig.parse('http://192.168.1.20:5000'), isNotNull);
      expect(ApiConfig.parse('http://api.example.com'), isNull); // no cleartext
      expect(ApiConfig.parse(''), isNull);
      expect(ApiConfig.parse('not a url'), isNull);
      expect(ApiConfig.parse('ftp://x.com'), isNull);
    });
  });

  group('HttpApiClient (real loopback server)', () {
    late HttpServer server;
    late List<_Seen> seen;
    late Future<void> Function(HttpRequest, String body) respond;
    late HttpApiClient client;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      seen = [];
      respond = (req, body) async {
        req.response.statusCode = 200;
        req.response.headers.contentType = ContentType.json;
        req.response.write(jsonEncode({'ok': true}));
        await req.response.close();
      };
      server.listen((req) async {
        final body = await utf8.decoder.bind(req).join();
        seen.add(
          _Seen(
            req.method,
            req.uri.path,
            req.uri.queryParameters,
            req.headers,
            body,
          ),
        );
        await respond(req, body);
      });
      client = HttpApiClient(
        baseUri: Uri.parse('http://127.0.0.1:${server.port}/base/'),
        timeout: const Duration(milliseconds: 600),
      );
    });

    tearDown(() async {
      client.close();
      await server.close(force: true);
    });

    test('GET: base path, query, custom headers and decoded JSON', () async {
      final response = await client.send(
        const ApiRequest(
          HttpMethod.get,
          '/api/v1/x',
          query: {'a': '1', 'b': 'ç ş'},
          headers: {'X-Test': 'yes'},
        ),
      );
      expect(response.statusCode, 200);
      expect(response.json, {'ok': true});
      expect(seen.single.method, 'GET');
      expect(seen.single.path, '/base/api/v1/x');
      expect(seen.single.query, {'a': '1', 'b': 'ç ş'});
      expect(seen.single.headers.value('x-test'), 'yes');
      expect(seen.single.headers.value('accept'), 'application/json');
    });

    test('POST sends UTF-8 JSON and keeps Arabic text intact', () async {
      await client.send(
        const ApiRequest(HttpMethod.post, '/echo', body: {'text': 'مَرْحَبًا'}),
      );
      expect(seen.single.headers.contentType?.mimeType, 'application/json');
      expect(jsonDecode(seen.single.body), {'text': 'مَرْحَبًا'});
    });

    test('empty body, non-JSON body and response headers', () async {
      respond = (req, _) async {
        req.response.statusCode = 204;
        req.response.headers.set('X-Next-Cursor', 'abc');
        await req.response.close();
      };
      final empty = await client.send(const ApiRequest(HttpMethod.put, '/e'));
      expect(empty.statusCode, 204);
      expect(empty.json, isNull);
      expect(empty.headers['x-next-cursor'], 'abc');

      respond = (req, _) async {
        req.response.statusCode = 503;
        req.response.write('<html>down</html>');
        await req.response.close();
      };
      final html = await client.send(const ApiRequest(HttpMethod.get, '/h'));
      expect(html.statusCode, 503);
      expect(html.json, isNull);
      expect(() => html.ensureSuccess(), throwsA(isA<ServerFailure>()));
    });

    test('problem+json errors are mapped by status only', () async {
      respond = (req, _) async {
        req.response.statusCode = 404;
        req.response.headers.contentType = ContentType(
          'application',
          'problem+json',
        );
        req.response.write(
          jsonEncode({'title': 'secret detail', 'status': 404}),
        );
        await req.response.close();
      };
      final r = await client.send(const ApiRequest(HttpMethod.get, '/m'));
      expect(() => r.unwrap((j) => j), throwsA(isA<NotFoundFailure>()));
    });

    test('slow server becomes TimeoutFailure', () async {
      respond = (req, _) => Future<void>.delayed(const Duration(seconds: 3));
      await expectLater(
        client.send(const ApiRequest(HttpMethod.get, '/slow')),
        throwsA(isA<TimeoutFailure>()),
      );
    });

    test(
      'closed server never succeeds and maps to a connectivity failure',
      () async {
        final closed = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final deadPort = closed.port;
        await closed.close(force: true);
        final dead = HttpApiClient(
          baseUri: Uri.parse('http://127.0.0.1:$deadPort'),
          timeout: const Duration(seconds: 6),
          maxGetRetries: 0,
        );
        addTearDown(dead.close);
        await expectLater(
          dead.send(const ApiRequest(HttpMethod.get, '/x')),
          throwsA(
            anyOf(isA<NetworkUnavailableFailure>(), isA<TimeoutFailure>()),
          ), // Windows delays refusals
        );
      },
    );
  });

  group('AuthenticatedApiClient', () {
    TokenPair pair(String a, [String r = 'r1']) =>
        TokenPair(accessToken: a, refreshToken: r);

    test('adds the bearer only to requests that need it', () async {
      final tokens = InMemoryTokenStore();
      await tokens.save(pair('a1'));
      final inner = HandlerApiClient((_) async => const ApiResponse(200));
      final client = AuthenticatedApiClient(inner: inner, tokens: tokens);

      await client.send(const ApiRequest(HttpMethod.get, '/public'));
      await client.send(
        const ApiRequest(HttpMethod.get, '/private', requiresAuth: true),
      );
      expect(inner.requests[0].headers, isNull);
      expect(inner.requests[1].headers?['Authorization'], 'Bearer a1');
    });

    test(
      'no tokens: protected call is rejected without a network call',
      () async {
        final inner = HandlerApiClient((_) async => const ApiResponse(200));
        final client = AuthenticatedApiClient(
          inner: inner,
          tokens: InMemoryTokenStore(),
        );
        final r = await client.send(
          const ApiRequest(HttpMethod.get, '/p', requiresAuth: true),
        );
        expect(r.statusCode, 401);
        expect(inner.requests, isEmpty);
      },
    );

    test('401 -> one refresh -> retry once with the new token', () async {
      final tokens = InMemoryTokenStore();
      await tokens.save(pair('old'));
      final inner = HandlerApiClient((req) async {
        if (req.path == AuthenticatedApiClient.refreshPath) {
          return const ApiResponse(200, {
            'accessToken': 'new',
            'refreshToken': 'r2',
          });
        }
        return req.headers?['Authorization'] == 'Bearer new'
            ? const ApiResponse(200, {'ok': 1})
            : const ApiResponse(401);
      });
      final client = AuthenticatedApiClient(inner: inner, tokens: tokens);
      final r = await client.send(
        const ApiRequest(HttpMethod.get, '/me', requiresAuth: true),
      );
      expect(r.statusCode, 200);
      expect(tokens.read()?.accessToken, 'new');
      expect(tokens.read()?.refreshToken, 'r2'); // both replaced together
      expect(inner.requests.map((q) => q.path), [
        '/me',
        AuthenticatedApiClient.refreshPath,
        '/me',
      ]);
    });

    test('concurrent 401s share ONE refresh', () async {
      final tokens = InMemoryTokenStore();
      await tokens.save(pair('old'));
      final refreshGate = Completer<void>();
      var refreshCalls = 0;
      final inner = HandlerApiClient((req) async {
        if (req.path == AuthenticatedApiClient.refreshPath) {
          refreshCalls++;
          await refreshGate.future;
          return const ApiResponse(200, {
            'accessToken': 'new',
            'refreshToken': 'r2',
          });
        }
        return req.headers?['Authorization'] == 'Bearer new'
            ? const ApiResponse(200)
            : const ApiResponse(401);
      });
      final client = AuthenticatedApiClient(inner: inner, tokens: tokens);
      final calls = [
        for (var i = 0; i < 3; i++)
          client.send(ApiRequest(HttpMethod.get, '/a$i', requiresAuth: true)),
      ];
      await Future<void>.delayed(const Duration(milliseconds: 20));
      refreshGate.complete();
      final results = await Future.wait(calls);
      expect(results.map((r) => r.statusCode), [200, 200, 200]);
      expect(refreshCalls, 1);
    });

    test('failed refresh clears tokens and reports session expiry', () async {
      final tokens = InMemoryTokenStore();
      await tokens.save(pair('old'));
      var expired = 0;
      final inner = HandlerApiClient((req) async => const ApiResponse(401));
      final client = AuthenticatedApiClient(
        inner: inner,
        tokens: tokens,
        onSessionExpired: () => expired++,
      );
      final r = await client.send(
        const ApiRequest(HttpMethod.get, '/me', requiresAuth: true),
      );
      expect(r.statusCode, 401);
      expect(tokens.read(), isNull);
      expect(expired, 1);
    });

    test('network error during refresh keeps the session', () async {
      final tokens = InMemoryTokenStore();
      await tokens.save(pair('old'));
      var expired = 0;
      final inner = HandlerApiClient((req) async {
        if (req.path == AuthenticatedApiClient.refreshPath) {
          throw const NetworkUnavailableFailure();
        }
        return const ApiResponse(401);
      });
      final client = AuthenticatedApiClient(
        inner: inner,
        tokens: tokens,
        onSessionExpired: () => expired++,
      );
      await client.send(
        const ApiRequest(HttpMethod.get, '/me', requiresAuth: true),
      );
      expect(tokens.read()?.accessToken, 'old');
      expect(expired, 0);
    });
  });
}
