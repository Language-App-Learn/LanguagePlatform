import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/errors/app_failure.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';
import 'package:language_platform/features/courses/presentation/widgets/course_card.dart';
import 'package:language_platform/features/learning_track/application/track_providers.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

import '../fakes/five_stage_fakes.dart';
import '../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

List<Override> _remote(FakeFiveStageRepository repo) => [
  apiBaseUriProvider.overrideWithValue(Uri.parse('http://localhost:5000')),
  fiveStageRepositoryProvider.overrideWithValue(repo),
  sessionProvider.overrideWith(
    () => SessionNotifier(SessionStatus.authenticated),
  ),
];

void main() {
  group('Courses tab with a real account', () {
    testWidgets('shows the server course only; no demo catalog', (
      tester,
    ) async {
      useScreen(tester);
      final repo = FakeFiveStageRepository(
        course: const RemoteCourse(id: Json.courseId, title: 'Modern Arapça'),
      );
      await pumpApp(
        tester,
        initialLocation: '/courses',
        overrides: _remote(repo),
      );
      expect(find.text('Modern Arapça'), findsOneWidget);
      expect(find.byType(CourseCard), findsNothing); // no demo course cards
      // The only entry leads to the Turkish -> Arabic track.
      await tester.tap(_key('remote-course-card'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 20 lessons published'), findsOneWidget);
    });

    testWidgets('a changed server title is shown after a refresh', (
      tester,
    ) async {
      useScreen(tester);
      final repo = FakeFiveStageRepository(
        course: const RemoteCourse(id: Json.courseId, title: 'Eski ad'),
      );
      final c = await pumpApp(
        tester,
        initialLocation: '/courses',
        overrides: _remote(repo),
      );
      expect(find.text('Eski ad'), findsOneWidget);
      repo.course = const RemoteCourse(id: Json.courseId, title: 'Yeni ad');
      c.invalidate(remoteCourseProvider);
      await tester.pumpAndSettle();
      expect(find.text('Yeni ad'), findsOneWidget);
      expect(find.text('Eski ad'), findsNothing);
    });

    testWidgets('nothing published: an honest empty state', (tester) async {
      useScreen(tester);
      final repo = FakeFiveStageRepository()..course = null;
      await pumpApp(
        tester,
        initialLocation: '/courses',
        overrides: _remote(repo),
      );
      expect(
        find.text('No Turkish-to-Arabic course is published yet.'),
        findsOneWidget,
      );
      expect(_key('remote-course-card'), findsNothing);
    });

    testWidgets('server failure: error state and a working retry', (
      tester,
    ) async {
      useScreen(tester);
      var fail = true;
      final repo = _FlakyCatalog(() => fail);
      await pumpApp(
        tester,
        initialLocation: '/courses',
        overrides: _remote(repo),
      );
      expect(find.textContaining('No internet connection'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(_key('remote-course-card'), findsOneWidget);
    });
  });

  group('Home and local-data screens with a real account', () {
    testWidgets('Home keeps the track entry and hides demo summaries', (
      tester,
    ) async {
      useScreen(tester);
      await pumpApp(
        tester,
        initialLocation: '/home',
        overrides: _remote(FakeFiveStageRepository()),
      );
      expect(_key('track-card'), findsOneWidget);
      expect(_key('home-remote-notice'), findsOneWidget);
      expect(find.byType(CourseCard), findsNothing);
      expect(find.textContaining('Demo content'), findsNothing);
    });

    testWidgets('Vocabulary and Progress say their data is local only', (
      tester,
    ) async {
      useScreen(tester);
      await pumpApp(
        tester,
        initialLocation: '/vocabulary',
        overrides: _remote(FakeFiveStageRepository()),
      );
      expect(_key('local-practice-notice'), findsOneWidget);
    });

    testWidgets('Progress also carries the local-practice notice', (
      tester,
    ) async {
      useScreen(tester);
      await pumpApp(
        tester,
        initialLocation: '/progress',
        overrides: _remote(FakeFiveStageRepository()),
      );
      expect(_key('local-practice-notice'), findsOneWidget);
    });

    testWidgets('demo mode is unchanged: full Home, no notices', (
      tester,
    ) async {
      useScreen(tester);
      await pumpApp(tester, initialLocation: '/home');
      expect(_key('home-remote-notice'), findsNothing);
      await tester.scrollUntilVisible(
        find.byType(CourseCard).first,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(CourseCard), findsWidgets);
    });
  });
}

class _FlakyCatalog extends FakeFiveStageRepository {
  _FlakyCatalog(this._fail);

  final bool Function() _fail;

  @override
  Future<RemoteCourse?> findTrackCourse({String? locale}) async {
    if (_fail()) throw const NetworkUnavailableFailure();
    return super.findTrackCourse(locale: locale);
  }
}
