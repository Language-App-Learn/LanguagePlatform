import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/brand_mark.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../application/auth_providers.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/auth_validators.dart';

/// Giriş/kayıt/şifre sıfırlama sayfaları için ortak iskelet.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: AppSpacing.page,
            children: [
              const Center(child: BrandMark(size: 64, showName: false)),
              const SizedBox(height: AppSpacing.xl),
              Semantics(
                header: true,
                child: Text(title, style: theme.textTheme.headlineMedium),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension AuthFieldErrorText on AuthFieldError {
  String message(AppLocalizations l10n) => switch (this) {
    AuthFieldError.required => l10n.fieldRequired,
    AuthFieldError.invalidEmail => l10n.invalidEmail,
    AuthFieldError.passwordPolicy => l10n.passwordPolicy,
    AuthFieldError.passwordTooShort => l10n.passwordTooShort(
      AuthValidators.minPasswordLength,
    ),
    AuthFieldError.mismatch => l10n.passwordsDontMatch,
  };
}

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      // E-posta her dilde soldan sağa yazılır ve okunur.
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: l10n.emailLabel,
        prefixIcon: const Icon(Icons.mail_outline),
      ),
      validator: (v) => AuthValidators.email(v)?.message(l10n),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: const [AutofillHints.password],
      textDirection: TextDirection.ltr,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: widget.validator,
    );
  }
}

/// Honest status of the last auth request: errors by failure kind (never raw
/// server text) and the generic "request accepted" notices.
class AuthStatusBanner extends StatelessWidget {
  const AuthStatusBanner({super.key, required this.action});

  final AsyncValue<AuthOutcome?> action;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = action.error;
    final (String message, NoticeTone tone)? content;
    if (error != null) {
      final failure = failureOf(error);
      content = (
        error is ServiceUnavailableException
            ? l10n.authUnavailable
            : failure is UnauthorizedFailure
            ? l10n.authInvalidCredentials
            : failure is ValidationFailure
            ? l10n.authInvalidInput
            : failure.message(l10n),
        error is ServiceUnavailableException
            ? NoticeTone.warning
            : NoticeTone.info,
      );
    } else {
      content = switch (action.value) {
        AuthOutcome.registrationAccepted => (
          l10n.registerAccepted,
          NoticeTone.info,
        ),
        AuthOutcome.resetRequested => (l10n.resetRequested, NoticeTone.info),
        AuthOutcome.confirmationResent => (
          l10n.confirmationResent,
          NoticeTone.info,
        ),
        AuthOutcome.passwordChanged => (l10n.resetDone, NoticeTone.info),
        AuthOutcome.emailConfirmed => (l10n.confirmEmailDone, NoticeTone.info),
        _ => null,
      };
    }
    if (content == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
      child: Semantics(
        liveRegion: true,
        child: NoticeBanner(
          key: const ValueKey('auth-status'),
          tone: content.$2,
          message: content.$1,
        ),
      ),
    );
  }
}
