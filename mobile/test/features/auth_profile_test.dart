import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_router.dart';
import 'package:language_platform/app/router/app_routes.dart';
import 'package:language_platform/core/l10n/l10n.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';

import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

Finder _field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  group('giriş', () {
    Future<void> open(WidgetTester tester) async {
      useScreen(tester, height: 1400);
      await pumpApp(tester, initialLocation: AppRoutes.login);
    }

    testWidgets('boş gönderimde alanlar zorunlu uyarısı verir', (tester) async {
      await open(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
      expect(find.text('This field is required'), findsNWidgets(2));
      expect(_key('auth-status'), findsNothing);
    });

    testWidgets('geçersiz e-posta', (tester) async {
      await open(tester);
      await tester.enterText(_field('Email'), 'abc');
      await tester.enterText(_field('Password'), 'x');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('geçerli form: sahte başarı YOK, dürüst servis uyarısı', (
      tester,
    ) async {
      useScreen(tester, height: 1400);
      final c = await pumpApp(tester, initialLocation: AppRoutes.login);
      await tester.enterText(_field('Email'), 'user@mail.com');
      await tester.enterText(_field('Password'), 'secret123');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(_key('auth-status'), findsOneWidget);
      expect(find.textContaining('not connected to a server'), findsOneWidget);
      expect(currentPath(c), AppRoutes.login);
      expect(c.read(sessionProvider), SessionStatus.signedOut);
    });

    testWidgets('şifre görünürlüğü değişir', (tester) async {
      await open(tester);
      bool obscured() => tester
          .widget<TextField>(
            find.descendant(
              of: _field('Password'),
              matching: find.byType(TextField),
            ),
          )
          .obscureText;
      expect(obscured(), isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(obscured(), isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('e-posta alanı RTL arayüzde de soldan sağa', (tester) async {
      useScreen(tester, height: 1400);
      await pumpApp(
        tester,
        language: AppLanguage.ar,
        initialLocation: AppRoutes.login,
      );
      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).first,
          matching: find.byType(TextField),
        ),
      );
      expect(field.textDirection, TextDirection.ltr);
      expect(currentDirection(tester), TextDirection.rtl);
    });

    testWidgets('demo modu açık ve ayrı bir giriştir', (tester) async {
      useScreen(tester, height: 1400);
      final c = await pumpApp(tester, initialLocation: AppRoutes.login);
      expect(find.textContaining('No account is created'), findsOneWidget);
      await tester.ensureVisible(_key('continue-demo'));
      await tester.tap(_key('continue-demo'));
      await tester.pumpAndSettle();
      expect(c.read(sessionProvider), SessionStatus.demo);
      expect(currentPath(c), AppRoutes.home);
    });

    testWidgets('kayıt ve şifremi unuttum sayfalarına gider', (tester) async {
      useScreen(tester, height: 1400);
      final c = await pumpApp(tester, initialLocation: AppRoutes.login);
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.forgotPassword);
      c.read(routerProvider).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(currentPath(c), AppRoutes.register);
    });
  });

  group('kayıt', () {
    Future<void> fill(
      WidgetTester tester, {
      String name = 'Ayşe',
      String email = 'a@b.co',
      String password = 'password1',
      String confirm = 'password1',
    }) async {
      await tester.enterText(_field('Name'), name);
      await tester.enterText(_field('Email'), email);
      await tester.enterText(_field('Password'), password);
      await tester.enterText(_field('Confirm password'), confirm);
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
    }

    testWidgets('şifreler eşleşmezse uyarı', (tester) async {
      useScreen(tester, height: 1400);
      await pumpApp(tester, initialLocation: AppRoutes.register);
      await fill(tester, confirm: 'different1');
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(_key('auth-status'), findsNothing);
    });

    testWidgets('kısa şifre uyarısı', (tester) async {
      useScreen(tester, height: 1400);
      await pumpApp(tester, initialLocation: AppRoutes.register);
      await fill(tester, password: 'short', confirm: 'short');
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('geçerli form hesap OLUŞTURMAZ, servis uyarısı gösterir', (
      tester,
    ) async {
      useScreen(tester, height: 1400);
      final c = await pumpApp(tester, initialLocation: AppRoutes.register);
      await fill(tester);
      expect(_key('auth-status'), findsOneWidget);
      expect(c.read(sessionProvider), SessionStatus.signedOut);
    });
  });

  group('şifremi unuttum', () {
    testWidgets('doğrulama ve servis uyarısı', (tester) async {
      useScreen(tester, height: 1000);
      await pumpApp(tester, initialLocation: AppRoutes.forgotPassword);
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);

      await tester.enterText(_field('Email'), 'a@b.co');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();
      expect(_key('auth-status'), findsOneWidget);
    });
  });

  group('profil ve ayarlar', () {
    testWidgets('oturum açık değilken durum ve giriş butonu', (tester) async {
      useScreen(tester);
      await pumpApp(tester, initialLocation: AppRoutes.profile);
      expect(find.text('Not signed in'), findsOneWidget);
      expect(_key('exit-demo'), findsNothing);
    });

    testWidgets('demo oturumu açıkça belirtilir; çıkış girişe döner', (
      tester,
    ) async {
      useScreen(tester);
      final c = await pumpApp(
        tester,
        initialLocation: AppRoutes.profile,
        overrides: [
          sessionProvider.overrideWith(
            () => SessionNotifier(SessionStatus.demo),
          ),
          trToArPreferences,
        ],
      );
      expect(find.text('Demo mode, not signed in'), findsOneWidget);
      expect(find.text('Türkçe'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);

      await tester.tap(_key('exit-demo'));
      await tester.pumpAndSettle();
      expect(c.read(sessionProvider), SessionStatus.signedOut);
      expect(currentPath(c), AppRoutes.login);
    });

    testWidgets(
      'ayarlar açılır: diller, tema, hesap yer tutucuları, hakkında',
      (tester) async {
        useScreen(tester);
        final c = await pumpApp(tester, initialLocation: AppRoutes.profile);
        await tester.tap(_key('open-settings'));
        await tester.pumpAndSettle();
        expect(currentPath(c), AppRoutes.settings);
        expect(find.text('App language'), findsOneWidget);
        expect(find.text('I speak'), findsOneWidget);
        expect(find.text('I want to learn'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);

        // Hesap ayarları devre dışı; entegrasyon bekliyor notu görünür.
        final tile = tester.widget<ListTile>(
          find.widgetWithText(ListTile, 'Edit profile'),
        );
        expect(tile.enabled, isFalse);
        expect(find.textContaining('need a server connection'), findsWidgets);

        await tester.ensureVisible(_key('about-tile'));
        await tester.tap(_key('about-tile'));
        await tester.pumpAndSettle();
        expect(find.byType(AboutDialog), findsOneWidget);
        expect(find.textContaining('demo build'), findsOneWidget);
      },
    );
  });
}
