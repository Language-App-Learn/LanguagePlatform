import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../application/track_providers.dart';
import '../../domain/media_playback.dart';

String _clock(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
}

/// Shared transport controls for one [MediaPlayback].
class _Controls extends StatelessWidget {
  const _Controls({
    required this.keyPrefix,
    required this.playback,
    required this.onToggle,
    required this.onStop,
  });

  final String keyPrefix;
  final MediaPlayback playback;
  final VoidCallback onToggle;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueListenableBuilder<PlaybackSnapshot>(
      valueListenable: playback.snapshot,
      builder: (context, s, _) {
        final busy = s.status == PlaybackStatus.loading;
        final total = s.duration;
        final ratio = total == null || total.inMilliseconds == 0
            ? null
            : (s.position.inMilliseconds / total.inMilliseconds).clamp(
                0.0,
                1.0,
              );
        // Indeterminate only while really loading (an idle player must not
        // animate forever).
        final progress = busy ? null : (ratio ?? 0.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton.filled(
                  key: ValueKey('$keyPrefix-play'),
                  tooltip: s.isPlaying ? l10n.mediaPause : l10n.mediaPlay,
                  onPressed: busy ? null : onToggle,
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(s.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  key: ValueKey('$keyPrefix-stop'),
                  tooltip: l10n.mediaStop,
                  onPressed: s.status == PlaybackStatus.idle ? null : onStop,
                  icon: const Icon(Icons.stop),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ExcludeSemantics(
                    child: LinearProgressIndicator(value: progress),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${_clock(s.position)}${total == null ? '' : ' / ${_clock(total)}'}'
                      .isolateLtr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Mixin with the lifecycle behaviour both players share: pause when the app
/// leaves the foreground, release the platform player on dispose.
mixin _PlayerLifecycle<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, WidgetsBindingObserver {
  MediaPlayback get playback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) playback.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    playback.dispose();
    super.dispose();
  }
}

/// Listening audio of a stage. Nothing is downloaded until the learner
/// presses play. On a failure (expired link, offline) a retry first re-reads
/// the media metadata so a fresh link is used.
class StageAudioPlayer extends ConsumerStatefulWidget {
  const StageAudioPlayer({
    super.key,
    required this.url,
    required this.onRefreshLink,
  });

  final Uri url;

  /// Re-reads the media metadata (a new link may be issued).
  final VoidCallback onRefreshLink;

  @override
  ConsumerState<StageAudioPlayer> createState() => _StageAudioPlayerState();
}

class _StageAudioPlayerState extends ConsumerState<StageAudioPlayer>
    with WidgetsBindingObserver, _PlayerLifecycle<StageAudioPlayer> {
  late final AudioPlayback _playback = ref.read(audioPlaybackFactoryProvider)();
  bool _loaded = false;
  bool _failed = false;

  @override
  MediaPlayback get playback => _playback;

  @override
  void didUpdateWidget(StageAudioPlayer old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _loaded = false; // a refreshed link
  }

  Future<void> _toggle() async {
    if (_playback.snapshot.value.isPlaying) {
      await _playback.pause();
      return;
    }
    if (!_loaded) {
      try {
        setState(() => _failed = false);
        await _playback.load(widget.url);
        _loaded = true;
      } on Object {
        if (mounted) setState(() => _failed = true);
        return;
      }
    }
    await _playback.play();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      key: const ValueKey('audio-player'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones_outlined),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.mediaListeningAudio),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _Controls(
            keyPrefix: 'audio',
            playback: _playback,
            onToggle: _toggle,
            onStop: () => _playback.stop(),
          ),
          if (_failed) ...[
            const SizedBox(height: AppSpacing.sm),
            NoticeBanner(
              key: const ValueKey('audio-error'),
              message: l10n.mediaPlaybackFailed,
            ),
            TextButton(
              key: const ValueKey('audio-retry'),
              onPressed: () {
                widget.onRefreshLink();
                _loaded = false;
                _toggle();
              },
              child: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}

/// Teacher explanation video of a stage (same rules as the audio player).
class TeacherVideoPlayer extends ConsumerStatefulWidget {
  const TeacherVideoPlayer({
    super.key,
    required this.url,
    required this.title,
    required this.onRefreshLink,
  });

  final Uri url;
  final String title;
  final VoidCallback onRefreshLink;

  @override
  ConsumerState<TeacherVideoPlayer> createState() => _TeacherVideoPlayerState();
}

class _TeacherVideoPlayerState extends ConsumerState<TeacherVideoPlayer>
    with WidgetsBindingObserver, _PlayerLifecycle<TeacherVideoPlayer> {
  late final VideoPlayback _playback = ref.read(videoPlaybackFactoryProvider)();
  bool _loaded = false;
  bool _failed = false;

  @override
  MediaPlayback get playback => _playback;

  @override
  void didUpdateWidget(TeacherVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _loaded = false;
  }

  Future<void> _toggle() async {
    if (_playback.snapshot.value.isPlaying) {
      await _playback.pause();
      return;
    }
    if (!_loaded) {
      try {
        setState(() => _failed = false);
        await _playback.load(widget.url);
        _loaded = true;
      } on Object {
        if (mounted) setState(() => _failed = true);
        return;
      }
      if (mounted) setState(() {});
    }
    await _playback.play();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      key: const ValueKey('video-player'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam_outlined),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(l10n.mediaVideoAvailable(widget.title))),
            ],
          ),
          if (_loaded) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: _playback.aspectRatio,
                child: _playback.view(),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _Controls(
            keyPrefix: 'video',
            playback: _playback,
            onToggle: _toggle,
            onStop: () => _playback.stop(),
          ),
          if (_failed) ...[
            const SizedBox(height: AppSpacing.sm),
            NoticeBanner(
              key: const ValueKey('video-error'),
              message: l10n.mediaPlaybackFailed,
            ),
            TextButton(
              key: const ValueKey('video-retry'),
              onPressed: () {
                widget.onRefreshLink();
                _loaded = false;
                _toggle();
              },
              child: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}
