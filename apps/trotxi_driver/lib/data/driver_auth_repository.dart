import 'package:trotxi_client_next/driver_session_client.dart';
import 'package:trotxi_client_next/scoped_token_store.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';

/// The signed-in driver, as the app needs it after sign-in.
class DriverSession {
  const DriverSession({
    required this.driverId,
    required this.fullName,
    required this.mustChangePin,
    this.driverCode,
    this.accountId,
  });

  final String? driverId;
  final String? accountId;
  final String fullName;

  /// The operator-facing code that was authenticated for this session.
  ///
  /// `/v1/me` does not return it, so restored sessions leave this null
  /// rather than showing the internal user UUID as if it were a driver code.
  final String? driverCode;

  /// Credential metadata from sign-in, unknown after account-only restore.
  /// Operator-managed recovery remains the UI; this is not an admission gate.
  final bool? mustChangePin;
}

/// Sign-in, PIN rotation and sign-out for the driver app.
///
/// Wraps the generated client so screens never touch Dio or built_value. Errors
/// arrive as typed replacement-client exceptions, which the sign-in screen
/// turns into the states the prototype draws: wrong PIN, locked, suspended.
class DriverAuthRepository {
  DriverAuthRepository({
    required DriverApi client,
    required ScopedTokenStore tokenStore,
  }) : _session = DriverSessionClient(
         client: client.client,
         store: tokenStore,
         metadata: client.metadata,
       );
  final DriverSessionClient _session;
  Future<bool> hasStoredSession() => _session.hasStoredSession();
  Future<DriverSession?> currentDriver() async {
    final identity = await _session.restore();
    return identity == null ? null : _view(identity);
  }

  Future<DriverSession> signIn({
    required String driverCode,
    required String pin,
    required bool rememberDevice,
  }) async => _view(
    await _session.signIn(
      code: driverCode,
      pin: pin,
      ownDevice: rememberDevice,
    ),
  );
  Future<void> changePin({
    required String currentPin,
    required String newPin,
    required String idempotencyKey,
  }) => _session.changePin(
    currentPin: currentPin,
    newPin: newPin,
    idempotencyKey: idempotencyKey,
  );
  Future<void> signOut() async {
    await _session.signOut();
  }

  DriverSession _view(DriverIdentity identity) => DriverSession(
    accountId: identity.accountId,
    driverId: identity.fleetDriverId,
    fullName: identity.name,
    driverCode: identity.code,
    mustChangePin: identity.mustChangePin,
  );
}
