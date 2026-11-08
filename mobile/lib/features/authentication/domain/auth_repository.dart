import 'package:flutter/foundation.dart';

/// The signed-in account as reported by the server (`GET /api/v1/me`).
@immutable
class AccountInfo {
  const AccountInfo({required this.id, required this.email, this.displayName});

  final String id;
  final String email;

  /// Nullable on the server: accounts are created from email + password.
  final String? displayName;
}

/// Account operations over the confirmed backend routes. Implementations
/// never fabricate success: when a feature needs server-side delivery (email)
/// that is not configured, they throw `ServiceUnavailableException`.
abstract interface class AuthRepository {
  /// [authenticatorCode] is only needed for accounts with MFA enabled.
  Future<void> signIn({
    required String email,
    required String password,
    String? authenticatorCode,
  });

  /// The registration contract takes only email and password; [name] is
  /// accepted for the form but is not sent.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  /// `POST /auth/confirm-email` with the values from the confirmation link.
  Future<void> confirmEmail({required String userId, required String code});

  Future<void> resendConfirmation({required String email});

  Future<void> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  /// `POST /api/v1/me/privacy/deletion-request`: re-authenticates with the
  /// password (and an authenticator code if the account uses one). On 202 the
  /// server has deactivated the account and ended its sessions; the local
  /// session is cleared too. This is an ACCEPTED REQUEST: the final purge of
  /// the data is an operator task, not something the app can confirm.
  Future<void> requestAccountDeletion({
    required String password,
    String? authenticatorCode,
  });

  /// `GET /api/v1/me` (requires a session).
  Future<AccountInfo> currentAccount();

  /// Ends the session: best-effort server revocation, local tokens always
  /// cleared.
  Future<void> signOut();
}
