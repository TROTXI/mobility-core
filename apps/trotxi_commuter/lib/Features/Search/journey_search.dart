import 'package:trotxi_client/commute_selection.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';

String normalizeSearch(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\u00c0-\u024f]+'), ' ')
    .trim();

/// Exact and prefix matches win. A single mistyped character is tolerated
/// only in words of at least four letters; never invents a stop or an alias.
int searchScore(String text, String query) {
  final value = normalizeSearch(text), needle = normalizeSearch(query);
  if (needle.isEmpty) return 0;
  if (value == needle) return 100;
  if (value.startsWith(needle)) return 80;
  final words = value.split(' ');
  var score = 0;
  for (final token in needle.split(' ')) {
    if (words.contains(token)) {
      score += 20;
      continue;
    }
    if (words.any((word) => word.startsWith(token))) {
      score += 15;
      continue;
    }
    if (token.length >= 4 && words.any((word) => _oneEdit(word, token))) {
      score += 5;
      continue;
    }
    return -1;
  }
  return score;
}

bool _oneEdit(String a, String b) {
  if ((a.length - b.length).abs() > 1) return false;
  var i = 0, j = 0, edits = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      i++;
      j++;
      continue;
    }
    if (++edits > 1) return false;
    if (a.length >= b.length) i++;
    if (b.length >= a.length) j++;
  }
  return edits + (a.length - i) + (b.length - j) <= 1;
}

class JourneyMatch {
  const JourneyMatch(
    this.choice,
    this.pickup,
    this.dropoff,
    this.score, {
    this.serviceDate,
  });
  final CommuteLegChoice choice;
  final wire.StopOccurrence pickup, dropoff;
  final int score;
  final DateTime? serviceDate;
}

bool operatesOn(CommuteLegChoice choice, DateTime day) {
  final date = DateTime.utc(day.year, day.month, day.day);
  final schedule = choice.schedule;
  final parts = schedule.localDeparture.split(':');
  final departure = date.add(
    Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1])),
  );
  return schedule.weekdays.contains(date.weekday) &&
      !date.isBefore(schedule.effectiveFrom.toDateTime(utc: true)) &&
      (schedule.effectiveTo == null ||
          !date.isAfter(schedule.effectiveTo!.toDateTime(utc: true))) &&
      (choice.version.effectiveFrom == null ||
          !departure.isBefore(choice.version.effectiveFrom!)) &&
      (choice.version.effectiveTo == null ||
          departure.isBefore(choice.version.effectiveTo!));
}

List<JourneyMatch> findJourneys(
  List<CommuteLegChoice> choices, {
  required String from,
  required String to,
  required DateTime day,
}) {
  final matches = <JourneyMatch>[];
  if (normalizeSearch(from).isEmpty || normalizeSearch(to).isEmpty) {
    return matches;
  }
  for (final choice in choices) {
    if (!operatesOn(choice, day)) continue;
    // Keep occurrences distinct: loops may visit the same physical stop twice.
    for (final pickup in choice.pickups) {
      final fromScore = searchScore(pickup.name, from);
      if (fromScore < 0) continue;
      for (final dropoff in choice.dropoffsAfter(pickup.id)) {
        final toScore = searchScore(dropoff.name, to);
        if (toScore >= 0) {
          matches.add(
            JourneyMatch(
              choice,
              pickup,
              dropoff,
              fromScore + toScore,
              serviceDate: day,
            ),
          );
        }
      }
    }
  }
  matches.sort((a, b) {
    final rank = b.score.compareTo(a.score);
    if (rank != 0) return rank;
    final time = a.choice.schedule.localDeparture.compareTo(
      b.choice.schedule.localDeparture,
    );
    if (time != 0) return time;
    return a.choice.route.name.compareTo(b.choice.route.name);
  });
  return matches;
}

class JourneyCatalog {
  const JourneyCatalog(this.choices, this.failedRoutes);
  final List<CommuteLegChoice> choices;
  final int failedRoutes;
}

/// Cache only the public catalogue, never riders, trips or payments. Scoped
/// to the API instance and session, bounded to five minutes, with explicit retry.
class JourneyCatalogStore {
  static final _stores = Expando<JourneyCatalogStore>();
  static JourneyCatalogStore forClient(CommuterApi client) =>
      _stores[client] ??= JourneyCatalogStore();
  JourneyCatalog? _value;
  DateTime? _loadedAt;
  int? _generation;
  Future<JourneyCatalog>? _pending;

  Future<JourneyCatalog> load(CommuterApi client, {bool refresh = false}) {
    final generation = client.sessionGeneration;
    if (_generation != generation) {
      _value = null;
      _pending = null;
      _generation = generation;
    }
    if (_pending != null) return _pending!;
    if (refresh) _value = null;
    if (!refresh &&
        _value != null &&
        DateTime.now().difference(_loadedAt!) < const Duration(minutes: 5)) {
      return Future.value(_value);
    }
    late final Future<JourneyCatalog> pending;
    pending = _fetch(client, generation)
        .then((value) {
          client.ensureSession(generation);
          if (value.failedRoutes == 0) {
            _value = value;
            _loadedAt = DateTime.now();
          }
          return value;
        })
        .whenComplete(() {
          if (identical(_pending, pending)) _pending = null;
        });
    _pending = pending;
    return pending;
  }

  Future<JourneyCatalog> _fetch(CommuterApi client, int generation) async {
    final routes = (await client.routes()).where((r) => !r.archived).toList();
    final choices = <CommuteLegChoice>[];
    var failures = 0, next = 0;
    Future<void> worker() async {
      while (next < routes.length) {
        final route = routes[next++];
        client.ensureSession(generation);
        try {
          final schedules = await client.schedules(route.id);
          final patterns = <String, wire.Pattern>{};
          final versions = <String, wire.PatternVersion>{};
          final routeChoices = <CommuteLegChoice>[];
          for (final schedule in schedules) {
            client.ensureSession(generation);
            final pattern = patterns[schedule.patternId] ??= await client
                .pattern(schedule.patternId);
            final version = versions[schedule.patternVersionId] ??= await client
                .patternVersion(schedule.patternId, schedule.patternVersionId);
            routeChoices.add(
              CommuteLegChoice(
                route: route,
                pattern: pattern,
                version: version,
                schedule: schedule,
              ),
            );
          }
          client.ensureSession(generation);
          choices.addAll(routeChoices);
        } catch (error) {
          client.ensureSession(generation);
          if (error is UnauthorizedException ||
              error is UpgradeRequiredException) {
            rethrow;
          }
          failures++;
        }
      }
    }

    // Bound catalogue fan-out even when many corridors have been published.
    await Future.wait([worker(), worker(), worker()]);
    return JourneyCatalog(List.unmodifiable(choices), failures);
  }
}
