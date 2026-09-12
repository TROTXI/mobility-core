import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart';

/// The signed-in driver, as the app needs it after sign-in.
class DriverSession {
  const DriverSession({
    required this.driverId,
    required this.fullName,
    required this.mustChangePin,
  });

  final String driverId;
  final String fullName;

  /// True while the driver is still on the PIN operations issued. The flow
  /// sends them to change it before anything else.
  final bool mustChangePin;
}

/// Sign-in, PIN rotation and sign-out for the driver app.
///
/// Wraps the generated client so screens never touch Dio or built_value. Errors
/// arrive as the typed exceptions from `trotxi_client`, which the sign-in screen
/// turns into the states the prototype draws: wrong PIN, locked, suspended.
class DriverAuthRepository {
  DriverAuthRepository({required this._client, required this._tokenStore});

  final TrotxiApiClient _client;
  final TokenStore _tokenStore;

  /// Whether a session is already stored on this device.
  ///
  /// Only asks whether a token exists, not whether it still works. The app
  /// opens on Today and lets the first real call fail if the session has since
  /// been revoked, rather than holding a driver on a splash screen while a
  /// depot's connection decides whether it feels like working.
  ///
  /// @returns true when a stored access token is present.
  Future<bool> hasStoredSession() async {
    final token = await _tokenStore.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Who this device is signed in as.
  ///
  /// Needed because a restored session only proves a token EXISTS; it carries
  /// no name. Without this the profile screen greets a driver who has been
  /// using the app all shift as "Driver", which reads like the app has lost
  /// track of them.
  ///
  /// @returns the session, or null when the stored token is no longer good.
  Future<DriverSession?> currentDriver() async {
    try {
      final response = await _client.getAuthApi().meGet();
      final user = response.data;
      if (user == null) return null;
      return DriverSession(
        // The user id, not the driver id: /me knows nothing about the fleet
        // record. Nothing on the profile screen needs the driver id, and
        // inventing one here would be a lie waiting to be used.
        driverId: user.id,
        fullName: user.displayName,
        // A restored session is by definition past the forced change: the
        // driver could not have reached this state without clearing it.
        mustChangePin: false,
      );
    } on DioException {
      return null;
    }
  }

  /// Sign in with the code and PIN operations issued.
  ///
  /// @param driverCode - the code as typed; the server normalises case and the
  ///   `DR-` prefix, so it is sent through as entered.
  /// @param pin - the six-digit PIN.
  /// @param rememberDevice - true only on the driver's own handset. Left false
  ///   the session lasts a shift, which is what a shared depot phone should get.
  /// @returns the session.
  /// @throws InvalidCredentialsException on a wrong code or PIN.
  /// @throws CredentialLockedException when too many PINs have been tried.
  /// @throws AccountSuspendedException when operations has suspended the account.
  /// @throws OfflineException when the depot has no connection.
  Future<DriverSession> signIn({
    required String driverCode,
    required String pin,
    required bool rememberDevice,
  }) async {
    try {
      final response = await _client.getAuthApi().authDriverPost(
        authDriverPostRequest: AuthDriverPostRequest(
          (b) => b
            ..driverCode = driverCode
            ..pin = pin
            ..rememberDevice = rememberDevice,
        ),
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException(200, 'Sign-in returned no session.');
      }

      // Stored before returning: every call the next screen makes goes through
      // the auth interceptor, which reads the token back out of here.
      await _tokenStore.saveTokens(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
      );

      return DriverSession(
        driverId: data.driver.id,
        fullName: data.driver.fullName,
        mustChangePin: data.mustChangePin,
      );
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Replace the PIN. The server revokes every other session on the account.
  ///
  /// @param currentPin - the PIN in use.
  /// @param newPin - the replacement.
  /// @throws InvalidCredentialsException when the current PIN is wrong.
  /// @throws ApiException with 400 when the new PIN is a repeat or a run.
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      await _client.getAuthApi().authDriverPinPost(
        authDriverPinPostRequest: AuthDriverPinPostRequest(
          (b) => b
            ..currentPin = currentPin
            ..newPin = newPin,
        ),
      );
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Forget this device's session.
  ///
  /// Clears local tokens whatever the server says. "Not my account" and an
  /// explicit sign-out both have to leave the handset clean, and a depot with no
  /// signal is exactly when someone hands the phone to the next driver.
  Future<void> signOut() async {
    final refreshToken = await _tokenStore.getRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // The generated client reuses the refresh request model here: the
        // logout body is the same single field.
        await _client.getAuthApi().authLogoutPost(
          authRefreshPostRequest: AuthRefreshPostRequest(
            (b) => b..refreshToken = refreshToken,
          ),
        );
      }
    } on DioException {
      // Best effort. The local clear below is the part that matters here.
    } finally {
      await _tokenStore.clearTokens();
    }
  }

  /// Recover the typed exception the interceptors attached, or fall back to the
  /// raw Dio failure.
  ///
  /// @param err - the caught Dio exception.
  /// @returns the exception to surface to the screen.
  Object _unwrap(DioException err) {
    final inner = err.error;
    return inner is TrotxiException ? inner : err;
  }
}
