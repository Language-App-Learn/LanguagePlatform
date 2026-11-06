import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/design_system/widgets/confirm_dialog.dart';
import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/storage/key_value_store.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../language_selection/presentation/widgets/language_settings.dart';
import '../../../progress/application/progress_providers.dart';
import '../../../progress/domain/learning_progress.dart';
import '../../application/reset_local_data.dart';

/// Ayarlar: arayüz dili, öğrenme dilleri, tema, hesap ve hakkında.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              NoticeBanner(message: l10n.settingsDemoNotice),
              const _StorageWarning(),
              const SizedBox(height: AppSpacing.xl),
              const InterfaceLanguageSetting(),
              const SizedBox(height: AppSpacing.xl),
              const KnownLanguageSetting(),
              const SizedBox(height: AppSpacing.xl),
              const TargetLanguageSetting(),
              const SizedBox(height: AppSpacing.xl),
              const ThemeModeSetting(),
              const SizedBox(height: AppSpacing.xl),
              const DailyGoalSetting(),
              const SizedBox(height: AppSpacing.xl),
              const _AccountSection(),
              const SizedBox(height: AppSpacing.xl),
              const _AboutTile(),
              const SizedBox(height: AppSpacing.xl),
              const ResetLocalDataTile(),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeModeSetting extends ConsumerWidget {
  const ThemeModeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ChoiceGroup<ThemeMode>(
      groupId: 'theme-mode',
      title: l10n.themeTitle,
      selected: ref.watch(themeModeProvider),
      options: [
        ChoiceOption(
          id: 'system',
          value: ThemeMode.system,
          label: l10n.themeModeSystem,
        ),
        ChoiceOption(
          id: 'light',
          value: ThemeMode.light,
          label: l10n.themeModeLight,
        ),
        ChoiceOption(
          id: 'dark',
          value: ThemeMode.dark,
          label: l10n.themeModeDark,
        ),
      ],
      onSelected: ref.read(themeModeProvider.notifier).select,
    );
  }
}

/// Hesap ayarları: gelecekteki backend entegrasyon noktaları (devre dışı).
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.accountSectionTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        NoticeBanner(message: l10n.accountIntegrationPending),
        const SizedBox(height: AppSpacing.sm),
        ListTile(
          enabled: false,
          leading: const Icon(Icons.badge_outlined),
          title: Text(l10n.editProfile),
        ),
        ListTile(
          enabled: false,
          leading: const Icon(Icons.password),
          title: Text(l10n.changePassword),
        ),
      ],
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      key: const ValueKey('about-tile'),
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.aboutTitle),
      onTap: () => showAboutDialog(
        context: context,
        applicationName: AppConfig.appName,
        children: [Text(l10n.aboutDescription)],
      ),
    );
  }
}

/// Daily lesson goal (persisted with the local progress).
class DailyGoalSetting extends ConsumerWidget {
  const DailyGoalSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ChoiceGroup<int>(
      groupId: 'settings-daily-goal',
      title: l10n.progressDailyGoalTitle,
      selected: ref.watch(progressProvider.select((p) => p.dailyGoalLessons)),
      onSelected: ref.read(progressProvider.notifier).setDailyGoal,
      options: [
        for (final goal in LearningProgress.dailyGoalOptions)
          ChoiceOption(
            id: '$goal',
            value: goal,
            label: l10n.dailyGoalOption(goal),
          ),
      ],
    );
  }
}

/// Clearly labeled "reset local demo data" action with a confirmation.
class ResetLocalDataTile extends ConsumerWidget {
  const ResetLocalDataTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ListTile(
      key: const ValueKey('reset-local-data'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(l10n.resetDataTitle),
      subtitle: Text(l10n.resetDataSubtitle),
      onTap: () async {
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.resetDataConfirmTitle,
          message: l10n.resetDataConfirmMessage,
          confirmLabel: l10n.resetDataConfirmAction,
          destructive: true,
        );
        if (confirmed != true || !context.mounted) return;
        await resetLocalData(ref);
        if (context.mounted) context.go(AppRoutes.splash);
      },
    );
  }
}

/// Honest warning when local writes failed (changes may be lost on exit).
class _StorageWarning extends ConsumerWidget {
  const _StorageWarning();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(persistenceFailuresProvider) == 0) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.md),
      child: NoticeBanner(
        key: const ValueKey('storage-warning'),
        tone: NoticeTone.warning,
        message: context.l10n.storageWriteFailed,
      ),
    );
  }
}
