import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:trotxi_client_next/commuter_data_client.dart';
import 'package:trotxi_client_next/commuter_checkout.dart';
import 'package:trotxi_client_next/commuter_session_client.dart';
import 'package:trotxi_client_next/scoped_token_store.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;

export 'package:trotxi_client_next/trotxi_client_next.dart'
    show
        Account,
        Session,
        TrotxiException,
        ApiException,
        OfflineException,
        UnauthorizedException,
        UpgradeRequiredException,
        RateLimitException;

enum CommuterStage { loading, signedOut, ready, failed }

/// The root replaces its navigator AND provider container on session change.
class CommuterApi extends CommuterDataClient {
  factory CommuterApi({
    required wire.TrotxiApiClientNext client,
    required ScopedTokenStore store,
    required wire.ClientMetadata metadata,
  }) => CommuterApi._(client, store, metadata, ValueNotifier(false));

  CommuterApi._(
    wire.TrotxiApiClientNext transport,
    ScopedTokenStore tokens,
    wire.ClientMetadata metadata,
    this.upgradeRequired,
  ) : auth = CommuterSessionClient(
        client: transport,
        store: tokens,
        metadata: metadata,
      ),
      super(
        client: transport,
        store: tokens,
        metadata: metadata,
        onUpgradeRequired: () => upgradeRequired.value = true,
      ) {
    store.onCleared = _cleared;
  }

  final CommuterSessionClient auth;
  final ValueNotifier<bool> upgradeRequired;
  final stage = ValueNotifier(CommuterStage.loading);
  final identityRevision = ValueNotifier(0);
  wire.Account? currentAccount;
  wire.TrotxiException? startupError;
  wire.Bootstrap? configuration;
  bool _closed = false;
  int _loadAttempt = 0;

  void _cleared() {
    if (_closed) return;
    _loadAttempt++;
    currentAccount = null;
    identityRevision.value++;
    stage.value = CommuterStage.signedOut;
  }

  Future<void> load() async {
    final attempt = ++_loadAttempt;
    stage.value = CommuterStage.loading;
    startupError = null;
    try {
      final response = await client.getPublicApi().getBootstrap();
      if (_closed || attempt != _loadAttempt) return;
      final config = response.data;
      if (config == null) {
        throw const wire.ApiException(502, 'Configuration was empty.');
      }
      configuration = config;
      for (final app in config.applications) {
        if (app.app.name == metadata.app &&
            app.platform.name == metadata.platform &&
            metadata.build < app.minSupportedBuild) {
          upgradeRequired.value = true;
          return;
        }
      }
      final restored = await auth.restore();
      if (_closed || attempt != _loadAttempt) return;
      currentAccount = restored;
      stage.value = restored == null
          ? CommuterStage.signedOut
          : CommuterStage.ready;
    } catch (error) {
      if (_closed || attempt != _loadAttempt) return;
      final mapped = error is DioException ? error.error : error;
      if (mapped is wire.UpgradeRequiredException) upgradeRequired.value = true;
      startupError = mapped is wire.TrotxiException
          ? mapped
          : const wire.ApiException(
              0,
              'Could not restore your session. Please retry.',
            );
      stage.value = CommuterStage.failed;
    }
  }

  Future<void> signInGoogle(Future<String> Function() obtainIdToken) async {
    _loadAttempt++; // An older restore must not replace this sign-in's result.
    final account = await auth.signInGoogle(obtainIdToken: obtainIdToken);
    if (_closed) return;
    currentAccount = account;
    identityRevision.value++;
    stage.value = CommuterStage.ready;
  }

  Future<bool> signOut() => auth.signOut();

  @override
  Future<void> eraseAccount() async {
    final generation = sessionGeneration;
    final id = currentAccount?.id ?? (await account()).id;
    ensureSession(generation);
    Object? localFailure;
    try {
      await super.eraseAccount();
    } on wire.ApiException catch (e) {
      if (e.code != 'erasure_accepted_local_clear_failed') rethrow;
      localFailure = e;
    }
    try {
      await CommuterCheckout.clearErasedAccount(this, id);
    } catch (_) {
      const error = wire.ApiException(
        0,
        'The server accepted erasure, but this device could not remove its checkout recovery data. Contact support.',
        code: 'erasure_accepted_local_cleanup_failed',
      );
      if (!_closed &&
          currentAccount == null &&
          store.generation == generation + 1) {
        startupError = error;
        stage.value = CommuterStage.failed;
      }
      throw error;
    }
    if (localFailure != null) throw localFailure;
  }

  @override
  void dispose() {
    _closed = true;
    _loadAttempt++;
    store.onCleared = null;
    super.dispose();
    stage.dispose();
    identityRevision.dispose();
    upgradeRequired.dispose();
  }
}
