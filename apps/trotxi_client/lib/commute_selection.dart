import 'trotxi_client.dart';

/// A schedule and the exact version it operates, not the pattern's newest
/// published revision. The UI presents one of these per selectable departure.
/// These checks prevent accidental client mis-attribution; the server remains
/// authoritative for publication, availability, pricing and request approval.
class CommuteLegChoice {
  CommuteLegChoice({
    required this.route,
    required this.pattern,
    required this.version,
    required this.schedule,
  }) {
    if (route.archived ||
        pattern.routeId != route.id ||
        schedule.patternId != pattern.id ||
        version.patternId != pattern.id ||
        version.id != schedule.patternVersionId ||
        version.state == PatternVersionStateEnum.draft) {
      throw ArgumentError(
          'The departure does not belong to this published corridor');
    }
    final ids = <String>{};
    int? previous;
    for (final stop in version.stops) {
      if (!ids.add(stop.id) || (previous != null && stop.ordinal <= previous)) {
        throw ArgumentError('Stop occurrences must be distinct and ordered');
      }
      previous = stop.ordinal;
    }
    if (version.stops.length < 2) {
      throw ArgumentError('A commute needs at least two stop occurrences');
    }
  }

  final Route route;
  final Pattern pattern;
  final PatternVersion version;
  final Schedule schedule;

  List<StopOccurrence> get pickups =>
      List.unmodifiable(version.stops.take(version.stops.length - 1));

  List<StopOccurrence> dropoffsAfter(String pickupOccurrenceId) {
    final pickup = version.stops.indexWhere((s) => s.id == pickupOccurrenceId);
    if (pickup < 0) throw ArgumentError('Choose a pickup from this departure');
    return List.unmodifiable(version.stops.skip(pickup + 1));
  }

  CommuteLeg select({
    required String pickupOccurrenceId,
    required String dropoffOccurrenceId,
  }) {
    if (!dropoffsAfter(pickupOccurrenceId)
        .any((s) => s.id == dropoffOccurrenceId)) {
      throw ArgumentError('Choose a downstream drop-off on this departure');
    }
    return CommuteLeg((b) => b
      ..direction = pattern.direction == PatternDirectionEnum.outbound
          ? CommuteLegDirectionEnum.outbound
          : CommuteLegDirectionEnum.return_
      ..scheduleId = schedule.id
      ..patternVersionId = version.id
      ..pickupOccurrenceId = pickupOccurrenceId
      ..dropoffOccurrenceId = dropoffOccurrenceId);
  }
}

/// Builds the two explicit legs. It never derives direction from a clock or
/// assumes the return leg uses the outbound route's physical stop identities.
CommuteRequestInput buildCommuteRequest({
  required CommuteLegChoice outbound,
  required String outboundPickup,
  required String outboundDropoff,
  required CommuteLegChoice returning,
  required String returnPickup,
  required String returnDropoff,
  required Date requestedDate,
  bool pauseIfWaitlisted = false,
  String? note,
}) {
  if (outbound.route.id != returning.route.id ||
      outbound.pattern.direction != PatternDirectionEnum.outbound ||
      returning.pattern.direction != PatternDirectionEnum.return_ ||
      outbound.schedule.serviceWindow == returning.schedule.serviceWindow) {
    throw ArgumentError(
        'Choose outbound and return departures in different service windows');
  }
  final date = requestedDate.toDateTime(utc: true);
  if (requestedDate.year < 1 ||
      requestedDate.year > 9999 ||
      date.year != requestedDate.year ||
      date.month != requestedDate.month ||
      date.day != requestedDate.day) {
    throw ArgumentError('Choose a valid service date');
  }
  return CommuteRequestInput((b) => b
    ..routeId = outbound.route.id
    ..legs.addAll([
      outbound.select(
          pickupOccurrenceId: outboundPickup,
          dropoffOccurrenceId: outboundDropoff),
      returning.select(
          pickupOccurrenceId: returnPickup, dropoffOccurrenceId: returnDropoff),
    ])
    ..requestedDate = requestedDate
    ..pauseIfWaitlisted = pauseIfWaitlisted
    ..note = note);
}
