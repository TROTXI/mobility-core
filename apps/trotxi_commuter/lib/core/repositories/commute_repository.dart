import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';

class CommuteRepository {
  CommuteRepository(this.client);
  final CommuterApi client;

  Future<List<CommuteRequest>> list() async {
    final generation = client.sessionGeneration;
    final requests = await client.commuteRequests();
    final routes = await client.routes();
    client.ensureSession(generation);
    final names = {for (final route in routes) route.id: route.name};
    return requests
        .map(
          (r) => CommuteRequest(
            r,
            names[r.requested.routeId] ??
                'Requested corridor (not in current catalogue)',
          ),
        )
        .toList();
  }

  Future<void> submit(wire.CommuteRequestInput input) async {
    await client.submitCommute(input);
  }

  Future<void> withdraw(String id) async {
    await client.withdrawCommute(id);
  }
}

class CommuteRequest {
  CommuteRequest(this.row, this.routeName);
  final wire.CommuteRequest row;
  final String routeName;
  String get id => row.id;
  String get status => row.status.name;
  bool get paused => row.paused;
  String get requestedDate => row.requested.requestedDate.toString();
  String? get effectiveDate => row.effectiveDate?.toString();
  String? get decisionNote => row.decisionNote;
  bool get isOpen =>
      const ['submitted', 'waitlisted', 'approved'].contains(status);
}

String commuteError(Object error) {
  if (error is OfflineException) {
    return 'Connection unavailable. Refresh your requests before retrying; your request may already have reached operations.';
  }
  if (error is TrotxiException) return error.message;
  return 'Could not complete the request. Refresh and try again, or contact operations.';
}
