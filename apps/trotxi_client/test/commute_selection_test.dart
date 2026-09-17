import 'package:test/test.dart';
import 'package:trotxi_client/commute_selection.dart';
import 'package:trotxi_client/trotxi_client.dart';

const stamp = '2026-09-16T06:00:00Z';
final serializers = TrotxiApiClient().serializers;

CommuteLegChoice choice(
    {String direction = 'outbound',
    String? window,
    String routeId = 'corridor',
    String state = 'published'}) {
  final route = serializers.deserializeWith(Route.serializer, {
    'id': routeId,
    'name': 'Corridor',
    'description': null,
    'patternIds': ['outbound', 'return'],
    'acceptsDriverRequests': false,
    'archived': false,
    'editToken': 'route:1',
    'createdAt': stamp,
    'updatedAt': stamp,
    'version': 1,
  })!;
  final pattern = serializers.deserializeWith(Pattern.serializer, {
    'id': direction, 'routeId': routeId, 'direction': direction,
    // Deliberately NOT the version below: the selected schedule owns its version.
    'publishedVersionId': 'newest-$direction',
    'createdAt': stamp, 'updatedAt': stamp, 'version': 1,
  })!;
  final version = serializers.deserializeWith(PatternVersion.serializer, {
    'id': 'operated-$direction',
    'patternId': direction,
    'revision': 1,
    'state': state,
    'effectiveFrom': stamp,
    'effectiveTo': null,
    'geometryId': null,
    'editToken': 'version:1',
    'createdAt': stamp,
    'updatedAt': stamp,
    'version': 1,
    'stops': [
      for (var i = 0; i < 3; i++)
        {
          'id': '$direction-visit-$i',
          'stopId': i == 1 ? 'office' : 'same-physical-stop',
          'ordinal': i * 10,
          'name': i == 1 ? 'Office' : 'Home',
          'location': {'latitude': 5.6, 'longitude': -.1},
        }
    ],
  })!;
  final schedule = serializers.deserializeWith(Schedule.serializer, {
    'id': 'schedule-$direction',
    'departureId': 'departure-$direction',
    'patternId': direction,
    'patternVersionId': version.id,
    'serviceWindow':
        window ?? (direction == 'outbound' ? 'morning' : 'evening'),
    'localDeparture': direction == 'outbound' ? '06:30' : '17:30',
    'timeZone': 'Africa/Accra',
    'weekdays': [1, 2, 3, 4, 5],
    'effectiveFrom': '2026-09-01',
    'effectiveTo': null,
    'createdAt': stamp,
    'updatedAt': stamp,
    'version': 1,
  })!;
  return CommuteLegChoice(
      route: route, pattern: pattern, version: version, schedule: schedule);
}

void main() {
  test('explicit schedule ownership works without current route pattern links',
      () {
    final c = choice();
    final chosen = CommuteLegChoice(
        route: c.route.rebuild((b) => b.patternIds.clear()),
        pattern: c.pattern.rebuild((b) => b.publishedVersionId = null),
        version: c.version,
        schedule: c.schedule);
    expect(chosen.pickups, isNotEmpty);
  });
  test('loop stops retain occurrence identity and only downstream choices', () {
    final c = choice();
    expect(
        c.pickups.map((s) => s.id), ['outbound-visit-0', 'outbound-visit-1']);
    expect(c.dropoffsAfter('outbound-visit-0').map((s) => s.id),
        ['outbound-visit-1', 'outbound-visit-2']);
    final selected = c.select(
        pickupOccurrenceId: 'outbound-visit-0',
        dropoffOccurrenceId: 'outbound-visit-2');
    expect(selected.pickupOccurrenceId, isNot(selected.dropoffOccurrenceId));
    expect(c.version.stops.first.stopId, c.version.stops.last.stopId);
    expect(selected.patternVersionId, 'operated-outbound');
    expect(selected.scheduleId, 'schedule-outbound');
    expect(c.dropoffsAfter('outbound-visit-2'), isEmpty);
  });

  test('rejects physical IDs, other-leg occurrences and upstream travel', () {
    final c = choice();
    for (final pair in [
      ['same-physical-stop', 'office'],
      ['return-visit-0', 'outbound-visit-1'],
      ['outbound-visit-1', 'outbound-visit-0'],
      ['outbound-visit-1', 'outbound-visit-1'],
    ]) {
      expect(
          () => c.select(
              pickupOccurrenceId: pair[0], dropoffOccurrenceId: pair[1]),
          throwsArgumentError);
    }
  });

  test('mismatched route/pattern/version/schedule cannot be paired', () {
    final c = choice();
    for (final invalid in [
      () => CommuteLegChoice(
          route: c.route,
          pattern: c.pattern,
          version: c.version,
          schedule: c.schedule.rebuild((b) => b.patternId = 'other')),
      () => CommuteLegChoice(
          route: c.route,
          pattern: c.pattern.rebuild((b) => b.routeId = 'other'),
          version: c.version,
          schedule: c.schedule),
      () => CommuteLegChoice(
          route: c.route,
          pattern: c.pattern,
          version: c.version.rebuild((b) => b.patternId = 'other'),
          schedule: c.schedule),
      () => CommuteLegChoice(
          route: c.route,
          pattern: c.pattern,
          version: c.version,
          schedule: c.schedule
              .rebuild((b) => b.patternVersionId = 'newest-outbound')),
      () => CommuteLegChoice(
          route: c.route.rebuild((b) => b.archived = true),
          pattern: c.pattern,
          version: c.version,
          schedule: c.schedule),
    ]) {
      expect(invalid, throwsArgumentError);
    }
  });

  test('retired operated version remains representable; drafts do not', () {
    expect(choice(state: 'retired').version.id, 'operated-outbound');
    expect(() => choice(state: 'draft'), throwsArgumentError);
  });

  test(
      'malformed occurrence order or duplicate identities fail, not physical repeats',
      () {
    final c = choice();
    for (final stops in [
      [c.version.stops.first, c.version.stops.first],
      c.version.stops.reversed.toList(),
      [c.version.stops.first],
    ]) {
      expect(
          () => CommuteLegChoice(
              route: c.route,
              pattern: c.pattern,
              version: c.version.rebuild((b) => b.stops.replace(stops)),
              schedule: c.schedule),
          throwsArgumentError);
    }
  });

  CommuteRequestInput request(
          {bool pause = false, CommuteLegChoice? returning, Date? date}) =>
      buildCommuteRequest(
          outbound: choice(),
          outboundPickup: 'outbound-visit-0',
          outboundDropoff: 'outbound-visit-1',
          returning: returning ?? choice(direction: 'return'),
          returnPickup: 'return-visit-0',
          returnDropoff: 'return-visit-1',
          requestedDate: date ?? Date(2026, 9, 21),
          pauseIfWaitlisted: pause);

  test(
      'two explicit directions build the reviewed body with opt-in pause consent',
      () {
    final result = serializers.serializeWith(
        CommuteRequestInput.serializer, request()) as Map;
    expect(result['routeId'], 'corridor');
    expect(result['requestedDate'], '2026-09-21');
    expect(result['pauseIfWaitlisted'], isFalse);
    expect((result['legs'] as List).map((l) => l['direction']),
        ['outbound', 'return']);
    expect(request(pause: true).pauseIfWaitlisted, isTrue);
  });

  test('rejects same-direction, same-window and cross-corridor pairs', () {
    expect(() => request(returning: choice()), throwsArgumentError);
    expect(
        () =>
            request(returning: choice(direction: 'return', window: 'morning')),
        throwsArgumentError);
    expect(
        () => request(returning: choice(direction: 'return', routeId: 'other')),
        throwsArgumentError);
  });

  test('impossible dates and year zero fail before a request is sent', () {
    for (final date in [Date(0, 1, 1), Date(2026, 2, 30), Date(2026, 13, 1)]) {
      expect(() => request(date: date), throwsArgumentError);
    }
    expect(request(date: Date(2028, 2, 29)).requestedDate, Date(2028, 2, 29));
  });
}
