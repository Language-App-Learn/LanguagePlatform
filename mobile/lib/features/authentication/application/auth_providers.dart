import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../data/unavailable_auth_repository.dart';
import '../domain/auth_repository.dart';

/// Backend bağlanınca gerçek uygulamayla değiştirilecek tek nokta.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const UnavailableAuthRepository(),
);

/// Oturum durumu. GERÇEK oturum yoktur; `demo` yalnızca örnek içeriği
/// gezmek için açık bir geliştirme modudur (hesap/token oluşturmaz).
enum SessionStatus { signedOut, demo }

class SessionNotifier extends Notifier<SessionStatus> {
  SessionNotifier([this._initial = SessionStatus.signedOut]);

  final SessionStatus _initial;

  @override
  SessionStatus build() => _initial;

  /// Demo mod kapalıysa (`DEMO_MODE=false`) hiçbir şey yapmaz.
  void enterDemo() {
    if (!AppConfig.demoModeEnabled) return;
    state = SessionStatus.demo;
  }

  void signOut() => state = SessionStatus.signedOut;
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionStatus>(
  SessionNotifier.new,
);

/// Giriş/kayıt/şifre sıfırlama isteğinin durumu (sayfadan ayrılınca silinir).
/// Backend yokken her istek `ServiceUnavailableException` ile biter.
class AuthActionController extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<void> signIn(String email, String password) => _run(
    () => ref
        .read(authRepositoryProvider)
        .signIn(email: email.trim(), password: password),
  );

  Future<void> register(String name, String email, String password) => _run(
    () => ref
        .read(authRepositoryProvider)
        .register(name: name.trim(), email: email.trim(), password: password),
  );

  Future<void> requestPasswordReset(String email) => _run(
    () => ref
        .read(authRepositoryProvider)
        .requestPasswordReset(email: email.trim()),
  );

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}

final authActionProvider =
    AsyncNotifierProvider.autoDispose<AuthActionController, void>(
      AuthActionController.new,
    );
