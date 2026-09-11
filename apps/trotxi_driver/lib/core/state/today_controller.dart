import 'package:flutter/foundation.dart';
import 'package:trotxi_client/trotxi_client.dart';
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
  });

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
  bool get isEmpty => active == null && next == null && later.isEmpty && completed.isEmpty;

  /// Everything assigned is done.
  bool get isDayDone => active == null && next == null && later.isEmpty && completed.isNotEmpty;
}

/// Today's assignments (prototype frames 14 to 18).
class TodayController extends ChangeNotifier {
  TodayController({required TripsRepository trips, DateTime Function()? now})
    : _trips = trips,
      _now = now ?? DateTime.now;

  final TripsRepository _trips;

  /// Injectable so "which day is it" is testable without waiting for midnight.
  final DateTime Function() _now;

  Loadable<TodayBoard> _board = const Loadable.idle();
  Loadable<TodayBoard> get board => _board;

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
  Future<void> complete(String runId) => _act(runId, () => _trips.complete(runId));

  /// Run a lifecycle transition, then reload so the board reflects it.
  ///
  /// The reload is what keeps the screen honest: start() returns one run, but
  /// which card is "next" and what falls into "later" is a property of the
  /// whole day, not of the run that changed.
  ///
  /// @param runId - the run being changed.
  /// @param action - the transition to run.
  Future<void> _act(String runId, Future<DriverRun> Function() action) async {
    _busyRunId = runId;
    notifyListeners();
    try {
      await action();
      await _fetch();
    } on TrotxiException catch (err) {
      _board = Loadable.failure(err.message, previous: _board.valueOrNull);
      notifyListeners();
    } finally {
      _busyRunId = null;
      notifyListeners();
    }
  }

  /// Fetch and arrange the day.
  Future<void> _fetch() async {
    try {
      final today = _todayString(_now());
      final runs = await _trips.myRuns(date: today);

      final active = runs.where((r) => r.isActive).firstOrNull;
      final upcoming = runs.where((r) => r.status == RunStatus.scheduled).toList();
      final completed = runs.where((r) => r.isFinished).toList();

      _board = Loadable.data(
        TodayBoard(
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
      _board = Loadable.failure(
        'You are offline. Showing what was last loaded.',
        previous: _board.valueOrNull,
      );
    } on TrotxiException catch (err) {
      _board = Loadable.failure(err.message, previous: _board.valueOrNull);
    }
    notifyListeners();
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
