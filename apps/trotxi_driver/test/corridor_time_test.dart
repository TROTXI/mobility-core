import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';

/// The timezone trap, pinned down.
///
/// This app has been bitten by it twice: once when Today asked for a
/// device-local date and got an empty day back, and once when a run's ordering
/// scrambled because it was fetched in UTC and rendered in local time. Both
/// were invisible in Accra, which is exactly why they need tests.
void main() {
  group('an instant from the server', () {
    test('reads in the corridor clock, not the device clock', () {
      // 06:30 UTC. On a machine west of UTC this is the previous evening
      // locally, and rendering it that way is what scrambled the run order.
      final at = DateTime.utc(2026, 10, 15, 6, 30);
      expect(CorridorTime.hhmm(at), '06:30');
      expect(CorridorTime.day(at), '2026-10-15');
    });

    test('a late-evening run stays on its own corridor day', () {
      final at = DateTime.utc(2026, 10, 31, 23, 30);
      expect(CorridorTime.day(at), '2026-10-31');
    });

    test('converts a local instant to the corridor day the API filters on', () {
      // Whatever the device zone, the answer is the UTC day, because that is
      // what `(scheduled_at AT TIME ZONE 'UTC')::date` compares.
      final at = DateTime.utc(2026, 10, 15, 6, 30).toLocal();
      expect(CorridorTime.day(at), '2026-10-15');
    });
  });

  group('today, in the corridor clock', () {
    test('is the UTC calendar day, not the device one', () {
      final utcNow = DateTime.now().toUtc();
      final today = CorridorTime.todayDate();

      expect(today.year, utcNow.year);
      expect(today.month, utcNow.month);
      expect(today.day, utcNow.day);
    });

    test('carries no time, so it compares cleanly against calendar cells', () {
      final today = CorridorTime.todayDate();
      expect(today.hour, 0);
      expect(today.minute, 0);
    });

    test('round-trips through calendarDay to the day the API filters on', () {
      // The whole point: what Today fetches and what Schedule preselects have
      // to be the same day. West of UTC in the evening the corridor has already
      // rolled over, and using the local date would open the driver on a day
      // with no work while their next run sat on the cell beside it.
      expect(
        CorridorTime.calendarDay(CorridorTime.todayDate()),
        CorridorTime.day(DateTime.now()),
      );
    });
  });

  group('a date the driver picked', () {
    test('is taken exactly as chosen, with no conversion', () {
      // A calendar cell or a date picker hands back a LOCAL midnight. Converting
      // it would move the day east of UTC: local midnight on the 24th is 22:00
      // on the 23rd, so leave for Christmas Eve would be filed for the 23rd.
      final picked = DateTime(2026, 12, 24);
      expect(CorridorTime.calendarDay(picked), '2026-12-24');
    });

    test('pads a single-digit month and day', () {
      expect(CorridorTime.calendarDay(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('is the answer day() cannot be trusted to give', () {
      // The whole reason the two are separate functions.
      //
      // A local midnight converted to UTC moves BACKWARDS a day east of UTC
      // (Nairobi's 00:00 on the 24th is 21:00 on the 23rd) and stays put west
      // of it. So day() happens to agree on this machine or it does not,
      // depending on where the machine is — and that is exactly the property
      // that lets the bug through review in Accra and surface in Nairobi.
      //
      // calendarDay() has no such dependency, which is what this asserts.
      final picked = DateTime(2026, 12, 24);
      expect(CorridorTime.calendarDay(picked), '2026-12-24');

      final offset = picked.timeZoneOffset;
      if (offset > Duration.zero) {
        expect(
          CorridorTime.day(picked),
          '2026-12-23',
          reason: 'east of UTC a picked date goes through day() as the day before',
        );
      } else {
        expect(CorridorTime.day(picked), '2026-12-24');
      }
    });
  });
}
