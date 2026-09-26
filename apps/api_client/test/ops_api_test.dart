import 'package:test/test.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';


/// tests for OpsApi
void main() {
  final instance = TrotxiApiClient().getOpsApi();

  group(OpsApi, () {
    // assign Trip
    //
    //Future<OpsTripResponse> assignTrip(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, TripAssignment tripAssignment, { String xTrotxiPlatform }) async
    test('test assignTrip', () async {
      // TODO
    });

    // cancel Trip
    //
    //Future<OpsTripResponse> cancelTrip(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ReasonInput reasonInput, { String xTrotxiPlatform }) async
    test('test cancelTrip', () async {
      // TODO
    });

    // change Credential State
    //
    //Future changeCredentialState(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, CredentialAction credentialAction, { String xTrotxiPlatform }) async
    test('test changeCredentialState', () async {
      // TODO
    });

    // change Role
    //
    //Future<AccountResponse> changeRole(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, RoleEdit roleEdit, { String xTrotxiPlatform }) async
    test('test changeRole', () async {
      // TODO
    });

    // create Account Restriction
    //
    //Future<RestrictionResponse> createAccountRestriction(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, RestrictionInput restrictionInput, { String xTrotxiPlatform }) async
    test('test createAccountRestriction', () async {
      // TODO
    });

    // create Commute Slot
    //
    //Future<CommuteSlotResponse> createCommuteSlot(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, CommuteSlotInput commuteSlotInput, { String xTrotxiPlatform }) async
    test('test createCommuteSlot', () async {
      // TODO
    });

    // create Driver
    //
    //Future<DriverResponse> createDriver(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, DriverInput driverInput, { String xTrotxiPlatform }) async
    test('test createDriver', () async {
      // TODO
    });

    // create Fare
    //
    //Future<FareResponse> createFare(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, FareInput fareInput, { String xTrotxiPlatform }) async
    test('test createFare', () async {
      // TODO
    });

    // create Pattern
    //
    //Future<PatternResponse> createPattern(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, PatternInput patternInput, { String xTrotxiPlatform }) async
    test('test createPattern', () async {
      // TODO
    });

    // create Pattern Version
    //
    //Future<PatternVersionResponse> createPatternVersion(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, PatternVersionInput patternVersionInput, { String xTrotxiPlatform }) async
    test('test createPatternVersion', () async {
      // TODO
    });

    // create Route
    //
    //Future<RouteResponse> createRoute(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, RouteInput routeInput, { String xTrotxiPlatform }) async
    test('test createRoute', () async {
      // TODO
    });

    // create Schedule
    //
    //Future<ScheduleResponse> createSchedule(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ScheduleInput scheduleInput, { String xTrotxiPlatform }) async
    test('test createSchedule', () async {
      // TODO
    });

    // create Stop
    //
    //Future<StopResponse> createStop(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, StopInput stopInput, { String xTrotxiPlatform }) async
    test('test createStop', () async {
      // TODO
    });

    // create Trace Hold
    //
    //Future<TraceHoldResponse> createTraceHold(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, TraceHoldInput traceHoldInput, { String xTrotxiPlatform }) async
    test('test createTraceHold', () async {
      // TODO
    });

    // create Trip
    //
    //Future<OpsTripResponse> createTrip(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, TripInput tripInput, { String xTrotxiPlatform }) async
    test('test createTrip', () async {
      // TODO
    });

    // create Vehicle
    //
    //Future<VehicleResponse> createVehicle(String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, VehicleInput vehicleInput, { String xTrotxiPlatform }) async
    test('test createVehicle', () async {
      // TODO
    });

    // decide Commute Request
    //
    //Future<OpsCommuteRequestResponse> decideCommuteRequest(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, CommuteDecision commuteDecision, { String xTrotxiPlatform }) async
    test('test decideCommuteRequest', () async {
      // TODO
    });

    // decide Driver Request
    //
    //Future<OpsWorkRequestResponse> decideDriverRequest(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, WorkDecision workDecision, { String xTrotxiPlatform }) async
    test('test decideDriverRequest', () async {
      // TODO
    });

    // decide Incident
    //
    //Future<OpsIncidentResponse> decideIncident(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, IncidentDecision incidentDecision, { String xTrotxiPlatform }) async
    test('test decideIncident', () async {
      // TODO
    });

    // get Ops Overview
    //
    //Future<OpsOverviewResponse> getOpsOverview(String window, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getOpsOverview', () async {
      // TODO
    });

    // get Ops Pattern Version
    //
    //Future<PatternVersionResponse> getOpsPatternVersion(String id, String versionId, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getOpsPatternVersion', () async {
      // TODO
    });

    // get Ops Purchase
    //
    //Future<OpsPurchaseResponse> getOpsPurchase(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getOpsPurchase', () async {
      // TODO
    });

    // initiate Refund
    //
    //Future<RefundInitiationResponse> initiateRefund(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, RefundInitiationInput refundInitiationInput, { String xTrotxiPlatform }) async
    test('test initiateRefund', () async {
      // TODO
    });

    // issue Driver Credential
    //
    //Future<CredentialSecretResponse> issueDriverCredential(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, CredentialIssue credentialIssue, { String xTrotxiPlatform }) async
    test('test issueDriverCredential', () async {
      // TODO
    });

    // list Commute Events
    //
    //Future<DecisionEventPage> listCommuteEvents(String id, String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listCommuteEvents', () async {
      // TODO
    });

    // list Commute Slots
    //
    //Future<CommuteSlotPage> listCommuteSlots(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String routeId, String xTrotxiPlatform }) async
    test('test listCommuteSlots', () async {
      // TODO
    });

    // list Fares
    //
    //Future<FarePage> listFares(String id, String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listFares', () async {
      // TODO
    });

    // list Flags
    //
    //Future<FlagPage> listFlags(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listFlags', () async {
      // TODO
    });

    // list Minimum Versions
    //
    //Future<MinimumVersionPage> listMinimumVersions(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listMinimumVersions', () async {
      // TODO
    });

    // list Ops Commute Requests
    //
    //Future<OpsCommuteRequestPage> listOpsCommuteRequests(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String status, String xTrotxiPlatform }) async
    test('test listOpsCommuteRequests', () async {
      // TODO
    });

    // list Ops Driver Requests
    //
    //Future<OpsWorkRequestPage> listOpsDriverRequests(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String status, String xTrotxiPlatform }) async
    test('test listOpsDriverRequests', () async {
      // TODO
    });

    // list Ops Drivers
    //
    //Future<DriverPage> listOpsDrivers(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listOpsDrivers', () async {
      // TODO
    });

    // list Ops Incidents
    //
    //Future<OpsIncidentPage> listOpsIncidents(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String status, String xTrotxiPlatform }) async
    test('test listOpsIncidents', () async {
      // TODO
    });

    // list Ops Purchases
    //
    //Future<OpsPurchasePage> listOpsPurchases(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, Date fromDate, Date toDate, String xTrotxiPlatform }) async
    test('test listOpsPurchases', () async {
      // TODO
    });

    // list Ops Routes
    //
    //Future<RoutePage> listOpsRoutes(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listOpsRoutes', () async {
      // TODO
    });

    // list Ops Stops
    //
    //Future<StopPage> listOpsStops(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listOpsStops', () async {
      // TODO
    });

    // list Ops Trips
    //
    //Future<OpsTripPage> listOpsTrips(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, Date fromDate, Date toDate, String routeId, String xTrotxiPlatform }) async
    test('test listOpsTrips', () async {
      // TODO
    });

    // list Ops Vehicles
    //
    //Future<VehiclePage> listOpsVehicles(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listOpsVehicles', () async {
      // TODO
    });

    // list Pattern Versions
    //
    //Future<PatternVersionPage> listPatternVersions(String id, String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listPatternVersions', () async {
      // TODO
    });

    // list Patterns
    //
    //Future<PatternPage> listPatterns(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listPatterns', () async {
      // TODO
    });

    // list Payment Reviews
    //
    //Future<PaymentReviewPage> listPaymentReviews(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String status, String xTrotxiPlatform }) async
    test('test listPaymentReviews', () async {
      // TODO
    });

    // list Plan Pricing
    //
    //Future<PlanPricingPage> listPlanPricing(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listPlanPricing', () async {
      // TODO
    });

    // list Refund Initiations
    //
    //Future<RefundInitiationCollectionResponse> listRefundInitiations(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test listRefundInitiations', () async {
      // TODO
    });

    // list Schedules
    //
    //Future<SchedulePage> listSchedules(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String routeId, String xTrotxiPlatform }) async
    test('test listSchedules', () async {
      // TODO
    });

    // list Trace Holds
    //
    //Future<TraceHoldPage> listTraceHolds(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listTraceHolds', () async {
      // TODO
    });

    // publish Pattern Version
    //
    //Future<PatternVersionResponse> publishPatternVersion(String id, String versionId, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, PublishVersionInput publishVersionInput, { String xTrotxiPlatform }) async
    test('test publishPatternVersion', () async {
      // TODO
    });

    // release Account Restriction
    //
    //Future<RestrictionResponse> releaseAccountRestriction(String id, String restrictionId, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ReasonInput reasonInput, { String xTrotxiPlatform }) async
    test('test releaseAccountRestriction', () async {
      // TODO
    });

    // release Trace Hold
    //
    //Future<TraceHoldResponse> releaseTraceHold(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ReasonInput reasonInput, { String xTrotxiPlatform }) async
    test('test releaseTraceHold', () async {
      // TODO
    });

    // reschedule Trip
    //
    //Future<OpsTripResponse> rescheduleTrip(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, TripEdit tripEdit, { String xTrotxiPlatform }) async
    test('test rescheduleTrip', () async {
      // TODO
    });

    // reset Driver Pin
    //
    //Future<CredentialSecretResponse> resetDriverPin(String id, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ReasonInput reasonInput, { String xTrotxiPlatform }) async
    test('test resetDriverPin', () async {
      // TODO
    });

    // resolve Payment Review
    //
    //Future<PaymentReviewResponse> resolvePaymentReview(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ReviewDecision reviewDecision, { String xTrotxiPlatform }) async
    test('test resolvePaymentReview', () async {
      // TODO
    });

    // retire Commute Slot
    //
    //Future<CommuteSlotResponse> retireCommuteSlot(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, ReasonInput reasonInput, { String xTrotxiPlatform }) async
    test('test retireCommuteSlot', () async {
      // TODO
    });

    // run Personal Pause Resumes
    //
    //Future<MaintenanceResultResponse> runPersonalPauseResumes(String xTrotxiClient, int xTrotxiBuild, MaintenanceInput maintenanceInput, { String xTrotxiPlatform }) async
    test('test runPersonalPauseResumes', () async {
      // TODO
    });

    // set Flag
    //
    //Future<FlagResponse> setFlag(String key, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, FlagEdit flagEdit, { String xTrotxiPlatform }) async
    test('test setFlag', () async {
      // TODO
    });

    // set Minimum Version
    //
    //Future<MinimumVersionResponse> setMinimumVersion(String app, String platform, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, MinimumVersionEdit minimumVersionEdit, { String xTrotxiPlatform }) async
    test('test setMinimumVersion', () async {
      // TODO
    });

    // update Driver
    //
    //Future<DriverResponse> updateDriver(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, DriverEdit driverEdit, { String xTrotxiPlatform }) async
    test('test updateDriver', () async {
      // TODO
    });

    // update Plan Pricing
    //
    //Future<PlanPricingResponse> updatePlanPricing(String plan, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, PricingEdit pricingEdit, { String xTrotxiPlatform }) async
    test('test updatePlanPricing', () async {
      // TODO
    });

    // update Route
    //
    //Future<RouteResponse> updateRoute(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, RouteEdit routeEdit, { String xTrotxiPlatform }) async
    test('test updateRoute', () async {
      // TODO
    });

    // update Stop
    //
    //Future<StopResponse> updateStop(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, StopEdit stopEdit, { String xTrotxiPlatform }) async
    test('test updateStop', () async {
      // TODO
    });

    // update Vehicle
    //
    //Future<VehicleResponse> updateVehicle(String id, String ifMatch, String idempotencyKey, String xTrotxiClient, int xTrotxiBuild, VehicleEdit vehicleEdit, { String xTrotxiPlatform }) async
    test('test updateVehicle', () async {
      // TODO
    });

  });
}
