import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/track_providers.dart';
import '../../domain/remote_models.dart';

/// What audio / teacher video the server published for a stage. This is an
/// honest availability panel, NOT a player: there is no fake play control.
/// Playback needs an audio/video component that is pending dependency
/// approval; media URLs are never displayed or logged.
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
    final media = ref.watch(
      stageMediaProvider((lessonId: lessonId, stageId: stageId)),
    );
    final StageMedia? data = media.value;
    if (media.isLoading) return const SizedBox.shrink();
    if (data == null || data.isEmpty) {
      return expectsMedia
          ? NoticeBanner(
              key: const ValueKey('media-none'),
              message: l10n.mediaNone,
            )
          : const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return AppCard(
      key: const ValueKey('media-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.hasAudio)
            _Row(
              icon: Icons.headphones_outlined,
              text: l10n.mediaAudioAvailable,
            ),
          if (data.hasVideo)
            _Row(
              icon: Icons.videocam_outlined,
              text: l10n.mediaVideoAvailable(data.videoTitle ?? ''),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.mediaPlaybackUnavailable,
            key: const ValueKey('media-playback-unavailable'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
