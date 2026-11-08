import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_value_store.dart';

/// Idempotency keys of assessment attempts that were STARTED but not yet
/// SUBMITTED, kept across timeouts and app restarts.
///
/// * The same key is reused while an attempt is pending, so an ambiguous
///   failure (timeout, dropped connection, app killed) never creates a second
///   attempt: the server returns the attempt it already created.
/// * A deliberate retake gets a NEW key ([renew]).
/// * Keys are random ids, not secrets, and carry no account data; they are
///   still wiped on every identity change ([clearAll]) so one account's
///   pending attempt can never be resumed by another.
class PendingAttemptStore {
  PendingAttemptStore(this._store, [Random? random])
    : _random = random ?? Random.secure();

  static const storageKey = 'lp.attempts';

  final KeyValueStore _store;
  final Random _random;

  Map<String, String> _read() {
    final raw = _store.read(storageKey);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return {
          for (final e in json.entries)
            if (e.key is String && e.value is String && e.key != '')
              e.key as String: e.value as String,
        };
      }
    } on FormatException {
      // Corrupt: start clean.
    }
    return {};
  }

  Future<void> _write(Map<String, String> map) => map.isEmpty
      ? _store.remove(storageKey)
      : _store.write(storageKey, jsonEncode(map));

  /// The pending key of [assessmentId], or `null` when none was started.
  String? pending(String assessmentId) => _read()[assessmentId];

  /// The pending key, or a freshly created (and persisted) one.
  Future<String> keyFor(String assessmentId) async {
    final map = _read();
    final existing = map[assessmentId];
    if (existing != null) return existing;
    return renew(assessmentId);
  }

  /// A new key for a deliberate new attempt.
  Future<String> renew(String assessmentId) async {
    final map = _read();
    final key = _newKey();
    map[assessmentId] = key;
    await _write(map);
    return key;
  }

  /// The attempt was submitted (or definitively rejected): forget the key.
  Future<void> complete(String assessmentId) async {
    final map = _read();
    if (map.remove(assessmentId) != null) await _write(map);
  }

  Future<void> clearAll() => _store.remove(storageKey);

  // 128 bits, hex: well inside the server's 128 character limit.
  String _newKey() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

final pendingAttemptStoreProvider = Provider<PendingAttemptStore>(
  (ref) => PendingAttemptStore(ref.watch(keyValueStoreProvider)),
);
