import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../learning_track/application/track_providers.dart';
import '../../../learning_track/domain/learning_track.dart';
import '../../../learning_track/domain/remote_models.dart';

/// Courses tab for a REAL account: the published Turkish -> Arabic course
/// from the server, nothing else. The generic demo catalog (other languages,
/// demo ids, local answer keys) is never shown here, so first-release
/// students cannot be offered an unsupported learning direction.
///
/// Pull to refresh re-reads the catalog; loading, error (with retry) and the
/// "nothing published" state are all explicit.
class RemoteCatalogView extends ConsumerWidget {
  const RemoteCatalogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final course = ref.watch(remoteCourseProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(remoteCourseProvider);
        await ref.read(remoteCourseProvider.future).catchError((_) => null);
      },
      child: AsyncValueView<RemoteCourse?>(
        value: course,
        onRetry: () => reloadTrackCatalog(ref),
        isEmpty: (c) => c == null,
        emptyBuilder: (context) => EmptyStateView(
          icon: Icons.hourglass_empty,
          title: l10n.remoteNoCourse,
        ),
        data: (c) => ListView(
          padding: AppSpacing.page,
          children: [
            AppCard(
              key: const ValueKey('remote-course-card'),
              onTap: () => context.push(
                AppRoutes.trackOf(LearningTracks.turkishToArabic.id),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The server's current title (it may change).
                        Text(
                          c!.title.isEmpty ? l10n.trackTitle : c.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          l10n.trackSubtitle,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
