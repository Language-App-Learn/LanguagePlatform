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

/// Kayıt ekranı. Backend bağlı olmadığından hesap OLUŞTURMAZ.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(authActionProvider.notifier)
        .register(_name.text, _email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final action = ref.watch(authActionProvider);

    return AuthScaffold(
      showBack: true,
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      children: [
        AuthStatusBanner(action: action),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: l10n.nameLabel,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => AuthValidators.requiredText(v)?.message(l10n),
              ),
              const SizedBox(height: AppSpacing.lg),
              EmailField(controller: _email),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                controller: _password,
                label: l10n.passwordLabel,
                validator: (v) => AuthValidators.password(v)?.message(l10n),
              ),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                controller: _confirm,
                label: l10n.confirmPasswordLabel,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (v) => AuthValidators.confirmPassword(
                  v,
                  _password.text,
                )?.message(l10n),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: l10n.registerButton,
          isLoading: action.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.haveAccountPrompt),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: Text(l10n.loginButton),
            ),
          ],
        ),
      ],
    );
  }
}
