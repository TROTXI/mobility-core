import 'package:flutter/foundation.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Everything one run's screen needs, loaded together.
class RunDetail {
  const RunDetail({
    required this.run,
    required this.riders,
    required this.stops,
  });

  final DriverRun run;
  final List<ManifestRider> riders;

  /// The corridor's stops in order, for the "stop N of M" counter.
  final List<String> stops;

  int get boarded => riders.where((r) => r.boarded).length;

  /// Confirmed seats, which is what the counter is against.
  ///
  /// NOT the vehicle's capacity. Capacity lives on `vehicles` and is only
  /// exposed through the admin API, so a driver's token cannot read it. Against
  /// confirmed riders the number is still the one that matters at the kerb:
  /// how many of the people who said they were coming are aboard.
  int get expected => riders.length;

  List<ManifestRider> get waiting => riders.where((r) => !r.boarded).toList();
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
        RunDetail(run: current.run, riders: riders, stops: current.stops),
      );
    } on TrotxiException catch (err) {
      _detail = Loadable.failure(err.message, previous: current);
    }
    notifyListeners();
  }

  /// Start this run.
  Future<void> start() => _transition(() => _trips.start(_run.id));

  /// End this run.
  Future<void> complete() => _transition(() => _trips.complete(_run.id));

  Future<void> _transition(Future<DriverRun> Function() action) async {
    _transitioning = true;
    notifyListeners();
    try {
      _run = await action();
      await _fetch();
    } on TrotxiException catch (err) {
      _detail = Loadable.failure(err.message, previous: _detail.valueOrNull);
      notifyListeners();
    } finally {
      _transitioning = false;
      notifyListeners();
    }
  }

  Future<void> _fetch() async {
    try {
      // In parallel: the manifest and the stop list are independent, and a
      // driver waiting at a stop should not pay for them in series.
      final results = await Future.wait([
        _trips.manifest(_run.id),
        _trips.stopsFor(_run.routeId),
      ]);
      _detail = Loadable.data(
        RunDetail(
          run: _run,
          riders: results[0] as List<ManifestRider>,
          stops: results[1] as List<String>,
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
