import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/commute_selection.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Search/journey_search.dart';
import 'package:trotxi_commuter/Features/Search/journey_search_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/commute_picker.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_tab.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'replacement_fixture.dart';

final _serializers = wire.TrotxiApiClient().serializers;
final _day = DateTime.utc(2026, 10, 12);
Map<String, Object?> routeData(String id) => {
  'id': id,
  'name': 'Circle to Madina',
  'description': null,
  'patternIds': ['outbound', 'return'],
  'acceptsDriverRequests': false,
  'archived': false,
  'editToken': 'route:1',
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
};
Map<String, Object?> patternData(String direction) => {
  'id': direction,
  'routeId': 'route',
  'direction': direction,
  'publishedVersionId': 'v-$direction',
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
};
Map<String, Object?> versionData(String direction) => {
  'id': 'v-$direction',
  'patternId': direction,
  'revision': 1,
  'state': 'published',
  'effectiveFrom': timestamp,
  'effectiveTo': null,
  'geometryId': null,
  'editToken': 'version:1',
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
  'stops': [
    for (var i = 0; i < 3; i++)
      {
        'id': '$direction-$i',
        'stopId': 'stop-$i',
        'ordinal': i,
        'name': (direction == 'outbound'
            ? ['Circle', '37 Military Hospital', 'Madina']
            : ['Madina', '37 Military Hospital', 'Circle'])[i],
        'location': {'latitude': 5.6, 'longitude': -.1},
      },
  ],
};
Map<String, Object?> scheduleData(String direction) => {
  'id': 's-$direction',
  'departureId': 'd-$direction',
  'patternId': direction,
  'patternVersionId': 'v-$direction',
  'serviceWindow': direction == 'outbound' ? 'morning' : 'evening',
  'localDeparture': direction == 'outbound' ? '06:30' : '17:30',
  'timeZone': 'Africa/Accra',
  'weekdays': [1, 2, 3, 4, 5, 6, 7],
  'effectiveFrom': '2026-09-01',
  'effectiveTo': null,
  'createdAt': timestamp,
  'updatedAt': timestamp,
  'version': 1,
};
CommuteLegChoice choice([String direction = 'outbound']) => CommuteLegChoice(
  route: _serializers.deserializeWith(
    wire.Route.serializer,
    routeData('route'),
  )!,
  pattern: _serializers.deserializeWith(
    wire.Pattern.serializer,
    patternData(direction),
  )!,
  version: _serializers.deserializeWith(
    wire.PatternVersion.serializer,
    versionData(direction),
  )!,
  schedule: _serializers.deserializeWith(
    wire.Schedule.serializer,
    scheduleData(direction),
  )!,
);
CommuteLegChoice changed(
  CommuteLegChoice c, {
  wire.Schedule? schedule,
  wire.PatternVersion? version,
}) => CommuteLegChoice(
  route: c.route,
  pattern: c.pattern,
  version: version ?? c.version,
  schedule: schedule ?? c.schedule,
);

void catalogReplies(Fixture fixture, {bool failSchedule = false}) {
  fixture.reply = (request) {
    if (request.path == '/v1/routes') {
      return jsonResponse(page([routeData('route')]));
    }
    if (request.path == '/v1/routes/route/schedules' && !failSchedule) {
      return jsonResponse(
        page([scheduleData('outbound'), scheduleData('return')]),
      );
    }
    for (final direction in ['outbound', 'return']) {
      if (request.path == '/v1/route-patterns/$direction') {
        return jsonResponse({'data': patternData(direction)});
      }
      if (request.path ==
          '/v1/route-patterns/$direction/versions/v-$direction') {
        return jsonResponse({'data': versionData(direction)});
      }
    }
    return jsonResponse({
      'error': {'code': 'unavailable', 'message': 'Unavailable'},
    }, 503);
  };
}

Future<void> settleRequests(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('ranks exact and prefix stop names above one-character typos', () {
    expect(searchScore('Madina', 'MADINA'), 100);
    expect(
      searchScore('Madina Station', 'madina'),
      greaterThan(searchScore('Madina', 'madna')),
    );
    expect(searchScore('37 Military Hospital', 'hospital 37'), greaterThan(0));
    expect(searchScore('Circle-Station', 'circle station'), 100);
    expect(searchScore('Madina', 'med'), -1);
  });
  test('matches downstream stops, not route names or reversed travel', () {
    final c = choice();
    expect(
      findJourneys(
        [c],
        from: 'circle',
        to: 'military',
        day: _day,
      ).single.dropoff.name,
      '37 Military Hospital',
    );
    expect(findJourneys([c], from: 'madina', to: 'circle', day: _day), isEmpty);
    expect(
      findJourneys(
        [c, choice('return')],
        from: 'madina',
        to: 'circle',
        day: _day,
      ).single.choice.pattern.direction,
      wire.PatternDirectionEnum.return_,
    );
    expect(findJourneys([c], from: '', to: 'madina', day: _day), isEmpty);
    expect(findJourneys([c], from: 'circle', to: 'circle', day: _day), isEmpty);
  });
  test(
    'respects weekdays, inclusive schedule dates and exclusive version end',
    () {
      final c = choice();
      final bounded = changed(
        c,
        schedule: c.schedule.rebuild(
          (b) => b
            ..effectiveFrom = wire.Date(2026, 10, 12)
            ..effectiveTo = wire.Date(2026, 10, 12),
        ),
      );
      expect(operatesOn(bounded, _day), isTrue);
      expect(
        operatesOn(bounded, _day.subtract(const Duration(days: 1))),
        isFalse,
      );
      expect(operatesOn(bounded, _day.add(const Duration(days: 1))), isFalse);
      expect(
        operatesOn(
          changed(
            c,
            schedule: c.schedule.rebuild((b) => b.weekdays.replace([2])),
          ),
          _day,
        ),
        isFalse,
      );
      expect(
        operatesOn(
          changed(
            c,
            version: c.version.rebuild(
              (b) => b.effectiveTo = _day.add(
                const Duration(hours: 6, minutes: 30),
              ),
            ),
          ),
          _day,
        ),
        isFalse,
      );
      expect(
        operatesOn(
          changed(
            c,
            version: c.version.rebuild(
              (b) => b.effectiveFrom = _day.add(const Duration(hours: 7)),
            ),
          ),
          _day,
        ),
        isFalse,
      );
    },
  );
  test('loop visits retain occurrence identity', () {
    final c = choice();
    final loop = changed(
      c,
      version: c.version.rebuild(
        (b) => b.stops[2] = c.version.stops[2].rebuild(
          (s) => s
            ..name = 'Circle'
            ..stopId = 'stop-0',
        ),
      ),
    );
    final result = findJourneys(
      [loop],
      from: 'circle',
      to: 'circle',
      day: _day,
    ).single;
    expect(result.pickup.id, isNot(result.dropoff.id));
  });
  test('catalogue caches public data and retries partial failures', () async {
    final fixture = Fixture();
    await fixture.signedIn();
    catalogReplies(fixture, failSchedule: true);
    final store = JourneyCatalogStore.forClient(fixture.api);
    expect((await store.load(fixture.api)).failedRoutes, 1);
    catalogReplies(fixture);
    expect((await store.load(fixture.api)).choices, hasLength(2));
    final count = fixture.requests.length;
    await store.load(fixture.api);
    expect(fixture.requests.length, count);
    await store.load(fixture.api, refresh: true);
    expect(fixture.requests.length, greaterThan(count));
    expect(fixture.requests.any((r) => r.path.contains('/me/')), isFalse);
    fixture.api.dispose();
  });
  testWidgets(
    'stop search, swapping and selected-journey navigation work on a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = Fixture();
      await fixture.signedIn();
      catalogReplies(fixture);
      JourneyMatch? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await Navigator.of(context).push<JourneyMatch>(
                    MaterialPageRoute(
                      builder: (_) => JourneySearchPage(
                        client: fixture.api,
                        selectOnly: true,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await settleRequests(tester);
      await tester.enterText(find.widgetWithText(TextField, 'From'), 'Circl');
      await tester.enterText(find.widgetWithText(TextField, 'To'), 'Madina');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('Circle → Madina'), findsOneWidget);
      await tester.tap(find.byTooltip('Swap pickup and destination'));
      await tester.pumpAndSettle();
      expect(find.text('Madina → Circle'), findsOneWidget);
      await tester.ensureVisible(find.text('Choose this journey'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose this journey'));
      await tester.pumpAndSettle();
      expect(selected?.pickup.name, 'Madina');
      expect(tester.takeException(), isNull);
      fixture.api.dispose();
    },
  );
  testWidgets('partial failure is not presented as complete route coverage', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    catalogReplies(fixture, failSchedule: true);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: JourneySearchPage(client: fixture.api),
      ),
    );
    await settleRequests(tester);
    expect(find.text('Some routes couldn’t load'), findsOneWidget);
    await tester.ensureVisible(find.text('Try again'));
    catalogReplies(fixture);
    await tester.tap(find.text('Try again'));
    await settleRequests(tester);
    expect(find.text('Some routes couldn’t load'), findsNothing);
    expect(tester.takeException(), isNull);
    fixture.api.dispose();
  });
  testWidgets('selected outbound is preserved and return choices are shown', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    catalogReplies(fixture);
    final selected = findJourneys(
      [choice()],
      from: 'circle',
      to: 'madina',
      day: _day,
    ).single;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CommutePickerPage(client: fixture.api, initialJourney: selected),
      ),
    );
    await settleRequests(tester);
    expect(find.textContaining('Outbound: Circle → Madina'), findsOneWidget);
    expect(find.text('17:30'), findsOneWidget);
    fixture.api.dispose();
  });
  testWidgets('profile includes saved email without overflow', (tester) async {
    final fixture = Fixture();
    await fixture.signedIn();
    fixture.reply = (_) => jsonResponse({
      'data': {
        ...account('Mino Kwame Kuda'),
        'email': 'mino.long.address@example.com',
        'phone': '+233543843855',
      },
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: ProfileTab(client: fixture.api)),
      ),
    );
    await settleRequests(tester);
    expect(find.text('mino.long.address@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
    fixture.api.dispose();
  });
  testWidgets('retry preserves the selected journey', (tester) async {
    final fixture = Fixture();
    await fixture.signedIn();
    catalogReplies(fixture, failSchedule: true);
    final selected = findJourneys(
      [choice()],
      from: 'circle',
      to: 'madina',
      day: _day,
    ).single;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CommutePickerPage(client: fixture.api, initialJourney: selected),
      ),
    );
    await settleRequests(tester);
    catalogReplies(fixture);
    await tester.tap(find.text('Try again'));
    await settleRequests(tester);
    expect(find.textContaining('Outbound: Circle → Madina'), findsOneWidget);
    expect(find.text('17:30'), findsOneWidget);
    fixture.api.dispose();
  });
  testWidgets('return seed excludes same-window outbound choices', (
    tester,
  ) async {
    final fixture = Fixture();
    await fixture.signedIn();
    catalogReplies(fixture);
    final original = fixture.reply;
    fixture.reply = (request) => request.path.endsWith('/schedules')
        ? jsonResponse(
            page([
              scheduleData('return'),
              scheduleData('outbound'),
              {
                ...scheduleData('outbound'),
                'id': 'incompatible',
                'serviceWindow': 'evening',
                'localDeparture': '18:45',
              },
            ]),
          )
        : original(request);
    final selected = findJourneys(
      [choice('return')],
      from: 'madina',
      to: 'circle',
      day: _day,
    ).single;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CommutePickerPage(client: fixture.api, initialJourney: selected),
      ),
    );
    await settleRequests(tester);
    expect(find.text('06:30'), findsOneWidget);
    expect(find.text('18:45'), findsNothing);
    fixture.api.dispose();
  });
  testWidgets('Back during a seeded load leaves the picker', (tester) async {
    final fixture = Fixture();
    await fixture.signedIn();
    final response = Completer<ResponseBody>();
    fixture.reply = (_) => response.future;
    final c = choice();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              child: const Text('Open picker'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CommutePickerPage(
                    client: fixture.api,
                    initialJourney: JourneyMatch(
                      c,
                      c.version.stops.first,
                      c.version.stops.last,
                      100,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open picker'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Open picker'), findsOneWidget);
    response.complete(jsonResponse(page([])));
    await settleRequests(tester);
    expect(tester.takeException(), isNull);
    fixture.api.dispose();
  });
  for (final dark in [false, true]) {
    testWidgets('search fits narrow screens with large text, dark=$dark', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = Fixture();
      await fixture.signedIn();
      catalogReplies(fixture);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: JourneySearchPage(client: fixture.api),
        ),
      );
      await settleRequests(tester);
      final fromField = find.byKey(const ValueKey('journey-from'));
      final toField = find.byKey(const ValueKey('journey-to'));
      await tester.scrollUntilVisible(
        fromField,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(fromField, 'Circle');
      await tester.scrollUntilVisible(
        toField,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(toField, 'Madina');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      fixture.api.dispose();
    });
  }
}
