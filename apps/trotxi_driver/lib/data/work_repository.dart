import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';

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
  approved(
    'Approved',
    'Operations agreed. Your roster changes only when they publish it.',
  ),
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
  WorkRepository({required this.client});
  final DriverApi client;

  Future<List<OpenRoute>> openRoutes() async {
    final routes = await client.pages(
      '/v1/driver/available-routes',
      wire.RoutePage.serializer,
      (p) => p.data.toList(),
      (p) => p.page.nextCursor,
    );
    for (final route in routes) {
      client.routeNames[route.id] = route.name;
    }
    return routes
        .map(
          (r) => OpenRoute(id: r.id, name: r.name, description: r.description),
        )
        .toList();
  }

  Future<WorkRequest> requestRouteChange({
    required String routeId,
    String? fromDate,
    String? note,
  }) => _submit({
    'kind': 'route_change',
    'routeId': routeId,
    'fromDate': ?fromDate,
    if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
  });
  Future<WorkRequest> requestLeave({
    required String fromDate,
    required String toDate,
    String? note,
  }) => _submit({
    'kind': 'leave',
    'fromDate': fromDate,
    'toDate': toDate,
    if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
  });
  Future<WorkRequest> _submit(Map<String, dynamic> body) async => _view(
    (await client.post(
      '/v1/driver/requests',
      wire.WorkRequestResponse.serializer,
      body: body,
    )).data,
  );
  Future<List<WorkRequest>> mine() async => (await client.pages(
    '/v1/driver/requests',
    wire.WorkRequestPage.serializer,
    (p) => p.data.toList(),
    (p) => p.page.nextCursor,
  )).map(_view).toList();
  Future<WorkRequest> withdraw(String id) async => _view(
    (await client.post(
      '/v1/driver/requests/${Uri.encodeComponent(id)}/withdraw',
      wire.WorkRequestResponse.serializer,
    )).data,
  );

  WorkRequest _view(wire.WorkRequest r) {
    final value = r.request.oneOf.value;
    final route = value is wire.WorkRequestInputOneOf ? value : null;
    final leave = value is wire.WorkRequestInputOneOf1 ? value : null;
    return WorkRequest(
      id: r.id,
      kind: leave != null ? RequestKind.leave : RequestKind.routeChange,
      status: RequestStatus.values.byName(r.status.name),
      createdAt: r.createdAt,
      routeId: route?.routeId,
      routeName: client.routeNames[route?.routeId],
      fromDate: (route?.fromDate ?? leave?.fromDate)?.toString(),
      toDate: leave?.toDate.toString(),
      note: route?.note ?? leave?.note,
      decisionNote: r.decisionNote,
    );
  }
}
