import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/brand_continue_button.dart';
import '../../../../core/design_system/widgets/brand_illustrations.dart';
import '../../../../core/design_system/widgets/brand_screen_header.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/flag_badge.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/learning_preferences.dart';
import '../../domain/learning_language.dart';

/// Screen 4: the language pair of the learner (known -> target). Not the
/// interface language (screen 2). Only Turkish -> Arabic is offered, so each
/// dropdown holds exactly one choice; the pair is stored in the existing
/// learning preferences when the learner continues.
class LanguagePairPage extends ConsumerWidget {
  const LanguagePairPage({super.key});

  static final _known = LearningLanguage.fromCode('tr')!;
  static final _target = LearningLanguage.fromCode('ar')!;

  void _continue(BuildContext context, WidgetRef ref) {
    ref.read(learningPreferencesProvider.notifier).setPair(_known, _target);
    context.push(AppRoutes.arabicSections);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BrandWaves(bottomHeight: 96, soft: true),
          SafeArea(
            child: ContentWidth(
              // One scroll area: on a small phone with large text everything
              // scrolls together and the button stays reachable.
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        const BrandScreenHeader(),
                        const SizedBox(height: AppSpacing.lg),
                        const LanguagePairHero(),
                        const SizedBox(height: AppSpacing.md),
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: BrandTitleBlock(
                            title: l10n.languagePairTitle,
                            subtitle: l10n.languagePairSubtitle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.xl,
                            AppSpacing.xl,
                            AppSpacing.xl,
                            AppSpacing.lg,
                          ),
                          child: Column(
                            children: [
                              _PairField(
                                key: const ValueKey('pair-known'),
                                label: l10n.pairKnownLabel,
                                language: _known,
                                name: l10n.languageNameTr,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _PairField(
                                key: const ValueKey('pair-target'),
                                label: l10n.pairTargetLabel,
                                language: _target,
                                name: l10n.languageNameAr,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.xl,
                            AppSpacing.sm,
                            AppSpacing.xl,
                            AppSpacing.xxxl + AppSpacing.md,
                          ),
                          child: BrandContinueButton(
                            key: const ValueKey('pair-continue'),
                            label: l10n.continueButton,
                            onPressed: () => _continue(context, ref),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One dropdown-style field: a label above a flag + language name + chevron.
/// The only choice is the language itself, so the menu holds exactly that
/// one item (already chosen).
class _PairField extends StatelessWidget {
  const _PairField({
    super.key,
    required this.label,
    required this.language,
    required this.name,
  });

  final String label;
  final LearningLanguage language;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.brandDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: '$label: $name',
          excludeSemantics: true,
          child: PopupMenuButton<LearningLanguage>(
            tooltip: '',
            position: PopupMenuPosition.under,
            onSelected: (_) {},
            itemBuilder: (context) => [
              PopupMenuItem(
                value: language,
                child: Row(
                  children: [
                    FlagBadge(code: language.code, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Text(name),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.check, size: 18, color: AppColors.brand),
                  ],
                ),
              ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.brandMist,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.brandLight, width: 1.4),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      FlagBadge(code: language.code, size: 36),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.brandDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.brandDeep,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
