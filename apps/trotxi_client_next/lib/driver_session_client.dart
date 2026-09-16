import 'dart:async';

import 'package:dio/dio.dart';

import 'scoped_token_store.dart';
import 'trotxi_client_next.dart';

/// Account identity and fleet identity are different namespaces. The account
/// read does not expose a fleet ID; a restored session leaves it absent rather
/// than calling an account UUID a driver ID.
class DriverIdentity {
  const DriverIdentity({
    required this.accountId,
    required this.name,
    required this.mustChangePin,
    this.fleetDriverId,
    this.code,
  });
  final String accountId;
  final String? fleetDriverId;
  final String name;
  final String? code;

  /// Absent on an account-only restore; this is not an admission gate.
  final bool? mustChangePin;
}

/// Driver replacement auth, over the generated /v1 client. UI composition must
/// use the same scoped store and metadata for all its repositories. This does
/// not switch an app to the replacement or choose a backend on its behalf.
class DriverSessionClient {
  DriverSessionClient({
    required this.client,
    required this.store,
    required this.metadata,
  }) {
    metadata.validate();
    final scope = SessionScope(
      baseUrl: client.dio.options.baseUrl,
      app: metadata.app,
      realm: store.scope.realm,
    );
    if (metadata.app != 'driver' ||
        scope.storageKey != store.scope.storageKey) {
      throw ArgumentError('Driver session client and storage scopes differ');
    }
  }

  final TrotxiApiClientNext client;
  final ScopedTokenStore store;
  final ClientMetadata metadata;
  int _attempt = 0;
  Future<void> _localTail = Future.value();

  // Serialize identity bookkeeping with OS writes, not provider I/O. A second
  // attempt must take its generation after a pending first write, not before.
  Future<T> _local<T>(Future<T> Function() action) {
    final result = _localTail.then((_) => action());
    _localTail =
        result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<bool> hasStoredSession() async => await store.getAccessToken() != null;

  Future<DriverIdentity> signIn({
    required String code,
    required String pin,
    required bool ownDevice,
  }) async {
    final attempt = ++_attempt;
    final generation = await _local(() async {
      if (attempt != _attempt)
        throw const ApiException(0, 'Sign-in was superseded. Please retry.');
      return store.generation;
    });
    try {
      final response = await client.getPublicApi().signInDriver(
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            xTrotxiPlatform: metadata.platform,
            driverSignIn: DriverSignIn((b) => b
              ..code = code
              ..pin = pin
              ..ownDevice = ownDevice),
          );
      final tokens = response.data?.data;
      if (tokens == null ||
          tokens.account.role != AccountRoleEnum.driver ||
          tokens.accessToken.isEmpty ||
          tokens.refreshToken.isEmpty) {
        throw const ApiException(
            200, 'Sign-in returned an invalid driver session.');
      }
      return await _local(() async {
        if (attempt != _attempt ||
            !await store.saveTokensIfGenerationMatches(
              expectedGeneration: generation,
              accessToken: tokens.accessToken,
              refreshToken: tokens.refreshToken,
            )) {
          throw const ApiException(0, 'Sign-in was superseded. Please retry.');
        }
        if (attempt != _attempt) {
          // Logout/a newer attempt arrived during the OS write. Do not publish
          // this identity, and do not leave it installed behind a failed login.
          await store.clearTokensIfRefreshMatches(tokens.refreshToken);
          throw const ApiException(0, 'Sign-in was superseded. Please retry.');
        }
        return DriverIdentity(
          accountId: tokens.account.id,
          fleetDriverId: tokens.driver.id,
          name: tokens.driver.name,
          code: code.trim().toUpperCase(),
          mustChangePin: tokens.mustChangePin,
        );
      });
    } on DioException catch (error) {
      throw _unwrap(error);
    }
  }

  /// Only absent credentials or an authoritative rejection mean signed out.
  /// Offline, upgrade and server failures remain errors; no tokens are cleared
  /// by this method, and callers can keep an offline/blocked session screen.
  Future<DriverIdentity?> restore() async {
    final attempt = _attempt;
    final generation = store.generation;
    if (!await hasStoredSession()) return null;
    try {
      final response = await client.getSelfApi().getAccount(
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            xTrotxiPlatform: metadata.platform,
          );
      if (attempt != _attempt || generation != store.generation) return null;
      final account = response.data?.data;
      if (account == null || account.role != AccountRoleEnum.driver) {
        throw const ApiException(403, 'This account is not a driver.');
      }
      return DriverIdentity(
        accountId: account.id,
        name: account.displayName,
        mustChangePin: null,
      );
    } on DioException catch (error) {
      if (error.error is UnauthorizedException &&
          await store.getAccessToken() == null) return null;
      throw _unwrap(error);
    }
  }

  /// A caller supplies an action key, and reuses it after uncertain delivery.
  /// Neither PIN is persisted in a local retry queue or derived into the key.
  Future<void> changePin({
    required String currentPin,
    required String newPin,
    required String idempotencyKey,
  }) async {
    if (idempotencyKey.isEmpty || idempotencyKey.length > 128) {
      throw ArgumentError('A PIN change requires an action key');
    }
    try {
      await client.getDriverOwnApi().changeDriverPin(
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            xTrotxiPlatform: metadata.platform,
            idempotencyKey: idempotencyKey,
            pinChange: PinChange((b) => b
              ..currentPin = currentPin
              ..newPin = newPin),
          );
    } on DioException catch (error) {
      throw _unwrap(error);
    }
  }

  /// Local logout completes before provider I/O; returns whether remote logout
  /// was acknowledged. A false result does not claim server revocation.
  Future<bool> signOut() async {
    _attempt++;
    final SessionTokens? tokens;
    try {
      tokens = await _local(store.takeSession);
    } on FormatException {
      // takeSession still deletes an unreadable local record. Without its
      // refresh credential we cannot claim the server session was revoked.
      return false;
    }
    if (tokens == null) return true;
    final refreshToken = tokens.refreshToken;
    // Logout is credential-based and public. Do not let its failure refresh a
    // later driver's session or attach that driver's bearer to this request.
    final headers = Map<String, dynamic>.from(client.dio.options.headers)
      ..removeWhere((key, _) => key.toLowerCase() == 'authorization');
    final dio = client.dio.clone(
      options: client.dio.options.copyWith(headers: headers),
      interceptors: Interceptors(),
    );
    dio.interceptors.add(MetadataInterceptor(metadata));
    final logout = TrotxiApiClientNext(
      dio: dio,
      serializers: client.serializers,
      interceptors: [],
    );
    try {
      await logout.getPublicApi().logoutSession(
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            xTrotxiPlatform: metadata.platform,
            refreshInput: RefreshInput((b) => b.refreshToken = refreshToken),
          );
      return true;
    } on DioException {
      return false;
    }
    // clone shares the configured adapter; closing it would close app traffic.
  }

  static Object _unwrap(DioException error) =>
      error.error is TrotxiException ? error.error! : error;
}
