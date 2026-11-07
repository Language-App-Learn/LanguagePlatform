/// Form alanı doğrulama hataları. Metin karşılıkları arayüzde ARB'den gelir.
enum AuthFieldError {
  required,
  invalidEmail,
  passwordTooShort,
  passwordPolicy,
  mismatch,
}

/// Saf doğrulama kuralları (yalnızca biçim; sunucu doğrulaması değildir).
abstract final class AuthValidators {
  /// Sign-in only needs a non-trivial value: older rules must not lock
  /// anybody out. The server decides.
  static const int minPasswordLength = 8;

  /// Server password policy for NEW passwords (registration, reset).
  static const int minNewPasswordLength = 12;

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

  /// Mirrors the Identity policy (length >= 12, upper, lower, digit, symbol)
  /// so the learner is told BEFORE the request; the server stays the judge.
  static AuthFieldError? newPassword(String? value) {
    if (value == null || value.isEmpty) return AuthFieldError.required;
    final ok =
        value.length >= minNewPasswordLength &&
        value.contains(RegExp(r'\p{Lu}', unicode: true)) &&
        value.contains(RegExp(r'\p{Ll}', unicode: true)) &&
        value.contains(RegExp(r'\d')) &&
        value.contains(RegExp(r'[^\p{L}\p{N}]', unicode: true));
    return ok ? null : AuthFieldError.passwordPolicy;
  }

  static AuthFieldError? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return AuthFieldError.required;
    return value == password ? null : AuthFieldError.mismatch;
  }
}
