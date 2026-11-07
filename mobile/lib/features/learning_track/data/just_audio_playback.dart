import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/media_playback.dart';

/// [AudioPlayback] over `just_audio` (ExoPlayer on Android, AVPlayer on iOS).
/// HTTPS only; foreground playback only (no background audio service).
class JustAudioPlayback implements AudioPlayback {
  JustAudioPlayback([AudioPlayer? player]) : _player = player ?? AudioPlayer() {
    _subs.addAll([
      _player.playerStateStream.listen(_onState, onError: (_) => _fail()),
      _player.positionStream.listen((p) {
        final s = _value.value;
        _value.value = PlaybackSnapshot(
          status: s.status,
          position: p,
          duration: s.duration,
        );
      }),
      _player.durationStream.listen((d) {
        final s = _value.value;
        _value.value = PlaybackSnapshot(
          status: s.status,
          position: s.position,
          duration: d,
        );
      }),
    ]);
  }

  final AudioPlayer _player;
  final List<StreamSubscription<Object?>> _subs = [];
  final ValueNotifier<PlaybackSnapshot> _value = ValueNotifier(
    const PlaybackSnapshot(),
  );
  bool _disposed = false;

  @override
  ValueListenable<PlaybackSnapshot> get snapshot => _value;

  void _set(PlaybackStatus status) {
    if (_disposed) return;
    final s = _value.value;
    _value.value = PlaybackSnapshot(
      status: status,
      position: s.position,
      duration: s.duration,
    );
  }

  void _fail() => _set(PlaybackStatus.error);

  void _onState(PlayerState state) {
    if (_value.value.status == PlaybackStatus.error) return;
    switch (state.processingState) {
      case ProcessingState.loading || ProcessingState.buffering:
        _set(PlaybackStatus.loading);
      case ProcessingState.completed:
        _set(PlaybackStatus.completed);
      case ProcessingState.ready:
        _set(state.playing ? PlaybackStatus.playing : PlaybackStatus.paused);
      case ProcessingState.idle:
        break;
    }
  }

  @override
  Future<void> load(Uri url) async {
    if (url.scheme != 'https') {
      _fail();
      throw ArgumentError('Only https media is played.');
    }
    _set(PlaybackStatus.loading);
    try {
      await _player.setUrl(url.toString());
      _set(PlaybackStatus.ready);
    } on Object {
      _fail();
      rethrow; // callers show a generic, URL-free message
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    _set(PlaybackStatus.idle);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final s in _subs) {
      await s.cancel();
    }
    await _player.dispose();
    _value.dispose();
  }
}
