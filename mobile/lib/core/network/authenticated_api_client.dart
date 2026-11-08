import 'dart:async';

import 'api_client.dart';
import 'token_store.dart';

/// Adds the bearer token to requests that need it and performs ONE
/// coordinated refresh when the server answers 401.
///
/// Concurrent 401s share a single in-flight refresh (the refresh ticket is
/// single-use), then each retries once with the new access token. If the
/// refresh fails, the stored tokens are cleared and [onSessionExpired] is
/// called so the app can return to the signed-out state.
class AuthenticatedApiClient implements ApiClient {
  AuthenticatedApiClient({
    required this._inner,
    required this.tokens,
    this.onSessionExpired,
  });

  final ApiClient _inner;
  final TokenStore tokens;
  final void Function()? onSessionExpired;

  Future<bool>? _refreshing;

  static const refreshPath = '/api/v1/auth/refresh';

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    if (!request.requiresAuth) return _inner.send(request);
    final first = tokens.read();
    if (first == null) return const ApiResponse(401);

    var response = await _inner.send(_withBearer(request, first.accessToken));
    if (response.statusCode != 401) return response;

    final refreshed = await _refreshOnce(first.accessToken);
    final current = tokens.read();
    if (!refreshed || current == null) return response;
    response = await _inner.send(_withBearer(request, current.accessToken));
    return response;
  }

  ApiRequest _withBearer(ApiRequest r, String token) =>
      r.withHeader('Authorization', 'Bearer $token');

  Future<bool> _refreshOnce(String staleAccessToken) {
    return _refreshing ??= _refresh(staleAccessToken)
        .whenComplete(() => _refreshing = null);
  }

  Future<bool> _refresh(String staleAccessToken) async {
    final current = tokens.read();
    // Another caller already replaced the tokens: just retry with them.
    if (current == null) return false;
    if (current.accessToken != staleAccessToken) return true;
    try {
      final response = await _inner.send(
        ApiRequest(
          HttpMethod.post,
          refreshPath,
          body: {'refreshToken': current.refreshToken},
        ),
      );
      if (response.isSuccess) {
        final json = response.json;
        if (json is Map &&
            json['accessToken'] is String &&
            json['refreshToken'] is String) {
          // Replace both tokens together.
          await tokens.save(
            TokenPair(
              accessToken: json['accessToken'] as String,
              refreshToken: json['refreshToken'] as String,
            ),
          );
          return true;
        }
      }
      // 409 = concurrent state change: a parallel refresh may have won.
      if (response.statusCode == 409 &&
          tokens.read()?.accessToken != staleAccessToken) {
        return true;
      }
    } on Object {
      // Transport problem during refresh: keep the session for a later retry.
      return false;
    }
    await tokens.clear();
    onSessionExpired?.call();
    return false;
  }
}
