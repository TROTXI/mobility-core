import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';

/// How far a run has got.
enum RunStatus { scheduled, active, completed, cancelled }

/// One of the driver's assigned runs, with the corridor's name resolved.
///
/// `GET /me/trips` returns `routeId` and nothing readable, but every frame in
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
  });

  final String id;
  final String routeId;
  final String routeName;
  final DateTime scheduledAt;
  final RunStatus status;
  final String? vehicleId;

  /// The plate, once a run has told us which vehicle it is. The header shows it
  /// beside the driver's name; null until then, because inventing a plate is
  /// worse than showing none.
  final String? vehicleRegistration;

  /// Which stop the driver has reported reaching (#230), as a route sequence
  /// number. Null before the first arrival, which is the honest answer — the
  /// API deliberately does not guess one from GPS.
  final int? currentStopSeq;

  /// When operations last moved this run: driver, vehicle or departure time
  /// (#233). Null on a run nobody has touched.
  ///
  /// The Schedule marks a run CHANGED from this rather than from the push that
  /// announced it, so a phone that was switched off at 04:00 still finds out.
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
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.boarded,
    required this.direction,
    required this.source,
    required this.noShow,
  });

  final String reservationId;
  final String userId;

  /// Null for a rider who never set one, which the manifest has to render
  /// rather than skip: the seat is still taken.
  final String? name;
  final String? avatarUrl;
  final bool boarded;

  /// `morning` or `evening`. The manifest splits on it, and the Today card
  /// shows the morning share.
  final String direction;

  /// How the seat was taken: `confirmation`, `default` or `standby` (#230).
  /// The Today card breaks a run down as "12 morning · 6 standby", which was
  /// unanswerable while this was stored but never returned.
  final String source;

  /// Whether a driver has marked this rider as not having turned up (#227).
  /// They stay on the manifest: a mark made by mistake has to be findable, and
  /// a rider who catches up at the next stop is still boardable.
  final bool noShow;

  /// Filled from the standby pool rather than the rider's own confirmation.
  bool get isStandby => source == 'standby';
}

/// A corridor stop retaining the sequence understood by the API.
class DriverStop {
  const DriverStop({required this.seq, required this.name});

  /// Server sequence, not the one-based ordinal displayed to the driver.
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

/// What `GET /trips/:id` adds beyond the list (#230).
///
/// Named after the endpoint rather than the screen: `RunDetail` in
/// `run_controller.dart` is the composed view a screen renders, and this is the
/// raw extra the API returns.
///
/// Two numbers the run screen could not previously get: the van's seat ceiling,
/// and how many stops the corridor has. Both arrive together because they come
/// from the same request.
class TripDetail {
  const TripDetail({
    required this.stopCount,
    this.capacity,
    this.vehicleRegistration,
    this.currentStopSeq,
  });

  /// Stops on the corridor — the "of 11" in the driver's stop counter. Zero
  /// when no stops are attached to the route yet.
  final int stopCount;

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
  TripsRepository({required this._client, this.beginLifecycleChange});

  final TrotxiApiClient _client;

  /// Capture the current session before a request. A delayed response must not
  /// start location sharing after a different driver has signed in.
  final void Function(DriverRun) Function()? beginLifecycleChange;

  /// Corridor names by route id. A depot runs a handful of corridors and they
  /// do not change mid-shift, so one lookup each is plenty.
  final Map<String, String> _routeNames = {};

  /// The signed-in driver's assigned runs.
  ///
  /// Takes one day or an inclusive range, never both. The range is what makes
  /// the month calendar a single request rather than thirty-one (#231); both
  /// forms filter on the UTC calendar day, which is why every caller sends
  /// corridor time.
  ///
  /// @param date - optional `YYYY-MM-DD` filter for a single day.
  /// @param from - optional inclusive range start (`YYYY-MM-DD`).
  /// @param to - optional inclusive range end; required with [from].
  /// @returns the runs, soonest first.
  Future<List<DriverRun>> myRuns({
    String? date,
    String? from,
    String? to,
  }) async {
    try {
      final response = await _client.getMobilityApi().meTripsGet(
        date: date,
        from: from,
        to: to,
      );
      final trips = response.data?.trips.toList() ?? [];

      // Resolved once per unseen corridor, in parallel: a driver with a morning
      // and an evening run on the same route should not pay for two lookups.
      final unknown = trips.map((t) => t.routeId).toSet()
        ..removeWhere(_routeNames.containsKey);
      await Future.wait(unknown.map(_cacheRouteName));

      final runs =
          trips
              .map(
                (t) => DriverRun(
                  id: t.id,
                  routeId: t.routeId,
                  routeName: _routeNames[t.routeId] ?? 'Route',
                  scheduledAt: t.scheduledAt,
                  status: _statusOf(t.status.name),
                  vehicleId: t.vehicleId,
                  currentStopSeq: t.currentStopSeq,
                  assignmentChangedAt: t.assignmentChangedAt,
                ),
              )
              .toList()
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return runs;
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Start a run. Idempotent server-side: starting an already-active run
  /// succeeds, because a driver whose phone dropped mid-tap will press it again
  /// and an error at the roadside is a worse answer than "yes, it is running".
  ///
  /// @param runId - the run to start.
  /// @returns the run in its new state.
  Future<DriverRun> start(String runId) => _transition(runId, start: true);

  /// End a run. Refused server-side if it never started.
  ///
  /// @param runId - the run to complete.
  /// @returns the run in its new state.
  Future<DriverRun> complete(String runId) => _transition(runId, start: false);

  /// The confirmed riders on a run, with who has boarded.
  ///
  /// @param runId - the run.
  /// @returns the manifest.
  Future<List<ManifestRider>> manifest(String runId) async {
    try {
      final response = await _client.getBoardingApi().boardingManifestGet(
        tripId: runId,
      );
      return (response.data?.riders.toList() ?? [])
          .map(
            (r) => ManifestRider(
              reservationId: r.reservationId,
              userId: r.userId,
              name: r.name,
              avatarUrl: r.avatarUrl,
              boarded: r.boarded,
              direction: r.direction.name,
              // `source_` with the underscore: the generator renames a field
              // that would otherwise collide in the built_value output.
              source: r.source_.name,
              noShow: r.noShow,
            ),
          )
          .toList();
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// What a run did.
  ///
  /// @param runId - the run.
  /// @returns the summary.
  Future<RunSummary> summary(String runId) async {
    try {
      final response = await _client.getMobilityApi().tripsIdSummaryGet(
        id: runId,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(200, 'Summary returned nothing.');
      }
      return RunSummary(
        boarded: data.boarded,
        notBoarded: data.notBoarded,
        byQr: data.byMethod.qr,
        byPin: data.byMethod.pin,
        byPhoto: data.byMethod.photo,
        stopCount: data.stopCount,
        startedAt: data.startedAt,
        completedAt: data.completedAt,
      );
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// The corridor's stops, in order, for the stop list and progress counter.
  ///
  /// @param routeId - the corridor.
  /// @returns the stop names in sequence.
  Future<List<DriverStop>> stopsFor(String routeId) async {
    try {
      final response = await _client.getMobilityApi().routesIdGet(id: routeId);
      return (response.data?.stops.toList() ?? [])
          .map((s) => DriverStop(seq: s.seq, name: s.name))
          .toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// The extra detail one run carries: seat ceiling and stop count (#230).
  ///
  /// @param runId - the run.
  /// @returns the detail.
  Future<TripDetail> detail(String runId) async {
    try {
      final response = await _client.getMobilityApi().tripsIdGet(id: runId);
      final data = response.data;
      if (data == null) {
        throw const ApiException(200, 'The run returned nothing.');
      }
      return TripDetail(
        stopCount: data.stopCount,
        capacity: data.vehicle?.capacity,
        vehicleRegistration: data.vehicle?.registration,
        currentStopSeq: data.currentStopSeq,
      );
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Report reaching a stop (#230).
  ///
  /// Driver-advanced rather than derived from GPS, and not monotonic: a driver
  /// who taps one stop too far can tap back, because a counter stuck wrong for
  /// the rest of a run is worse than one that can be corrected.
  ///
  /// @param runId - the run.
  /// @param seq - the stop reached, as a route sequence number.
  /// @returns the run with its progress advanced.
  Future<DriverRun> arriveAtStop(String runId, int seq) async {
    try {
      final response = await _client.getMobilityApi().tripsIdArrivePost(
        id: runId,
        tripsIdArrivePostRequest: TripsIdArrivePostRequest((b) => b.seq = seq),
      );
      final trip = response.data;
      if (trip == null) {
        throw const ApiException(200, 'The run returned nothing.');
      }
      await _cacheRouteName(trip.routeId);
      return DriverRun(
        id: trip.id,
        routeId: trip.routeId,
        routeName: _routeNames[trip.routeId] ?? 'Route',
        scheduledAt: trip.scheduledAt,
        status: _statusOf(trip.status.name),
        vehicleId: trip.vehicleId,
        currentStopSeq: trip.currentStopSeq,
        assignmentChangedAt: trip.assignmentChangedAt,
      );
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Board a rider the driver has identified from the manifest photo (#227).
  ///
  /// No code is asked for, which is the whole point: the photo pass exists for
  /// the case where a code will not scan or the rider cannot produce one, and
  /// demanding one here would defeat the fallback it is.
  ///
  /// @param reservationId - the seat from the manifest.
  /// @returns the outcome.
  Future<BoardingResult> boardFromManifest(String reservationId) async {
    try {
      final response = await _client.getBoardingApi().boardingBoardPost(
        boardingBoardPostRequest: BoardingBoardPostRequest(
          (b) => b.reservationId = reservationId,
        ),
      );
      final data = response.data;
      if (data == null) {
        return const BoardingResult(outcome: BoardingOutcome.failed);
      }
      return BoardingResult(
        outcome: switch (data.reason.name) {
          'ok' => BoardingOutcome.ok,
          'alreadyBoarded' ||
          'already_boarded' => BoardingOutcome.alreadyBoarded,
          // The seat was declined, released or never confirmed, so it is not a
          // seat. Reads as "no reservation" because that is what it means to a
          // driver holding a queue.
          'notBoardable' || 'not_boardable' => BoardingOutcome.noReservation,
          'notFound' || 'not_found' => BoardingOutcome.noReservation,
          _ => BoardingOutcome.failed,
        },
        riderId: data.riderId,
        deducted: data.deducted,
      );
    } on DioException catch (err) {
      return _boardingFailure(err);
    }
  }

  /// Mark one rider as not having turned up (#227).
  ///
  /// Final for the seat and debited now, because the driver at the stop knows
  /// and the cutoff sweep hours later does not. Reversible by boarding them
  /// afterwards, which costs the rider nothing extra — both paths share the
  /// same ledger key.
  ///
  /// @param reservationId - the seat from the manifest.
  /// @returns the outcome.
  Future<NoShowResult> markNoShow(String reservationId) async {
    try {
      // Both endpoints take the same one-field body, so the generator folded
      // them onto a single request type.
      final response = await _client.getBoardingApi().boardingNoShowPost(
        boardingBoardPostRequest: BoardingBoardPostRequest(
          (b) => b.reservationId = reservationId,
        ),
      );
      final reason = response.data?.reason.name ?? '';
      return switch (reason) {
        'ok' => NoShowResult.marked,
        'alreadyNoShow' || 'already_no_show' => NoShowResult.marked,
        'alreadyBoarded' || 'already_boarded' => NoShowResult.alreadyBoarded,
        _ => NoShowResult.failed,
      };
    } on DioException catch (err) {
      final inner = err.error;
      if (inner is OfflineException) return NoShowResult.offline;
      if (inner is ApiException && inner.statusCode == 403) {
        return NoShowResult.forbidden;
      }
      return NoShowResult.failed;
    }
  }

  /// Board a rider from a scanned QR pass.
  ///
  /// @param pass - the token decoded from the QR.
  /// @param runId - the run being boarded.
  /// @returns the outcome, with the rider when the pass identified one.
  Future<BoardingResult> scan({
    required String pass,
    required String runId,
  }) async {
    try {
      final response = await _client.getBoardingApi().boardingScanPost(
        boardingScanPostRequest: BoardingScanPostRequest(
          (b) => b
            ..pass = pass
            ..tripId = runId,
        ),
      );
      final data = response.data;
      if (data == null) {
        return const BoardingResult(outcome: BoardingOutcome.invalid);
      }
      return BoardingResult(
        outcome: switch (data.reason.name) {
          'ok' => BoardingOutcome.ok,
          'expired' => BoardingOutcome.expired,
          'reused' => BoardingOutcome.reused,
          _ => BoardingOutcome.invalid,
        },
        riderId: data.riderId,
        deducted: data.deducted,
      );
    } on DioException catch (err) {
      return _boardingFailure(err);
    }
  }

  /// Board whoever holds this code on this run (#241).
  ///
  /// No rider is named first, which is the point: a driver at a door takes the
  /// code they were just read and acts on it. The server searches the run's
  /// open seats.
  ///
  /// @param runId - the run being boarded.
  /// @param code - the four-character code as typed.
  /// @returns the outcome, with the rider when the code named one.
  Future<BoardingResult> boardByCodeOnRun({
    required String runId,
    required String code,
  }) async {
    try {
      final response = await _client.getBoardingApi().boardingVerifyCodePost(
        boardingVerifyCodePostRequest: BoardingVerifyCodePostRequest(
          (b) => b
            ..tripId = runId
            ..code = code,
        ),
      );
      final data = response.data;
      if (data == null) {
        return const BoardingResult(outcome: BoardingOutcome.failed);
      }
      return BoardingResult(
        outcome: switch (data.reason.name) {
          'ok' => BoardingOutcome.ok,
          'alreadyBoarded' ||
          'already_boarded' => BoardingOutcome.alreadyBoarded,
          'ambiguous' => BoardingOutcome.ambiguous,
          // Four characters nobody on this run holds, which at a door is
          // almost always a mishearing rather than a forgery.
          'invalid' => BoardingOutcome.codeNotFound,
          _ => BoardingOutcome.failed,
        },
        riderId: data.riderId,
        deducted: data.deducted,
      );
    } on DioException catch (err) {
      return _boardingFailure(err);
    }
  }

  /// Board a rider by the daily code they read out.
  ///
  /// @param reservationId - the seat from the manifest.
  /// @param code - the four-character code as typed.
  /// @returns the outcome.
  Future<BoardingResult> boardByCode({
    required String reservationId,
    required String code,
  }) async {
    try {
      final response = await _client.getBoardingApi().boardingVerifyPinPost(
        boardingVerifyPinPostRequest: BoardingVerifyPinPostRequest(
          (b) => b
            ..reservationId = reservationId
            ..pin = code,
        ),
      );
      final data = response.data;
      if (data == null) {
        return const BoardingResult(outcome: BoardingOutcome.invalid);
      }
      return BoardingResult(
        outcome: switch (data.reason.name) {
          'ok' => BoardingOutcome.ok,
          'already_boarded' => BoardingOutcome.alreadyBoarded,
          'not_found' => BoardingOutcome.noReservation,
          // The driver already knows who they mean, so this is "wrong code for
          // this person", not "unknown pass".
          _ => BoardingOutcome.codeMismatch,
        },
        riderId: data.riderId,
        deducted: data.deducted,
      );
    } on DioException catch (err) {
      return _boardingFailure(err);
    }
  }

  /// Turn a transport failure into an outcome rather than an exception.
  ///
  /// Boarding happens at a door with people waiting, so every path has to end
  /// in something the driver can read and act on.
  ///
  /// @param err - the caught Dio exception.
  /// @returns the outcome to show.
  BoardingResult _boardingFailure(DioException err) {
    final inner = err.error;
    if (inner is OfflineException) {
      return const BoardingResult(outcome: BoardingOutcome.offline);
    }
    // A dead session is NOT a bad pass. Saying "pass not accepted" to a driver
    // whose token expired turns our problem into an accusation about a paying
    // rider, and turns them away at the door.
    if (inner is UnauthorizedException ||
        inner is InvalidCredentialsException) {
      return const BoardingResult(outcome: BoardingOutcome.sessionExpired);
    }
    if (inner is ApiException && inner.statusCode == 403) {
      return const BoardingResult(outcome: BoardingOutcome.forbidden);
    }
    // Only the API actually saying so makes a pass invalid. Everything else is
    // our failure and has to read as one.
    return const BoardingResult(outcome: BoardingOutcome.failed);
  }

  /// Shared start/complete path.
  ///
  /// @param runId - the run.
  /// @param start - true to start, false to complete.
  /// @returns the run in its new state.
  Future<DriverRun> _transition(String runId, {required bool start}) async {
    final reportChange = beginLifecycleChange?.call();
    try {
      final api = _client.getMobilityApi();
      final response = start
          ? await api.tripsIdStartPost(id: runId)
          : await api.tripsIdCompletePost(id: runId);
      final trip = response.data;
      if (trip == null) {
        throw const ApiException(200, 'The run returned nothing.');
      }
      final run = DriverRun(
        id: trip.id,
        routeId: trip.routeId,
        routeName: _routeNames[trip.routeId] ?? 'Route',
        scheduledAt: trip.scheduledAt,
        status: _statusOf(trip.status.name),
        vehicleId: trip.vehicleId,
        currentStopSeq: trip.currentStopSeq,
        assignmentChangedAt: trip.assignmentChangedAt,
      );
      reportChange?.call(run);
      await _cacheRouteName(trip.routeId);
      return DriverRun(
        id: run.id,
        routeId: run.routeId,
        routeName: _routeNames[run.routeId] ?? run.routeName,
        scheduledAt: run.scheduledAt,
        status: run.status,
        vehicleId: run.vehicleId,
        currentStopSeq: run.currentStopSeq,
        assignmentChangedAt: run.assignmentChangedAt,
      );
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Look up and remember a corridor's name.
  ///
  /// Failure is swallowed: a run with an unresolved name still has to appear on
  /// Today, because a driver who cannot see their assignment cannot work.
  ///
  /// @param routeId - the corridor to resolve.
  Future<void> _cacheRouteName(String routeId) async {
    if (_routeNames.containsKey(routeId)) return;
    try {
      final response = await _client.getMobilityApi().routesIdGet(id: routeId);
      final name = response.data?.name;
      if (name != null) _routeNames[routeId] = name;
    } on DioException {
      // Left unresolved; the run still lists, labelled generically.
    }
  }

  /// Map the wire status onto the enum, defaulting to scheduled for a value we
  /// do not know rather than dropping the run off the screen.
  ///
  /// @param raw - the status string from the API.
  /// @returns the status.
  static RunStatus _statusOf(String raw) => switch (raw) {
    'active' => RunStatus.active,
    'completed' => RunStatus.completed,
    'cancelled' => RunStatus.cancelled,
    _ => RunStatus.scheduled,
  };

  /// Recover the typed exception the interceptors attached.
  ///
  /// @param err - the caught Dio exception.
  /// @returns the exception to surface.
  Object _unwrap(DioException err) {
    final inner = err.error;
    return inner is TrotxiException ? inner : err;
  }
}
