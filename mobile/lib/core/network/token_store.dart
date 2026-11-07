import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Access/refresh token pair of a REAL signed-in account.
@immutable
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Where session tokens live. Tokens must NEVER go to SharedPreferences,
/// logs or analytics.
///
/// Reads are synchronous (the HTTP layer needs them on every call); the
/// persistent implementation therefore loads once at startup and keeps an
/// in-memory copy that mirrors the secure store.
abstract interface class TokenStore {
  TokenPair? read();

  /// Replaces BOTH tokens together (refresh tickets are single-use).
  Future<void> save(TokenPair tokens);

  Future<void> clear();
}

/// Session-only storage: lost when the app process ends. Used in tests and
/// whenever no platform secure store is available.
class InMemoryTokenStore implements TokenStore {
  TokenPair? _tokens;

  @override
  TokenPair? read() => _tokens;

  @override
  Future<void> save(TokenPair tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

/// Minimal async secret storage (Android Keystore-backed / iOS Keychain-
/// backed on a device). The platform adapter implements this; nothing else
/// in the app talks to the platform store directly.
abstract interface class SecretStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// Token store persisted in a [SecretStore].
///
/// * Both tokens are serialized into ONE entry, so a crash can never leave a
///   new access token next to an old (already consumed) refresh token.
/// * Memory is updated first: a rotated refresh ticket is single-use, so
///   losing it because persistence hiccupped would end the session. A failed
///   write therefore keeps the session for this run and the next successful
///   save repairs the stored copy.
/// * An unreadable or malformed entry is deleted and treated as signed out.
class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._secrets);

  static const storageKey = 'lp.session.v1';

  final SecretStore _secrets;
  TokenPair? _cache;

  /// Reads the stored session once (call before the app starts).
  Future<void> load() async {
    try {
      final raw = await _secrets.read(storageKey);
      if (raw == null) return;
      final json = jsonDecode(raw);
      if (json is Map &&
          json['a'] is String &&
          json['r'] is String &&
          (json['a'] as String).isNotEmpty &&
          (json['r'] as String).isNotEmpty) {
        _cache = TokenPair(
          accessToken: json['a'] as String,
          refreshToken: json['r'] as String,
        );
        return;
      }
      await _secrets.delete(storageKey);
    } on Object {
      // Corrupt / undecryptable entry (e.g. keystore reset): signed out.
      _cache = null;
      try {
        await _secrets.delete(storageKey);
      } on Object {
        // Nothing more can be done.
      }
    }
  }

  @override
  TokenPair? read() => _cache;

  @override
  Future<void> save(TokenPair tokens) async {
    _cache = tokens;
    try {
      await _secrets.write(
        storageKey,
        jsonEncode({'a': tokens.accessToken, 'r': tokens.refreshToken}),
      );
    } on Object {
      // Keep the in-memory session; see class comment.
    }
  }

  @override
  Future<void> clear() async {
    _cache = null;
    try {
      await _secrets.delete(storageKey);
    } on Object {
      // The in-memory copy is already gone; a stale stored copy is dropped
      // on the next successful clear or fails closed at the server.
    }
  }
}
