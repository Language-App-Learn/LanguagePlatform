import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum PlaybackStatus { idle, loading, ready, playing, paused, completed, error }

@immutable
class PlaybackSnapshot {
  const PlaybackSnapshot({
    this.status = PlaybackStatus.idle,
    this.position = Duration.zero,
    this.duration,
  });

  final PlaybackStatus status;
  final Duration position;
  final Duration? duration;

  bool get isPlaying => status == PlaybackStatus.playing;
}

/// Playback of ONE remote media file. Implementations accept `https` URLs
/// only and never log or expose the URL. They must release the platform
/// player in [dispose].
abstract interface class MediaPlayback {
  ValueListenable<PlaybackSnapshot> get snapshot;

  /// Opens [url] (network access happens here, not before). Throws when the
  /// link is not HTTPS, expired, or unreachable; the snapshot then reports
  /// [PlaybackStatus.error].
  Future<void> load(Uri url);

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}

abstract interface class AudioPlayback implements MediaPlayback {}

abstract interface class VideoPlayback implements MediaPlayback {
  /// The video surface (valid after a successful [load]).
  Widget view();

  double get aspectRatio;
}
