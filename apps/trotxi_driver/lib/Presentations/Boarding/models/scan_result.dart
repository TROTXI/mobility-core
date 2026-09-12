/// What a boarding attempt came back as.
///
/// The API answers `ok | invalid | expired | reused` for a scan and
/// `ok | invalid | not_found | already_boarded` for a code, and the prototype
/// draws each differently because each means something different to a driver
/// standing at a door with a queue behind them. Collapsing them into
/// "accepted / rejected" throws away exactly the information that tells them
/// what to do next.
enum BoardingOutcome {
  /// Boarded, ride debited.
  ok,

  /// Not a genuine pass, or the wrong code.
  invalid,

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
    this.riderId,
    this.deducted = false,
  });

  final BoardingOutcome outcome;

  /// Null when the pass was forged or unreadable, which is itself the signal:
  /// there is nobody to show the driver.
  final String? riderName;
  final String? riderId;

  /// Whether this attempt actually consumed a ride.
  final bool deducted;

  bool get isAccepted => outcome == BoardingOutcome.ok;

  /// Whether showing the pass again could work. "Expired" can; "invalid" and
  /// "reused" cannot, and offering a retry on those wastes everyone's time.
  bool get isRetryable =>
      outcome == BoardingOutcome.expired ||
      outcome == BoardingOutcome.offline ||
      outcome == BoardingOutcome.failed;

  /// The headline the driver reads across a vehicle.
  String get title => switch (outcome) {
    BoardingOutcome.ok => 'Boarded',
    BoardingOutcome.invalid => 'Pass not accepted',
    BoardingOutcome.expired => 'Pass expired',
    BoardingOutcome.reused => 'Already scanned',
    BoardingOutcome.alreadyBoarded => 'Already boarded',
    BoardingOutcome.noReservation => 'No reservation found',
    BoardingOutcome.forbidden => 'Not your run',
    BoardingOutcome.offline => 'No connection',
    BoardingOutcome.sessionExpired => 'Signed out',
    BoardingOutcome.failed => 'Could not board',
  };

  /// What to do about it.
  String get detail => switch (outcome) {
    BoardingOutcome.ok => 'Ride counted. Wave them on.',
    BoardingOutcome.invalid =>
      'This is not a valid pass. Check the manifest and board them by code instead.',
    BoardingOutcome.expired =>
      'Passes rotate every minute. Ask the rider to refresh and show it again.',
    BoardingOutcome.reused =>
      'This pass has already been used on this run. Check the manifest before boarding.',
    BoardingOutcome.alreadyBoarded =>
      'This seat is already aboard. Nothing to do.',
    BoardingOutcome.noReservation =>
      'This rider has no confirmed seat on this run. Check the manifest.',
    BoardingOutcome.forbidden =>
      'This run is assigned to another driver, so you cannot board its riders.',
    BoardingOutcome.offline =>
      'Boarding needs a connection. Try again once you have signal.',
    BoardingOutcome.sessionExpired =>
      'Your session has ended, so this could not be checked. Sign in again, then '
          'board this rider. Their pass is fine.',
    BoardingOutcome.failed =>
      'Something went wrong our end, so this could not be checked. Try again, and '
          'board by code if it keeps failing.',
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
