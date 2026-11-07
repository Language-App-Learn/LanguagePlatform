import 'dart:typed_data';

import '../errors/app_failure.dart';

enum HttpMethod { get, post, put, delete }

/// Lets the caller abandon an in-flight request (screen closed, user
/// cancelled a download). The transport aborts the socket and the call
/// completes with [CancelledFailure].
class CancelToken {
  bool _cancelled = false;
  void Function()? _onCancel;

  bool get isCancelled => _cancelled;

  /// Transport hook; set by the client while a request is in flight.
  // ignore: use_setters_to_change_properties
  void attach(void Function()? onCancel) => _onCancel = onCancel;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _onCancel?.call();
  }

  void throwIfCancelled() {
    if (_cancelled) throw const CancelledFailure();
  }
}

/// Transport-level request. Paths come from feature data layers and follow
/// the confirmed backend contracts only.
class ApiRequest {
  const ApiRequest(
    this.method,
    this.path, {
    this.query,
    this.body,
    this.requiresAuth = false,
    this.headers,
    this.expectedMime,
    this.cancelToken,
  });

  final HttpMethod method;
  final String path;
  final Map<String, String>? query;

  /// JSON-encodable body (maps/lists/primitives).
  final Object? body;

  /// Whether the request needs the learner's bearer token (added by the
  /// authenticated client; never set by feature code).
  final bool requiresAuth;
  final Map<String, String>? headers;

  /// When set, a successful response is binary: it is returned as
  /// [ApiResponse.bytes] and its `Content-Type` MUST match (a JSON or HTML
  /// body can never be mistaken for the file).
  final String? expectedMime;

  final CancelToken? cancelToken;

  ApiRequest withHeader(String name, String value) => ApiRequest(
    method,
    path,
    query: query,
    body: body,
    requiresAuth: requiresAuth,
    headers: {...?headers, name: value},
    expectedMime: expectedMime,
    cancelToken: cancelToken,
  );
}

/// Diagnostic view of an RFC 9457 `application/problem+json` body. Server
/// wording is NEVER shown to the learner; only [status] is interpreted (by
/// the transport) and the rest is for developers.
class ProblemDetails {
  const ProblemDetails({this.status, this.type, this.title});

  final int? status;
  final String? type;
  final String? title;

  static ProblemDetails? tryParse(Object? json) {
    if (json is! Map) return null;
    final status = json['status'];
    final type = json['type'];
    final title = json['title'];
    if (status is! num && type is! String && title is! String) return null;
    return ProblemDetails(
      status: status is num ? status.toInt() : null,
      type: type is String ? type : null,
      title: title is String ? title : null,
    );
  }
}

/// Transport-level response with already-decoded JSON (or `null`), or raw
/// [bytes] for binary requests.
class ApiResponse {
  const ApiResponse(
    this.statusCode, [
    this.json,
    this.headers = const {},
    this.bytes,
  ]);

  final int statusCode;
  final Object? json;

  /// Response headers, lower-cased names, first value only.
  final Map<String, String> headers;

  /// Raw body of a binary request (null for JSON responses).
  final Uint8List? bytes;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  ProblemDetails? get problem =>
      isSuccess ? null : ProblemDetails.tryParse(json);

  AppFailure get failure =>
      failureForStatus(statusCode, retryAfter: headers['retry-after']);

  /// Returns the parsed body for 2xx responses, otherwise throws the
  /// matching [AppFailure]. A body that cannot be parsed becomes
  /// [UnexpectedResponseFailure].
  T unwrap<T>(T Function(Object? json) parse) {
    if (!isSuccess) throw failure;
    try {
      return parse(json);
    } on Object {
      throw const UnexpectedResponseFailure();
    }
  }

  /// For endpoints without a response body (204 etc.).
  void ensureSuccess() {
    if (!isSuccess) throw failure;
  }
}

/// HTTP status → failure. Only the status (and `Retry-After` for 429) is
/// interpreted; ProblemDetails text is a diagnostic and is never shown.
AppFailure failureForStatus(int status, {String? retryAfter}) {
  return switch (status) {
    401 => const UnauthorizedFailure(),
    403 => const ForbiddenFailure(),
    404 => const NotFoundFailure(),
    409 => const ConflictFailure(),
    413 => const PayloadTooLargeFailure(),
    415 => const UnsupportedMediaFailure(),
    429 => RateLimitedFailure(retryAfter: _parseRetryAfter(retryAfter)),
    400 || 422 => const ValidationFailure(),
    408 || 504 => const TimeoutFailure(),
    >= 500 && < 600 => const ServerFailure(),
    _ => const UnexpectedResponseFailure(),
  };
}

/// Only the delta-seconds form is honoured (bounded to one hour); a date
/// form or garbage is ignored rather than guessed.
Duration? _parseRetryAfter(String? raw) {
  final seconds = int.tryParse(raw?.trim() ?? '');
  if (seconds == null || seconds < 0) return null;
  return Duration(seconds: seconds > 3600 ? 3600 : seconds);
}

/// Network boundary used by remote repositories. Implementations must throw
/// [AppFailure] (or exceptions understood by `failureOf`) for transport
/// problems such as timeouts or missing connectivity, and must not log
/// request bodies, credentials or tokens.
abstract interface class ApiClient {
  Future<ApiResponse> send(ApiRequest request);
}
