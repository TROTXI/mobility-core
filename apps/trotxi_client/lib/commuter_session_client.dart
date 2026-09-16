import 'package:dio/dio.dart';

import 'scoped_token_store.dart';
import 'trotxi_client.dart';

/// Native provider results are transient inputs, never app session storage.
class AppleCredential {
  const AppleCredential({
    required this.idToken,
    this.nonce,
    this.authorizationCode,
    this.displayName,
  });
  final String idToken;
  final String? nonce;
  final String? authorizationCode;
  final String? displayName;
}

/// Replacement social sign-in. Start the attempt BEFORE opening a native
/// provider prompt, so a late prompt cannot sign somebody back in after logout.
/// This boundary does not select a backend or migrate the commuter UI by itself.
class CommuterSessionClient {
  CommuterSessionClient({
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
    if (metadata.app != 'commuter' ||
        scope.storageKey != store.scope.storageKey) {
      throw ArgumentError('Commuter session client and storage scopes differ');
    }
  }

  final TrotxiApiClient client;
  final ScopedTokenStore store;
  final ClientMetadata metadata;
  int _attempt = 0;
  Future<void> _localTail = Future.value();

  Future<T> _local<T>(Future<T> Function() action) {
    final result = _localTail.then((_) => action());
    _localTail =
        result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  static const _superseded =
      ApiException(0, 'Sign-in was superseded. Please retry.');

  void _current(int attempt, int generation) {
    if (attempt != _attempt || generation != store.generation)
      throw _superseded;
  }

  Future<Account> signInGoogle(
          {required Future<String> Function() obtainIdToken}) =>
      _signIn((check) async {
        final idToken = await obtainIdToken();
        check();
        if (idToken.trim().isEmpty)
          throw const ApiException(0, 'Google did not return an ID token.');
        return client.getPublicApi().signInGoogle(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              xTrotxiPlatform: metadata.platform,
              googleSignIn: GoogleSignIn((b) => b.idToken = idToken),
            );
      });

  Future<Account> signInApple(
          {required Future<AppleCredential> Function() obtainCredential}) =>
      _signIn((check) async {
        final credential = await obtainCredential();
        check();
        if (credential.idToken.trim().isEmpty)
          throw const ApiException(0, 'Apple did not return an ID token.');
        return client.getPublicApi().signInApple(
              xTrotxiClient: metadata.app,
              xTrotxiBuild: metadata.build,
              xTrotxiPlatform: metadata.platform,
              appleSignIn: AppleSignIn((b) => b
                ..idToken = credential.idToken
                ..nonce = credential.nonce
                ..authorizationCode = credential.authorizationCode
                ..displayName = credential.displayName),
            );
      });

  Future<Account> _signIn(
    Future<Response<TokensResponse>> Function(void Function() check) exchange,
  ) async {
    final attempt = ++_attempt;
    final generation = await _local(() async {
      if (attempt != _attempt) throw _superseded;
      return store.generation;
    });
    try {
      final response = await exchange(() => _current(attempt, generation));
      final tokens = response.data?.data;
      if (tokens == null ||
          tokens.account.role != AccountRoleEnum.commuter ||
          tokens.accessToken.isEmpty ||
          tokens.refreshToken.isEmpty) {
        throw const ApiException(
            502, 'Sign-in returned an invalid commuter session.');
      }
      return await _local(() async {
        _current(attempt, generation);
        if (!await store.saveTokensIfGenerationMatches(
          expectedGeneration: generation,
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        )) throw _superseded;
        if (attempt != _attempt) {
          await store.clearTokensIfRefreshMatches(tokens.refreshToken);
          throw _superseded;
        }
        return tokens.account;
      });
    } on DioException catch (error) {
      throw _unwrap(error);
    }
  }

  Future<Account?> restore() async {
    final attempt = _attempt;
    final generation = store.generation;
    if (await store.getAccessToken() == null) return null;
    // A secure-storage read may finish after logout or a replacement login.
    if (attempt != _attempt || generation != store.generation) return null;
    try {
      final response = await client.getSelfApi().getAccount(
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            xTrotxiPlatform: metadata.platform,
          );
      if (attempt != _attempt || generation != store.generation) return null;
      final account = response.data?.data;
      if (account == null || account.role != AccountRoleEnum.commuter) {
        throw const ApiException(403, 'This account is not a commuter.');
      }
      return account;
    } on DioException catch (error) {
      if (error.error is UnauthorizedException &&
          await store.getAccessToken() == null) return null;
      throw _unwrap(error);
    }
  }

  /// Local clearing must succeed before returning. False means remote logout
  /// was not acknowledged, not that a later login should be cleared.
  Future<bool> signOut() async {
    _attempt++;
    final SessionTokens? tokens;
    try {
      tokens = await _local(store.takeSession);
    } on FormatException {
      return false; // Corrupt local record was deleted; no remote credential.
    }
    if (tokens == null) return true;
    final headers = Map<String, dynamic>.from(client.dio.options.headers)
      ..removeWhere((key, _) => key.toLowerCase() == 'authorization');
    final detached = client.dio.clone(
      options: client.dio.options.copyWith(headers: headers),
      interceptors: Interceptors(),
    );
    detached.interceptors.add(MetadataInterceptor(metadata));
    final logout = TrotxiApiClient(
        dio: detached, serializers: client.serializers, interceptors: []);
    try {
      await logout.getPublicApi().logoutSession(
            xTrotxiClient: metadata.app,
            xTrotxiBuild: metadata.build,
            xTrotxiPlatform: metadata.platform,
            refreshInput:
                RefreshInput((b) => b.refreshToken = tokens!.refreshToken),
          );
      return true;
    } on DioException {
      return false;
    }
    // The cloned client shares the configured adapter; do not close it.
  }

  static Object _unwrap(DioException error) =>
      error.error is TrotxiException ? error.error! : error;
}
