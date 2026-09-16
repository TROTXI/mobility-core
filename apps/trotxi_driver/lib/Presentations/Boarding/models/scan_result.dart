/// What a boarding attempt came back as.
///
/// View outcomes, not a copy of the wire enum. The replacement returns a
/// reservation-keyed result or a stable error code. Its shared invalid-proof
/// code does not distinguish malformed, expired, foreign or ambiguous proofs;
/// the repository must not invent those distinctions from an HTTP status.
enum BoardingOutcome {
  /// Boarded, ride debited.
  ok,

  /// QR proof refused; may be expired, malformed or for another trip.
  invalid,

  /// Typed with nobody selected, and no seat on this run holds that code
  /// (#241). Distinct from [invalid] because the instruction differs: a forged
  /// QR is a rider problem, a code nobody holds is usually four characters
  /// misheard across a noisy door.
  codeNotFound,

  /// Typed against a rider already picked off the manifest, and it is not
  /// their code. Distinct again: the driver knows who they mean, so the useful
  /// next step is to re-read the code rather than to go looking for a person.
  codeMismatch,

  /// A real pass, but past its short life. The rider refreshes and shows again.
  expired,

  /// Already used. A screenshot being passed around dies here.
  reused,

  /// Correct code, but this seat was already boarded. Not an error.
  alreadyBoarded,

  /// The rider has no confirmed seat on this run.
  noReservation,

  /// This driver is not the one the run is assigned to.
  forbidden,

  /// Two riders on this run hold the same code (#241). Vanishingly unlikely,
  /// and refused rather than guessed: picking one would spend the wrong
  /// rider's ride and leave the right one at the door.
  ambiguous,

  /// Could not reach the server.
  offline,

  /// The driver's session is gone (expired, or revoked by an operations PIN
  /// reset). Kept separate from [invalid] because the two are opposite
  /// instructions: one says the rider's pass is bad, the other says the
  /// DRIVER has to sign in again. Telling a driver a genuine pass is forged is
  /// how a paying rider gets turned away at the door.
  sessionExpired,

  /// The server failed in some other way. Also kept out of [invalid]: an
  /// outage is not evidence about a rider's pass.
  failed,
}

/// A boarding attempt's outcome, with whoever it was for.
class BoardingResult {
  const BoardingResult({
    required this.outcome,
    this.riderName,
    this.reservationId,
    this.deducted = false,
    this.failureMessage,
  });

  final BoardingOutcome outcome;

  /// Optional view label. The replacement resolves it from the manifest using
  /// reservationId, not from a user ID or a preselected rider.
  final String? riderName;
  final String? reservationId;

  /// A reviewed business refusal, without guessing that the seat is absent.
  final String? failureMessage;

  /// Whether this attempt actually consumed a ride.
  final bool deducted;

  bool get isAccepted => outcome == BoardingOutcome.ok;

  /// The replacement reports expired and malformed QR proofs with the same
  /// code. A refreshed pass must therefore be retryable; reused is not.
  bool get isRetryable =>
      outcome == BoardingOutcome.invalid ||
      outcome == BoardingOutcome.expired ||
      outcome == BoardingOutcome.offline ||
      outcome == BoardingOutcome.failed;

  /// Whether the driver should go and find the person on the manifest instead.
  bool get needsManifest =>
      outcome == BoardingOutcome.ambiguous ||
      outcome == BoardingOutcome.codeNotFound ||
      outcome == BoardingOutcome.noReservation;

  /// The headline the driver reads across a vehicle.
  String get title => switch (outcome) {
    BoardingOutcome.ok => 'Boarded',
    BoardingOutcome.invalid => 'Pass not accepted',
    BoardingOutcome.codeNotFound => 'Code not recognised',
    BoardingOutcome.codeMismatch => 'Not their code',
    BoardingOutcome.expired => 'Pass expired',
    BoardingOutcome.reused => 'Already scanned',
    BoardingOutcome.alreadyBoarded => 'Already boarded',
    BoardingOutcome.noReservation => 'No reservation found',
    BoardingOutcome.forbidden => 'Run unavailable',
    BoardingOutcome.ambiguous => 'Two riders, one code',
    BoardingOutcome.offline => 'No connection',
    BoardingOutcome.sessionExpired => 'Signed out',
    BoardingOutcome.failed => 'Could not board',
  };

  /// What to do about it.
  String get detail =>
      failureMessage ??
      switch (outcome) {
        BoardingOutcome.ok => 'Ride counted. Wave them on.',
        BoardingOutcome.invalid =>
          'Ask the rider to refresh their pass. If it still fails, check the manifest and use code or photo boarding.',
        BoardingOutcome.codeNotFound =>
          'This code could not identify one reservation on this run. Ask them to read it again — or find '
              'them on the manifest and board them from there.',
        BoardingOutcome.codeMismatch =>
          'That is not this rider’s code. Ask them to read it again.',
        BoardingOutcome.expired =>
          'Passes rotate every minute. Ask the rider to refresh and show it again.',
        BoardingOutcome.reused =>
          'This pass has already been used on this run. Check the manifest before boarding.',
        BoardingOutcome.alreadyBoarded =>
          'This seat is already aboard. Nothing to do.',
        BoardingOutcome.noReservation =>
          'This rider has no confirmed seat on this run. Check the manifest.',
        BoardingOutcome.forbidden =>
          'This run is not available to you. Reload your assigned runs or contact operations.',
        BoardingOutcome.ambiguous =>
          'Two seats on this run hold that code, so we will not guess which. Find '
              'the rider on the manifest and board them there.',
        BoardingOutcome.offline =>
          'Boarding needs a connection. Try again once you have signal.',
        BoardingOutcome.sessionExpired =>
          'Your session has ended, so this could not be checked. Sign in again, then '
              'check their pass again.',
        BoardingOutcome.failed =>
          'Boarding could not be completed. Refresh the manifest and retry, or contact operations if it keeps failing.',
      };
}

/// What marking a rider a no-show came back as (#227).
///
/// Deliberately not folded into [BoardingOutcome]. The two actions sit side by
/// side on the same manifest row and mean opposite things, and a shared enum
/// would let a boarding message surface on a no-show — at a door, with a queue,
/// that is the kind of mix-up that strands a paying rider.
enum NoShowResult {
  /// Recorded. Idempotent: marking twice reports this both times.
  marked,

  /// The rider is already aboard, so there is nothing to mark. Refused rather
  /// than reversed — someone verified onto the vehicle is on it.
  alreadyBoarded,

  /// This driver is not the one the run is assigned to.
  forbidden,

  /// Could not reach the server.
  offline,

  /// Something else went wrong.
  failed;

  /// What the driver reads.
  String get message => switch (this) {
    NoShowResult.marked => 'Marked as a no-show.',
    NoShowResult.alreadyBoarded =>
      'This rider is already aboard, so they cannot be a no-show.',
    NoShowResult.forbidden => 'This run is assigned to another driver.',
    NoShowResult.offline => 'No connection. Try again once you have signal.',
    NoShowResult.failed => 'Could not mark that. Try again.',
  };
}
