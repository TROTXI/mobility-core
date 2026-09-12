import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart';

/// What a driver is asking operations for.
enum RequestKind {
  routeChange('Route change'),
  leave('Leave');

  const RequestKind(this.label);
  final String label;
}

/// Where the ask has got to.
///
/// `pending` is the state that matters most to get right in the UI: a driver
/// looking at it has to understand that nothing about their roster has moved.
enum RequestStatus {
  pending('Waiting', 'Operations has not answered yet.'),
  approved('Approved', 'Operations agreed. Your roster changes only when they publish it.'),
  declined('Declined', 'Operations said no.'),
  withdrawn('Withdrawn', 'You took this back.');

  const RequestStatus(this.label, this.detail);

  final String label;
  final String detail;
}

/// A corridor a driver may ask to be moved to.
///
/// Not every route in the system. Operations opens one when it can actually
/// accept requests for it, so a driver never asks for something that could only
/// ever be declined.
class OpenRoute {
  const OpenRoute({required this.id, required this.name, this.description});

  final String id;
  final String name;
  final String? description;
}

/// One request the driver has made, and operations' answer.
class WorkRequest {
  const WorkRequest({
    required this.id,
    required this.kind,
    required this.status,
    required this.createdAt,
    this.routeId,
    this.routeName,
    this.fromDate,
    this.toDate,
    this.note,
    this.decisionNote,
    this.decidedAt,
  });

  final String id;
  final RequestKind kind;
  final RequestStatus status;
  final DateTime createdAt;
  final String? routeId;

  /// Resolved from the open-route list where possible. A request that names a
  /// corridor by uuid is unreadable, and a route ops has since closed will not
  /// be in that list — hence nullable rather than a lookup that might fail.
  final String? routeName;

  final String? fromDate;
  final String? toDate;
  final String? note;
  final String? decisionNote;
  final DateTime? decidedAt;

  bool get isPending => status == RequestStatus.pending;
}

/// Driver self-service requests (#232).
///
/// Nothing here changes an assignment, and nothing in the API behind it does
/// either: a request is a proposal, and operations still has to publish the
/// change separately. The screens say so to drivers for the same reason.
class WorkRepository {
  WorkRepository({required this._client});

  final TrotxiApiClient _client;

  /// Route names by id, filled from [openRoutes] so the request list can show a
  /// corridor rather than a uuid.
  final Map<String, String> _routeNames = {};

  /// Corridors operations will accept reassignment requests for.
  ///
  /// @returns the open routes.
  Future<List<OpenRoute>> openRoutes() async {
    try {
      final response = await _client.getWorkApi().meWorkRoutesGet();
      final routes = (response.data?.routes.toList() ?? [])
          .map(
            (r) => OpenRoute(
              id: r.id,
              name: r.name,
              description: r.description,
            ),
          )
          .toList();
      for (final route in routes) {
        _routeNames[route.id] = route.name;
      }
      return routes;
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Ask to be moved to another corridor.
  ///
  /// @param routeId - the corridor asked for.
  /// @param fromDate - when it should take effect (`YYYY-MM-DD`), if given.
  /// @param note - why.
  /// @returns the stored request, pending.
  Future<WorkRequest> requestRouteChange({
    required String routeId,
    String? fromDate,
    String? note,
  }) async {
    return _submit(
      MeWorkRequestsPostRequest(
        (b) => b.oneOf = OneOf2<
            MeWorkRequestsPostRequestOneOf,
            MeWorkRequestsPostRequestOneOf1>(
          typeIndex: 0,
          value: MeWorkRequestsPostRequestOneOf(
            (r) {
              r.kind = MeWorkRequestsPostRequestOneOfKindEnum.routeChange;
              r.routeId = routeId;
              if (fromDate != null) r.fromDate = fromDate;
              if (note != null && note.trim().isNotEmpty) r.note = note.trim();
            },
          ),
        ),
      ),
    );
  }

  /// Ask for days off.
  ///
  /// @param fromDate - the first day (`YYYY-MM-DD`).
  /// @param toDate - the last day (`YYYY-MM-DD`).
  /// @param note - coverage information, which is free text until there is a
  ///   roster to point at.
  /// @returns the stored request, pending.
  Future<WorkRequest> requestLeave({
    required String fromDate,
    required String toDate,
    String? note,
  }) async {
    return _submit(
      MeWorkRequestsPostRequest(
        (b) => b.oneOf = OneOf2<
            MeWorkRequestsPostRequestOneOf,
            MeWorkRequestsPostRequestOneOf1>(
          typeIndex: 1,
          value: MeWorkRequestsPostRequestOneOf1(
            (r) {
              r.kind = MeWorkRequestsPostRequestOneOf1KindEnum.leave;
              r.fromDate = fromDate;
              r.toDate = toDate;
              if (note != null && note.trim().isNotEmpty) r.note = note.trim();
            },
          ),
        ),
      ),
    );
  }

  /// The driver's own requests, newest first.
  ///
  /// @returns their requests.
  Future<List<WorkRequest>> mine() async {
    try {
      final response = await _client.getWorkApi().meWorkRequestsGet();
      return (response.data?.requests.toList() ?? []).map(_toRequest).toList();
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Take back a request operations has not answered.
  ///
  /// @param id - the request to withdraw.
  /// @returns the withdrawn request.
  Future<WorkRequest> withdraw(String id) async {
    try {
      final response = await _client.getWorkApi().meWorkRequestsIdWithdrawPost(
        id: id,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(200, 'The request returned nothing.');
      }
      return _toRequest(data);
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Shared submit path for both kinds.
  ///
  /// @param body - the built request body.
  /// @returns the stored request.
  Future<WorkRequest> _submit(MeWorkRequestsPostRequest body) async {
    try {
      final response = await _client.getWorkApi().meWorkRequestsPost(
        meWorkRequestsPostRequest: body,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(201, 'The request was sent but returned nothing.');
      }
      return _toRequest(data);
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Map a wire request onto the app's shape, resolving the corridor name from
  /// whatever the open-route list has already told us.
  ///
  /// @param r - the wire request.
  /// @returns the request.
  WorkRequest _toRequest(MeWorkRequestsGet200ResponseRequestsInner r) {
    return WorkRequest(
      id: r.id,
      kind: r.kind.name == 'leave' ? RequestKind.leave : RequestKind.routeChange,
      status: switch (r.status.name) {
        'approved' => RequestStatus.approved,
        'declined' => RequestStatus.declined,
        'withdrawn' => RequestStatus.withdrawn,
        _ => RequestStatus.pending,
      },
      createdAt: r.createdAt,
      routeId: r.routeId,
      routeName: r.routeId == null ? null : _routeNames[r.routeId],
      fromDate: r.fromDate,
      toDate: r.toDate,
      note: r.note,
      decisionNote: r.decisionNote,
      decidedAt: r.decidedAt,
    );
  }

  /// Recover the typed exception the interceptors attached.
  ///
  /// @param err - the caught Dio exception.
  /// @returns the exception to surface.
  Object _unwrap(DioException err) {
    final inner = err.error;
    return inner is TrotxiException ? inner : err;
  }
}
