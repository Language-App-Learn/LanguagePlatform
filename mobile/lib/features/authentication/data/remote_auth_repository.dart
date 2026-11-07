import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/token_store.dart';
import '../domain/auth_repository.dart';

/// [AuthRepository] over the confirmed account routes. Passwords are sent
/// only to the backend (HTTPS outside local development) and are never
/// stored; tokens go to the [TokenStore].
///
/// Registration, confirmation resend and password reset need server-side
/// email delivery. When the backend reports 503 for them, the call fails with
/// `ServiceUnavailableException`, so the UI never pretends it worked.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  static const _base = '/api/v1/auth';

  @override
  Future<void> signIn({required String email, required String password}) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '$_base/login',
        body: {'email': email, 'password': password},
      ),
    );
    final pair = response.unwrap((json) {
      final m = json! as Map;
      return TokenPair(
        accessToken: m['accessToken']! as String,
        refreshToken: m['refreshToken']! as String,
      );
    });
    await _tokens.save(pair);
  }

  /// The API takes only email and password; the display name is not part of
  /// the registration contract (profile editing is pending server-side).
  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '$_base/register',
        body: {'email': email, 'password': password},
      ),
    );
    _requireDelivery(response);
    response.ensureSuccess();
  }

  @override
  Future<void> confirmEmail({
    required String userId,
    required String code,
  }) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '$_base/confirm-email',
        body: {'userId': userId, 'code': code},
      ),
    );
    response.ensureSuccess();
  }

  @override
  Future<void> resendConfirmation({required String email}) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '$_base/confirm-email/resend',
        body: {'email': email},
      ),
    );
    _requireDelivery(response);
    response.ensureSuccess();
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '$_base/password-reset/request',
        body: {'email': email},
      ),
    );
    _requireDelivery(response);
    response.ensureSuccess();
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _api.send(
      ApiRequest(
        HttpMethod.post,
        '$_base/password-reset/confirm',
        body: {'email': email, 'code': code, 'newPassword': newPassword},
      ),
    );
    response.ensureSuccess();
  }

  @override
  Future<AccountInfo> currentAccount() async {
    final response = await _api.send(
      const ApiRequest(HttpMethod.get, '/api/v1/me', requiresAuth: true),
    );
    return response.unwrap((json) {
      final m = json! as Map;
      final name = m['displayName'];
      return AccountInfo(
        id: m['id']! as String,
        email: m['email']! as String,
        displayName: name is String && name.isNotEmpty ? name : null,
      );
    });
  }

  @override
  Future<void> signOut() async {
    try {
      final response = await _api.send(
        const ApiRequest(HttpMethod.post, '$_base/logout', requiresAuth: true),
      );
      response.ensureSuccess();
    } on AppFailure {
      // Best effort: an already-expired session or a network problem must
      // not keep the learner signed in locally.
    } finally {
      await _tokens.clear();
    }
  }

  void _requireDelivery(ApiResponse response) {
    if (response.statusCode == 503) {
      throw const ServiceUnavailableException('email-delivery');
    }
  }
}
