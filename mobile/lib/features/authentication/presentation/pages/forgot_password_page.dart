import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_widgets.dart';

/// Şifremi unuttum. Backend bağlı olmadığından e-posta GÖNDERMEZ.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref.read(authActionProvider.notifier).requestPasswordReset(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final action = ref.watch(authActionProvider);

    return AuthScaffold(
      showBack: true,
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.forgotPasswordSubtitle,
      children: [
        AuthStatusBanner(action: action),
        Form(
          key: _formKey,
          child: EmailField(
            controller: _email,
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: l10n.sendResetButton,
          isLoading: action.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
