import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/network/token_store.dart';
import 'package:language_platform/core/utils/bidi.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';
import 'package:language_platform/features/authentication/data/remote_auth_repository.dart';
import 'package:language_platform/features/learning_track/application/track_providers.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

import '../../fakes/five_stage_fakes.dart';
import '../../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

List<Override> _remote(
  FakeFiveStageRepository repo, {
  SessionStatus session = SessionStatus.authenticated,
}) => [
  apiBaseUriProvider.overrideWithValue(Uri.parse('http://localhost:5000')),
  fiveStageRepositoryProvider.overrideWithValue(repo),
  sessionProvider.overrideWith(() => SessionNotifier(session)),
];

String _status(WidgetTester tester, String stage) =>
    tester.widget<Tooltip>(_key('stage-status:$stage')).message!;

void main() {
  const lesson = Json.lessonId;
  final done = List.filled(5, RemoteStageStatus.completed);

  group('catalog from the server', () {
    testWidgets('six levels with real counts; 20 positions per level', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository();
      final c = await pumpApp(
        tester,
        initialLocation: '/track/tr-ar',
        overrides: _remote(repo, session: SessionStatus.signedOut),
      );
      expect(find.textContaining('lessons published'), findsNothing);
      final levels = c.read(levelOverviewsProvider).requireValue;
      expect(levels.first.publishedLessons, 2);
      expect(levels.skip(1).every((l) => l.publishedLessons == 0), isTrue);
      expect(find.text('Demo content'), findsNothing); // real data

      await tester.tap(_key('level-card:a1'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/track/tr-ar/level/a1');
      expect(find.text('Ders 1 başlığı'), findsOneWidget);
      expect(find.text('Ders 2 başlığı'), findsOneWidget);
      expect(find.text('Lesson 3'), findsOneWidget);
      expect(find.text('In preparation'), findsWidgets);
      await tester.scrollUntilVisible(_key('position:20'), 300);
      expect(_key('position:20'), findsOneWidget);
    });

    testWidgets('passed lessons feed the level progress', (tester) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository()..passed = {Json.lessonId};
      final c = await pumpApp(
        tester,
        initialLocation: '/track/tr-ar',
        overrides: _remote(repo),
      );
      final levels = c.read(levelOverviewsProvider).requireValue;
      expect(levels.first.completedLessons, 1);
    });

    testWidgets('server failure shows an error with a working retry', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository()
        ..slotsError = const NetworkUnavailableFailure();
      await pumpApp(
        tester,
        initialLocation: '/track/tr-ar',
        overrides: _remote(repo, session: SessionStatus.signedOut),
      );
      expect(find.textContaining('No internet connection'), findsOneWidget);
      repo.slotsError = null;
      expect(_key('level-card:a1'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(_key('level-card:a1'), findsOneWidget); // recovered
    });

    testWidgets('no published course: honest empty state', (tester) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository()..course = null;
      final c = await pumpApp(
        tester,
        initialLocation: '/track/tr-ar',
        overrides: _remote(repo, session: SessionStatus.signedOut),
      );
      final levels = c.read(levelOverviewsProvider).requireValue;
      expect(levels.length, 6);
      expect(levels.every((l) => l.publishedLessons == 0), isTrue);
    });
  });

  group('lesson overview from the server', () {
    testWidgets('signed out: sign-in prompt, locked cards, no learner calls', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository();
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo, session: SessionStatus.signedOut),
      );
      expect(_key('sign-in-prompt'), findsOneWidget);
      expect(_status(tester, 'reading'), 'Not yet accessible');
      expect(repo.progressCalls, 0);
      expect(find.text('Not started'), findsOneWidget);
    });

    testWidgets('signed in but not started: begin enrolls and starts', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository();
      repo.onStart = () => repo.progress = progressOf();
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo),
      );
      expect(_key('begin-lesson'), findsOneWidget);
      await tester.tap(_key('begin-lesson'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['enroll', 'start']);
      expect(_status(tester, 'reading'), 'Available');
      expect(_status(tester, 'speaking'), 'Not yet accessible');
    });

    testWidgets('server stage states and fractional scores are shown as-is', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository(
        initialProgress: progressOf(
          statuses: [
            RemoteStageStatus.completed,
            RemoteStageStatus.available,
            RemoteStageStatus.locked,
            RemoteStageStatus.locked,
            RemoteStageStatus.locked,
          ],
          scores: [80.5, null, null, null, null],
        ),
      );
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo),
      );
      expect(_status(tester, 'reading'), 'Completed');
      expect(_status(tester, 'speaking'), 'Available');
      expect(
        find.text('${'80.5'.isolateLtr} of ${'100'.isolateLtr}'),
        findsOneWidget,
      );
      expect(find.text('In progress'), findsWidgets);
      expect(find.text('No official score yet'), findsOneWidget);
      expect(find.text('Overall pass mark: 60 out of 100'), findsOneWidget);
    });

    testWidgets('all five done but no server score: never "Passed"', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository(
        initialProgress: progressOf(
          statuses: done,
          scores: [90, 90, 90, 90, 90],
        ),
      );
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo),
      );
      expect(find.text('Awaiting official assessment'), findsOneWidget);
      expect(find.text('Passed'), findsNothing);
    });

    testWidgets('server says passed at exactly 60 and offers the next lesson', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository(
        initialProgress: progressOf(
          statuses: done,
          scores: [60, 60, 60, 60, 60],
          finalScore: 60,
          passed: true,
          next: Json.nextLessonId,
        ),
      );
      final c = await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo),
      );
      expect(find.text('Passed'), findsOneWidget);
      expect(find.text('60/100'.isolateLtr), findsOneWidget);
      // The server published all five weights: no "weights missing" notice.
      expect(
        find.textContaining('weights are set by the server'),
        findsNothing,
      );
      await tester.ensureVisible(_key('next-lesson'));
      await tester.tap(_key('next-lesson'));
      await tester.pumpAndSettle();
      expect(currentPath(c), '/stages/${Json.nextLessonId}');
    });

    testWidgets('server says not passed at 59.5: shown as returned', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository(
        initialProgress: progressOf(
          statuses: done,
          scores: [59.5, 59.5, 59.5, 59.5, 59.5],
          finalScore: 59.5,
          passed: false,
          next: Json.nextLessonId, // ignored unless passed
        ),
      );
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson',
        overrides: _remote(repo),
      );
      expect(find.text('Not passed, try again'), findsOneWidget);
      expect(find.text('59.5/100'.isolateLtr), findsOneWidget);
      expect(_key('next-lesson'), findsNothing);
    });

    testWidgets('a locked stage cannot be opened by URL', (tester) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository(initialProgress: progressOf());
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/listening',
        overrides: _remote(repo),
      );
      expect(find.text('Not yet accessible'), findsOneWidget);
    });
  });

  group('server-graded assessment', () {
    testWidgets('start, answer, submit and show the official result', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository(
        assessmentId: 'assess-1',
        initialProgress: progressOf(),
      );
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      // Published Arabic text keeps its diacritics.
      expect(find.text('مَرْحَبًا'), findsOneWidget);
      expect(_key('media-none'), findsOneWidget); // reading expects media

      await tester.tap(_key('start-assessment'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['enroll', 'start', 'attempt']);

      final submit = find.widgetWithText(FilledButton, 'Submit answers');
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      await tester.tap(_key('option:o1'));
      await tester.pump();
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      await tester.tap(_key('option:true'));
      await tester.pump();
      expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);

      final before = repo.progressCalls;
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(repo.calls.last, 'submit');
      expect(repo.submitted.map((a) => a.questionId), ['q1', 'q2']);
      expect(repo.submitted[0].optionId, 'o1');
      expect(repo.submitted[1].value, isTrue);

      expect(_key('assessment-result'), findsOneWidget);
      expect(find.text('Official result'), findsOneWidget);
      // No per-attempt verdict: the objective result's flag uses a zero
      // threshold; the lesson verdict is only on the lesson page.
      expect(_key('attempt-verdict'), findsNothing);
      expect(_key('attempt-recorded'), findsOneWidget);
      expect(
        find.text('${'1'.isolateLtr} of ${'2'.isolateLtr}'),
        findsOneWidget,
      );
      // Official state changed: progress was reloaded from the server.
      expect(repo.progressCalls, greaterThan(before));
    });

    testWidgets('a full-score attempt still shows no lesson verdict', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo =
          FakeFiveStageRepository(
              assessmentId: 'assess-1',
              initialProgress: progressOf(),
            )
            ..result = const RemoteAssessmentResult(
              attemptId: 'attempt-1',
              score: 2,
              maximumScore: 2,
              percentage: 100,
              passingScore: 60,
              passed: true,
            );
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      await tester.tap(_key('start-assessment'));
      await tester.pumpAndSettle();
      await tester.tap(_key('option:o2'));
      await tester.tap(_key('option:false'));
      await tester.pump();
      await tester.tap(find.text('Submit answers'));
      await tester.pumpAndSettle();
      // Even with passed=true on the attempt, the lesson verdict is not
      // announced here.
      expect(_key('attempt-verdict'), findsNothing);
      expect(
        find.text('${'2'.isolateLtr} of ${'2'.isolateLtr}'),
        findsOneWidget,
      );
      expect(find.text('Passed'), findsNothing);
    });

    testWidgets('stage without an assessment says so', (tester) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository(initialProgress: progressOf());
      await pumpApp(
        tester,
        initialLocation: '/stages/$lesson/reading',
        overrides: _remote(repo),
      );
      expect(_key('start-assessment'), findsNothing);
      expect(find.textContaining('No graded activity'), findsOneWidget);
    });
  });

  group('demo and real stay separate', () {
    testWidgets('explicit demo session ignores the server entirely', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final repo = FakeFiveStageRepository();
      await pumpApp(
        tester,
        initialLocation: '/track/tr-ar',
        overrides: [
          ..._remote(repo, session: SessionStatus.demo),
          trToArPreferences,
        ],
      );
      expect(_key('level-card:a1'), findsOneWidget);
      expect(find.text('Demo content'), findsOneWidget);
      expect(repo.calls, isEmpty);
      expect(repo.progressCalls, 0);
    });

    testWidgets('without a configured backend the app stays in demo mode', (
      tester,
    ) async {
      useScreen(tester, height: 3200);
      final c = await pumpApp(tester, initialLocation: '/track/tr-ar');
      expect(c.read(contentModeProvider), ContentMode.demo);
    });
  });

  group('sign-in and sign-out', () {
    List<Override> authOverrides(
      HandlerApiClient api,
      InMemoryTokenStore tokens, {
      SessionStatus session = SessionStatus.signedOut,
    }) => [
      apiBaseUriProvider.overrideWithValue(Uri.parse('http://localhost:5000')),
      tokenStoreProvider.overrideWithValue(tokens),
      authRepositoryProvider.overrideWithValue(
        RemoteAuthRepository(api, tokens),
      ),
      sessionProvider.overrideWith(() => SessionNotifier(session)),
      fiveStageRepositoryProvider.overrideWithValue(FakeFiveStageRepository()),
    ];

    testWidgets('valid credentials create a real session and continue', (
      tester,
    ) async {
      useScreen(tester, height: 1400);
      final tokens = InMemoryTokenStore();
      final api = HandlerApiClient(
        (_) async => const ApiResponse(200, {
          'tokenType': 'Bearer',
          'accessToken': 'acc',
          'expiresIn': 600,
          'refreshToken': 'ref',
        }),
      );
      final c = await pumpApp(
        tester,
        initialLocation: '/auth/login',
        overrides: authOverrides(api, tokens),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.co',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Secret123!x',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(c.read(sessionProvider), SessionStatus.authenticated);
      expect(tokens.read()?.accessToken, 'acc');
      expect(currentPath(c), '/home');
    });

    testWidgets('rejected credentials: honest message, no session', (
      tester,
    ) async {
      useScreen(tester, height: 1400);
      final tokens = InMemoryTokenStore();
      final api = HandlerApiClient((_) async => const ApiResponse(401));
      final c = await pumpApp(
        tester,
        initialLocation: '/auth/login',
        overrides: authOverrides(api, tokens),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'a@b.co',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'bad-password',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.textContaining('incorrect'), findsOneWidget);
      expect(c.read(sessionProvider), SessionStatus.signedOut);
      expect(tokens.read(), isNull);
      expect(currentPath(c), '/auth/login');
    });

    testWidgets('registration: 202 is acknowledged, 503 is "not connected"', (
      tester,
    ) async {
      useScreen(tester, height: 1600);
      final tokens = InMemoryTokenStore();
      var status = 202;
      final api = HandlerApiClient((_) async => ApiResponse(status));
      await pumpApp(
        tester,
        initialLocation: '/auth/register',
        overrides: authOverrides(api, tokens),
      );
      Future<void> submit() async {
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'),
          'Ayşe',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'a@b.co',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'Secret123!xyz',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm password'),
          'Secret123!xyz',
        );
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Create account'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
        await tester.pumpAndSettle();
      }

      await submit();
      expect(find.textContaining('Registration request sent'), findsOneWidget);

      status = 503;
      await submit();
      expect(find.textContaining('not connected to a server'), findsOneWidget);
      expect(tokens.read(), isNull);
    });

    testWidgets('profile sign-out clears tokens and returns to login', (
      tester,
    ) async {
      useScreen(tester, height: 2400);
      final tokens = InMemoryTokenStore();
      await tokens.save(const TokenPair(accessToken: 'a', refreshToken: 'r'));
      final api = HandlerApiClient((_) async => const ApiResponse(204));
      final c = await pumpApp(
        tester,
        initialLocation: '/profile',
        overrides: authOverrides(
          api,
          tokens,
          session: SessionStatus.authenticated,
        ),
      );
      expect(find.text('Signed in to your account'), findsOneWidget);
      await tester.ensureVisible(_key('sign-out'));
      await tester.tap(_key('sign-out'));
      await tester.pumpAndSettle();
      expect(tokens.read(), isNull);
      expect(c.read(sessionProvider), SessionStatus.signedOut);
      expect(api.requests.single.path, '/api/v1/auth/logout');
      expect(currentPath(c), '/auth/login');
    });
  });
}
