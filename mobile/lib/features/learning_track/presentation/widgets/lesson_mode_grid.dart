import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/brand_illustrations.dart';
import '../../../../core/design_system/widgets/brand_list_card.dart';
import '../../../../core/design_system/widgets/brand_screen_header.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../domain/lesson_outcome.dart';
import '../../domain/lesson_stage.dart';
import 'stage_widgets.dart';

/// Screen 7 frame: waves and the logo header; the body is the list of the
/// lesson menu (see [LessonMenuIntro] and [LessonModeGrid]).
class LessonMenuFrame extends StatelessWidget {
  const LessonMenuFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BrandWaves(bottomHeight: 96, soft: true),
          SafeArea(
            child: ContentWidth(
              child: Column(
                children: [
                  const BrandScreenHeader(),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Padding of the lesson menu body, shared by the demo and remote overview.
const lessonMenuPadding = EdgeInsetsDirectional.fromSTEB(
  AppSpacing.xl,
  AppSpacing.md,
  AppSpacing.xl,
  AppSpacing.xxxl,
);

/// Hero illustration and the fixed heading "Arapça Dersleri" with its hint.
/// The heading never shows the title of an individual lesson.
class LessonMenuIntro extends StatelessWidget {
  const LessonMenuIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const LessonsHero(),
        const SizedBox(height: AppSpacing.sm),
        BrandTitleBlock(
          title: l10n.lessonMenuTitle,
          subtitle: l10n.lessonMenuSubtitle,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// The order of the drawn lesson menu (rows of two). This is only the visual
/// order: the study sequence, the unlocking and the grading stay exactly as
/// the stages define them (`LessonStage` order and the server progress).
/// `null` is the "Test" card, which is not a stage and not available.
const lessonMenuLayout = <LessonStage?>[
  LessonStage.reading,
  LessonStage.listening,
  LessonStage.translation,
  LessonStage.writing,
  LessonStage.speaking,
  null,
];

/// Two-column grid of six cards. [cardFor] returns the card of a stage (the
/// caller supplies its status, score and open action); the sixth card,
/// "Test", is built here and never opens anything.
class LessonModeGrid extends StatelessWidget {
  const LessonModeGrid({super.key, required this.cardFor});

  final Widget Function(LessonStage stage) cardFor;

  @override
  Widget build(BuildContext context) {
    final cells = [
      for (final stage in lessonMenuLayout)
        stage == null ? const _TestCard() : cardFor(stage),
    ];
    return Column(
      children: [
        for (var i = 0; i < cells.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          // Both cards of a row get the same height, also with large text.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cells[i]),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: cells[i + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

IconData modeIcon(LessonStage? stage) => switch (stage) {
  LessonStage.reading => Icons.menu_book_outlined,
  LessonStage.listening => Icons.headphones_outlined,
  LessonStage.translation => Icons.translate,
  LessonStage.writing => Icons.edit_outlined,
  LessonStage.speaking => Icons.mic_none_outlined,
  null => Icons.assignment_turned_in_outlined,
};

/// A stage as a grid card: icon and name only, as drawn. The real status is
/// shown by a small corner badge (lock, check, ...) with a tooltip and the
/// screen-reader label; the card opens only when [onOpen] is set (the server
/// says the stage is open), otherwise it does nothing.
class LessonModeCard extends StatelessWidget {
  const LessonModeCard({
    super.key,
    required this.stage,
    required this.status,
    required this.onOpen,
    this.officialScore,
  });

  final LessonStage stage;
  final StageStatus status;

  /// OFFICIAL server score (0..100).
  final double? officialScore;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final semantic = context.semanticColors;
    final statusText = l10n.statusName(status);
    final score = officialScore == null
        ? null
        : l10n.officialResultScore(
            formatScore(officialScore!).isolateLtr,
            '100'.isolateLtr,
          );
    final (badge, badgeColor) = switch (status) {
      StageStatus.completed => (Icons.check_circle, semantic.success),
      StageStatus.inProgress => (Icons.timelapse, AppColors.brand),
      StageStatus.locked => (Icons.lock_outline, AppColors.brandDeep),
      StageStatus.unavailable => (Icons.hourglass_empty, AppColors.brandDeep),
      StageStatus.available => (null, AppColors.brand),
    };
    return _ModeCardShell(
      cardKey: ValueKey('stage-card:${stage.name}'),
      icon: modeIcon(stage),
      title: l10n.stageName(stage),
      muted: onOpen == null,
      onTap: onOpen,
      semanticsLabel: [l10n.stageName(stage), statusText, ?score].join(', '),
      corner: Tooltip(
        key: ValueKey('stage-status:${stage.name}'),
        message: statusText,
        child: badge == null
            ? const SizedBox(width: 22, height: 22)
            : Icon(badge, size: 22, color: badgeColor),
      ),
      footer: score == null
          ? null
          : Text(
              score,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
    );
  }
}

/// The lesson menu while NO lesson is selected: all six cards look as drawn
/// but none opens anything; pressing one only says it is not available.
class UnavailableLessonMenuGrid extends StatelessWidget {
  const UnavailableLessonMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LessonModeGrid(
      cardFor: (stage) => _ModeCardShell(
        cardKey: ValueKey('stage-card:${stage.name}'),
        icon: modeIcon(stage),
        title: l10n.stageName(stage),
        muted: false,
        onTap: () => showUnavailable(context),
        semanticsLabel: '${l10n.stageName(stage)}, ${l10n.comingSoonTag}',
      ),
    );
  }
}

/// The sixth card. "Test" is not one of the five lesson stages, so it looks
/// like the others but opens nothing; it only says it is not available.
class _TestCard extends StatelessWidget {
  const _TestCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ModeCardShell(
      cardKey: const ValueKey('mode-test'),
      icon: modeIcon(null),
      title: l10n.modeTest,
      muted: false,
      onTap: () => showUnavailable(context),
      semanticsLabel: '${l10n.modeTest}, ${l10n.comingSoonTag}',
    );
  }
}

class _ModeCardShell extends StatelessWidget {
  const _ModeCardShell({
    required this.cardKey,
    required this.icon,
    required this.title,
    required this.muted,
    required this.onTap,
    required this.semanticsLabel,
    this.corner,
    this.footer,
  });

  final Key cardKey;
  final IconData icon;
  final String title;
  final bool muted;
  final VoidCallback? onTap;
  final String semanticsLabel;
  final Widget? corner;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(18);
    final fade = muted ? 0.55 : 1.0;
    return Semantics(
      key: cardKey,
      button: true,
      enabled: onTap != null,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.brandMist,
            borderRadius: radius,
            border: Border.all(color: AppColors.brandLight, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 120),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.lg,
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: fade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 44, color: AppColors.brand),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.brandDeep,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              ?footer,
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (corner != null)
                      PositionedDirectional(
                        top: AppSpacing.sm,
                        end: AppSpacing.sm,
                        child: corner!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
