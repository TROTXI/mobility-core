import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:trotxi_map/trotxi_map.dart';

StopEta _eta({double metres = 1200, double seconds = 240}) => StopEta(
  seq: 3,
  name: 'Shiashie',
  distanceMeters: metres,
  etaSeconds: seconds,
  basis: 'observed',
);

void main() {
  test('fallback estimates are explicitly labelled', () {
    expect(
      const StopEta(
        seq: 0,
        name: 'Stop',
        distanceMeters: 50,
        etaSeconds: 90,
      ).summary,
      contains('(fallback)'),
    );
  });

  test('predictions expire locally even when no new response arrives', () {
    final fix = VehicleFix(
      position: const LatLng(5.6, -0.2),
      recordedAt: DateTime.now(),
      receivedLocallyAt: DateTime.now().subtract(const Duration(seconds: 2)),
      ageAtReceipt: const Duration(seconds: 119),
      etas: [_eta()],
    );
    expect(fix.etas, isEmpty);
    expect(fix.position.latitude, 5.6);
  });
  test('reads as the file sets it', () {
    expect(_eta().summary, '1.2 km · ~4 min');
  });

  test('under a kilometre is metres, not 0.4 km', () {
    // A driver reading "0.4 km" at a kerb is doing arithmetic they should not
    // have to; the stop is 380 metres away.
    expect(_eta(metres: 380).summary, '380 m · ~4 min');
  });

  test('under a minute says arriving rather than ~0 min', () {
    // Zero would send a driver looking up expecting to already be there.
    expect(_eta(metres: 40, seconds: 20).summary, '40 m · arriving');
  });

  test('no ETAs means no next stop, not a guess at one', () {
    // The API empties this when the corridor has fewer than two stops or the
    // van is past the last one. Both are ordinary and neither is an error.
    final fix = VehicleFix(
      position: const LatLng(5.6, -0.2),
      recordedAt: DateTime.now(),
    );
    expect(fix.nextStop, isNull);
  });

  test('the next stop is the first one still ahead', () {
    final fix = VehicleFix(
      position: const LatLng(5.6, -0.2),
      recordedAt: DateTime.now(),
      etas: [_eta(), _eta(metres: 4000, seconds: 900)],
    );
    expect(fix.nextStop?.summary, '1.2 km · ~4 min');
  });
}
