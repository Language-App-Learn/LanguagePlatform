import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal, synchronous-read key/value storage for NON-SENSITIVE data only.
///
/// Never store passwords, access tokens or refresh tokens here; those need
/// platform secure storage once real authentication exists.
abstract interface class KeyValueStore {
  String? read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);

  /// Removes every key owned by this app (used by "reset local data").
  Future<void> clearAll();
}

/// In-memory store: default for tests, and the fallback when platform
/// storage cannot be opened (the app keeps working, state just isn't kept).
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? initial]) : _data = {...?initial};

  final Map<String, String> _data;

  @override
  String? read(String key) => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> clearAll() async => _data.clear();
}

/// A write that the platform reported as failed.
class StorageException implements Exception {
  const StorageException(this.key);

  final String key;

  @override
  String toString() => 'StorageException($key)';
}

/// `shared_preferences`-backed store. Reads come from the already-loaded
/// in-memory cache of the plugin, so providers can build synchronously.
/// A write the plugin reports as unsuccessful throws [StorageException]
/// instead of being treated as persisted.
class SharedPreferencesKeyValueStore implements KeyValueStore {
  SharedPreferencesKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  static const keyPrefix = 'lp.';

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    if (!await _prefs.setString(key, value)) throw StorageException(key);
  }

  @override
  Future<void> remove(String key) async {
    if (!await _prefs.remove(key)) throw StorageException(key);
  }

  @override
  Future<void> clearAll() async {
    for (final key in _prefs.getKeys().where((k) => k.startsWith(keyPrefix))) {
      await remove(key);
    }
  }
}

/// Adds ordering, read-your-writes and failure accounting around any store.
///
/// - Writes to the same key run strictly one after another (no interleaving).
/// - Rapid writes are coalesced: only the newest pending value is written.
/// - [read] returns the newest value immediately, even before it is flushed.
/// - A failed write never throws into UI code and is never reported as
///   persisted: it increments [failedWrites] (surfaced in Settings) and the
///   value is retried by the next write of that key.
class GuardedKeyValueStore implements KeyValueStore {
  GuardedKeyValueStore(this._inner);

  final KeyValueStore _inner;

  /// Number of writes that failed since the app started.
  final ValueNotifier<int> failedWrites = ValueNotifier(0);

  // Newest not-yet-flushed value per key (`null` = removal).
  final Map<String, String?> _pending = {};
  final Map<String, Future<void>> _tails = {};

  @override
  String? read(String key) =>
      _pending.containsKey(key) ? _pending[key] : _inner.read(key);

  @override
  Future<void> write(String key, String value) {
    _pending[key] = value;
    return _enqueue(key);
  }

  @override
  Future<void> remove(String key) {
    _pending[key] = null;
    return _enqueue(key);
  }

  Future<void> _enqueue(String key) {
    final previous = _tails[key] ?? Future<void>.value();
    final next = previous.then((_) => _flush(key));
    _tails[key] = next;
    return next;
  }

  Future<void> _flush(String key) async {
    // An earlier queued flush may already have written the newest value.
    if (!_pending.containsKey(key)) return;
    final value = _pending[key];
    try {
      if (value == null) {
        await _inner.remove(key);
      } else {
        await _inner.write(key, value);
      }
      // Only clear when nothing newer arrived while we were writing.
      if (_pending.containsKey(key) && _pending[key] == value) {
        _pending.remove(key);
      }
    } catch (error) {
      failedWrites.value++;
      if (kDebugMode) debugPrint('Storage write failed for $key: $error');
    }
  }

  /// Completes when every queued write has been attempted.
  Future<void> flush() async {
    while (_tails.values.isNotEmpty) {
      final pending = _tails.values.toList();
      await Future.wait(pending);
      _tails.removeWhere((_, f) => pending.contains(f));
    }
  }

  @override
  Future<void> clearAll() async {
    await flush();
    _pending.clear();
    await _inner.clearAll();
  }
}

/// Opens platform storage. Falls back to memory if it fails, so a storage
/// problem never prevents the app from starting.
Future<KeyValueStore> openKeyValueStore() async {
  try {
    return SharedPreferencesKeyValueStore(
      await SharedPreferences.getInstance(),
    );
  } catch (error) {
    if (kDebugMode) debugPrint('Storage unavailable, using memory: $error');
    return MemoryKeyValueStore();
  }
}

/// Overridden in `main()` with the real store; tests get memory by default.
final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => MemoryKeyValueStore(),
);

/// Decodes a stored JSON object, returning `null` when missing or corrupted.
/// Corrupted data is treated as absent (defaults apply) instead of crashing.
Map<String, Object?>? readJsonObject(KeyValueStore store, String key) {
  final raw = store.read(key);
  if (raw == null) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, Object?> ? decoded : null;
  } catch (_) {
    return null;
  }
}

Future<void> writeJsonObject(
  KeyValueStore store,
  String key,
  Map<String, Object?> json,
) => store.write(key, jsonEncode(json));

/// Number of failed local writes (0 when the store is not guarded).
class PersistenceHealthNotifier extends Notifier<int> {
  @override
  int build() {
    final store = ref.watch(keyValueStoreProvider);
    if (store is! GuardedKeyValueStore) return 0;
    void onChange() => state = store.failedWrites.value;
    store.failedWrites.addListener(onChange);
    ref.onDispose(() => store.failedWrites.removeListener(onChange));
    return store.failedWrites.value;
  }
}

final persistenceFailuresProvider =
    NotifierProvider<PersistenceHealthNotifier, int>(
      PersistenceHealthNotifier.new,
    );
