import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';
import 'package:language_platform/features/authentication/data/remote_auth_repository.dart';

import '../fakes/five_stage_fakes.dart';
import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

Future<InMemoryTokenStore> _signedInTokens() async {
  final t = InMemoryTokenStore();
  await t.save(const TokenPair(accessToken: 'acc', refreshToken: 'ref'));
  return t;
}

List<Override> _auth(HandlerApiClient api, InMemoryTokenStore tokens) => [
  apiBaseUriProvider.overrideWithValue(Uri.parse('http://localhost:5000')),
  tokenStoreProvider.overrideWithValue(tokens),
  authRepositoryProvider.overrideWithValue(RemoteAuthRepository(api, tokens)),
  sessionProvider.overrideWith(
    () => SessionNotifier(SessionStatus.authenticated),
  ),
];

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String password = 'My-Password-1!',
  String code = '',
  bool understand = true,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  if (code.isNotEmpty) {
    await tester.enterText(_key('delete-authenticator'), code);
  }
  if (understand) {
    await tester.ensureVisible(_key('delete-understand'));
    await tester.tap(_key('delete-understand'));
    await tester.pump();
  }
  await tester.ensureVisible(_key('delete-submit'));
  await tester.tap(_key('delete-submit'));
  await tester.pumpAndSettle();
}

void main() {
  group('account deletion request', () {
    testWidgets('the page states what really happens', (tester) async {
      useScreen(tester, height: 2400);
      final tokens = await _signedInTokens();
      await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(
          HandlerApiClient((_) async => const ApiResponse(202)),
          tokens,
        ),
      );
      expect(
        find.textContaining('deactivates your account right away'),
        findsOneWidget,
      );
      // Honest about the purge being an operator task.
      expect(find.textContaining('not erased instantly'), findsOneWidget);
      expect(
        find.textContaining('final removal is completed by the operator'),
        findsOneWidget,
      );
    });

    testWidgets('needs the password AND an explicit acknowledgement', (
      tester,
    ) async {
      useScreen(tester, height: 2400);
      final api = HandlerApiClient((_) async => const ApiResponse(202));
      await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(api, await _signedInTokens()),
      );
      await _fillAndSubmit(tester, password: '', understand: false);
      expect(api.requests, isEmpty);
      await _fillAndSubmit(tester, understand: false);
      expect(api.requests, isEmpty); // password given, not acknowledged
      expect(find.text('This field is required'), findsWidgets);
    });

    testWidgets('the final dialog can be cancelled: nothing is sent', (
      tester,
    ) async {
      useScreen(tester, height: 2400);
      final api = HandlerApiClient((_) async => const ApiResponse(202));
      final tokens = await _signedInTokens();
      final c = await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(api, tokens),
      );
      await _fillAndSubmit(tester);
      expect(find.text('Request deletion?'), findsOneWidget);
      await tester.tap(_key('delete-cancel'));
      await tester.pumpAndSettle();
      expect(api.requests, isEmpty);
      expect(tokens.read(), isNotNull);
      expect(c.read(sessionProvider), SessionStatus.authenticated);
    });

    testWidgets('202: request sent with the password, session ended locally', (
      tester,
    ) async {
      useScreen(tester, height: 2400);
      final api = HandlerApiClient((_) async => const ApiResponse(202));
      final tokens = await _signedInTokens();
      final c = await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(api, tokens),
      );
      await _fillAndSubmit(tester, code: '123456');
      await tester.tap(_key('delete-confirm'));
      await tester.pumpAndSettle();

      final sent = api.requests.single;
      expect(sent.path, '/api/v1/me/privacy/deletion-request');
      expect(sent.method, HttpMethod.post);
      expect(sent.requiresAuth, isTrue);
      expect(sent.body, {
        'password': 'My-Password-1!',
        'authenticatorCode': '123456',
      });
      expect(_key('delete-done'), findsOneWidget);
      expect(find.textContaining('Deletion request received'), findsOneWidget);
      expect(tokens.read(), isNull);
      expect(c.read(sessionProvider), SessionStatus.signedOut);

      await tester.tap(_key('delete-back-to-login'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/auth/login');
    });

    testWidgets('an empty authenticator code is not sent', (tester) async {
      useScreen(tester, height: 2400);
      final api = HandlerApiClient((_) async => const ApiResponse(202));
      await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(api, await _signedInTokens()),
      );
      await _fillAndSubmit(tester);
      await tester.tap(_key('delete-confirm'));
      await tester.pumpAndSettle();
      expect(api.requests.single.body, {'password': 'My-Password-1!'});
    });

    testWidgets('wrong password: explained, account and session untouched', (
      tester,
    ) async {
      useScreen(tester, height: 2400);
      final api = HandlerApiClient((_) async => const ApiResponse(400));
      final tokens = await _signedInTokens();
      final c = await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(api, tokens),
      );
      await _fillAndSubmit(tester, password: 'wrong');
      await tester.tap(_key('delete-confirm'));
      await tester.pumpAndSettle();
      expect(find.text('The password or code is not valid.'), findsOneWidget);
      expect(_key('delete-done'), findsNothing);
      expect(tokens.read(), isNotNull); // nothing was deleted or signed out
      expect(c.read(sessionProvider), SessionStatus.authenticated);
    });

    testWidgets('429 and 409 keep their own messages', (tester) async {
      useScreen(tester, height: 2400);
      var status = 429;
      final api = HandlerApiClient((_) async => ApiResponse(status));
      await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(api, await _signedInTokens()),
      );
      await _fillAndSubmit(tester);
      await tester.tap(_key('delete-confirm'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Too many requests'), findsOneWidget);
      status = 409;
      await tester.ensureVisible(_key('delete-submit'));
      await tester.tap(_key('delete-submit'));
      await tester.pumpAndSettle();
      await tester.tap(_key('delete-confirm'));
      await tester.pumpAndSettle();
      expect(find.textContaining("isn't available right now"), findsOneWidget);
    });

    testWidgets('a 200 (not 202) is never treated as a deletion', (
      tester,
    ) async {
      useScreen(tester, height: 2400);
      final api = HandlerApiClient((_) async => const ApiResponse(200));
      final tokens = await _signedInTokens();
      await pumpApp(
        tester,
        initialLocation: '/delete-account',
        overrides: _auth(api, tokens),
      );
      await _fillAndSubmit(tester);
      await tester.tap(_key('delete-confirm'));
      await tester.pumpAndSettle();
      expect(_key('delete-done'), findsNothing);
      expect(tokens.read(), isNotNull);
    });
  });

  group('login with an authenticator code', () {
    testWidgets('the optional code is sent only when entered', (tester) async {
      useScreen(tester, height: 1600);
      final api = HandlerApiClient(
        (_) async =>
            const ApiResponse(200, {'accessToken': 'a', 'refreshToken': 'r'}),
      );
      final tokens = InMemoryTokenStore();
      await pumpApp(
        tester,
        initialLocation: '/auth/login',
        overrides: [
          apiBaseUriProvider.overrideWithValue(
            Uri.parse('http://localhost:5000'),
          ),
          tokenStoreProvider.overrideWithValue(tokens),
          authRepositoryProvider.overrideWithValue(
            RemoteAuthRepository(api, tokens),
          ),
          sessionProvider.overrideWith(
            () => SessionNotifier(SessionStatus.signedOut),
          ),
        ],
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.co',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'pw-123456',
      );
      await tester.enterText(_key('login-authenticator'), '654321');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(api.requests.single.body, {
        'email': 'a@b.co',
        'password': 'pw-123456',
        'authenticatorCode': '654321',
      });
    });
  });
}
