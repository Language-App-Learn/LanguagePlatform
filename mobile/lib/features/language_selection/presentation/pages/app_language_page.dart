import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_logo.dart';
import '../../../../core/design_system/widgets/brand_continue_button.dart';
import '../../../../core/design_system/widgets/brand_waves.dart';
import '../../../../core/design_system/widgets/flag_badge.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Screen 2: the app (interface) language, asked once. The choice is only
/// saved when the user presses continue; the screen's own texts and
/// direction preview the highlighted language right away. Changing it later
/// is a Settings matter (not designed yet).
class AppLanguagePage extends ConsumerStatefulWidget {
  const AppLanguagePage({super.key});

  @override
  ConsumerState<AppLanguagePage> createState() => _AppLanguagePageState();
}

class _AppLanguagePageState extends ConsumerState<AppLanguagePage> {
  AppLanguage? _selected;

  /// The order of the drawing: Türkçe, English, العربية.
  static const _order = [AppLanguage.tr, AppLanguage.en, AppLanguage.ar];

  AppLanguage get _effective =>
      _selected ??
      ref.read(appLanguageProvider) ??
      AppLanguage.fromCode(Localizations.localeOf(context).languageCode) ??
      AppLanguage.en;

  void _continue() {
    ref.read(appLanguageProvider.notifier).select(_effective);
    context.go(AppRoutes.menu);
  }

  @override
  Widget build(BuildContext context) {
    final language = _effective;
    // Preview: texts and reading direction follow the highlighted language.
    return Localizations.override(
      context: context,
      locale: language.locale,
      child: Builder(
        builder: (context) {
          final l10n = context.l10n;
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              fit: StackFit.expand,
              children: [
                const BrandWaves(bottomHeight: 96, soft: true),
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ContentWidth(
                          child: ListView(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              AppSpacing.xl,
                              AppSpacing.xl,
                              AppSpacing.xl,
                              AppSpacing.lg,
                            ),
                            children: [
                              const Center(
                                child: AppLogo(markSize: 96, wordSize: 24),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.appLanguageTitle,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: AppColors.brandDeep,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.appLanguageSubtitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              for (final option in _order) ...[
                                _LanguageOption(
                                  key: ValueKey('app-language:${option.code}'),
                                  language: option,
                                  selected: option == language,
                                  onTap: () =>
                                      setState(() => _selected = option),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            ],
                          ),
                        ),
                      ),
                      ContentWidth(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.xl,
                            AppSpacing.sm,
                            AppSpacing.xl,
                            AppSpacing.xxxl,
                          ),
                          child: BrandContinueButton(
                            key: const ValueKey('app-language-continue'),
                            label: l10n.continueButton,
                            onPressed: _continue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    super.key,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: language.nativeName,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? AppColors.brandLight : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selected ? AppColors.brand : const Color(0xFFD9CFEA),
              width: selected ? 2 : 1.2,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    FlagBadge(code: language.code, size: 44),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        // Native name: always written in its own language.
                        language.nativeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.brandDeep,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? AppColors.brand
                          : const Color(0xFF8F84A8),
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
