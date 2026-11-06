/// Kimlik doğrulama sözleşmesi.
///
/// Backend sözleşmesi bilinmiyor: uç noktalar, token türü (JWT/refresh),
/// hata kodları, e-posta doğrulama ve parola sıfırlama akışı netleşince
/// Dio tabanlı uygulama bu arayüzü gerçekleyecek. Token'lar güvenli
/// depolamada (ör. platform keystore) tutulacak, asla kodda/logda değil.
abstract interface class AuthRepository {
  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset({required String email});
}
