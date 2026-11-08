import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/auth_providers.dart';
import '../widgets/auth_widgets.dart';

/// Confirms an email address from the values of the emailed link
/// (`/auth/confirm-email?userId=...&code=...`). It confirms automatically
/// when both values are present and never fabricates success.
///
/// NOTE: the app does not register an OS-level deep link for this route
/// (an insecure or unverified link scheme would be a security risk); the
/// backend email template and verified App Links / Universal Links are an
/// open dependency tracked in PROJECT_STATUS.md.
class ConfirmEmailPage extends ConsumerStatefulWidget {
  const ConfirmEmailPage({super.key, this.userId, this.code});

  final String? userId;
  final String? code;

  @override
  ConsumerState<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends ConsumerState<ConfirmEmailPage> {
  bool get _hasValues =>
      (widget.userId?.isNotEmpty ?? false) &&
      (widget.code?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    if (_hasValues) {
      Future.microtask(
        () => ref
            .read(authActionProvider.notifier)
            .confirmEmail(userId: widget.userId!, code: widget.code!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final action = ref.watch(authActionProvider);
    // An invalid/expired/missing code is a 400 from the server (or a link
    // without values); other failures (network, unavailable) keep their own
    // honest message.
    final rejected =
        !_hasValues ||
        (action.hasError && failureOf(action.error) is ValidationFailure);
    return AuthScaffold(
      showBack: true,
      title: l10n.confirmEmailTitle,
      subtitle: '',
      children: [
        if (rejected)
          NoticeBanner(
            key: const ValueKey('confirm-email-failed'),
            message: l10n.confirmEmailFailed,
          )
        else
          AuthStatusBanner(action: action),
        if (action.isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: l10n.loginButton,
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ],
    );
  }
}
