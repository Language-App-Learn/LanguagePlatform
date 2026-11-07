import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/learning_preferences.dart';
import '../widgets/language_settings.dart';

/// İlk kurulum: arayüz dili, bildiğim dil ve öğrenmek istediğim dil
/// birbirinden bağımsız üç ayrı seçimdir.
class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final prefs = ref.watch(learningPreferencesProvider);
    final bothChosen =
        prefs.knownLanguage != null && prefs.targetLanguage != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ContentWidth(
                child: ListView(
                  padding: AppSpacing.page,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.languageSetupTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.languageSetupSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const InterfaceLanguageSetting(
                      layout: ChoiceGroupLayout.chips,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const KnownLanguageSetting(layout: ChoiceGroupLayout.list),
                    const SizedBox(height: AppSpacing.lg),
                    const TargetLanguageSetting(layout: ChoiceGroupLayout.list),
                    if (!prefs.isComplete) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        bothChosen
                            ? l10n.sameLanguageHint
                            : l10n.chooseBothLanguagesHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ContentWidth(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: AppPrimaryButton(
                  label: l10n.continueAction,
                  icon: Icons.arrow_forward,
                  onPressed: prefs.isComplete
                      ? () => context.go(AppRoutes.login)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
