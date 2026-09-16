import 'package:flutter/foundation.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// The driver's day, arranged the way Today draws it.
///
/// Sorted once here rather than in the widget: the prototype's Today is a
/// running assignment, then the next one, then the rest, and a screen deciding
/// that mid-build would recompute it on every rebuild.
class TodayBoard {
  const TodayBoard({
    required this.active,
    required this.next,
    required this.later,
    required this.completed,
    this.headline,
  });

  /// Counts for the run the frame gives top billing, and only that one.
  ///
  /// The card shows riders and stops, which cost a manifest and a route read
  /// each. Fetching them for every run on the board would mean four round trips
  /// to render a screen where three of the cards are one line of text.
  final RunHeadline? headline;

  /// The run under way, if the driver started one.
  final DriverRun? active;

  /// The next run to start, when nothing is running.
  final DriverRun? next;

  /// Everything after [next], for the "Later today" list.
  final List<DriverRun> later;

  /// Finished runs, which drive the "You're done for today" state.
  final List<DriverRun> completed;

  /// Nothing assigned at all (prototype frame 16), as distinct from having
  /// finished everything (frame 17). The two look alike and read completely
  /// differently to a driver at the start of a shift.
  bool get isEmpty =>
      active == null && next == null && later.isEmpty && completed.isEmpty;

  /// Everything assigned is done.
  bool get isDayDone =>
      active == null && next == null && later.isEmpty && completed.isNotEmpty;
}

/// The extra numbers the leading run's card carries.
class RunHeadline {
  const RunHeadline({
    required this.riders,
    required this.morning,
    required this.standby,
    required this.stops,
  });

  /// Confirmed seats on this run.
  final int riders;

  /// How many of them are travelling this morning, which is the split the
  /// frame shows.
  final int morning;

  /// Seats filled from the standby pool — the "· 6 standby" the Today card
  /// shows (#230). Real now that the manifest returns `source`; it used to be
  /// omitted rather than guessed.
  final int standby;

  final int stops;
}

/// Today's assignments (prototype frames 14 to 18).
class TodayController extends ChangeNotifier {
  TodayController({required this._trips, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final TripsRepository _trips;

  /// Injectable so "which day is it" is testable without waiting for midnight.
  final DateTime Function() _now;

  Loadable<TodayBoard> _board = const Loadable.idle();
  Loadable<TodayBoard> get board => _board;
  int _revision = 0;
  int _fetchId = 0;
  void reset() {
    _revision++;
    _busyRunId = null;
    _board = const Loadable.idle();
    notifyListeners();
  }

  /// The run currently being started or ended, so only that card shows a
  /// spinner rather than the whole screen going blank under the driver.
  String? _busyRunId;
  String? get busyRunId => _busyRunId;

  /// Load or reload the day.
  ///
  /// Keeps whatever is on screen while it reloads. A driver pulling to refresh
  /// at a depot gate should not watch their assignment disappear and come back.
  Future<void> load() async {
    _board = Loadable.loading(previous: _board.valueOrNull);
    notifyListeners();
    await _fetch();
  }

  /// Start a run and reflect it immediately.
  ///
  /// @param runId - the run to start.
  Future<void> start(String runId) => _act(runId, () => _trips.start(runId));

  /// End a run.
  ///
  /// @param runId - the run to complete.
  Future<void> complete(String runId) =>
      _act(runId, () => _trips.complete(runId));

  /// Run a lifecycle transition, then reload so the board reflects it.
  ///
  /// The reload is what keeps the screen honest: start() returns one run, but
  /// which card is "next" and what falls into "later" is a property of the
  /// whole day, not of the run that changed.
  ///
  /// @param runId - the run being changed.
  /// @param action - the transition to run.
  Future<void> _act(String runId, Future<DriverRun> Function() action) async {
    final revision = _revision;
    _busyRunId = runId;
    notifyListeners();
    try {
      await action();
      if (revision != _revision) return;
      await _fetch();
    } on TrotxiException catch (err) {
      if (revision != _revision) return;
      _board = Loadable.failure(err.message, previous: _board.valueOrNull);
      notifyListeners();
    } finally {
      if (revision == _revision) {
        _busyRunId = null;
        notifyListeners();
      }
    }
  }

  /// Fetch and arrange the day.
  Future<void> _fetch() async {
    final revision = _revision;
    final fetchId = ++_fetchId;
    Loadable<TodayBoard> next;
    try {
      final today = _todayString(_now());
      final runs = await _trips.myRuns(date: today);

      final active = runs.where((r) => r.isActive).firstOrNull;
      final upcoming = runs
          .where((r) => r.status == RunStatus.scheduled)
          .toList();
      final completed = runs.where((r) => r.isFinished).toList();

      final leading = active ?? upcoming.firstOrNull;
      next = Loadable.data(
        TodayBoard(
          headline: leading == null ? null : await _headlineFor(leading),
          active: active,
          // Nothing is "next" while a run is under way: the driver's next action
          // is to finish the one they are on, and offering another start button
          // beside it invites the wrong tap at the kerb.
          next: active == null ? upcoming.firstOrNull : null,
          later: active == null ? upcoming.skip(1).toList() : upcoming,
          completed: completed,
        ),
      );
    } on OfflineException {
      next = Loadable.failure(
        'You are offline. Showing what was last loaded.',
        previous: _board.valueOrNull,
      );
    } on TrotxiException catch (err) {
      next = Loadable.failure(err.message, previous: _board.valueOrNull);
    }
    if (revision != _revision || fetchId != _fetchId) return;
    _board = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _revision++;
    super.dispose();
  }

  /// Riders and stops for the run the board leads with.
  ///
  /// Failure is swallowed and the card simply omits the numbers: a driver
  /// needs to see the assignment far more than they need to see its headcount,
  /// and a manifest that will not load must not take Today down with it.
  ///
  /// @param run - the leading run.
  /// @returns its counts, or null when they could not be read.
  Future<RunHeadline?> _headlineFor(DriverRun run) async {
    try {
      final results = await Future.wait([
        _trips.manifest(run.id),
        _trips.stopsFor(run.id),
      ]);
      final riders = results[0] as List<ManifestRider>;
      return RunHeadline(
        riders: riders.length,
        morning: riders.where((r) => r.direction == 'morning').length,
        standby: riders.where((r) => r.isStandby).length,
        stops: (results[1] as List<DriverStop>).length,
      );
    } on TrotxiException {
      return null;
    }
  }

  /// Today in the corridor's clock.
  ///
  /// See [CorridorTime]: the API groups runs by UTC day and the screens render
  /// in the same frame, so asking and showing agree.
  ///
  /// @param now - the instant to read the day from.
  /// @returns the corridor's calendar day.
  static String _todayString(DateTime now) => CorridorTime.day(now);
}
