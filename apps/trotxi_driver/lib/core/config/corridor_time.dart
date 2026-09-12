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
  static String day(DateTime at) => _format(at.toUtc());

  /// Today, in the corridor's clock, as a date with no time on it.
  ///
  /// What "today" means to this app is the UTC calendar day, because that is
  /// the day `/me/trips` groups runs by. On a device west of UTC in the evening
  /// the corridor has already rolled over, so the local date and the corridor
  /// date are different days — and a screen that fetches one and labels it with
  /// the other tells the driver their Friday runs are on Thursday.
  ///
  /// Returned as a plain date so it can be formatted for display, compared
  /// against calendar cells, and passed to [calendarDay] without any of them
  /// converting it again.
  ///
  /// @returns the corridor's current calendar day, at midnight.
  static DateTime todayDate() {
    final utc = DateTime.now().toUtc();
    return DateTime(utc.year, utc.month, utc.day);
  }

  /// A date the driver picked off a calendar, as `YYYY-MM-DD`.
  ///
  /// Deliberately does NOT convert. A calendar cell or a date picker hands back
  /// a local midnight, and the year, month and day on it ARE the answer — the
  /// driver pointed at them. Running [day] over one would convert an instant
  /// nobody meant: east of UTC, local midnight on the 24th is 22:00 on the
  /// 23rd, and a leave request for Christmas Eve would be filed for the day
  /// before.
  ///
  /// The two are separate functions rather than one because the difference is
  /// invisible in Accra, where the app runs, and only shows up on a developer's
  /// machine somewhere else — which is precisely how this class of mistake got
  /// into the app the first time.
  ///
  /// @param picked - a date chosen on a calendar.
  /// @returns that date.
  static String calendarDay(DateTime picked) => _format(picked);

  /// Format year, month and day with no conversion of any kind.
  ///
  /// @param at - the date to read the fields off.
  /// @returns `YYYY-MM-DD`.
  static String _format(DateTime at) =>
      '${at.year.toString().padLeft(4, '0')}-'
      '${at.month.toString().padLeft(2, '0')}-'
      '${at.day.toString().padLeft(2, '0')}';
}
