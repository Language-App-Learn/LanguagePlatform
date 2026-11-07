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
  Future<void> signIn({required String email, required String password});

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

  /// `GET /api/v1/me` (requires a session).
  Future<AccountInfo> currentAccount();

  /// Ends the session: best-effort server revocation, local tokens always
  /// cleared.
  Future<void> signOut();
}
