import '../errors/app_failure.dart';

enum HttpMethod { get, post, put, delete }

/// Transport-level request. Paths are supplied by feature data layers once a
/// backend contract is confirmed; nothing here assumes any endpoint.
class ApiRequest {
  const ApiRequest(this.method, this.path, {this.query, this.body});

  final HttpMethod method;
  final String path;
  final Map<String, String>? query;

  /// JSON-encodable body (maps/lists/primitives).
  final Object? body;
}

/// Transport-level response with already-decoded JSON (or `null`).
class ApiResponse {
  const ApiResponse(this.statusCode, [this.json]);

  final int statusCode;
  final Object? json;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Returns the parsed body for 2xx responses, otherwise throws the
  /// matching [AppFailure]. A body that cannot be parsed becomes
  /// [UnexpectedResponseFailure].
  T unwrap<T>(T Function(Object? json) parse) {
    if (!isSuccess) throw failureForStatus(statusCode);
    try {
      return parse(json);
    } on Object {
      throw const UnexpectedResponseFailure();
    }
  }
}

/// HTTP status → failure. The backend's error body format is undecided, so
/// only the status code is interpreted.
AppFailure failureForStatus(int status) {
  return switch (status) {
    401 => const UnauthorizedFailure(),
    403 => const ForbiddenFailure(),
    404 => const NotFoundFailure(),
    400 || 409 || 422 => const ValidationFailure(),
    408 || 504 => const TimeoutFailure(),
    >= 500 && < 600 => const ServerFailure(),
    _ => const UnexpectedResponseFailure(),
  };
}

/// Network boundary used by future remote repositories. A Dio-based
/// implementation will be added together with the first real integration;
/// until then tests use an in-memory fake. Implementations must throw
/// [AppFailure] (or exceptions understood by `failureOf`) for transport
/// problems such as timeouts or missing connectivity, and must not log
/// request bodies, credentials or tokens.
abstract interface class ApiClient {
  Future<ApiResponse> send(ApiRequest request);
}
