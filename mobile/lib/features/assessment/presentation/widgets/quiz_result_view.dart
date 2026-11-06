import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../domain/quiz.dart';

/// Quiz sonucu: başarı yüzdesi, özet, tekrar dene / bitir.
class QuizResultView extends StatelessWidget {
  const QuizResultView({
    super.key,
    required this.result,
    required this.onRetry,
    required this.onDone,
  });

  final QuizResult result;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = result.passed
        ? context.semanticColors.success
        : theme.colorScheme.error;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          label: l10n.quizResultTitle,
          value: '${result.percentage}%',
          child: ExcludeSemantics(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: result.percentage / 100,
                    strokeWidth: 12,
                    color: color,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      '${result.percentage}%'.isolateLtr,
                      key: const ValueKey('quiz-percentage'),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          result.passed ? l10n.quizPassed : l10n.quizFailed,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.quizScoreSummary(result.correctAnswers, result.totalQuestions),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        NoticeBanner(message: l10n.quizLocalOnly),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: l10n.quizTryAgain,
          icon: Icons.refresh,
          onPressed: onRetry,
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(onPressed: onDone, child: Text(l10n.done)),
      ],
    );
  }
}
