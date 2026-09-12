// Boarding outcomes (#41 frames 27 to 34). The distinctions are the whole
// point: a driver at a vehicle door acts differently on each one, and the
// dangerous failure is telling them a genuine pass is forged.

import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';

void main() {
  test('only the API saying so makes a pass invalid', () {
    // Our own failures must never read as an accusation about the rider.
    for (final outcome in [
      BoardingOutcome.sessionExpired,
      BoardingOutcome.failed,
      BoardingOutcome.offline,
    ]) {
      expect(
        BoardingResult(outcome: outcome).title,
        isNot('Pass not accepted'),
        reason: '$outcome is our problem, not the rider\'s',
      );
    }
    expect(
      const BoardingResult(outcome: BoardingOutcome.invalid).title,
      'Pass not accepted',
    );
  });

  test(
    'a dead session tells the driver to sign in, not the rider to go away',
    () {
      final result = const BoardingResult(
        outcome: BoardingOutcome.sessionExpired,
      );
      expect(result.detail, contains('Sign in again'));
      expect(result.detail, contains('pass is fine'));
      expect(result.isAccepted, isFalse);
    },
  );

  test('only outcomes another attempt could fix are retryable', () {
    // Offering "try again" on a forged or already-used pass wastes time at a
    // door with a queue behind it.
    expect(
      const BoardingResult(outcome: BoardingOutcome.expired).isRetryable,
      isTrue,
    );
    expect(
      const BoardingResult(outcome: BoardingOutcome.offline).isRetryable,
      isTrue,
    );
    expect(
      const BoardingResult(outcome: BoardingOutcome.failed).isRetryable,
      isTrue,
    );

    expect(
      const BoardingResult(outcome: BoardingOutcome.invalid).isRetryable,
      isFalse,
    );
    expect(
      const BoardingResult(outcome: BoardingOutcome.reused).isRetryable,
      isFalse,
    );
    expect(
      const BoardingResult(outcome: BoardingOutcome.forbidden).isRetryable,
      isFalse,
    );
  });

  test('already boarded is not an error', () {
    // The rider is aboard, which is the outcome everyone wanted.
    final result = const BoardingResult(
      outcome: BoardingOutcome.alreadyBoarded,
    );
    expect(result.detail, contains('Nothing to do'));
  });

  test('every outcome says something, so no path ends in a blank screen', () {
    for (final outcome in BoardingOutcome.values) {
      final result = BoardingResult(outcome: outcome);
      expect(result.title, isNotEmpty);
      expect(result.detail, isNotEmpty);
    }
  });

  group('a code is not a QR pass (#241)', () {
    test('a code nobody holds says so, and points at the manifest', () {
      const result = BoardingResult(outcome: BoardingOutcome.codeNotFound);

      expect(result.title, 'Code not recognised');
      // Not "this is not a valid pass" — at a door that reads as an accusation
      // about the rider, when it is almost always four characters misheard.
      expect(result.detail, contains('read it again'));
      expect(result.needsManifest, isTrue);
      expect(result.isAccepted, isFalse);
    });

    test('a wrong code for a named rider does not send the driver looking', () {
      const result = BoardingResult(outcome: BoardingOutcome.codeMismatch);

      expect(result.title, 'Not their code');
      // The driver already knows who they mean, so the manifest is no help.
      expect(result.needsManifest, isFalse);
    });

    test('two seats holding one code is refused, not guessed', () {
      const result = BoardingResult(outcome: BoardingOutcome.ambiguous);

      expect(result.title, 'Two riders, one code');
      expect(result.detail, contains('will not guess'));
      expect(result.needsManifest, isTrue);
      expect(result.isAccepted, isFalse);
    });
  });
}
