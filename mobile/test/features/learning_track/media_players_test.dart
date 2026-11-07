import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/app/router/app_router.dart';
import 'package:language_platform/features/authentication/application/auth_providers.dart';
import 'package:language_platform/features/learning_track/application/track_providers.dart';
import 'package:language_platform/features/learning_track/domain/media_playback.dart';
import 'package:language_platform/features/learning_track/domain/remote_models.dart';

import '../../fakes/five_stage_fakes.dart';
import '../../helpers/pump_app.dart';

Finder _key(String k) => find.byKey(ValueKey(k));

class _FakePlayback implements AudioPlayback, VideoPlayback {
  _FakePlayback(this.log, {this.failLoads = 0});

  final List<String> log;
  int failLoads;
  final ValueNotifier<PlaybackSnapshot> _v = ValueNotifier(
    const PlaybackSnapshot(),
  );
  Uri? loaded;
  bool disposed = false;

  @override
  ValueListenable<PlaybackSnapshot> get snapshot => _v;

  @override
  double get aspectRatio => 16 / 9;

  @override
  Widget view() => const SizedBox(key: ValueKey('video-surface'));

  @override
  Future<void> load(Uri url) async {
    log.add('load');
    if (url.scheme != 'https') throw ArgumentError('https only');
    if (failLoads > 0) {
      failLoads--;
      _v.value = const PlaybackSnapshot(status: PlaybackStatus.error);
      throw StateError('expired');
    }
    loaded = url;
    _v.value = const PlaybackSnapshot(
      status: PlaybackStatus.ready,
      duration: Duration(seconds: 30),
    );
  }

  @override
  Future<void> play() async {
    log.add('play');
    _v.value = const PlaybackSnapshot(
      status: PlaybackStatus.playing,
      position: Duration(seconds: 3),
      duration: Duration(seconds: 30),
    );
  }

  @override
  Future<void> pause() async {
    log.add('pause');
    _v.value = const PlaybackSnapshot(
      status: PlaybackStatus.paused,
      position: Duration(seconds: 3),
      duration: Duration(seconds: 30),
    );
  }

  @override
  Future<void> stop() async {
    log.add('stop');
    _v.value = const PlaybackSnapshot();
  }

  @override
  Future<void> dispose() async {
    log.add('dispose');
    disposed = true;
  }
}

StageMedia _media({String? video}) => StageMedia(
  audioUrl: Uri.parse('https://cdn.example.com/a.mp3?sig=SECRET'),
  videoUrl: video == null ? null : Uri.parse(video),
  videoTitle: 'Dersin özeti',
);

List<Override> _setup(
  FakeFiveStageRepository repo,
  List<_FakePlayback> players,
  List<String> log, {
  int failLoads = 0,
}) => [
  apiBaseUriProvider.overrideWithValue(Uri.parse('http://localhost:5000')),
  fiveStageRepositoryProvider.overrideWithValue(repo),
  sessionProvider.overrideWith(
    () => SessionNotifier(SessionStatus.authenticated),
  ),
  audioPlaybackFactoryProvider.overrideWithValue(() {
    final p = _FakePlayback(log, failLoads: failLoads);
    players.add(p);
    return p;
  }),
  videoPlaybackFactoryProvider.overrideWithValue(() {
    final p = _FakePlayback(log);
    players.add(p);
    return p;
  }),
];

FakeFiveStageRepository _repo() => FakeFiveStageRepository(
  initialProgress: progressOf(
    statuses: List.filled(5, RemoteStageStatus.available),
  ),
)..reading = const ReadingMaterial(lines: [], hasOriginalPdf: false);

void main() {
  const lesson = Json.lessonId;

  testWidgets('no media: no player and no fake play control', (tester) async {
    useScreen(tester);
    final players = <_FakePlayback>[];
    await pumpApp(
      tester,
      initialLocation: '/stages/$lesson/listening',
      overrides: _setup(_repo(), players, []),
    );
    expect(_key('audio-player'), findsNothing);
    expect(_key('video-player'), findsNothing);
    expect(_key('media-none'), findsOneWidget);
    expect(players, isEmpty); // not even a platform player was created
  });

  testWidgets('blocked / unconfigured media (status != available) is hidden', (
    tester,
  ) async {
    useScreen(tester);
    final players = <_FakePlayback>[];
    final repo = _repo()..media = const StageMedia(status: 'unconfigured');
    await pumpApp(
      tester,
      initialLocation: '/stages/$lesson/listening',
      overrides: _setup(repo, players, []),
    );
    expect(_key('audio-player'), findsNothing);
    expect(players, isEmpty);
  });

  testWidgets('audio: nothing loads until Play; play/pause/stop work', (
    tester,
  ) async {
    useScreen(tester);
    final log = <String>[];
    final players = <_FakePlayback>[];
    final repo = _repo()..media = _media();
    await pumpApp(
      tester,
      initialLocation: '/stages/$lesson/listening',
      overrides: _setup(repo, players, log),
    );
    expect(_key('audio-player'), findsOneWidget);
    expect(log, isEmpty, reason: 'no network before the learner presses play');
    expect(find.textContaining('sig='), findsNothing); // URL never shown
    expect(find.textContaining('cdn.example.com'), findsNothing);

    await tester.tap(_key('audio-play'));
    await tester.pumpAndSettle();
    expect(log, ['load', 'play']);
    expect(players.single.loaded?.scheme, 'https');

    await tester.tap(_key('audio-play')); // now it pauses
    await tester.pumpAndSettle();
    expect(log.last, 'pause');
    await tester.tap(_key('audio-play')); // resume without reloading
    await tester.pumpAndSettle();
    expect(log.where((e) => e == 'load'), hasLength(1));
    await tester.tap(_key('audio-stop'));
    await tester.pumpAndSettle();
    expect(log.last, 'stop');
  });

  testWidgets('leaving the screen releases the platform player', (
    tester,
  ) async {
    useScreen(tester);
    final log = <String>[];
    final players = <_FakePlayback>[];
    final repo = _repo()..media = _media();
    final c = await pumpApp(
      tester,
      initialLocation: '/stages/$lesson/listening',
      overrides: _setup(repo, players, log),
    );
    await tester.tap(_key('audio-play'));
    await tester.pumpAndSettle();
    c.read(routerProvider).go('/home');
    await tester.pumpAndSettle();
    expect(players.single.disposed, isTrue);
  });

  testWidgets('going to the background pauses playback', (tester) async {
    useScreen(tester);
    final log = <String>[];
    final players = <_FakePlayback>[];
    final repo = _repo()..media = _media();
    await pumpApp(
      tester,
      initialLocation: '/stages/$lesson/listening',
      overrides: _setup(repo, players, log),
    );
    await tester.tap(_key('audio-play'));
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(log.last, 'pause');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('expired link: generic message, retry re-reads the metadata', (
    tester,
  ) async {
    useScreen(tester);
    final log = <String>[];
    final players = <_FakePlayback>[];
    final repo = _repo()..media = _media();
    var metadataReads = 0;
    final counting = _CountingRepo(repo, () => metadataReads++);
    await pumpApp(
      tester,
      initialLocation: '/stages/$lesson/listening',
      overrides: [..._setup(counting, players, log, failLoads: 1)],
    );
    final before = metadataReads;
    await tester.tap(_key('audio-play'));
    await tester.pumpAndSettle();
    expect(_key('audio-error'), findsOneWidget);
    expect(find.textContaining('may have expired'), findsOneWidget);
    expect(find.textContaining('cdn.example.com'), findsNothing);
    expect(find.textContaining('StateError'), findsNothing); // no raw error

    await tester.tap(_key('audio-retry'));
    await tester.pumpAndSettle();
    expect(metadataReads, greaterThan(before)); // fresh link requested
    expect(log, containsAllInOrder(['load', 'load', 'play']));
    expect(_key('audio-error'), findsNothing);
  });

  testWidgets('teacher video: lazy, shows the surface only after load', (
    tester,
  ) async {
    useScreen(tester);
    final log = <String>[];
    final players = <_FakePlayback>[];
    final repo = _repo()
      ..media = StageMedia(
        videoUrl: Uri.parse('https://cdn.example.com/v.mp4'),
        videoTitle: 'Dersin özeti',
      );
    await pumpApp(
      tester,
      initialLocation: '/stages/$lesson/reading',
      overrides: _setup(repo, players, log),
    );
    expect(find.text('Teacher video: Dersin özeti'), findsOneWidget);
    expect(_key('video-surface'), findsNothing);
    expect(log, isEmpty);
    await tester.tap(_key('video-play'));
    await tester.pumpAndSettle();
    expect(_key('video-surface'), findsOneWidget);
    expect(log, ['load', 'play']);
  });

  test('AudioPlayback implementations are HTTPS only', () async {
    final p = _FakePlayback([]);
    await expectLater(
      p.load(Uri.parse('http://insecure.example.com/a.mp3')),
      throwsArgumentError,
    );
  });
}

/// Counts how often the stage media metadata is (re-)read.
class _CountingRepo extends FakeFiveStageRepository {
  _CountingRepo(FakeFiveStageRepository base, this._onRead)
    : super(initialProgress: base.progress) {
    media = base.media;
    reading = base.reading;
    stageAssessments = base.stageAssessments;
  }

  final VoidCallback _onRead;

  @override
  Future<StageMedia?> getStageMedia(
    String courseId,
    String lessonId,
    String stageId,
  ) {
    _onRead();
    return super.getStageMedia(courseId, lessonId, stageId);
  }
}
