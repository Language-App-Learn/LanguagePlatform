/// Form alanı doğrulama hataları. Metin karşılıkları arayüzde ARB'den gelir.
enum AuthFieldError { required, invalidEmail, passwordTooShort, mismatch }

/// Saf doğrulama kuralları (yalnızca biçim; sunucu doğrulaması değildir).
abstract final class AuthValidators {
  static const int minPasswordLength = 8;

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static AuthFieldError? requiredText(String? value) =>
      (value == null || value.trim().isEmpty) ? AuthFieldError.required : null;

  static AuthFieldError? email(String? value) {
    final required = requiredText(value);
    if (required != null) return required;
    return _email.hasMatch(value!.trim()) ? null : AuthFieldError.invalidEmail;
  }

  static AuthFieldError? password(String? value) {
    if (value == null || value.isEmpty) return AuthFieldError.required;
    return value.length < minPasswordLength
        ? AuthFieldError.passwordTooShort
        : null;
  }

  static AuthFieldError? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return AuthFieldError.required;
    return value == password ? null : AuthFieldError.mismatch;
  }
}
