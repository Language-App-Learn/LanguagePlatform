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
Finder _field(String label) => find.widgetWithText(TextFormField, label);

List<Override> _auth(HandlerApiClient api) => [
  apiBaseUriProvider.overrideWithValue(Uri.parse('http://localhost:5000')),
  authRepositoryProvider.overrideWithValue(
    RemoteAuthRepository(api, InMemoryTokenStore()),
  ),
];

void main() {
  group('password reset: request, then confirm with the emailed code', () {
    testWidgets('full flow with the password policy enforced first', (
      tester,
    ) async {
      useScreen(tester, height: 1600);
      final api = HandlerApiClient(
        (r) async => r.path.endsWith('/request')
            ? const ApiResponse(202)
            : const ApiResponse(204),
      );
      await pumpApp(
        tester,
        initialLocation: '/auth/forgot-password',
        overrides: _auth(api),
      );
      expect(_key('reset-code'), findsNothing); // step 2 hidden until needed
      await tester.enterText(_field('Email'), 'a@b.co');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: _key('auth-status'),
          matching: find.textContaining('reset instructions'),
        ),
        findsOneWidget,
      );
      expect(_key('reset-code'), findsOneWidget);

      // Weak password: told before any request is made.
      await tester.enterText(_key('reset-code'), '123456');
      await tester.enterText(_field('New password'), 'weakpass');
      await tester.ensureVisible(_key('reset-confirm'));
      await tester.tap(_key('reset-confirm'));
      await tester.pumpAndSettle();
      expect(find.textContaining('at least 12 characters'), findsOneWidget);
      expect(api.requests, hasLength(1)); // only the request step

      await tester.enterText(_field('New password'), 'Str0ng!Passw0rd');
      await tester.tap(_key('reset-confirm'));
      await tester.pumpAndSettle();
      expect(api.requests.last.path, '/api/v1/auth/password-reset/confirm');
      expect(api.requests.last.body, {
        'email': 'a@b.co',
        'code': '123456',
        'newPassword': 'Str0ng!Passw0rd',
      });
      expect(
        find.text('Password changed. You can sign in now.'),
        findsOneWidget,
      );
      expect(_key('reset-code'), findsNothing);
    });

    testWidgets('no email delivery: honest "not connected", no step 2', (
      tester,
    ) async {
      useScreen(tester, height: 1600);
      final api = HandlerApiClient((_) async => const ApiResponse(503));
      await pumpApp(
        tester,
        initialLocation: '/auth/forgot-password',
        overrides: _auth(api),
      );
      await tester.enterText(_field('Email'), 'a@b.co');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      expect(find.textContaining('not connected to a server'), findsOneWidget);
      expect(_key('reset-code'), findsNothing);
    });

    testWidgets('a wrong or expired code is reported without server text', (
      tester,
    ) async {
      useScreen(tester, height: 1600);
      final api = HandlerApiClient(
        (r) async => r.path.endsWith('/request')
            ? const ApiResponse(202)
            : const ApiResponse(400, {'title': 'SERVER-DETAIL'}),
      );
      await pumpApp(
        tester,
        initialLocation: '/auth/forgot-password',
        overrides: _auth(api),
      );
      await tester.enterText(_field('Email'), 'a@b.co');
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      await tester.enterText(_key('reset-code'), '000000');
      await tester.enterText(_field('New password'), 'Str0ng!Passw0rd');
      await tester.ensureVisible(_key('reset-confirm'));
      await tester.tap(_key('reset-confirm'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please check the details you entered.'),
        findsOneWidget,
      );
      expect(find.textContaining('SERVER-DETAIL'), findsNothing);
    });
  });

  group('email confirmation', () {
    testWidgets('link values are posted and success is shown', (tester) async {
      useScreen(tester, height: 1200);
      final api = HandlerApiClient((_) async => const ApiResponse(204));
      await pumpApp(
        tester,
        initialLocation: '/auth/confirm-email?userId=u-1&code=abc%2B123',
        overrides: _auth(api),
      );
      expect(api.requests.single.path, '/api/v1/auth/confirm-email');
      expect(api.requests.single.body, {'userId': 'u-1', 'code': 'abc+123'});
      expect(
        find.text('Email confirmed. You can sign in now.'),
        findsOneWidget,
      );
    });

    testWidgets('an invalid or expired link says so', (tester) async {
      useScreen(tester, height: 1200);
      final api = HandlerApiClient((_) async => const ApiResponse(400));
      await pumpApp(
        tester,
        initialLocation: '/auth/confirm-email?userId=u-1&code=bad',
        overrides: _auth(api),
      );
      expect(_key('confirm-email-failed'), findsOneWidget);
      expect(find.textContaining('Email confirmed'), findsNothing);
    });

    testWidgets('a link without values never calls the server', (tester) async {
      useScreen(tester, height: 1200);
      final api = HandlerApiClient((_) async => const ApiResponse(204));
      await pumpApp(
        tester,
        initialLocation: '/auth/confirm-email',
        overrides: _auth(api),
      );
      expect(_key('confirm-email-failed'), findsOneWidget);
      expect(api.requests, isEmpty);
    });
  });

  group('registration follow-up', () {
    testWidgets('after 202 the learner can resend the confirmation email', (
      tester,
    ) async {
      useScreen(tester, height: 1600);
      final api = HandlerApiClient((_) async => const ApiResponse(202));
      await pumpApp(
        tester,
        initialLocation: '/auth/register',
        overrides: _auth(api),
      );
      await tester.enterText(_field('Name'), 'Ayşe');
      await tester.enterText(_field('Email'), 'a@b.co');
      await tester.enterText(_field('Password'), 'Str0ng!Passw0rd');
      await tester.enterText(_field('Confirm password'), 'Str0ng!Passw0rd');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(api.requests.single.body, {
        'email': 'a@b.co',
        'password': 'Str0ng!Passw0rd',
      }); // the name is not part of the contract
      await tester.ensureVisible(_key('resend-confirmation'));
      await tester.tap(_key('resend-confirmation'));
      await tester.pumpAndSettle();
      expect(api.requests.last.path, '/api/v1/auth/confirm-email/resend');
      expect(api.requests.last.body, {'email': 'a@b.co'});
      expect(find.textContaining('a new email will be sent'), findsOneWidget);
    });

    testWidgets('resend without delivery is "not connected"', (tester) async {
      useScreen(tester, height: 1600);
      var status = 202;
      final api = HandlerApiClient((_) async => ApiResponse(status));
      await pumpApp(
        tester,
        initialLocation: '/auth/register',
        overrides: _auth(api),
      );
      await tester.enterText(_field('Name'), 'Ayşe');
      await tester.enterText(_field('Email'), 'a@b.co');
      await tester.enterText(_field('Password'), 'Str0ng!Passw0rd');
      await tester.enterText(_field('Confirm password'), 'Str0ng!Passw0rd');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
      status = 503;
      await tester.ensureVisible(_key('resend-confirmation'));
      await tester.tap(_key('resend-confirmation'));
      await tester.pumpAndSettle();
      expect(find.textContaining('not connected to a server'), findsOneWidget);
    });
  });
}
