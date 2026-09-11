import 'package:intl/intl.dart';

/// Formats run times in the corridor's own clock.
///
/// Deliberately NOT the device's local time. `GET /me/trips?date=` groups runs
/// by their UTC calendar day, so rendering in device-local time lets one day's
/// runs straddle two local days: on a UTC-7 machine the 06:30 run shows as
/// 23:30 and sorts ahead of the 17:30 one, which reads as scrambled ordering
/// rather than as a timezone.
///
/// Ghana is UTC+0 all year and has no daylight saving, so for a driver standing
/// in Accra with their phone on Accra time this IS their local clock. The two
/// only diverge on a developer's machine somewhere else, which is exactly where
/// the inconsistency was found.
abstract final class CorridorTime {
  static final _hhmm = DateFormat('HH:mm');

  /// A run's departure time as the driver reads it off the board.
  ///
  /// @param at - the scheduled instant.
  /// @returns `HH:mm` in the corridor's clock.
  static String hhmm(DateTime at) => _hhmm.format(at.toUtc());

  /// The corridor's calendar day for an instant, as `YYYY-MM-DD`.
  ///
  /// Matches what the API filters on, so what is asked for and what is shown
  /// agree.
  ///
  /// @param at - the instant.
  /// @returns the corridor's day.
  static String day(DateTime at) {
    final utc = at.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }
}
