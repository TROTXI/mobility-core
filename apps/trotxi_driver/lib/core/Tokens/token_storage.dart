import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trotxi_client/trotxi_client.dart';

/// Where the session lives on the device, and the one place that knows when it
/// has been taken away.
///
/// [onCleared] is the fix for #235. The client's interceptor clears tokens only
/// after a refresh has actually failed, which is a PROVEN dead session rather
/// than a guess — the exact signal the app was missing. Hanging the callback
/// here rather than in `trotxi_client` keeps the shared package untouched and
/// puts the notification at the moment the session stops existing, not at some
/// later screen that happens to notice a 401.
class TokenStorage implements TokenStore {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  /// Called after the stored session is discarded, by a failed refresh or by an
  /// explicit sign-out. Both mean the same thing to the app: there is no
  /// session, show sign-in.
  void Function()? onCleared;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    // After the delete, so a listener that reads storage back sees the truth.
    onCleared?.call();
  }
}
