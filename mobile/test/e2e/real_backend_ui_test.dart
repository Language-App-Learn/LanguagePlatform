// REAL END-TO-END through the app UI: the real widgets, providers, secure
// token handling and HTTP transport against the local API + disposable
// PostgreSQL. Skipped unless `E2E_DIR` is set (see real_backend_journey_test).
// Run AFTER the journey test, which leaves student A with a passed lesson 1.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/core/utils/bidi.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';

import '../helpers/pump_app.dart';

final String? _dir = Platform.environment['E2E_DIR'];

Finder _key(String k) => find.byKey(ValueKey(k));

Future<void> _waitFor(WidgetTester t, Finder f, {int tries = 80}) async {
  for (var i = 0; i < tries; i++) {
    if (f.evaluate().isNotEmpty) return;
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await t.pump(const Duration(milliseconds: 50));
  }
  fail('timed out waiting for $f');
}

Map<String, dynamic> _acc(String who) =>
    (jsonDecode(File('$_dir/accounts.json').readAsStringSync())
            as Map<String, dynamic>)[who]
        as Map<String, dynamic>;

List<Override> _real(InMemoryTokenStore tokens) => [
  apiBaseUriProvider.overrideWithValue(Uri.parse('http://127.0.0.1:5199')),
  tokenStoreProvider.overrideWithValue(tokens),
];

Future<void> _login(WidgetTester t, String who) async {
  final a = _acc(who);
  await t.enterText(
    find.widgetWithText(TextFormField, 'Email'),
    a['email'] as String,
  );
  await t.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    a['password'] as String,
  );
  await t.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await _waitFor(t, _key('track-card'));
}

void main() {
  if (_dir == null) {
    test('real backend UI journey', () {}, skip: 'Set E2E_DIR to run.');
    return;
  }

  setUp(() => HttpOverrides.global = null); // real sockets, not the test stub

  testWidgets('student A: login, track, A1 positions, passed lesson, stages', (
    tester,
  ) async {
    useScreen(tester, height: 3600);
    final tokens = InMemoryTokenStore();
    await pumpApp(
      tester,
      initialLocation: '/auth/login',
      overrides: _real(tokens),
    );
    await _login(tester, 'student');
    expect(tokens.read(), isNotNull); // a real session

    // Home (real account): track entry, no demo sections.
    expect(_key('home-remote-notice'), findsOneWidget);

    // Track -> six level cards with the server's counts.
    await tester.tap(_key('track-card'));
    await _waitFor(tester, _key('level-card:a1'));
    expect(find.text('2 of 20 lessons published'), findsOneWidget);
    expect(find.text('1 completed'), findsOneWidget); // server-passed lesson
    expect(find.text('No lessons published yet'), findsNWidgets(5));
    expect(find.text('Demo content'), findsNothing);

    // A1 -> twenty positions, server titles, preserved empty slots.
    await tester.tap(_key('level-card:a1'));
    await _waitFor(tester, _key('position:1'));
    expect(find.text('Tanışma ve selamlaşma (sentetik)'), findsOneWidget);
    expect(find.text('Eşyalar (sentetik, ikinci ders)'), findsOneWidget);
    await tester.scrollUntilVisible(_key('position:20'), 400);
    expect(_key('position:20'), findsOneWidget);
    await tester.scrollUntilVisible(_key('position:1'), -400);

    // Lesson 1: the official result is the server's.
    await tester.tap(_key('position:1'));
    await _waitFor(tester, _key('stage-status:reading'));
    await _waitFor(tester, find.text('Passed'));
    expect(find.text('60/100'.isolateLtr), findsOneWidget);
    expect(_status(tester, 'reading'), 'Completed');
    expect(_status(tester, 'translation'), 'Completed');
    await tester.ensureVisible(_key('next-lesson'));
    expect(_key('next-lesson'), findsOneWidget);

    // Reading stage: approved Arabic lines with diacritics, PDF offered.
    await tester.tap(_key('stage-card:reading'));
    await _waitFor(tester, _key('reading-lines'));
    expect(find.text('مَرْحَبًا، أَنَا طَالِبٌ.'), findsOneWidget);
    expect(find.text('هَذَا كِتَابٌ.'), findsOneWidget);
    expect(_key('pdf-download'), findsOneWidget);
    // Media metadata: the example host is not an approved media host in a
    // real deployment; whichever status the server returned, no URL is shown.
    expect(find.textContaining('media.example.test'), findsNothing);
    await _drain(tester);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('student B sees none of A\'s results (fresh account)', (
    tester,
  ) async {
    useScreen(tester, height: 3600);
    final tokens = InMemoryTokenStore();
    await pumpApp(
      tester,
      initialLocation: '/auth/login',
      overrides: _real(tokens),
    );
    await _login(tester, 'student2');
    await tester.tap(_key('track-card'));
    await _waitFor(tester, _key('level-card:a1'));
    expect(find.text('0 completed'), findsWidgets);
    expect(find.text('1 completed'), findsNothing);
    await tester.tap(_key('level-card:a1'));
    await _waitFor(tester, _key('position:1'));
    await tester.tap(_key('position:1'));
    await _waitFor(tester, _key('begin-lesson'));
    expect(find.text('Passed'), findsNothing);
    expect(find.text('60/100'.isolateLtr), findsNothing);
    await _drain(tester);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('a wrong password is explained and creates no session', (
    tester,
  ) async {
    useScreen(tester, height: 2000);
    final tokens = InMemoryTokenStore();
    final c = await pumpApp(
      tester,
      initialLocation: '/auth/login',
      overrides: _real(tokens),
    );
    final a = _acc('student');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      a['email'] as String,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'Wrong-Password-1!',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await _waitFor(tester, _key('auth-status'));
    expect(find.textContaining('incorrect'), findsOneWidget);
    expect(tokens.read(), isNull);
    expect(c.read(sessionProvider), SessionStatus.signedOut);
    await _drain(tester);
  }, timeout: const Timeout(Duration(minutes: 2)));
}

String _status(WidgetTester tester, String stage) =>
    tester.widget<Text>(_key('stage-status:$stage')).data!;

/// Unmounts the app and advances the fake clock so request-timeout timers
/// created by the real transport do not outlive the test.
Future<void> _drain(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pump(const Duration(seconds: 90));
}
