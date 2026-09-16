import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// The location lifetime is a confirmed session plus an active trip, never a
/// particular page. No background permissions or foreground service is added.
class DriverLocationController with WidgetsBindingObserver {
  DriverLocationController({
    required this.trips,
    required this.publisher,
    this.refreshEvery = const Duration(seconds: 30),
  }) {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  final TripsRepository trips;
  final PositionPublisher publisher;
  final Duration refreshEvery;
  bool _ready = false;
  bool _foreground = false;
  bool _disposed = false;
  bool _refreshing = false;
  int _revision = 0;
  int _sessionGeneration = 0;
  DriverRun? _active;
  Timer? _poll;

  void setSessionReady(bool ready) {
    if (_disposed || _ready == ready) return;
    _ready = ready;
    _sessionGeneration++;
    _revision++;
    _active = null;
    _poll?.cancel();
    unawaited(publisher.stop());
    if (ready) {
      _poll = Timer.periodic(refreshEvery, (_) => unawaited(refresh()));
      unawaited(refresh());
    }
  }

  /// Called from successful lifecycle responses, before the UI navigates.
  /// Incrementing the revision prevents an older roster read undoing a start
  /// or reviving a trip that was just completed.
  void observeRun(DriverRun run) {
    if (!_ready || _disposed) return;
    _revision++;
    if (run.isActive) {
      _active = run;
    } else if (_active?.id == run.id) {
      _active = null;
    }
    _sync();
  }

  void Function(DriverRun) captureRunObserver() {
    final session = _sessionGeneration;
    return (run) {
      if (session == _sessionGeneration) observeRun(run);
    };
  }

  Future<void> refresh() async {
    if (!_ready || !_foreground || _disposed || _refreshing) return;
    _refreshing = true;
    final revision = _revision;
    try {
      // Not date-filtered: a trip crossing midnight is still under way.
      final runs = await trips.myRuns();
      if (revision != _revision || _disposed) return;
      _active = runs.where((run) => run.isActive).firstOrNull;
      _sync();
    } on UnauthorizedException {
      if (revision != _revision || _disposed) return;
      _active = null;
      _sync();
    } on TrotxiException {
      // A failed refresh is not evidence that the active trip ended. Keep
      // trying foreground uploads; their acknowledgement controls the label.
      if (revision == _revision && !_disposed) _sync();
    } finally {
      _refreshing = false;
    }
  }

  void _sync() {
    final active = _active;
    if (_ready && _foreground && active != null && !_disposed) {
      unawaited(publisher.start(active.id));
    } else {
      unawaited(publisher.stop());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (_foreground == foreground || _disposed) return;
    _foreground = foreground;
    _revision++;
    _sync();
    if (foreground) unawaited(refresh());
  }

  void dispose() {
    _disposed = true;
    _revision++;
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(publisher.stop());
  }
}
