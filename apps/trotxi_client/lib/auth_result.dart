import 'package:dio/dio.dart';

import 'package:trotxi_api_client/trotxi_api_client.dart';

/// Outcome of an auth attempt (sign-in or refresh). Modeled as a closed
/// set of subclasses so the UI can switch on it exhaustively instead of
/// catching exceptions and guessing what went wrong.
///
/// Maps directly to what auth.md documents:
/// - 401 on /auth/google → invalid Google ID token → [AuthFailure.invalidCredential]
/// - 401 on /auth/refresh → expired/revoked/reused refresh token → [AuthFailure.sessionExpired]
/// - 429 → rate limited (10/min/IP on both endpoints) → [AuthFailure.rateLimited]
/// - 503 → GOOGLE_CLIENT_ID unset in production, sign-in not configured → [AuthFailure.serviceUnavailable]
/// - no response at all → [AuthFailure.network]
/// - user backed out of the native Google sheet → [AuthCancelled] (this one
///   doesn't come from the API at all — it's thrown by google_sign_in
///   *before* authGooglePost is ever called)
 class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);
  final MeGet200Response user;

  /// True when this looks like a first-run account (phone not yet on
  /// file). Once a profile-update endpoint exists on the backend, the
  /// first-run screen should call it to fill this in.
  bool get needsProfileCompletion => user.phone == null;
}

class AuthCancelled extends AuthResult {
  const AuthCancelled();
}

enum AuthFailureReason {
  invalidCredential,
  sessionExpired,
  rateLimited,
  serviceUnavailable,
  network,
  unknown,
}

class AuthFailure extends AuthResult {
  const AuthFailure(this.reason, {this.retryAfter});

  final AuthFailureReason reason;

  /// Populated from the `Retry-After` header when [reason] is
  /// [AuthFailureReason.rateLimited].
  final Duration? retryAfter;

  /// Builds an [AuthFailure] from a DioException thrown by an
  /// AuthApi call, per the status codes documented in auth.md.
  factory AuthFailure.fromDioException(DioException e, {bool isRefresh = false}) {
    final statusCode = e.response?.statusCode;

    if (statusCode == null) {
      return const AuthFailure(AuthFailureReason.network);
    }

    switch (statusCode) {
      case 401:
        return AuthFailure(
          isRefresh
              ? AuthFailureReason.sessionExpired
              : AuthFailureReason.invalidCredential,
        );
      case 429:
        final retryAfterHeader = e.response?.headers.value('retry-after');
        final seconds = int.tryParse(retryAfterHeader ?? '');
        return AuthFailure(
          AuthFailureReason.rateLimited,
          retryAfter: seconds == null ? null : Duration(seconds: seconds),
        );
      case 503:
        return const AuthFailure(AuthFailureReason.serviceUnavailable);
      default:
        return const AuthFailure(AuthFailureReason.unknown);
    }
  }
}