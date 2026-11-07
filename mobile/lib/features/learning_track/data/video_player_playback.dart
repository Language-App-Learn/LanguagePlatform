import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import '../domain/media_playback.dart';

/// [VideoPlayback] over the official `video_player` plugin. HTTPS only; no
/// auth headers are ever attached (the teacher video URL is a plain media
/// link, and the app's bearer token must never be sent to a media host).
class VideoPlayerPlayback implements VideoPlayback {
  VideoPlayerPlayback([VideoPlayerController Function(Uri url)? controllerFor])
    : _controllerFor =
          controllerFor ?? ((url) => VideoPlayerController.networkUrl(url));

  final VideoPlayerController Function(Uri url) _controllerFor;
  VideoPlayerController? _controller;
  final ValueNotifier<PlaybackSnapshot> _value = ValueNotifier(
    const PlaybackSnapshot(),
  );
  bool _disposed = false;

  @override
  ValueListenable<PlaybackSnapshot> get snapshot => _value;

  @override
  double get aspectRatio {
    final r = _controller?.value.aspectRatio ?? 16 / 9;
    return r > 0 ? r : 16 / 9;
  }

  void _sync() {
    final c = _controller;
    if (c == null || _disposed) return;
    final v = c.value;
    final status = v.hasError
        ? PlaybackStatus.error
        : v.isCompleted
        ? PlaybackStatus.completed
        : v.isBuffering && !v.isPlaying
        ? PlaybackStatus.loading
        : v.isPlaying
        ? PlaybackStatus.playing
        : v.isInitialized
        ? PlaybackStatus.paused
        : PlaybackStatus.loading;
    _value.value = PlaybackSnapshot(
      status: status,
      position: v.position,
      duration: v.isInitialized ? v.duration : null,
    );
  }

  @override
  Future<void> load(Uri url) async {
    if (url.scheme != 'https') {
      _value.value = const PlaybackSnapshot(status: PlaybackStatus.error);
      throw ArgumentError('Only https media is played.');
    }
    _value.value = const PlaybackSnapshot(status: PlaybackStatus.loading);
    final old = _controller;
    _controller = null;
    old?.removeListener(_sync);
    await old?.dispose();
    final controller = _controllerFor(url);
    _controller = controller;
    controller.addListener(_sync);
    try {
      await controller.initialize();
      _sync();
    } on Object {
      _value.value = const PlaybackSnapshot(status: PlaybackStatus.error);
      rethrow; // callers show a generic, URL-free message
    }
  }

  @override
  Widget view() {
    final c = _controller;
    return c == null ? const SizedBox.shrink() : VideoPlayer(c);
  }

  @override
  Future<void> play() async => _controller?.play();

  @override
  Future<void> pause() async => _controller?.pause();

  @override
  Future<void> stop() async {
    await _controller?.pause();
    await _controller?.seekTo(Duration.zero);
    _sync();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final c = _controller;
    _controller = null;
    c?.removeListener(_sync);
    await c?.dispose();
    _value.dispose();
  }
}
