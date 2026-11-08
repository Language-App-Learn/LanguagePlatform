/// İstenen içerik/kayıt bulunamadı.
class NotFoundException implements Exception {
  const NotFoundException(this.what);

  final String what;

  @override
  String toString() => 'NotFoundException($what)';
}

/// Özellik, henüz bağlanmamış bir backend entegrasyonuna ihtiyaç duyuyor.
class ServiceUnavailableException implements Exception {
  const ServiceUnavailableException(this.service);

  final String service;

  @override
  String toString() => 'ServiceUnavailableException($service)';
}
