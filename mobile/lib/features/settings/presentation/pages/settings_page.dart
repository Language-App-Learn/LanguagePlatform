import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/design_system/widgets/choice_group.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../language_selection/presentation/widgets/language_settings.dart';

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
            children: const [
              InterfaceLanguageSetting(),
              SizedBox(height: AppSpacing.xl),
              KnownLanguageSetting(),
              SizedBox(height: AppSpacing.xl),
              TargetLanguageSetting(),
              SizedBox(height: AppSpacing.xl),
              ThemeModeSetting(),
              SizedBox(height: AppSpacing.xl),
              _AccountSection(),
              SizedBox(height: AppSpacing.xl),
              _AboutTile(),
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
