import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/routes_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/trip_tracking_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

Map<String, Object?> tripRow(String id) => {
  'id': id,
  'departureId': 'departure',
  'patternId': 'outbound',
  'serviceDate': '2026-09-16',
  'runNumber': 1,
  'routeId': 'route',
  'patternVersionId': 'version',
  'direction': 'outbound',
  'scheduledAt': '2026-09-17T00:15:00Z',
  'status': 'active',
  'vehicleLabel': 'Bus A',
};
Map<String, Object?> liveRow({int age = 20, String state = 'live'}) => {
  'tripId': 'trip',
  'patternVersionId': 'version',
  'geometryId': null,
  'riderPickupOccurrenceId': 'pickup',
  'state': state,
  'position': {
    'location': {'latitude': 5.6, 'longitude': -.1},
    'capturedAt': timestamp,
    'receivedAt': timestamp,
    'ageSeconds': age,
  },
  'etas': [
    {
      'stopOccurrenceId': 'pickup',
      'durationSeconds': 180,
      'distanceMeters': 1000,
      'basis': 'fallback',
    },
  ],
  'serverTime': timestamp,
};
void main() {
  test(
    'commuter excludes transitive location permissions and has no iOS location prompt',
    () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      for (final permission in [
        'ACCESS_COARSE_LOCATION',
        'ACCESS_FINE_LOCATION',
        'ACCESS_BACKGROUND_LOCATION',
      ]) {
        expect(
          manifest,
          contains(
            'android:name="android.permission.$permission" tools:node="remove"',
          ),
        );
      }
      expect(
        File('ios/Runner/Info.plist').readAsStringSync(),
        isNot(contains('NSLocation')),
      );
      expect(
        File('../trotxi_map/lib/src/trotxi_map_view.dart').readAsStringSync(),
        contains('myLocationEnabled: false'),
      );
    },
  );
  late Fixture f;
  late int status, age;
  late String state;
  Future<void> drain(
    WidgetTester tester,
    Future<void> Function() action,
  ) async {
    await tester.runAsync(() async {
      await action();
      for (var i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
        if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
      }
    });
    await tester.pump();
  }

  Future<void> pump(
    WidgetTester tester, {
    bool catalogue = false,
    Duration interval = const Duration(seconds: 5),
  }) async {
    status = 200;
    age = 20;
    state = 'live';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await drain(tester, () async {
      f = Fixture();
      await f.signedIn();
      f.reply = (o) {
        if (o.path.endsWith('/live')) {
          return status == 200
              ? jsonResponse({'data': liveRow(age: age, state: state)})
              : jsonResponse({
                  'error': {'code': 'not_found', 'message': 'Not found'},
                }, status);
        }
        if (o.path == '/v1/trips/trip') {
          return jsonResponse({'data': tripRow('trip')});
        }
        if (o.path == '/v1/trips') {
          return jsonResponse(
            page([
              tripRow(o.queryParameters['cursor'] == null ? 'one' : 'two'),
            ], o.queryParameters['cursor'] == null ? 'next' : null),
          );
        }
        if (o.path == '/v1/routes') return jsonResponse(page([]));
        return jsonResponse({
          'error': {'code': 'not_found', 'message': 'Not found'},
        }, 404);
      };
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: catalogue
              ? Scaffold(body: RoutesTab(client: f.api))
              : TripTrackingPage(
                  client: f.api,
                  tripId: 'trip',
                  pollInterval: interval,
                ),
        ),
      );
    });
  }

  Future<void> refresh(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Refresh tracking'));
    await drain(tester, () => tester.tap(find.text('Refresh tracking')));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    f.api.dispose();
    await tester.pump();
  }

  testWidgets(
    'catalogue follows pages and displays service day separately from midnight delay',
    (tester) async {
      await pump(tester, catalogue: true);
      expect(
        find.text('Bus A', findRichText: true),
        findsNothing,
      ); // Label lives with timing, not seat proof.
      expect(find.textContaining('Departs 17 Sep 00:15'), findsNWidgets(2));
      expect(find.textContaining('Service 2026-09-16'), findsNWidgets(2));
      final reads = f.requests.where((r) => r.path == '/v1/trips').toList();
      expect(reads, hasLength(2));
      expect(
        reads[0].queryParameters['fromDate'],
        reads[1].queryParameters['fromDate'],
      );
      expect(
        reads[0].queryParameters['fromDate'],
        reads[0].queryParameters['toDate'],
      );
      expect(find.textContaining('does not confirm your seat'), findsOneWidget);
      await finish(tester);
    },
  );
  testWidgets(
    'missing tiles do not hide authorized ETA; rider location is never requested',
    (tester) async {
      await pump(tester);
      expect(find.text('Map unavailable'), findsOneWidget);
      expect(find.textContaining('~3 min'), findsWidgets);
      expect(find.textContaining('Live bus'), findsOneWidget);
      expect(
        find.textContaining('does not collect your location'),
        findsOneWidget,
      );
      expect(f.requests.every((r) => r.method == 'GET'), isTrue);
      await finish(tester);
    },
  );
  testWidgets(
    '404 after a successful read removes map, position and all predictions',
    (tester) async {
      await pump(tester);
      expect(find.textContaining('~3 min'), findsWidgets);
      status = 404;
      await refresh(tester);
      expect(find.textContaining('~3 min'), findsNothing);
      expect(find.textContaining('Live bus'), findsNothing);
      expect(find.text('Map unavailable'), findsNothing);
      expect(find.textContaining('current access'), findsOneWidget);
      await finish(tester);
    },
  );
  testWidgets(
    'stale position retains age but discards server ETA past 120 seconds',
    (tester) async {
      await pump(tester);
      age = 121;
      state = 'stale';
      await refresh(tester);
      expect(find.textContaining('Last known bus position'), findsOneWidget);
      expect(find.textContaining('~3 min'), findsNothing);
      expect(find.textContaining('too old'), findsOneWidget);
      await finish(tester);
    },
  );
  testWidgets(
    'background stops polling and clears position; resume reauthorizes',
    (tester) async {
      await pump(tester, interval: const Duration(milliseconds: 100));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(find.textContaining('Live bus'), findsNothing);
      final before = f.requests.length;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      expect(f.requests.length, before);
      status = 404;
      await drain(tester, () async {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      });
      expect(f.requests.length, greaterThan(before));
      expect(find.textContaining('current access'), findsOneWidget);
      expect(find.textContaining('Live bus'), findsNothing);
      await finish(tester);
    },
  );
  testWidgets(
    'a pending response across background cannot redraw or trigger overlapping reads',
    (tester) async {
      await pump(tester, interval: const Duration(milliseconds: 100));
      final entered = Completer<void>(), release = Completer<void>();
      final reply = f.reply;
      f.reply = (o) async {
        if (o.path.endsWith('/live')) {
          if (!entered.isCompleted) entered.complete();
          await release.future;
        }
        return reply(o);
      };
      final liveReadsBefore = f.requests
          .where((r) => r.path.endsWith('/live'))
          .length;
      await tester.runAsync(() async {
        await tester.tap(find.text('Refresh tracking'));
        for (var i = 0; i < 100 && !entered.isCompleted; i++) {
          await tester.pump();
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(
          entered.isCompleted,
          isTrue,
          reason: 'The blocked live request must actually start.',
        );
        await Future<void>.delayed(const Duration(milliseconds: 250));
        expect(
          f.requests.where((r) => r.path.endsWith('/live')).length,
          liveReadsBefore + 1,
          reason: 'A second poll must not overlap the blocked live request.',
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      });
      await tester.pump();
      final before = f.requests.length;
      await tester.runAsync(() async {
        release.complete();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      expect(
        f.requests.length,
        before,
      ); // No trip/geometry reads after invalidation.
      expect(find.textContaining('Live bus'), findsNothing);
      await finish(tester);
    },
  );
  testWidgets(
    'ended state removes a supplied fix and stops automatic refresh',
    (tester) async {
      await pump(tester, interval: const Duration(milliseconds: 100));
      state = 'ended';
      await refresh(tester);
      expect(find.textContaining('Trip ended'), findsOneWidget);
      expect(find.textContaining('Live bus'), findsNothing);
      expect(find.textContaining('~3 min'), findsNothing);
      final before = f.requests.length;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      expect(f.requests.length, before);
      await finish(tester);
    },
  );
}
