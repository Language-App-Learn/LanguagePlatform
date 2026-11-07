import '../../../core/errors/app_exceptions.dart';
import '../domain/auth_repository.dart';

/// Placeholder used while no backend is configured. NOTHING succeeds: no fake
/// token, session or success is ever produced.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  static const _service = 'authentication';

  static Future<T> _fail<T>() =>
      Future.error(const ServiceUnavailableException(_service));

  @override
  Future<void> signIn({
    required String email,
    required String password,
    String? authenticatorCode,
  }) => _fail();

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) => _fail();

  @override
  Future<void> confirmEmail({required String userId, required String code}) =>
      _fail();

  @override
  Future<void> resendConfirmation({required String email}) => _fail();

  @override
  Future<void> requestPasswordReset({required String email}) => _fail();

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) => _fail();

  @override
  Future<AccountInfo> currentAccount() => _fail();

  @override
  Future<void> requestAccountDeletion({
    required String password,
    String? authenticatorCode,
  }) => _fail();

  @override
  Future<void> signOut() async {}
}
