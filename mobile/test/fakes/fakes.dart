import 'dart:async';

import 'package:language_platform/core/network/api_client.dart';
import 'package:language_platform/core/storage/key_value_store.dart';

/// Store whose writes can be delayed or made to fail, to test ordering and
/// failure accounting. Reads see the latest successful write only.
class ControllableStore implements KeyValueStore {
  ControllableStore({this.failWrites = false});

  final MemoryKeyValueStore inner = MemoryKeyValueStore();
  bool failWrites;

  /// Completers gate each write when non-null (FIFO).
  final List<Completer<void>> gates = [];
  bool gated = false;

  /// Values actually written, in order.
  final List<String> writes = [];

  @override
  String? read(String key) => inner.read(key);

  @override
  Future<void> write(String key, String value) async {
    if (gated) {
      final gate = Completer<void>();
      gates.add(gate);
      await gate.future;
    }
    if (failWrites) throw StorageException(key);
    writes.add(value);
    await inner.write(key, value);
  }

  @override
  Future<void> remove(String key) async {
    if (failWrites) throw StorageException(key);
    await inner.remove(key);
  }

  @override
  Future<void> clearAll() => inner.clearAll();
}

/// Scripted [ApiClient]: returns queued responses/errors and records requests.
class FakeApiClient implements ApiClient {
  FakeApiClient(this._script);

  final List<Object> _script; // ApiResponse or an error to throw
  final List<ApiRequest> requests = [];

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    requests.add(request);
    final next = _script.removeAt(0);
    if (next is ApiResponse) return next;
    throw next;
  }
}
