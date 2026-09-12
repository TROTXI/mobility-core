import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart';

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
  IncidentsRepository({required this._client});

  final TrotxiApiClient _client;

  /// File a report.
  ///
  /// The vehicle is NOT sent: the server resolves it from the trip. A report is
  /// evidence, and the field operations most needs to trust should not be the
  /// one this app could get wrong.
  ///
  /// @param category - the chosen category.
  /// @param tripId - the run it happened on; null for a yard report.
  /// @param note - what the driver typed, if anything.
  /// @param lat - current or last-known latitude, if the device had one.
  /// @param lng - the matching longitude.
  /// @returns the filed report.
  Future<DriverIncident> file({
    required IncidentCategory category,
    String? tripId,
    String? note,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _client.getIncidentsApi().meIncidentsPost(
        meIncidentsPostRequest: MeIncidentsPostRequest(
          (b) {
            b.category = _wire(category);
            if (tripId != null) b.tripId = tripId;
            if (note != null && note.trim().isNotEmpty) b.note = note.trim();
            if (lat != null) b.lat = lat;
            if (lng != null) b.lng = lng;
          },
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException(201, 'The report was sent but returned nothing.');
      }
      return DriverIncident(
        id: data.id,
        category: _categoryOf(data.category.name),
        status: _statusOf(data.status.name),
        occurredAt: data.occurredAt,
        note: data.note,
        resolution: data.resolution,
        tripId: data.tripId,
      );
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// The driver's own reports, newest first.
  ///
  /// @returns their reports.
  Future<List<DriverIncident>> mine() async {
    try {
      final response = await _client.getIncidentsApi().meIncidentsGet();
      return (response.data?.incidents.toList() ?? [])
          .map(
            (i) => DriverIncident(
              id: i.id,
              category: _categoryOf(i.category.name),
              status: _statusOf(i.status.name),
              occurredAt: i.occurredAt,
              note: i.note,
              resolution: i.resolution,
              tripId: i.tripId,
            ),
          )
          .toList();
    } on DioException catch (err) {
      throw _unwrap(err);
    }
  }

  /// Map the app's category onto the wire enum.
  ///
  /// @param category - the chosen category.
  /// @returns the generated client's enum value.
  static MeIncidentsPostRequestCategoryEnum _wire(IncidentCategory category) =>
      switch (category) {
        IncidentCategory.vehicle => MeIncidentsPostRequestCategoryEnum.vehicle,
        IncidentCategory.collision =>
          MeIncidentsPostRequestCategoryEnum.collision,
        IncidentCategory.passengerSafety =>
          MeIncidentsPostRequestCategoryEnum.passengerSafety,
        IncidentCategory.routeBlocked =>
          MeIncidentsPostRequestCategoryEnum.routeBlocked,
        IncidentCategory.other => MeIncidentsPostRequestCategoryEnum.other,
      };

  /// Map the wire category back, defaulting rather than dropping a report off
  /// the list for a value this build does not know.
  ///
  /// @param raw - the category string from the API.
  /// @returns the category.
  static IncidentCategory _categoryOf(String raw) => switch (raw) {
    'vehicle' => IncidentCategory.vehicle,
    'collision' => IncidentCategory.collision,
    'passengerSafety' || 'passenger_safety' => IncidentCategory.passengerSafety,
    'routeBlocked' || 'route_blocked' => IncidentCategory.routeBlocked,
    _ => IncidentCategory.other,
  };

  /// Map the wire status back.
  ///
  /// @param raw - the status string from the API.
  /// @returns the status.
  static IncidentStatus _statusOf(String raw) => switch (raw) {
    'acknowledged' => IncidentStatus.acknowledged,
    'resolved' => IncidentStatus.resolved,
    _ => IncidentStatus.open,
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
