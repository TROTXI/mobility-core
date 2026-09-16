import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for OpsOrScopedWorkerApi
void main() {
  final instance = TrotxiApiClient().getOpsOrScopedWorkerApi();

  group(OpsOrScopedWorkerApi, () {
    // run Ask Dispatch
    //
    //Future<MaintenanceResultResponse> runAskDispatch(String xTrotxiClient, int xTrotxiBuild, ServiceDayInput serviceDayInput, { String xTrotxiPlatform }) async
    test('test runAskDispatch', () async {
      // TODO
    });

    // run Gps Retention
    //
    //Future<MaintenanceResultResponse> runGpsRetention(String xTrotxiClient, int xTrotxiBuild, MaintenanceInput maintenanceInput, { String xTrotxiPlatform }) async
    test('test runGpsRetention', () async {
      // TODO
    });

    // run No Shows
    //
    //Future<MaintenanceResultResponse> runNoShows(String xTrotxiClient, int xTrotxiBuild, ServiceDayInput serviceDayInput, { String xTrotxiPlatform }) async
    test('test runNoShows', () async {
      // TODO
    });

    // run Payment Inbox
    //
    //Future<MaintenanceResultResponse> runPaymentInbox(String xTrotxiClient, int xTrotxiBuild, MaintenanceInput maintenanceInput, { String xTrotxiPlatform }) async
    test('test runPaymentInbox', () async {
      // TODO
    });

    // run Payment Reconciliation
    //
    //Future<MaintenanceResultResponse> runPaymentReconciliation(String xTrotxiClient, int xTrotxiBuild, MaintenanceInput maintenanceInput, { String xTrotxiPlatform }) async
    test('test runPaymentReconciliation', () async {
      // TODO
    });

    // run Payments
    //
    //Future<PaymentMaintenanceResultResponse> runPayments(String xTrotxiClient, int xTrotxiBuild, MaintenanceInput maintenanceInput, { String xTrotxiPlatform }) async
    test('test runPayments', () async {
      // TODO
    });

    // run Period Close
    //
    //Future<MaintenanceResultResponse> runPeriodClose(String xTrotxiClient, int xTrotxiBuild, MaintenanceInput maintenanceInput, { String xTrotxiPlatform }) async
    test('test runPeriodClose', () async {
      // TODO
    });

    // run Reservation Defaults
    //
    //Future<MaintenanceResultResponse> runReservationDefaults(String xTrotxiClient, int xTrotxiBuild, ServiceDayInput serviceDayInput, { String xTrotxiPlatform }) async
    test('test runReservationDefaults', () async {
      // TODO
    });

    // run Route Learning
    //
    //Future<MaintenanceResultResponse> runRouteLearning(String xTrotxiClient, int xTrotxiBuild, MaintenanceInput maintenanceInput, { String xTrotxiPlatform }) async
    test('test runRouteLearning', () async {
      // TODO
    });

  });
}
