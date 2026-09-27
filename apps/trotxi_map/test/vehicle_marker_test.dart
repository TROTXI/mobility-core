import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_map/trotxi_map.dart';

class FakeMap implements MapLibreMapController {
  int adds = 0, updates = 0, removes = 0;
  CircleOptions? last;
  @override
  Future<Circle> addCircle(
    CircleOptions options, [
    Map<String, dynamic>? data,
  ]) async {
    adds++;
    last = options;
    return Circle('bus', options, data);
  }

  @override
  Future<void> updateCircle(Circle circle, CircleOptions changes) async {
    updates++;
    last = changes;
  }

  @override
  Future<void> removeCircle(Circle circle) async {
    removes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final first = DateTime.utc(2026, 9, 19, 9);
  const depot = LatLng(5.60, -0.20);
  const pickup = LatLng(5.60, -0.199);

  test(
    'approach moves between confirmed fixes and never predicts beyond the last fix',
    () {
      final motion = VehicleMotion();
      motion.accept(depot, first, first, fresh: true);
      motion.accept(
        pickup,
        first.add(const Duration(seconds: 5)),
        first.add(const Duration(seconds: 5)),
        fresh: true,
      );
      final halfway = motion.at(
        first.add(const Duration(seconds: 5, milliseconds: 400)),
      )!;
      expect(halfway.longitude, closeTo(-0.1995, .00001));
      expect(motion.at(first.add(const Duration(seconds: 6))), pickup);
      expect(motion.at(first.add(const Duration(seconds: 30))), pickup);
    },
  );

  test(
    'stationary, stale, old and implausibly distant fixes cannot create motion',
    () {
      final motion = VehicleMotion();
      motion.accept(depot, first, first, fresh: true);
      motion.accept(
        depot,
        first.add(const Duration(seconds: 5)),
        first.add(const Duration(seconds: 5)),
        fresh: true,
      );
      expect(motion.moving, false);
      motion.accept(
        pickup,
        first.add(const Duration(seconds: 10)),
        first.add(const Duration(seconds: 10)),
        fresh: false,
      );
      expect(motion.at(first.add(const Duration(seconds: 10))), pickup);
      expect(motion.moving, false);
      motion.accept(
        depot,
        first.add(const Duration(seconds: 9)),
        first.add(const Duration(seconds: 11)),
        fresh: true,
      );
      expect(motion.position, pickup);
      motion.accept(
        const LatLng(5.6, -0.18),
        first.add(const Duration(seconds: 15)),
        first.add(const Duration(seconds: 15)),
        fresh: true,
      );
      expect(motion.moving, false);
    },
  );

  testWidgets(
    'one map circle moves in place, style reload recreates it, and ending removes it',
    (tester) async {
      var now = first;
      final one = FakeMap(), reloaded = FakeMap();
      final marker = VehicleMarker(
        now: () => now,
        options: (point, fresh) => CircleOptions(
          geometry: point,
          circleColor: fresh ? '#00AA00' : '#555555',
        ),
      );
      marker.attach(one);
      marker.accept(depot, first, fresh: true);
      await tester.pump();
      expect(one.adds, 1);
      now = first.add(const Duration(seconds: 5));
      marker.accept(pickup, first.add(const Duration(seconds: 5)), fresh: true);
      now = first.add(const Duration(seconds: 5, milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 60));
      expect(one.adds, 1);
      expect(one.updates, greaterThan(0));
      expect(one.last!.geometry!.longitude, closeTo(-0.1995, .0001));
      now = first.add(const Duration(seconds: 6));
      marker.accept(
        pickup,
        first.add(const Duration(seconds: 10)),
        fresh: false,
      );
      await tester.pump();
      expect(one.last!.circleColor, '#555555');
      marker.attach(reloaded);
      await tester.pump();
      expect(reloaded.adds, 1);
      marker.clear();
      await tester.pump();
      expect(reloaded.removes, 1);
      marker.dispose();
    },
  );
}
