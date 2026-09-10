/// What the sign-in screen is currently showing.
///
/// The prototype draws four distinct outcomes for one form, and they are not
/// interchangeable: a wrong PIN invites another try, a lock does not, and a
/// suspension is not something the driver can resolve at all. Modelling them as
/// one enum keeps the screen from deciding that from a string it parsed.
enum SignInStatus {
  /// Nothing entered yet, or the driver is editing after a failure.
  idle,

  /// A request is in flight. The button is disabled and the form is locked.
  submitting,

  /// Wrong code or PIN (frame 04). The driver tries again.
  invalidCredentials,

  /// Too many wrong PINs (423). Retrying will not help until it lifts.
  locked,

  /// Operations has suspended the account (403). Nothing to retry.
  suspended,

  /// No connection. Worth its own state because a depot's signal is the most
  /// likely reason sign-in fails, and "check your PIN" would be a lie.
  offline,

  /// Anything else the server said.
  failed,
}

/// The sign-in form's state, including why it last failed.
class SignInState {
  const SignInState({this.status = SignInStatus.idle, this.message, this.retryAfter});

  final SignInStatus status;

  /// What to show the driver, when the status alone is not enough.
  final String? message;

  /// How long the lock has left, for [SignInStatus.locked].
  final Duration? retryAfter;

  bool get isSubmitting => status == SignInStatus.submitting;

  /// Whether the failure is one another attempt could fix.
  bool get isRetryable =>
      status != SignInStatus.locked && status != SignInStatus.suspended;

  /// Whether the PIN boxes should be painted as rejected.
  bool get highlightsPin =>
      status == SignInStatus.invalidCredentials || status == SignInStatus.locked;

  static const idle = SignInState();
  static const submitting = SignInState(status: SignInStatus.submitting);
}
