import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/api_config.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/authenticated_api_client.dart';
import '../../../core/network/http_api_client.dart';
import '../../../core/network/token_store.dart';
import '../../../core/storage/pending_attempt_store.dart';
import '../data/remote_auth_repository.dart';
import '../data/unavailable_auth_repository.dart';
import '../domain/auth_repository.dart';

/// Base URL of the backend (`--dart-define=API_BASE_URL=...`); `null` keeps
/// the app in local demo mode with no network calls.
final apiBaseUriProvider = Provider<Uri?>((ref) => ApiConfig.baseUri);

/// Session tokens are NEVER written to SharedPreferences. `bootstrap`
/// overrides this with a Keychain/Keystore-backed store when the platform
/// secret store is available (see `platform_secret_store.dart`); otherwise
/// the session lives in memory only.
final tokenStoreProvider = Provider<TokenStore>((ref) => InMemoryTokenStore());

/// Transport used by all remote repositories. When the backend is not
/// configured, every call fails honestly with `ServiceUnavailable`.
final apiClientProvider = Provider<ApiClient>((ref) {
  final base = ref.watch(apiBaseUriProvider);
  if (base == null) return const _UnconfiguredApiClient();
  final http = HttpApiClient(baseUri: base);
  ref.onDispose(http.close);
  return AuthenticatedApiClient(
    inner: http,
    tokens: ref.watch(tokenStoreProvider),
    onSessionExpired: () => ref.read(sessionProvider.notifier).expired(),
  );
});

class _UnconfiguredApiClient implements ApiClient {
  const _UnconfiguredApiClient();

  @override
  Future<ApiResponse> send(ApiRequest request) =>
      Future.error(const ServiceUnavailableException('api'));
}

/// Real repository when a backend is configured, otherwise the honest
/// "not connected" placeholder. Demo mode is never an authenticated account.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(apiBaseUriProvider) == null) {
    return const UnavailableAuthRepository();
  }
  return RemoteAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider),
  );
});

/// Session status. `authenticated` means real tokens obtained from the
/// backend; `demo` is an explicit local sandbox that creates no account or
/// token.
enum SessionStatus { signedOut, demo, authenticated }

class SessionNotifier extends Notifier<SessionStatus> {
  SessionNotifier([this._initial]);

  final SessionStatus? _initial;

  /// An explicit status wins (tests, demo). Otherwise the session is
  /// restored from the secure token store: tokens present means "signed in"
  /// until the server says otherwise (a revoked or expired session fails its
  /// first call, the refresh fails and [expired] returns the app to
  /// signed-out).
  @override
  SessionStatus build() {
    final explicit = _initial;
    if (explicit != null) return explicit;
    if (ref.watch(apiBaseUriProvider) == null) return SessionStatus.signedOut;
    return ref.read(tokenStoreProvider).read() == null
        ? SessionStatus.signedOut
        : SessionStatus.authenticated;
  }

  /// Does nothing when demo mode is disabled (`DEMO_MODE=false`).
  void enterDemo() {
    if (!AppConfig.demoModeEnabled) return;
    state = SessionStatus.demo;
    // The sandbox must never inherit (or later resurrect) a real session.
    unawaited(ref.read(tokenStoreProvider).clear());
    unawaited(ref.read(pendingAttemptStoreProvider).clearAll());
    ref.read(accountEpochProvider.notifier).bump();
  }

  void authenticated() {
    state = SessionStatus.authenticated;
    // A (possibly different) account just signed in: nothing cached for the
    // previous one may be reused (pending attempt keys included).
    unawaited(ref.read(pendingAttemptStoreProvider).clearAll());
    ref.read(accountEpochProvider.notifier).bump();
  }

  /// Refresh failed / server rejected the session.
  void expired() {
    if (state == SessionStatus.authenticated) {
      state = SessionStatus.signedOut;
      ref.read(accountEpochProvider.notifier).bump();
    }
  }

  void signOut() {
    state = SessionStatus.signedOut;
    unawaited(ref.read(pendingAttemptStoreProvider).clearAll());
    ref.read(accountEpochProvider.notifier).bump();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionStatus>(
  SessionNotifier.new,
);

/// Changes whenever the signed-in identity may have changed (sign-in,
/// sign-out, expiry, demo entry). Every provider that holds learner-specific
/// server data watches it, so one account's cache is never shown to the next.
class AccountEpoch extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final accountEpochProvider = NotifierProvider<AccountEpoch, int>(
  AccountEpoch.new,
);

/// What a successful auth action achieved (shown as an honest status).
enum AuthOutcome {
  signedIn,
  registrationAccepted,
  resetRequested,
  confirmationResent,
  passwordChanged,
  emailConfirmed,
  deletionRequested,
}

/// State of a sign-in / register / reset request (disposed with the page).
/// `null` data = nothing done yet.
class AuthActionController extends AsyncNotifier<AuthOutcome?> {
  @override
  AuthOutcome? build() => null;

  Future<void> signIn(
    String email,
    String password, {
    String? authenticatorCode,
  }) => _run(() async {
    await ref
        .read(authRepositoryProvider)
        .signIn(
          email: email.trim(),
          password: password,
          authenticatorCode: authenticatorCode?.trim(),
        );
    ref.read(sessionProvider.notifier).authenticated();
    return AuthOutcome.signedIn;
  });

  /// Account deletion REQUEST (re-authenticated). On acceptance the local
  /// session ends as well; the data purge itself is an operator task.
  Future<void> requestAccountDeletion(
    String password, {
    String? authenticatorCode,
  }) => _run(() async {
    await ref
        .read(authRepositoryProvider)
        .requestAccountDeletion(
          password: password,
          authenticatorCode: authenticatorCode?.trim(),
        );
    ref.read(sessionProvider.notifier).signOut();
    return AuthOutcome.deletionRequested;
  });

  Future<void> register(String name, String email, String password) => _run(
    () async {
      await ref
          .read(authRepositoryProvider)
          .register(name: name.trim(), email: email.trim(), password: password);
      return AuthOutcome.registrationAccepted;
    },
  );

  Future<void> requestPasswordReset(String email) => _run(() async {
    await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(email: email.trim());
    return AuthOutcome.resetRequested;
  });

  Future<void> resendConfirmation(String email) => _run(() async {
    await ref
        .read(authRepositoryProvider)
        .resendConfirmation(email: email.trim());
    return AuthOutcome.confirmationResent;
  });

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) => _run(() async {
    await ref
        .read(authRepositoryProvider)
        .confirmPasswordReset(
          email: email.trim(),
          code: code.trim(),
          newPassword: newPassword,
        );
    return AuthOutcome.passwordChanged;
  });

  Future<void> confirmEmail({required String userId, required String code}) =>
      _run(() async {
        await ref
            .read(authRepositoryProvider)
            .confirmEmail(userId: userId.trim(), code: code.trim());
        return AuthOutcome.emailConfirmed;
      });

  Future<void> _run(Future<AuthOutcome> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}

final authActionProvider =
    AsyncNotifierProvider.autoDispose<AuthActionController, AuthOutcome?>(
      AuthActionController.new,
    );

/// Ends the real session: best-effort server logout, tokens always cleared.
Future<void> signOutOfAccount(WidgetRef ref) async {
  try {
    await ref.read(authRepositoryProvider).signOut();
  } finally {
    ref.read(sessionProvider.notifier).signOut();
  }
}
