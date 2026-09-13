import 'package:flutter/foundation.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Everything one run's screen needs, loaded together.
class RunDetail {
  const RunDetail({
    required this.run,
    required this.riders,
    required this.stops,
    this.capacity,
    this.vehicleRegistration,
  });

  final DriverRun run;
  final List<ManifestRider> riders;

  /// The corridor's stops in order, for the "stop N of M" counter.
  final List<DriverStop> stops;

  /// The van's seat ceiling (#230), or null when this run has no vehicle
  /// assigned yet. Reachable now that `GET /trips/:id` serves it to the trip's
  /// own assigned driver; it used to live only behind the admin API.
  final int? capacity;

  /// The plate, from `GET /trips/:id`. The hero's second line reads
  /// "GT 4821-22 · ACTIVE RUN"; null until a vehicle is assigned, and the line
  /// drops the plate rather than inventing one.
  final String? vehicleRegistration;

  int get boarded => riders.where((r) => r.boarded).length;

  /// Confirmed seats: how many of the people who said they were coming there
  /// are to board.
  int get expected => riders.length;

  /// What the boarding counter counts against.
  ///
  /// The seat ceiling when the API gives one, and confirmed riders otherwise.
  /// The fallback is not a lesser answer — a run with no vehicle assigned has
  /// no ceiling to show, and "4 of 12 confirmed" is still the number that
  /// matters at a kerb.
  int get ceiling => capacity ?? riders.length;

  /// Whether [ceiling] is the van's real capacity rather than the fallback, so
  /// the screen can label it honestly instead of calling confirmed riders a
  /// seat count.
  bool get hasCapacity => capacity != null;

  /// Riders still to board. A no-show is not waiting — the driver has already
  /// said they did not turn up — but stays on the manifest so the mark can be
  /// undone.
  List<ManifestRider> get waiting =>
      riders.where((r) => !r.boarded && !r.noShow).toList();

  /// Seats filled from the standby pool (#230), the "· 6 standby" half of the
  /// Today breakdown.
  int get standby => riders.where((r) => r.isStandby).length;

  /// How far along the corridor the driver has reported being (#230).
  int? get currentStopSeq => run.currentStopSeq;

  /// Display position in the ordered route, independent of server numbering.
  int? get currentStopNumber {
    final index = stops.indexWhere((stop) => stop.seq == currentStopSeq);
    return index < 0 ? null : index + 1;
  }

  /// The stop the driver last reported reaching, or null before the first
  /// arrival.
  String? get currentStopName {
    final number = currentStopNumber;
    return number == null ? null : stops[number - 1].name;
  }
}

/// One run's detail (prototype frames 19 to 24), and its manifest.
class RunController extends ChangeNotifier {
  RunController({required this._trips, required this._run});

  final TripsRepository _trips;
  DriverRun _run;

  Loadable<RunDetail> _detail = const Loadable.idle();
  Loadable<RunDetail> get detail => _detail;

  bool _transitioning = false;
  bool get isTransitioning => _transitioning;

  /// Load or reload the run and its manifest.
  Future<void> load() async {
    _detail = Loadable.loading(previous: _detail.valueOrNull);
    notifyListeners();
    await _fetch();
  }

  /// Refresh just the manifest, after a boarding.
  ///
  /// Cheaper than [load] and the only thing that changes when someone boards,
  /// so the counters move without the stop list being fetched again.
  Future<void> refreshManifest() async {
    final current = _detail.valueOrNull;
    if (current == null) return load();
    try {
      final riders = await _trips.manifest(_run.id);
      _detail = Loadable.data(
        RunDetail(
          run: current.run,
          riders: riders,
          stops: current.stops,
          capacity: current.capacity,
          vehicleRegistration: current.vehicleRegistration,
        ),
      );
    } on TrotxiException catch (err) {
      _detail = Loadable.failure(err.message, previous: current);
    }
    notifyListeners();
  }

  /// Start this run.
  Future<bool> start() => _transition(() => _trips.start(_run.id));

  /// End this run.
  Future<bool> complete() => _transition(() => _trips.complete(_run.id));

  /// Report reaching a stop (#230).
  ///
  /// Optimistic in neither direction: the counter moves only once the server
  /// has taken it, because a driver who saw "Stop 4" and then saw it snap back
  /// would stop trusting the number.
  ///
  /// @param seq - the stop reached, as a route sequence number.
  Future<void> arriveAtStop(int seq) async {
    final current = _detail.valueOrNull;
    try {
      _run = await _trips.arriveAtStop(_run.id, seq);
      if (current != null) {
        _detail = Loadable.data(
          RunDetail(
            run: _run,
            riders: current.riders,
            stops: current.stops,
            capacity: current.capacity,
            vehicleRegistration: current.vehicleRegistration,
          ),
        );
      }
    } on TrotxiException catch (err) {
      _detail = Loadable.failure(err.message, previous: current);
    }
    notifyListeners();
  }

  /// Board a rider straight off the manifest (#227), then refresh it.
  ///
  /// @param reservationId - the seat the driver tapped.
  /// @returns the outcome, for the screen to report.
  Future<BoardingResult> boardFromManifest(String reservationId) async {
    final result = await _trips.boardFromManifest(reservationId);
    if (result.isAccepted || result.outcome == BoardingOutcome.alreadyBoarded) {
      await refreshManifest();
    }
    return result;
  }

  /// Mark a rider as not having turned up (#227), then refresh the manifest.
  ///
  /// @param reservationId - the seat the driver tapped.
  /// @returns the outcome, for the screen to report.
  Future<NoShowResult> markNoShow(String reservationId) async {
    final result = await _trips.markNoShow(reservationId);
    if (result == NoShowResult.marked) await refreshManifest();
    return result;
  }

  Future<bool> _transition(Future<DriverRun> Function() action) async {
    _transitioning = true;
    notifyListeners();
    try {
      _run = await action();
      final previous = _detail.valueOrNull;
      if (previous != null) {
        // Preserve the accepted lifecycle response even if the subsequent
        // manifest/detail refresh fails. Do not leave a completed run active.
        _detail = Loadable.data(
          RunDetail(
            run: _run,
            riders: previous.riders,
            stops: previous.stops,
            capacity: previous.capacity,
            vehicleRegistration: previous.vehicleRegistration,
          ),
        );
      }
      await _fetch();
      return true;
    } on TrotxiException catch (err) {
      _detail = Loadable.failure(err.message, previous: _detail.valueOrNull);
      notifyListeners();
      return false;
    } finally {
      _transitioning = false;
      notifyListeners();
    }
  }

  Future<void> _fetch() async {
    try {
      // In parallel: the manifest, the stop list and the run's own detail are
      // independent, and a driver waiting at a stop should not pay for them in
      // series.
      final riders = _trips.manifest(_run.id);
      final stops = _trips.stopsFor(_run.routeId);
      final detail = _trips.detail(_run.id);
      final facts = await detail;
      _detail = Loadable.data(
        RunDetail(
          run: _run,
          riders: await riders,
          stops: await stops,
          capacity: facts.capacity,
          vehicleRegistration: facts.vehicleRegistration,
        ),
      );
    } on OfflineException {
      _detail = Loadable.failure(
        'You are offline. Showing the last manifest loaded.',
        previous: _detail.valueOrNull,
      );
    } on TrotxiException catch (err) {
      _detail = Loadable.failure(err.message, previous: _detail.valueOrNull);
    }
    notifyListeners();
  }
}
