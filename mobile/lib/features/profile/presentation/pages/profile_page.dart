import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/section_header.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../authentication/application/auth_providers.dart';
import '../../../language_selection/application/learning_preferences.dart';

/// Profil: oturum durumu, diller ve ayarlara kısayol.
/// Gerçek hesap yok; demo oturumu açıkça belirtilir.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final session = ref.watch(sessionProvider);
    final prefs = ref.watch(learningPreferencesProvider);
    final interface = AppLanguage.fromCode(context.languageCode);
    final isDemo = session == SessionStatus.demo;
    final isAccount = session == SessionStatus.authenticated;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDemo
                                ? l10n.profileDemoName
                                : isAccount
                                ? l10n.profileAccountSubtitle
                                : l10n.profileGuestName,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            isDemo
                                ? l10n.profileDemoSubtitle
                                : l10n.profileSignedOutSubtitle,
                            key: const ValueKey('session-subtitle'),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.profileLanguagesTitle),
              AppCard(
                child: Column(
                  children: [
                    _LanguageRow(
                      label: l10n.interfaceLanguageTitle,
                      value: interface?.nativeName ?? context.languageCode,
                    ),
                    _LanguageRow(
                      label: l10n.knownLanguageTitle,
                      value: prefs.knownLanguage?.nativeName ?? '–',
                    ),
                    _LanguageRow(
                      label: l10n.targetLanguageTitle,
                      value: prefs.targetLanguage?.nativeName ?? '–',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                key: const ValueKey('open-settings'),
                onTap: () => context.push(AppRoutes.settings),
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        l10n.settingsTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              NoticeBanner(message: l10n.accountIntegrationPending),
              const SizedBox(height: AppSpacing.xl),
              if (isAccount)
                OutlinedButton(
                  key: const ValueKey('sign-out'),
                  onPressed: () async {
                    await signOutOfAccount(ref);
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  child: Text(l10n.signOut),
                )
              else if (isDemo)
                OutlinedButton(
                  key: const ValueKey('exit-demo'),
                  onPressed: () {
                    ref.read(sessionProvider.notifier).signOut();
                    context.go(AppRoutes.login);
                  },
                  child: Text(l10n.exitDemoMode),
                )
              else
                FilledButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text(l10n.loginButton),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
