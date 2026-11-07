import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/auth_providers.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_widgets.dart';

/// Giriş ekranı. Backend bağlı olmadığı için "Giriş yap" gerçek bir giriş
/// YAPMAZ; dürüst bir "servis bağlı değil" durumu gösterir. Örnek içeriği
/// gezmek için açık bir demo modu sunulur.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authActionProvider.notifier).signIn(_email.text, _password.text);
  }

  void _enterDemo() {
    ref.read(sessionProvider.notifier).enterDemo();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final action = ref.watch(authActionProvider);
    // A real sign-in (tokens received) continues to the app.
    ref.listen(authActionProvider, (previous, next) {
      if (next.value == AuthOutcome.signedIn) context.go(AppRoutes.home);
    });

    return AuthScaffold(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      children: [
        AuthStatusBanner(action: action),
        Form(
          key: _formKey,
          child: Column(
            children: [
              EmailField(controller: _email),
              const SizedBox(height: AppSpacing.lg),
              PasswordField(
                controller: _password,
                label: l10n.passwordLabel,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
                validator: (v) => AuthValidators.requiredText(v)?.message(l10n),
              ),
            ],
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () => context.push(AppRoutes.forgotPassword),
            child: Text(l10n.forgotPasswordLink),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppPrimaryButton(
          label: l10n.loginButton,
          isLoading: action.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.noAccountPrompt),
            TextButton(
              onPressed: () => context.push(AppRoutes.register),
              child: Text(l10n.registerButton),
            ),
          ],
        ),
        if (AppConfig.demoModeEnabled) ...[
          const Divider(height: AppSpacing.xxl),
          Text(
            l10n.demoModeExplain,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: const ValueKey('continue-demo'),
            onPressed: _enterDemo,
            icon: const Icon(Icons.explore_outlined),
            label: Text(l10n.continueDemo),
          ),
        ],
      ],
    );
  }
}
