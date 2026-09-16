import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'trotxi_client_next.dart' show TokenStore, ConditionalTokenStore;

/// One application, backend generation and disposable-database incarnation.
/// A replacement build never reads or copies the old access_token/refresh_token
/// keys. Changing a local/staging database's identity also changes this scope,
/// even when its URL stays the same. Build numbers deliberately do not belong
/// here: upgrading an app must not sign out a valid replacement session.
class SessionScope {
  SessionScope({
    required String baseUrl,
    required this.app,
    required this.realm,
  }) : baseUrl = _canonicalUrl(baseUrl) {
    if (!const ['driver', 'commuter'].contains(app) ||
        !RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{0,63}$').hasMatch(realm)) {
      throw ArgumentError('Invalid session scope');
    }
  }

  final String baseUrl;
  final String app;
  final String realm;

  String get storageKey => 'trotxi.replacement-v1.session.${sha256.convert(
        utf8.encode(jsonEncode([app, realm, baseUrl])),
      )}';

  static String _canonicalUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !const ['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('A session needs an explicit backend URL');
    }
    final path = uri.normalizePath().path.replaceFirst(RegExp(r'/+$'), '');
    return Uri(
      scheme: uri.scheme,
      host: uri.host.toLowerCase(),
      port: uri.hasPort ? uri.port : null,
      path: path,
    ).toString();
  }
}

/// The production implementation below uses OS secure storage. This seam lets
/// tests prove the same key/read/write protocol without mocking token logic.
abstract class SessionStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage([this.storage = const FlutterSecureStorage()]);
  final FlutterSecureStorage storage;

  @override
  Future<String?> read(String key) => storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => storage.delete(key: key);
}

class SessionTokens {
  const SessionTokens(this.accessToken, this.refreshToken);
  final String accessToken;
  final String refreshToken;
}

/// Own one instance per app composition root; all HTTP clients share it.
///
/// A token pair is a single secure-storage record, so interruption between two
/// writes cannot combine an old refresh token with a new access token. Reads,
/// writes and conditional rotation/clearing are serialized on this instance.
class ScopedTokenStore implements TokenStore, ConditionalTokenStore {
  ScopedTokenStore({
    required this.scope,
    this.storage = const SecureSessionStorage(),
  });

  final SessionScope scope;
  final SessionStorage storage;
  void Function()? onCleared;
  Future<void> _tail = Future.value();
  int _generation = 0;

  /// Local identity changes, not ordinary access-token rotations.
  int get generation => _generation;

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    // A failed OS operation must not poison all later storage operations.
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<SessionTokens?> _read() async {
    final value = await storage.read(scope.storageKey);
    if (value == null) return null;
    try {
      final json = jsonDecode(value);
      if (json is Map &&
          json['format'] == 1 &&
          json['accessToken'] is String &&
          (json['accessToken'] as String).isNotEmpty &&
          json['refreshToken'] is String &&
          (json['refreshToken'] as String).isNotEmpty) {
        return SessionTokens(json['accessToken'], json['refreshToken']);
      }
    } on FormatException {
      // An incomplete/corrupt record is not a usable session. Never fall back
      // to the old keys or reveal the raw payload in an error/log.
    }
    throw const FormatException('Stored session is invalid');
  }

  Future<void> _save(String access, String refresh) {
    if (access.isEmpty || refresh.isEmpty) {
      throw ArgumentError('Both session credentials are required');
    }
    return storage.write(
        scope.storageKey,
        jsonEncode({
          'format': 1,
          'accessToken': access,
          'refreshToken': refresh,
        }));
  }

  @override
  Future<String?> getAccessToken() =>
      _exclusive(() async => (await _read())?.accessToken);
  @override
  Future<String?> getRefreshToken() =>
      _exclusive(() async => (await _read())?.refreshToken);
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      _exclusive(() async {
        await _save(accessToken, refreshToken);
        _generation++;
      });

  Future<bool> saveTokensIfGenerationMatches({
    required int expectedGeneration,
    required String accessToken,
    required String refreshToken,
  }) =>
      _exclusive(() async {
        if (_generation != expectedGeneration) return false;
        await _save(accessToken, refreshToken);
        _generation++;
        return true;
      });

  @override
  Future<bool> saveTokensIfRefreshMatches({
    required String expectedRefreshToken,
    required String accessToken,
    required String refreshToken,
  }) =>
      _exclusive(() async {
        if ((await _read())?.refreshToken != expectedRefreshToken) return false;
        await _save(accessToken, refreshToken);
        return true;
      });

  @override
  Future<bool> clearTokensIfRefreshMatches(String expectedRefreshToken) =>
      _exclusive(() async {
        if ((await _read())?.refreshToken != expectedRefreshToken) return false;
        await storage.delete(scope.storageKey);
        _generation++;
        onCleared?.call();
        return true;
      });

  /// Logout takes the credential and removes it atomically before making a
  /// network call. A delayed logout response cannot clear the next login.
  Future<SessionTokens?> takeSession() => _exclusive(() async {
        try {
          return await _read();
        } finally {
          // Even an unreadable record must be discardable on a shared phone.
          await storage.delete(scope.storageKey);
          _generation++;
          onCleared?.call();
        }
      });

  @override
  Future<void> clearTokens() => _exclusive(() async {
        await storage.delete(scope.storageKey);
        _generation++;
        onCleared?.call();
      });
}
