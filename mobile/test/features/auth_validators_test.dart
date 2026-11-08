import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/features/authentication/domain/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('e-posta', () {
      expect(AuthValidators.email(''), AuthFieldError.required);
      expect(AuthValidators.email('abc'), AuthFieldError.invalidEmail);
      expect(AuthValidators.email('a@b'), AuthFieldError.invalidEmail);
      expect(AuthValidators.email(' user@mail.com '), isNull);
    });

    test('şifre ve tekrar', () {
      expect(AuthValidators.password(null), AuthFieldError.required);
      expect(
        AuthValidators.password('1234567'),
        AuthFieldError.passwordTooShort,
      );
      expect(AuthValidators.password('12345678'), isNull);
      expect(AuthValidators.confirmPassword('', 'x'), AuthFieldError.required);
      expect(AuthValidators.confirmPassword('a', 'b'), AuthFieldError.mismatch);
      expect(AuthValidators.confirmPassword('a', 'a'), isNull);
    });
  });
}
