import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/track_providers.dart';
import '../../domain/remote_models.dart';
import 'media_players.dart';

/// Audio / teacher video the server published for a stage.
///
/// A player is shown ONLY when the server reports `available` media with a
/// valid HTTPS link; otherwise nothing playable is rendered (no fake play
/// control). Nothing is downloaded until the learner presses play, links are
/// never displayed or logged, and a failed playback re-reads the metadata so
/// an expired link can be replaced.
class StageMediaPanel extends ConsumerWidget {
  const StageMediaPanel({
    super.key,
    required this.lessonId,
    required this.stageId,
    required this.expectsMedia,
  });

  final String lessonId;
  final String stageId;

  /// Reading and listening stages are expected to carry media; for the others
  /// an empty result simply renders nothing.
  final bool expectsMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = stageMediaProvider((lessonId: lessonId, stageId: stageId));
    final media = ref.watch(provider);
    final StageMedia? data = media.value;
    if (media.isLoading && data == null) return const SizedBox.shrink();
    if (data == null || data.isEmpty) {
      return expectsMedia
          ? NoticeBanner(
              key: const ValueKey('media-none'),
              message: l10n.mediaNone,
            )
          : const SizedBox.shrink();
    }
    void refresh() => ref.invalidate(provider);
    return Column(
      key: const ValueKey('media-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.audioUrl != null)
          StageAudioPlayer(url: data.audioUrl!, onRefreshLink: refresh),
        if (data.audioUrl != null && data.videoUrl != null)
          const SizedBox(height: AppSpacing.md),
        if (data.videoUrl != null)
          TeacherVideoPlayer(
            url: data.videoUrl!,
            title: data.videoTitle ?? '',
            onRefreshLink: refresh,
          ),
      ],
    );
  }
}
