import '../../../core/error/app_exceptions.dart';
import '../domain/auth_repository.dart';

/// Backend bağlanana kadar kullanılan yer tutucu. HİÇBİR işlem başarılı
/// sayılmaz: sahte token, sahte oturum veya sahte başarı üretmez.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  static const _service = 'authentication';

  @override
  Future<void> signIn({required String email, required String password}) =>
      Future.error(const ServiceUnavailableException(_service));

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) => Future.error(const ServiceUnavailableException(_service));

  @override
  Future<void> requestPasswordReset({required String email}) =>
      Future.error(const ServiceUnavailableException(_service));
}
