import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../errors/app_failure.dart';
import 'api_client.dart';

/// `dart:io` HTTP transport (no extra package). JSON in and out, binary on
/// request; transport problems become typed [AppFailure]s. Bodies, headers
/// and tokens are never logged.
///
/// Safety properties:
/// * redirects are NOT followed (an API never needs them, and following one
///   could carry the bearer to another host);
/// * only GET is retried automatically (network errors, timeouts, 502/503/
///   504); POST/PUT/DELETE are never replayed here - callers use
///   idempotency keys for that;
/// * every request carries a random `X-Correlation-Id` for support tracing.
class HttpApiClient implements ApiClient {
  HttpApiClient({
    required this.baseUri,
    HttpClient? client,
    this.timeout = const Duration(seconds: 20),
    this.maxGetRetries = 2,
    this.retryDelay = const Duration(milliseconds: 400),
    this.maxBinaryBytes = 10 * 1024 * 1024,
  }) : _client =
           client ??
           (HttpClient()..connectionTimeout = const Duration(seconds: 10));

  final Uri baseUri;
  final Duration timeout;
  final int maxGetRetries;
  final Duration retryDelay;

  /// Upper bound of a binary download held in memory.
  final int maxBinaryBytes;
  final HttpClient _client;
  static final Random _random = Random.secure();

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    final retries = request.method == HttpMethod.get ? maxGetRetries : 0;
    for (var attempt = 0; ; attempt++) {
      request.cancelToken?.throwIfCancelled();
      try {
        final response = await _once(request);
        if (attempt < retries && _isTransient(response.statusCode)) {
          await _backoff(attempt);
          continue;
        }
        return response;
      } on NetworkUnavailableFailure {
        if (attempt >= retries || (request.cancelToken?.isCancelled ?? false)) {
          rethrow;
        }
        await _backoff(attempt);
      } on TimeoutFailure {
        if (attempt >= retries || (request.cancelToken?.isCancelled ?? false)) {
          rethrow;
        }
        await _backoff(attempt);
      }
    }
  }

  static bool _isTransient(int status) =>
      status == 502 || status == 503 || status == 504;

  Future<void> _backoff(int attempt) =>
      Future<void>.delayed(retryDelay * (attempt + 1));

  Future<ApiResponse> _once(ApiRequest request) async {
    HttpClientRequest? call;
    final token = request.cancelToken;
    try {
      final uri = _resolve(request);
      call = await _client
          .openUrl(request.method.name.toUpperCase(), uri)
          .timeout(timeout);
      final active = call;
      token?.attach(active.abort);
      active.followRedirects = false;
      active.headers
        ..set(
          HttpHeaders.acceptHeader,
          request.expectedMime == null
              ? 'application/json'
              : '${request.expectedMime}, application/json;q=0.5',
        )
        ..set('X-Correlation-Id', _correlationId());
      request.headers?.forEach(active.headers.set);
      if (request.body != null) {
        active.headers.contentType = ContentType.json;
        active.add(utf8.encode(jsonEncode(request.body)));
      }
      final response = await active.close().timeout(timeout);
      return await _read(request, response);
    } on CancelledFailure {
      rethrow;
    } on TimeoutException {
      throw const TimeoutFailure();
    } on HttpException {
      // `abort()` surfaces as an HttpException too.
      if (token?.isCancelled ?? false) throw const CancelledFailure();
      throw const NetworkUnavailableFailure();
    } on SocketException {
      throw const NetworkUnavailableFailure();
    } on HandshakeException {
      throw const NetworkUnavailableFailure();
    } finally {
      token?.attach(null);
    }
  }

  Future<ApiResponse> _read(ApiRequest request, HttpClientResponse r) async {
    final headers = _headers(r);
    final wantsBytes = request.expectedMime != null;
    if (wantsBytes && r.statusCode >= 200 && r.statusCode < 300) {
      final mime = r.headers.contentType?.mimeType;
      if (mime != request.expectedMime) {
        await r.drain<void>(); // never decode a JSON/HTML body as the file
        throw const UnexpectedResponseFailure();
      }
      final bytes = await _collect(r).timeout(timeout);
      return ApiResponse(r.statusCode, null, headers, bytes);
    }
    final text = await r.transform(utf8.decoder).join().timeout(timeout);
    return ApiResponse(r.statusCode, _decode(text), headers);
  }

  Future<Uint8List> _collect(HttpClientResponse r) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in r) {
      builder.add(chunk);
      if (builder.length > maxBinaryBytes) {
        throw const PayloadTooLargeFailure();
      }
    }
    return builder.takeBytes();
  }

  Uri _resolve(ApiRequest r) {
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final path = r.path.startsWith('/') ? r.path : '/${r.path}';
    return baseUri.replace(
      path: '$basePath$path',
      queryParameters: (r.query?.isEmpty ?? true) ? null : r.query,
    );
  }

  static String _correlationId() {
    final bytes = List<int>.generate(12, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Object? _decode(String text) {
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      return null; // not JSON; callers treat missing body as unexpected
    }
  }

  static Map<String, String> _headers(HttpClientResponse r) {
    final map = <String, String>{};
    r.headers.forEach((name, values) {
      if (values.isNotEmpty) map[name.toLowerCase()] = values.first;
    });
    return map;
  }

  void close() => _client.close(force: true);
}
