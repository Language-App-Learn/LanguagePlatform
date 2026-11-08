import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../domain/lesson_outcome.dart';
import '../widgets/lesson_mode_grid.dart';
import '../widgets/stage_widgets.dart';
import 'remote_lesson_pages.dart';

/// Screen 7: the lesson menu (Okuma, Dinleme, Tercüme, Yazma, Konuşma, Test).
///
/// Without a [lessonId] no lesson has been selected (the owner has not defined
/// lesson selection yet), so all six cards are safely unavailable: no content
/// is read, invented or opened. With a [lessonId] it shows the REAL server
/// lesson: stage states, scores and unlocking come only from the server.
class LessonMenuPage extends StatelessWidget {
  const LessonMenuPage({super.key, this.lessonId});

  final String? lessonId;

  @override
  Widget build(BuildContext context) {
    final id = lessonId;
    if (id != null) return RemoteLessonOverviewPage(lessonId: id);
    return LessonMenuFrame(
      child: ListView(
        padding: lessonMenuPadding,
        children: const [LessonMenuIntro(), UnavailableLessonMenuGrid()],
      ),
    );
  }
}

/// Server-side overall result of a lesson. The result is shown only when the
/// backend provides it; a local average is never presented as pass/fail.
class OverallPanel extends StatelessWidget {
  const OverallPanel({
    super.key,
    required this.outcome,
    required this.server,
    required this.l10n,
  });

  final LessonOutcomeStatus outcome;
  final ServerLessonResult? server;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      key: const ValueKey('overall-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.outcomeName(outcome),
            key: const ValueKey('overall-status'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            server == null
                ? l10n.overallScoreNone
                : '${formatScore(server!.finalScore)}/100'.isolateLtr,
            key: const ValueKey('overall-score'),
            style: theme.textTheme.titleMedium,
          ),
          Text(
            l10n.passMarkInfo(overallPassMark),
            style: theme.textTheme.bodyMedium,
          ),
          if (server?.weights == null) ...[
            const SizedBox(height: AppSpacing.md),
            NoticeBanner(message: l10n.scoringPolicyMissing),
          ],
        ],
      ),
    );
  }
}
