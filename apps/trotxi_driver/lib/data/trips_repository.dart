import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';

/// How far a run has got.
enum RunStatus { scheduled, active, completed, cancelled }

/// One of the driver's assigned runs, with the corridor's name resolved.
///
/// `GET /v1/driver/trips` returns `routeId`, but every frame in
/// the prototype labels a run by its corridor ("7:40 Medina · Circle"). The
/// repository joins the name on rather than making each screen do it, and
/// caches routes for the session since a depot runs a handful of corridors and
/// they do not change during a shift.
class DriverRun {
  const DriverRun({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.scheduledAt,
    required this.status,
    this.vehicleId,
    this.vehicleRegistration,
    this.currentStopSeq,
    this.assignmentChangedAt,
    this.serviceDate,
    this.direction,
    this.patternVersionId,
    this.editToken,
  });

  final String id;
  final String routeId;
  final String routeName;
  final String? serviceDate;
  final String? direction;
  final String? patternVersionId;
  final String? editToken;
  final DateTime scheduledAt;
  final RunStatus status;
  final String? vehicleId;

  /// Registration plate when supplied, falling back to the vehicle label.
  /// Null means the assignment has no vehicle information yet.
  final String? vehicleRegistration;

  /// The ordinal of the trip-owned occurrence the driver reported reaching.
  /// Used for display only; arrival commands send the occurrence ID, not this
  /// ordinal. Null before the first arrival; never guessed from GPS.
  final int? currentStopSeq;

  /// Optional change metadata. The replacement does not currently expose it,
  /// so its mapper leaves this null and the UI must not infer a change badge.
  final DateTime? assignmentChangedAt;

  bool get isActive => status == RunStatus.active;
  bool get isFinished =>
      status == RunStatus.completed || status == RunStatus.cancelled;

  /// Whether operations has moved this run recently enough to be worth
  /// flagging.
  ///
  /// Bounded rather than "ever changed": a run reassigned three weeks ago is
  /// simply the roster now, and a badge that never clears is one a driver stops
  /// reading — which would cost them the one that matters.
  bool get wasRecentlyChanged {
    final changed = assignmentChangedAt;
    if (changed == null) return false;
    return DateTime.now().difference(changed) < const Duration(days: 7);
  }
}

/// A rider on a run's manifest.
class ManifestRider {
  const ManifestRider({
    required this.reservationId,
    required this.name,
    required this.avatarUrl,
    required this.boarded,
    required this.direction,
    required this.source,
    required this.noShow,
  });

  final String reservationId;

  /// Null for a rider who never set one, which the manifest has to render
  /// rather than skip: the seat is still taken.
  final String? name;
  final String? avatarUrl;
  final bool boarded;

  /// Explicit pattern direction: outbound or return, not inferred time of day.
  final String direction;

  /// Not exposed by the replacement manifest. Null means unknown, so the UI
  /// shows a booked total rather than an invented confirmation/standby split.
  final String? source;

  /// Whether a driver has marked this rider as not having turned up (#227).
  /// They stay on the manifest: a mark made by mistake has to be findable, and
  /// a rider who catches up at the next stop is still boardable.
  final bool noShow;

  /// Filled from the standby pool rather than the rider's own confirmation.
  bool get isStandby => source == 'standby';

  String get directionLabel => switch (direction) {
    'outbound' => 'Outbound',
    'return_' || 'return' => 'Return',
    'morning' => 'Morning',
    'evening' => 'Evening',
    _ => direction,
  };
}

/// A trip-owned stop occurrence with its display ordering.
class DriverStop {
  const DriverStop({required this.seq, required this.name, this.occurrenceId});
  final String? occurrenceId;

  /// Occurrence ordinal; the command identity is [occurrenceId].
  final int seq;
  final String name;
}

/// What a finished run did.
class RunSummary {
  const RunSummary({
    required this.boarded,
    required this.notBoarded,
    required this.byQr,
    required this.byPin,
    required this.byPhoto,
    required this.stopCount,
    this.startedAt,
    this.completedAt,
  });

  final int boarded;

  /// Reported as "not boarded" rather than "no-shows": the deduction is the ops
  /// cutoff's decision, and a driver should not read one that has not happened.
  final int notBoarded;
  final int byQr;
  final int byPin;
  final int byPhoto;
  final int stopCount;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Duration? get duration => startedAt == null || completedAt == null
      ? null
      : completedAt!.difference(startedAt!);
}

/// Refreshed assigned-trip facts used by the composed run screen. Capacity is
/// unknown under the replacement contract; stop count comes from this trip's
/// immutable occurrences, not the corridor's newest revision.
class TripDetail {
  const TripDetail({
    required this.stopCount,
    this.capacity,
    this.vehicleRegistration,
    this.currentStopSeq,
    this.run,
  });

  /// Stops on the corridor — the "of 11" in the driver's stop counter. Zero
  /// when no stops are attached to the route yet.
  final int stopCount;
  final DriverRun? run;

  /// Seats on the van.
  ///
  /// Null for anyone who is not this run's assigned driver, which is how the
  /// API scopes it: a rider reading the same endpoint still gets null, because
  /// the seat count was never rider-facing. Null here therefore means "not
  /// ours to show", and the screen falls back to counting confirmed riders.
  final int? capacity;

  final String? vehicleRegistration;
  final int? currentStopSeq;
}

/// The driver's runs, their manifests, and the lifecycle transitions.
class TripsRepository {
  TripsRepository({
    required this.client,
    this.beginLifecycleChange,
    this.beforeComplete,
    this.completionFailed,
  });
  final DriverApi client;
  final Future<void> Function(String)? beforeComplete;
  final void Function()? completionFailed;
  final void Function(DriverRun) Function()? beginLifecycleChange;
  final Map<String, String> _seatTrips = {};
  int? _generation;

  void _sync() {
    if (_generation != client.store.generation) {
      _seatTrips.clear();
      _generation = client.store.generation;
    }
  }

  Future<DriverRun> _run(wire.DriverTrip t) async {
    var name = 'Route';
    try {
      name = await client.routeName(t.routeId);
    } on TrotxiException {
      /* Keep the assignment visible. */
    }
    final reached = t.stops
        .where((s) => s.id == t.currentStopOccurrenceId)
        .firstOrNull;
    return DriverRun(
      id: t.id,
      routeId: t.routeId,
      routeName: name,
      scheduledAt: t.scheduledAt,
      status: RunStatus.values.byName(t.status.name),
      vehicleRegistration: t.vehiclePlate ?? t.vehicleLabel,
      assignmentChangedAt: t.assignmentChangedAt,
      currentStopSeq: reached?.ordinal,
      serviceDate: t.serviceDate.toString(),
      direction: t.direction.name,
      patternVersionId: t.patternVersionId,
      editToken: t.editToken,
    );
  }

  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async {
    _sync();
    final generation = client.sessionGeneration;
    if ((date != null && (from != null || to != null)) ||
        ((from == null) != (to == null))) {
      throw const ApiException(400, 'Choose one day or a complete date range.');
    }
    final trips = await client.assigned(from: date ?? from, to: date ?? to);
    client.ensureSession(generation);
    final runs = await Future.wait(trips.map(_run));
    client.ensureSession(generation);
    return runs..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  Future<DriverRun> start(String runId) => _transition(runId, 'start');
  Future<DriverRun> complete(String runId) async {
    try {
      await beforeComplete?.call(runId);
      return await _transition(runId, 'complete');
    } catch (_) {
      completionFailed?.call();
      rethrow;
    }
  }

  Future<DriverRun> _transition(String id, String action) async {
    final observe = beginLifecycleChange?.call();
    final response = await client.post(
      '/v1/driver/trips/${Uri.encodeComponent(id)}/$action',
      wire.DriverTripResponse.serializer,
    );
    client.trips[id] = response.data;
    final run = await _run(response.data);
    observe?.call(run);
    return run;
  }

  Future<List<ManifestRider>> manifest(String runId) async {
    _sync();
    final trip = await client.trip(runId);
    final manifest = (await client.get(
      '/v1/driver/trips/${Uri.encodeComponent(runId)}/manifest',
      wire.ManifestResponse.serializer,
    )).data;
    if (manifest.tripId != runId || !manifest.complete) {
      throw const ApiException(502, 'The manifest is incomplete.');
    }
    for (final rider in manifest.riders) {
      _seatTrips[rider.reservationId] = runId;
    }
    return manifest.riders
        .where((r) => ['reserved', 'boarded', 'noShow'].contains(r.status.name))
        .map(
          (r) => ManifestRider(
            reservationId: r.reservationId,
            name: r.displayName,
            avatarUrl: r.avatarUrl,
            boarded: r.status.name == 'boarded',
            noShow: r.status.name == 'noShow' || r.status.name == 'no_show',
            direction: trip.direction.name,
            source: null,
          ),
        )
        .toList();
  }

  /// The argument is a trip ID: two directions/revisions on one corridor may
  /// visit the same stop more than once. Ordinals are display values only.
  Future<List<DriverStop>> stopsFor(String runId) async {
    final trip = await client.trip(runId);
    return trip.stops
        .map(
          (s) => DriverStop(seq: s.ordinal, name: s.name, occurrenceId: s.id),
        )
        .toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
  }

  Future<TripDetail> detail(String runId) async {
    final trip = await client.trip(runId, refresh: true);
    final reached = trip.stops
        .where((s) => s.id == trip.currentStopOccurrenceId)
        .firstOrNull;
    return TripDetail(
      stopCount: trip.stops.length,
      vehicleRegistration: trip.vehiclePlate ?? trip.vehicleLabel,
      currentStopSeq: reached?.ordinal,
      run: await _run(trip),
    );
  }

  Future<RunSummary> summary(String runId) async {
    final data = (await client.get(
      '/v1/driver/trips/${Uri.encodeComponent(runId)}/summary',
      wire.TripSummaryResponse.serializer,
    )).data;
    final trip = await client.trip(runId);
    return RunSummary(
      boarded: data.boarded,
      notBoarded: data.noShows + data.unseated,
      byQr: data.scanned,
      byPin: data.codeVerified,
      byPhoto: data.photoVerified,
      stopCount: trip.stops.length,
      startedAt: trip.startedAt,
      completedAt: trip.completedAt,
    );
  }

  Future<DriverRun> arriveAtStop(
    String runId,
    int seq, {
    String? editToken,
    bool correction = false,
  }) async {
    // Use the row the UI read, not a silently refreshed token that could mask
    // a concurrent arrival or ops change. 412 requires an explicit reload.
    final trip = await client.trip(runId);
    final stop = trip.stops.where((s) => s.ordinal == seq).firstOrNull;
    if (stop == null) {
      throw const ApiException(400, 'That stop is not on this run.');
    }
    final response = await client.post(
      '/v1/driver/trips/${Uri.encodeComponent(runId)}/arrivals',
      wire.DriverTripResponse.serializer,
      ifMatch: editToken ?? trip.editToken,
      body: {'stopOccurrenceId': stop.id, 'correction': correction},
    );
    client.trips[runId] = response.data;
    return _run(response.data);
  }

  String _tripForSeat(String reservationId) {
    _sync();
    final trip = _seatTrips[reservationId];
    if (trip == null) {
      throw const ApiException(409, 'Reload the manifest before boarding.');
    }
    return trip;
  }

  Future<BoardingResult> boardFromManifest(String reservationId) async {
    try {
      return await _board(_tripForSeat(reservationId), {
        'kind': 'photo',
        'reservationId': reservationId,
      });
    } on TrotxiException catch (error) {
      return _boardingFailure(error);
    }
  }

  Future<NoShowResult> markNoShow(String reservationId) async {
    try {
      final trip = _tripForSeat(reservationId);
      final result = (await client.post(
        '/v1/driver/trips/${Uri.encodeComponent(trip)}/reservations/${Uri.encodeComponent(reservationId)}/no-show',
        wire.BoardingResultResponse.serializer,
      )).data;
      return result.status.name == 'boarded'
          ? NoShowResult.alreadyBoarded
          : NoShowResult.marked;
    } on OfflineException {
      return NoShowResult.offline;
    } on ApiException catch (error) {
      return error.statusCode == 404 || error.statusCode == 403
          ? NoShowResult.forbidden
          : NoShowResult.failed;
    } on TrotxiException {
      return NoShowResult.failed;
    }
  }

  Future<BoardingResult> scan({required String pass, required String runId}) =>
      _board(runId, {'kind': 'qr', 'token': pass});
  Future<BoardingResult> boardByCodeOnRun({
    required String runId,
    required String code,
  }) => _board(runId, {'kind': 'code', 'code': code.toUpperCase()});

  Future<BoardingResult> _board(
    String runId,
    Map<String, dynamic> proof,
  ) async {
    try {
      final result = (await client.post(
        '/v1/driver/trips/${Uri.encodeComponent(runId)}/boardings',
        wire.BoardingResultResponse.serializer,
        body: proof,
      )).data;
      return BoardingResult(
        outcome: result.alreadyApplied
            ? BoardingOutcome.alreadyBoarded
            : BoardingOutcome.ok,
        reservationId: result.reservationId,
        deducted: result.chargedRides > 0,
      );
    } on TrotxiException catch (error) {
      return _boardingFailure(error, kind: proof['kind'] as String);
    }
  }

  BoardingResult _boardingFailure(TrotxiException error, {String? kind}) {
    final outcome = switch (error) {
      OfflineException() => BoardingOutcome.offline,
      UnauthorizedException() ||
      InvalidCredentialsException() => BoardingOutcome.sessionExpired,
      ApiException(statusCode: 404) ||
      ApiException(statusCode: 403) => BoardingOutcome.forbidden,
      ApiException(code: 'boarding_pass_reused') => BoardingOutcome.reused,
      ApiException(code: 'invalid_boarding_proof') =>
        kind == 'code' ? BoardingOutcome.codeNotFound : BoardingOutcome.invalid,
      _ => BoardingOutcome.failed,
    };
    return BoardingResult(
      outcome: outcome,
      failureMessage: switch (error) {
        ApiException(code: 'boarding_ineligible') ||
        ApiException(code: 'insufficient_rides') => error.message,
        _ => null,
      },
    );
  }
}
