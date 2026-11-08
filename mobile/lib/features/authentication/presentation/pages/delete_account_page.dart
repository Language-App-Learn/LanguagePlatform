import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/auth_providers.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_widgets.dart';

/// Account deletion REQUEST with clear confirmation and re-authentication.
///
/// What really happens (backend contract): the account is deactivated at
/// once and every session is invalidated (HTTP 202); the operator reviews the
/// request and completes the final data removal later. The page says exactly
/// that and never claims the data is already erased.
class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _understood = false;
  bool _needsAck = false;

  @override
  void dispose() {
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() => _needsAck = !_understood);
    if (!valid || !_understood) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountDialogTitle),
        content: Text(l10n.deleteAccountDialogBody),
        actions: [
          TextButton(
            key: const ValueKey('delete-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const ValueKey('delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteAccountAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(authActionProvider.notifier)
        .requestAccountDeletion(_password.text, authenticatorCode: _code.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final action = ref.watch(authActionProvider);

    if (action.value == AuthOutcome.deletionRequested) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.deleteAccountTitle)),
        body: SafeArea(
          child: ContentWidth(
            child: ListView(
              padding: AppSpacing.page,
              children: [
                NoticeBanner(
                  key: const ValueKey('delete-done'),
                  message: l10n.deleteAccountDone,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  key: const ValueKey('delete-back-to-login'),
                  label: l10n.loginButton,
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final error = action.error;
    final String? errorText = error == null
        ? null
        : error is ServiceUnavailableException
        ? l10n.authUnavailable
        : switch (failureOf(error)) {
            ValidationFailure() ||
            UnauthorizedFailure() => l10n.deleteAccountInvalid,
            final f => f.message(l10n),
          };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccountTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: AppSpacing.page,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.deleteAccountTitle,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.deleteAccountIntro),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.deleteAccountReview),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.deleteAccountPermanent,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.lg,
                  ),
                  child: Semantics(
                    liveRegion: true,
                    child: NoticeBanner(
                      key: const ValueKey('delete-error'),
                      message: errorText,
                    ),
                  ),
                ),
              Text(l10n.deleteAccountReauth),
              const SizedBox(height: AppSpacing.md),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    PasswordField(
                      controller: _password,
                      label: l10n.passwordLabel,
                      validator: (v) =>
                          AuthValidators.requiredText(v)?.message(l10n),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      key: const ValueKey('delete-authenticator'),
                      controller: _code,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.authenticatorCodeLabel,
                        prefixIcon: const Icon(Icons.pin_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CheckboxListTile(
                key: const ValueKey('delete-understand'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _understood,
                onChanged: (v) => setState(() {
                  _understood = v ?? false;
                  _needsAck = false;
                }),
                title: Text(l10n.deleteAccountUnderstand),
                subtitle: _needsAck
                    ? Text(
                        l10n.fieldRequired,
                        style: TextStyle(color: theme.colorScheme.error),
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                key: const ValueKey('delete-submit'),
                label: l10n.deleteAccountAction,
                isLoading: action.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
