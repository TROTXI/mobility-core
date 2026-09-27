import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Schedule/pages/schedule_page.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/data/trips_repository.dart';
import 'support/replacement_client.dart';

class MidnightTrips extends TripsRepository {
  MidnightTrips() : super(client: replacementClient(authenticate: false));

  @override
  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async {
    final today = CorridorTime.todayDate();
    return [
      DriverRun(
        id: 'late-run',
        routeId: 'corridor',
        routeName: 'Delayed evening run',
        serviceDate: CorridorTime.calendarDay(today),
        scheduledAt: DateTime.utc(
          today.year,
          today.month,
          today.day + 1,
          0,
          15,
        ),
        status: RunStatus.scheduled,
      ),
    ];
  }
}

void main() {
  testWidgets(
    'a midnight delay stays on its stored service day in the agenda',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        Provider<TripsRepository>.value(
          value: MidnightTrips(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: SchedulePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Delayed evening run'), findsOneWidget);
      expect(find.text('00:15'), findsOneWidget);
    },
  );
}
