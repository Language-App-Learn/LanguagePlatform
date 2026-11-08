import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/auth_providers.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_widgets.dart';

/// Password reset in two honest steps: request (the server sends an email
/// only when delivery is configured) and confirmation with the emailed code.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _requestKey = GlobalKey<FormState>();
  final _confirmKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _newPassword = TextEditingController();
  bool _requested = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  void _request() {
    if (!(_requestKey.currentState?.validate() ?? false)) return;
    ref.read(authActionProvider.notifier).requestPasswordReset(_email.text);
  }

  void _confirm() {
    if (!(_confirmKey.currentState?.validate() ?? false)) return;
    ref
        .read(authActionProvider.notifier)
        .confirmPasswordReset(
          email: _email.text,
          code: _code.text,
          newPassword: _newPassword.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final action = ref.watch(authActionProvider);
    ref.listen(authActionProvider, (_, next) {
      if (next.value == AuthOutcome.resetRequested && !_requested) {
        setState(() => _requested = true);
      }
    });
    final done = action.value == AuthOutcome.passwordChanged;

    return AuthScaffold(
      showBack: true,
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.forgotPasswordSubtitle,
      children: [
        AuthStatusBanner(action: action),
        Form(
          key: _requestKey,
          child: EmailField(
            controller: _email,
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: l10n.sendResetButton,
          isLoading: action.isLoading && !_requested,
          onPressed: _request,
        ),
        if (_requested && !done) ...[
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: _confirmKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const ValueKey('reset-code'),
                  controller: _code,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.resetCodeLabel,
                    prefixIcon: const Icon(Icons.pin_outlined),
                  ),
                  validator: (v) =>
                      AuthValidators.requiredText(v)?.message(l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                PasswordField(
                  controller: _newPassword,
                  label: l10n.newPasswordLabel,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _confirm,
                  validator: (v) =>
                      AuthValidators.newPassword(v)?.message(l10n),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            key: const ValueKey('reset-confirm'),
            label: l10n.resetConfirmAction,
            isLoading: action.isLoading,
            onPressed: _confirm,
          ),
        ],
        if (done) ...[
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: Text(l10n.loginButton),
          ),
        ],
      ],
    );
  }
}
