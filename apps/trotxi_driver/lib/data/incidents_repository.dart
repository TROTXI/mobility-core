import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_driver/core/api/driver_api.dart';

/// The five categories the design names, kept literally because they exist to
/// route a report to whoever can act on it.
///
/// Emergency is deliberately not one of them. The file draws EMERGENCY HELP
/// apart from reporting, and the API refuses it as a category: an emergency
/// needs a person on a phone now, not a row in a queue someone reads later.
enum IncidentCategory {
  vehicle('Vehicle problem'),
  collision('Collision or road hazard'),
  passengerSafety('Passenger safety concern'),
  routeBlocked('Route blocked'),
  other('Other issue');

  const IncidentCategory(this.label);

  /// The wording from the prototype, shown to the driver.
  final String label;
}

/// Where a filed report has got to in operations.
enum IncidentStatus {
  open('Sent', 'Operations has not opened it yet.'),
  acknowledged('Seen', 'Operations has read it.'),
  resolved('Resolved', 'Operations has closed it.');

  const IncidentStatus(this.label, this.detail);

  final String label;
  final String detail;
}

/// One report the driver has filed, and what came back.
class DriverIncident {
  const DriverIncident({
    required this.id,
    required this.category,
    required this.status,
    required this.occurredAt,
    this.note,
    this.resolution,
    this.tripId,
  });

  final String id;
  final IncidentCategory category;
  final IncidentStatus status;
  final DateTime occurredAt;
  final String? note;

  /// What operations wrote back. The reason a driver opens this list at all —
  /// a report with no visible answer is indistinguishable from one that was
  /// never sent.
  final String? resolution;

  final String? tripId;
}

/// Filing incident reports, and reading operations' answers (#226).
class IncidentsRepository {
  IncidentsRepository({required this.client});
  final DriverApi client;
  Future<DriverIncident> file({
    required IncidentCategory category,
    String? tripId,
    String? note,
    double? lat,
    double? lng,
  }) async {
    if ((lat == null) != (lng == null)) {
      throw const ApiException(
        400,
        'A report location needs both coordinates.',
      );
    }
    final response = await client.post(
      '/v1/driver/incidents',
      wire.IncidentResponse.serializer,
      body: {
        'category': switch (category) {
          IncidentCategory.passengerSafety => 'passenger_safety',
          IncidentCategory.routeBlocked => 'route_blocked',
          _ => category.name,
        },
        'tripId': ?tripId,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (lat != null && lng != null)
          'location': {'latitude': lat, 'longitude': lng},
      },
    );
    return _view(response.data);
  }

  Future<List<DriverIncident>> mine() async => (await client.pages(
    '/v1/driver/incidents',
    wire.IncidentPage.serializer,
    (p) => p.data.toList(),
    (p) => p.page.nextCursor,
  )).map(_view).toList();
  DriverIncident _view(wire.Incident incident) => DriverIncident(
    id: incident.id,
    category: IncidentCategory.values.byName(incident.category.name),
    status: IncidentStatus.values.byName(incident.status.name),
    occurredAt: incident.createdAt,
    tripId: incident.tripId,
    note: incident.note,
    resolution: incident.resolution,
  );
}
