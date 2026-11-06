import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/app_progress_bar.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../../language_selection/application/content_language.dart';
import '../../application/review_session.dart';
import '../../domain/review_scheduler.dart';

/// Flashcard review: show the word, reveal the meaning, rate recall.
/// The schedule is saved locally after every rating.
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: SafeArea(
        child: AsyncValueView<ReviewSessionState>(
          value: ref.watch(reviewSessionProvider),
          onRetry: () => ref.invalidate(reviewSessionProvider),
          data: (state) {
            if (state.queue.isEmpty) {
              return EmptyStateView(
                icon: Icons.task_alt,
                title: l10n.reviewNothingTitle,
                message: l10n.reviewNothingMessage,
              );
            }
            return ContentWidth(
              child: ListView(
                padding: AppSpacing.page,
                children: [
                  state.isFinished
                      ? _Summary(state: state)
                      : _Card(state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  const _Card({required this.state});

  final ReviewSessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final controller = ref.read(reviewSessionProvider.notifier);
    final item = state.current;
    final contentLanguage = ref.watch(contentLanguageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.reviewProgress(state.index + 1, state.queue.length),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppProgressBar(value: state.index / state.queue.length),
        const SizedBox(height: AppSpacing.xl),
        // Tapping the card reveals the back; keyed so state resets per card.
        AppCard(
          key: ValueKey('flashcard:${item.id}'),
          onTap: state.revealed ? null : controller.reveal,
          padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
          child: Column(
            children: [
              ContentText(
                item.term,
                languageCode: item.languageCode,
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              if (item.transliteration != null)
                Text(
                  item.transliteration!.isolateLtr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              AnimatedCrossFade(
                duration: AppMotion.fast,
                crossFadeState: state.revealed
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  l10n.reviewShowAnswer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                secondChild: Column(
                  children: [
                    Text(
                      item.meaning.resolve(contentLanguage),
                      key: const ValueKey('flashcard-back'),
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (item.example != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      ContentText(
                        item.example!.text,
                        languageCode: item.languageCode,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        item.example!.translation.resolve(contentLanguage),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (!state.revealed)
          AppPrimaryButton(
            label: l10n.reviewShowAnswer,
            icon: Icons.visibility_outlined,
            onPressed: controller.reveal,
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final rating in ReviewRating.values)
                FilledButton.tonal(
                  key: ValueKey('rate:${rating.name}'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      AppSizes.minTouchTarget * 2,
                      AppSizes.buttonHeight,
                    ),
                  ),
                  onPressed: () => controller.rate(rating),
                  child: Text(_label(l10n, rating)),
                ),
            ],
          ),
      ],
    );
  }
}

String _label(AppLocalizations l10n, ReviewRating rating) => switch (rating) {
  ReviewRating.again => l10n.ratingAgain,
  ReviewRating.hard => l10n.ratingHard,
  ReviewRating.good => l10n.ratingGood,
  ReviewRating.easy => l10n.ratingEasy,
};

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final ReviewSessionState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        Icon(
          Icons.emoji_events_outlined,
          size: AppSizes.iconXl,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.reviewDoneTitle,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(l10n.reviewDoneSummary(state.reviewed)),
        const SizedBox(height: AppSpacing.lg),
        for (final rating in ReviewRating.values)
          Text('${_label(l10n, rating)}: ${state.ratings[rating] ?? 0}'),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: l10n.done,
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.vocabulary),
        ),
      ],
    );
  }
}
