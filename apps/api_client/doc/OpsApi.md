# trotxi_api_client.api.OpsApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**assignTrip**](OpsApi.md#assigntrip) | **PUT** /v1/ops/trips/{id}/assignment | assign Trip
[**cancelOperatorInvitation**](OpsApi.md#canceloperatorinvitation) | **POST** /v1/ops/team/invitations/{id}/cancel | cancel Operator Invitation
[**cancelTrip**](OpsApi.md#canceltrip) | **POST** /v1/ops/trips/{id}/cancel | cancel Trip
[**changeCredentialState**](OpsApi.md#changecredentialstate) | **POST** /v1/ops/drivers/{id}/credentials/actions | change Credential State
[**changeRole**](OpsApi.md#changerole) | **PATCH** /v1/ops/users/{id}/role | change Role
[**createAccountRestriction**](OpsApi.md#createaccountrestriction) | **POST** /v1/ops/users/{id}/restrictions | create Account Restriction
[**createCommuteSlot**](OpsApi.md#createcommuteslot) | **POST** /v1/ops/commute-slots | create Commute Slot
[**createDriver**](OpsApi.md#createdriver) | **POST** /v1/ops/drivers | create Driver
[**createFare**](OpsApi.md#createfare) | **POST** /v1/ops/routes/{id}/fares | create Fare
[**createPattern**](OpsApi.md#createpattern) | **POST** /v1/ops/route-patterns | create Pattern
[**createPatternVersion**](OpsApi.md#createpatternversion) | **POST** /v1/ops/route-patterns/{id}/versions | create Pattern Version
[**createRoute**](OpsApi.md#createroute) | **POST** /v1/ops/routes | create Route
[**createSchedule**](OpsApi.md#createschedule) | **POST** /v1/ops/service-schedules | create Schedule
[**createStop**](OpsApi.md#createstop) | **POST** /v1/ops/stops | create Stop
[**createTraceHold**](OpsApi.md#createtracehold) | **POST** /v1/ops/trace-holds | create Trace Hold
[**createTrip**](OpsApi.md#createtrip) | **POST** /v1/ops/trips | create Trip
[**createVehicle**](OpsApi.md#createvehicle) | **POST** /v1/ops/vehicles | create Vehicle
[**decideCommuteRequest**](OpsApi.md#decidecommuterequest) | **POST** /v1/ops/commute-requests/{id}/decisions | decide Commute Request
[**decideDriverRequest**](OpsApi.md#decidedriverrequest) | **POST** /v1/ops/driver-requests/{id}/decisions | decide Driver Request
[**decideIncident**](OpsApi.md#decideincident) | **POST** /v1/ops/incidents/{id}/decisions | decide Incident
[**getOpsManifest**](OpsApi.md#getopsmanifest) | **GET** /v1/ops/trips/{id}/manifest | get Ops Manifest
[**getOpsOverview**](OpsApi.md#getopsoverview) | **GET** /v1/ops/overview | get Ops Overview
[**getOpsPatternVersion**](OpsApi.md#getopspatternversion) | **GET** /v1/ops/route-patterns/{id}/versions/{versionId} | get Ops Pattern Version
[**getOpsPurchase**](OpsApi.md#getopspurchase) | **GET** /v1/ops/purchases/{id} | get Ops Purchase
[**getOpsReportSummary**](OpsApi.md#getopsreportsummary) | **GET** /v1/ops/reports/summary | get Ops Report Summary
[**getOpsRiderDetail**](OpsApi.md#getopsriderdetail) | **GET** /v1/ops/riders/{id} | get Ops Rider Detail
[**getOpsRiderSummary**](OpsApi.md#getopsridersummary) | **GET** /v1/ops/riders/summary | get Ops Rider Summary
[**initiateRefund**](OpsApi.md#initiaterefund) | **POST** /v1/ops/purchases/{id}/refunds | initiate Refund
[**inviteOperator**](OpsApi.md#inviteoperator) | **POST** /v1/ops/team/invitations | invite Operator
[**issueDriverCredential**](OpsApi.md#issuedrivercredential) | **POST** /v1/ops/drivers/{id}/credentials | issue Driver Credential
[**listCommuteEvents**](OpsApi.md#listcommuteevents) | **GET** /v1/ops/commute-requests/{id}/events | list Commute Events
[**listCommuteSlots**](OpsApi.md#listcommuteslots) | **GET** /v1/ops/commute-slots | list Commute Slots
[**listFares**](OpsApi.md#listfares) | **GET** /v1/ops/routes/{id}/fares | list Fares
[**listFlags**](OpsApi.md#listflags) | **GET** /v1/ops/flags | list Flags
[**listMinimumVersions**](OpsApi.md#listminimumversions) | **GET** /v1/ops/min-versions | list Minimum Versions
[**listOpsAccountErasures**](OpsApi.md#listopsaccounterasures) | **GET** /v1/ops/account-erasures | list Ops Account Erasures
[**listOpsAuditEvents**](OpsApi.md#listopsauditevents) | **GET** /v1/ops/audit-events | list Ops Audit Events
[**listOpsAutoRenewals**](OpsApi.md#listopsautorenewals) | **GET** /v1/ops/auto-renewals | list Ops Auto Renewals
[**listOpsCommuteRequests**](OpsApi.md#listopscommuterequests) | **GET** /v1/ops/commute-requests | list Ops Commute Requests
[**listOpsDeliveries**](OpsApi.md#listopsdeliveries) | **GET** /v1/ops/deliveries | list Ops Deliveries
[**listOpsDriverRequests**](OpsApi.md#listopsdriverrequests) | **GET** /v1/ops/driver-requests | list Ops Driver Requests
[**listOpsDrivers**](OpsApi.md#listopsdrivers) | **GET** /v1/ops/drivers | list Ops Drivers
[**listOpsIncidents**](OpsApi.md#listopsincidents) | **GET** /v1/ops/incidents | list Ops Incidents
[**listOpsOperators**](OpsApi.md#listopsoperators) | **GET** /v1/ops/operators | list Ops Operators
[**listOpsPurchases**](OpsApi.md#listopspurchases) | **GET** /v1/ops/purchases | list Ops Purchases
[**listOpsRiders**](OpsApi.md#listopsriders) | **GET** /v1/ops/riders | list Ops Riders
[**listOpsRoutes**](OpsApi.md#listopsroutes) | **GET** /v1/ops/routes | list Ops Routes
[**listOpsStandby**](OpsApi.md#listopsstandby) | **GET** /v1/ops/standby | list Ops Standby
[**listOpsStops**](OpsApi.md#listopsstops) | **GET** /v1/ops/stops | list Ops Stops
[**listOpsTeam**](OpsApi.md#listopsteam) | **GET** /v1/ops/team | list Ops Team
[**listOpsTrips**](OpsApi.md#listopstrips) | **GET** /v1/ops/trips | list Ops Trips
[**listOpsVehicles**](OpsApi.md#listopsvehicles) | **GET** /v1/ops/vehicles | list Ops Vehicles
[**listPatternVersions**](OpsApi.md#listpatternversions) | **GET** /v1/ops/route-patterns/{id}/versions | list Pattern Versions
[**listPatterns**](OpsApi.md#listpatterns) | **GET** /v1/ops/route-patterns | list Patterns
[**listPaymentReviews**](OpsApi.md#listpaymentreviews) | **GET** /v1/ops/payments/reviews | list Payment Reviews
[**listPlanPricing**](OpsApi.md#listplanpricing) | **GET** /v1/ops/plan-pricing | list Plan Pricing
[**listRefundInitiations**](OpsApi.md#listrefundinitiations) | **GET** /v1/ops/purchases/{id}/refunds | list Refund Initiations
[**listSchedules**](OpsApi.md#listschedules) | **GET** /v1/ops/service-schedules | list Schedules
[**listTraceHolds**](OpsApi.md#listtraceholds) | **GET** /v1/ops/trace-holds | list Trace Holds
[**offerStandby**](OpsApi.md#offerstandby) | **POST** /v1/ops/standby/{id}/offers | offer Standby
[**publishPatternVersion**](OpsApi.md#publishpatternversion) | **POST** /v1/ops/route-patterns/{id}/versions/{versionId}/publish | publish Pattern Version
[**releaseAccountRestriction**](OpsApi.md#releaseaccountrestriction) | **POST** /v1/ops/users/{id}/restrictions/{restrictionId}/release | release Account Restriction
[**releaseTraceHold**](OpsApi.md#releasetracehold) | **POST** /v1/ops/trace-holds/{id}/release | release Trace Hold
[**rescheduleTrip**](OpsApi.md#rescheduletrip) | **PATCH** /v1/ops/trips/{id} | reschedule Trip
[**resendOperatorInvitation**](OpsApi.md#resendoperatorinvitation) | **POST** /v1/ops/team/invitations/{id}/resend | resend Operator Invitation
[**resetDriverPin**](OpsApi.md#resetdriverpin) | **POST** /v1/ops/drivers/{id}/credentials/reset-pin | reset Driver Pin
[**resetOperatorPasskeys**](OpsApi.md#resetoperatorpasskeys) | **POST** /v1/ops/users/{id}/passkeys/reset | reset Operator Passkeys
[**resolvePaymentReview**](OpsApi.md#resolvepaymentreview) | **POST** /v1/ops/payments/reviews/{id}/decisions | resolve Payment Review
[**retireCommuteSlot**](OpsApi.md#retirecommuteslot) | **POST** /v1/ops/commute-slots/{id}/retire | retire Commute Slot
[**runPersonalPauseResumes**](OpsApi.md#runpersonalpauseresumes) | **POST** /v1/ops/maintenance/personal-pause-resumes | run Personal Pause Resumes
[**setFlag**](OpsApi.md#setflag) | **PUT** /v1/ops/flags/{key} | set Flag
[**setMinimumVersion**](OpsApi.md#setminimumversion) | **PUT** /v1/ops/min-versions/{app}/{platform} | set Minimum Version
[**updateDriver**](OpsApi.md#updatedriver) | **PATCH** /v1/ops/drivers/{id} | update Driver
[**updateOperatorAccess**](OpsApi.md#updateoperatoraccess) | **POST** /v1/ops/team/members/{id}/access | update Operator Access
[**updatePlanPricing**](OpsApi.md#updateplanpricing) | **PATCH** /v1/ops/plan-pricing/{plan} | update Plan Pricing
[**updateRoute**](OpsApi.md#updateroute) | **PATCH** /v1/ops/routes/{id} | update Route
[**updateStop**](OpsApi.md#updatestop) | **PATCH** /v1/ops/stops/{id} | update Stop
[**updateVehicle**](OpsApi.md#updatevehicle) | **PATCH** /v1/ops/vehicles/{id} | update Vehicle


# **assignTrip**
> OpsTripResponse assignTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, tripAssignment, xTrotxiPlatform)

assign Trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final TripAssignment tripAssignment = ; // TripAssignment |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.assignTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, tripAssignment, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->assignTrip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **tripAssignment** | [**TripAssignment**](TripAssignment.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsTripResponse**](OpsTripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelOperatorInvitation**
> OperatorCommandResultResponse cancelOperatorInvitation(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

cancel Operator Invitation

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.cancelOperatorInvitation(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->cancelOperatorInvitation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OperatorCommandResultResponse**](OperatorCommandResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **cancelTrip**
> OpsTripResponse cancelTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

cancel Trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.cancelTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->cancelTrip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsTripResponse**](OpsTripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **changeCredentialState**
> changeCredentialState(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, credentialAction, xTrotxiPlatform)

change Credential State

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final CredentialAction credentialAction = ; // CredentialAction |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.changeCredentialState(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, credentialAction, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling OpsApi->changeCredentialState: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **credentialAction** | [**CredentialAction**](CredentialAction.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **changeRole**
> AccountResponse changeRole(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, roleEdit, xTrotxiPlatform)

change Role

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final RoleEdit roleEdit = ; // RoleEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.changeRole(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, roleEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->changeRole: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **roleEdit** | [**RoleEdit**](RoleEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**AccountResponse**](AccountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createAccountRestriction**
> RestrictionResponse createAccountRestriction(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, restrictionInput, xTrotxiPlatform)

create Account Restriction

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final RestrictionInput restrictionInput = ; // RestrictionInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createAccountRestriction(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, restrictionInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createAccountRestriction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **restrictionInput** | [**RestrictionInput**](RestrictionInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RestrictionResponse**](RestrictionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCommuteSlot**
> CommuteSlotResponse createCommuteSlot(idempotencyKey, xTrotxiClient, xTrotxiBuild, commuteSlotInput, xTrotxiPlatform)

create Commute Slot

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final CommuteSlotInput commuteSlotInput = ; // CommuteSlotInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createCommuteSlot(idempotencyKey, xTrotxiClient, xTrotxiBuild, commuteSlotInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createCommuteSlot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **commuteSlotInput** | [**CommuteSlotInput**](CommuteSlotInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**CommuteSlotResponse**](CommuteSlotResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createDriver**
> DriverResponse createDriver(idempotencyKey, xTrotxiClient, xTrotxiBuild, driverInput, xTrotxiPlatform)

create Driver

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final DriverInput driverInput = ; // DriverInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createDriver(idempotencyKey, xTrotxiClient, xTrotxiBuild, driverInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createDriver: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **driverInput** | [**DriverInput**](DriverInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**DriverResponse**](DriverResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createFare**
> FareResponse createFare(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, fareInput, xTrotxiPlatform)

create Fare

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final FareInput fareInput = ; // FareInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createFare(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, fareInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createFare: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **fareInput** | [**FareInput**](FareInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**FareResponse**](FareResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPattern**
> PatternResponse createPattern(idempotencyKey, xTrotxiClient, xTrotxiBuild, patternInput, xTrotxiPlatform)

create Pattern

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PatternInput patternInput = ; // PatternInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createPattern(idempotencyKey, xTrotxiClient, xTrotxiBuild, patternInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createPattern: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **patternInput** | [**PatternInput**](PatternInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PatternResponse**](PatternResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPatternVersion**
> PatternVersionResponse createPatternVersion(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, patternVersionInput, xTrotxiPlatform)

create Pattern Version

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PatternVersionInput patternVersionInput = ; // PatternVersionInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createPatternVersion(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, patternVersionInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createPatternVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **patternVersionInput** | [**PatternVersionInput**](PatternVersionInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PatternVersionResponse**](PatternVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRoute**
> RouteResponse createRoute(idempotencyKey, xTrotxiClient, xTrotxiBuild, routeInput, xTrotxiPlatform)

create Route

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final RouteInput routeInput = ; // RouteInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createRoute(idempotencyKey, xTrotxiClient, xTrotxiBuild, routeInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createRoute: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **routeInput** | [**RouteInput**](RouteInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createSchedule**
> ScheduleResponse createSchedule(idempotencyKey, xTrotxiClient, xTrotxiBuild, scheduleInput, xTrotxiPlatform)

create Schedule

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ScheduleInput scheduleInput = ; // ScheduleInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createSchedule(idempotencyKey, xTrotxiClient, xTrotxiBuild, scheduleInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createSchedule: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **scheduleInput** | [**ScheduleInput**](ScheduleInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**ScheduleResponse**](ScheduleResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createStop**
> StopResponse createStop(idempotencyKey, xTrotxiClient, xTrotxiBuild, stopInput, xTrotxiPlatform)

create Stop

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final StopInput stopInput = ; // StopInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createStop(idempotencyKey, xTrotxiClient, xTrotxiBuild, stopInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createStop: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **stopInput** | [**StopInput**](StopInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StopResponse**](StopResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTraceHold**
> TraceHoldResponse createTraceHold(idempotencyKey, xTrotxiClient, xTrotxiBuild, traceHoldInput, xTrotxiPlatform)

create Trace Hold

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final TraceHoldInput traceHoldInput = ; // TraceHoldInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createTraceHold(idempotencyKey, xTrotxiClient, xTrotxiBuild, traceHoldInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createTraceHold: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **traceHoldInput** | [**TraceHoldInput**](TraceHoldInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**TraceHoldResponse**](TraceHoldResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTrip**
> OpsTripResponse createTrip(idempotencyKey, xTrotxiClient, xTrotxiBuild, tripInput, xTrotxiPlatform)

create Trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final TripInput tripInput = ; // TripInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createTrip(idempotencyKey, xTrotxiClient, xTrotxiBuild, tripInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createTrip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **tripInput** | [**TripInput**](TripInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsTripResponse**](OpsTripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createVehicle**
> VehicleResponse createVehicle(idempotencyKey, xTrotxiClient, xTrotxiBuild, vehicleInput, xTrotxiPlatform)

create Vehicle

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final VehicleInput vehicleInput = ; // VehicleInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createVehicle(idempotencyKey, xTrotxiClient, xTrotxiBuild, vehicleInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->createVehicle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **vehicleInput** | [**VehicleInput**](VehicleInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**VehicleResponse**](VehicleResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **decideCommuteRequest**
> OpsCommuteRequestResponse decideCommuteRequest(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, commuteDecision, xTrotxiPlatform)

decide Commute Request

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final CommuteDecision commuteDecision = ; // CommuteDecision |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.decideCommuteRequest(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, commuteDecision, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->decideCommuteRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **commuteDecision** | [**CommuteDecision**](CommuteDecision.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsCommuteRequestResponse**](OpsCommuteRequestResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **decideDriverRequest**
> OpsWorkRequestResponse decideDriverRequest(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, workDecision, xTrotxiPlatform)

decide Driver Request

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final WorkDecision workDecision = ; // WorkDecision |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.decideDriverRequest(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, workDecision, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->decideDriverRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **workDecision** | [**WorkDecision**](WorkDecision.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsWorkRequestResponse**](OpsWorkRequestResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **decideIncident**
> OpsIncidentResponse decideIncident(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, incidentDecision, xTrotxiPlatform)

decide Incident

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final IncidentDecision incidentDecision = ; // IncidentDecision |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.decideIncident(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, incidentDecision, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->decideIncident: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **incidentDecision** | [**IncidentDecision**](IncidentDecision.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsIncidentResponse**](OpsIncidentResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsManifest**
> ManifestResponse getOpsManifest(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Ops Manifest

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getOpsManifest(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->getOpsManifest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**ManifestResponse**](ManifestResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsOverview**
> OpsOverviewResponse getOpsOverview(window, xTrotxiClient, xTrotxiBuild, date, xTrotxiPlatform)

get Ops Overview

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String window = window_example; // String | Which service window the board shows. Stated by the caller, never inferred.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final Date date = 2013-10-20; // Date | Service day to show. Defaults to today in Accra; set it to review a past day.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getOpsOverview(window, xTrotxiClient, xTrotxiBuild, date, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->getOpsOverview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **window** | **String**| Which service window the board shows. Stated by the caller, never inferred. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **date** | **Date**| Service day to show. Defaults to today in Accra; set it to review a past day. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsOverviewResponse**](OpsOverviewResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsPatternVersion**
> PatternVersionResponse getOpsPatternVersion(id, versionId, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Ops Pattern Version

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String versionId = versionId_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getOpsPatternVersion(id, versionId, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->getOpsPatternVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **versionId** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PatternVersionResponse**](PatternVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsPurchase**
> OpsPurchaseResponse getOpsPurchase(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Ops Purchase

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getOpsPurchase(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->getOpsPurchase: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsPurchaseResponse**](OpsPurchaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsReportSummary**
> OpsReportSummaryResponse getOpsReportSummary(xTrotxiClient, xTrotxiBuild, fromDate, toDate, xTrotxiPlatform)

get Ops Report Summary

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final Date fromDate = 2013-10-20; // Date | Inclusive reporting day.
final Date toDate = 2013-10-20; // Date | Inclusive reporting day.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getOpsReportSummary(xTrotxiClient, xTrotxiBuild, fromDate, toDate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->getOpsReportSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **fromDate** | **Date**| Inclusive reporting day. | [optional]
 **toDate** | **Date**| Inclusive reporting day. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsReportSummaryResponse**](OpsReportSummaryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsRiderDetail**
> OpsRiderDetailResponse getOpsRiderDetail(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Ops Rider Detail

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getOpsRiderDetail(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->getOpsRiderDetail: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsRiderDetailResponse**](OpsRiderDetailResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOpsRiderSummary**
> OpsRiderSummaryResponse getOpsRiderSummary(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Ops Rider Summary

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getOpsRiderSummary(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->getOpsRiderSummary: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsRiderSummaryResponse**](OpsRiderSummaryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **initiateRefund**
> RefundInitiationResponse initiateRefund(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, refundInitiationInput, xTrotxiPlatform)

initiate Refund

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final RefundInitiationInput refundInitiationInput = ; // RefundInitiationInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.initiateRefund(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, refundInitiationInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->initiateRefund: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **refundInitiationInput** | [**RefundInitiationInput**](RefundInitiationInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RefundInitiationResponse**](RefundInitiationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **inviteOperator**
> OperatorCommandResultResponse inviteOperator(idempotencyKey, xTrotxiClient, xTrotxiBuild, operatorInvitationInput, xTrotxiPlatform)

invite Operator

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final OperatorInvitationInput operatorInvitationInput = ; // OperatorInvitationInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.inviteOperator(idempotencyKey, xTrotxiClient, xTrotxiBuild, operatorInvitationInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->inviteOperator: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **operatorInvitationInput** | [**OperatorInvitationInput**](OperatorInvitationInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OperatorCommandResultResponse**](OperatorCommandResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **issueDriverCredential**
> CredentialSecretResponse issueDriverCredential(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, credentialIssue, xTrotxiPlatform)

issue Driver Credential

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final CredentialIssue credentialIssue = ; // CredentialIssue |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.issueDriverCredential(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, credentialIssue, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->issueDriverCredential: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **credentialIssue** | [**CredentialIssue**](CredentialIssue.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**CredentialSecretResponse**](CredentialSecretResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCommuteEvents**
> DecisionEventPage listCommuteEvents(id, xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Commute Events

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listCommuteEvents(id, xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listCommuteEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**DecisionEventPage**](DecisionEventPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCommuteSlots**
> CommuteSlotPage listCommuteSlots(xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, xTrotxiPlatform)

list Commute Slots

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String routeId = routeId_example; // String | Filter within caller scope; never expands authorization.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listCommuteSlots(xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listCommuteSlots: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **routeId** | **String**| Filter within caller scope; never expands authorization. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**CommuteSlotPage**](CommuteSlotPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFares**
> FarePage listFares(id, xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Fares

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listFares(id, xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listFares: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**FarePage**](FarePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFlags**
> FlagPage listFlags(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Flags

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listFlags(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listFlags: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**FlagPage**](FlagPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listMinimumVersions**
> MinimumVersionPage listMinimumVersions(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Minimum Versions

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listMinimumVersions(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listMinimumVersions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**MinimumVersionPage**](MinimumVersionPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsAccountErasures**
> OpsAccountErasurePage listOpsAccountErasures(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Account Erasures

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsAccountErasures(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsAccountErasures: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsAccountErasurePage**](OpsAccountErasurePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsAuditEvents**
> OpsAuditEventPage listOpsAuditEvents(xTrotxiClient, xTrotxiBuild, cursor, limit, area, actorId, action, targetId, fromDate, toDate, xTrotxiPlatform)

list Ops Audit Events

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String area = area_example; // String | Audit domain.
final String actorId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Operator user ID.
final String action = action_example; // String | Exact audit action.
final String targetId = targetId_example; // String | Exact resource ID.
final Date fromDate = 2013-10-20; // Date | Earliest UTC date, inclusive.
final Date toDate = 2013-10-20; // Date | Latest UTC date, inclusive.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsAuditEvents(xTrotxiClient, xTrotxiBuild, cursor, limit, area, actorId, action, targetId, fromDate, toDate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsAuditEvents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **area** | **String**| Audit domain. | [optional]
 **actorId** | **String**| Operator user ID. | [optional]
 **action** | **String**| Exact audit action. | [optional]
 **targetId** | **String**| Exact resource ID. | [optional]
 **fromDate** | **Date**| Earliest UTC date, inclusive. | [optional]
 **toDate** | **Date**| Latest UTC date, inclusive. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsAuditEventPage**](OpsAuditEventPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsAutoRenewals**
> OpsAutoRenewalPage listOpsAutoRenewals(xTrotxiClient, xTrotxiBuild, cursor, limit, filter, xTrotxiPlatform)

list Ops Auto Renewals

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String filter = filter_example; // String | attention: declined, unconfirmed or waiting on a new offer. open: not yet paid or ended.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsAutoRenewals(xTrotxiClient, xTrotxiBuild, cursor, limit, filter, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsAutoRenewals: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **filter** | **String**| attention: declined, unconfirmed or waiting on a new offer. open: not yet paid or ended. | [optional] [default to 'attention']
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsAutoRenewalPage**](OpsAutoRenewalPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsCommuteRequests**
> OpsCommuteRequestPage listOpsCommuteRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Ops Commute Requests

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String status = status_example; // String | Must match the resource state enum; unknown values return 400.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsCommuteRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsCommuteRequests: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **status** | **String**| Must match the resource state enum; unknown values return 400. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsCommuteRequestPage**](OpsCommuteRequestPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsDeliveries**
> OpsDeliveryPage listOpsDeliveries(xTrotxiClient, xTrotxiBuild, cursor, limit, channel, state, xTrotxiPlatform)

list Ops Deliveries

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String channel = channel_example; // String | Delivery channel.
final String state = state_example; // String | Provider delivery state.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsDeliveries(xTrotxiClient, xTrotxiBuild, cursor, limit, channel, state, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsDeliveries: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **channel** | **String**| Delivery channel. | [optional]
 **state** | **String**| Provider delivery state. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsDeliveryPage**](OpsDeliveryPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsDriverRequests**
> OpsWorkRequestPage listOpsDriverRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Ops Driver Requests

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String status = status_example; // String | Must match the resource state enum; unknown values return 400.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsDriverRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsDriverRequests: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **status** | **String**| Must match the resource state enum; unknown values return 400. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsWorkRequestPage**](OpsWorkRequestPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsDrivers**
> DriverPage listOpsDrivers(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Drivers

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsDrivers(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsDrivers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**DriverPage**](DriverPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsIncidents**
> OpsIncidentPage listOpsIncidents(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Ops Incidents

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String status = status_example; // String | Must match the resource state enum; unknown values return 400.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsIncidents(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsIncidents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **status** | **String**| Must match the resource state enum; unknown values return 400. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsIncidentPage**](OpsIncidentPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsOperators**
> OpsOperatorPage listOpsOperators(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Operators

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsOperators(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsOperators: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsOperatorPage**](OpsOperatorPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsPurchases**
> OpsPurchasePage listOpsPurchases(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform)

list Ops Purchases

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Optional inclusive Africa/Accra purchase-creation day. With no date filters, returns all purchase history, including unresolved purchases. No default recency cutoff.
final Date toDate = 2013-10-20; // Date | Optional inclusive purchase-creation day; if both bounds are supplied, toDate must not precede fromDate.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsPurchases(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsPurchases: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **fromDate** | **Date**| Optional inclusive Africa/Accra purchase-creation day. With no date filters, returns all purchase history, including unresolved purchases. No default recency cutoff. | [optional]
 **toDate** | **Date**| Optional inclusive purchase-creation day; if both bounds are supplied, toDate must not precede fromDate. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsPurchasePage**](OpsPurchasePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsRiders**
> OpsRiderPage listOpsRiders(xTrotxiClient, xTrotxiBuild, cursor, limit, q, xTrotxiPlatform)

list Ops Riders

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String q = q_example; // String | Name, phone or email, partial.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsRiders(xTrotxiClient, xTrotxiBuild, cursor, limit, q, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsRiders: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **q** | **String**| Name, phone or email, partial. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsRiderPage**](OpsRiderPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsRoutes**
> RoutePage listOpsRoutes(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Routes

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsRoutes(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsRoutes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RoutePage**](RoutePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsStandby**
> StandbyApplicationPage listOpsStandby(xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, state, plan, day, q, xTrotxiPlatform)

list Ops Standby

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Filter by route identity, not its display name.
final String state = state_example; // String | Application state. Omit for all states.
final String plan = plan_example; // String | Requested plan.
final int day = 56; // int | Travel weekday: Monday=1, Sunday=7.
final String q = q_example; // String | Literal partial rider name. Route demand totals respect these filters except routeId and pagination.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsStandby(xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, state, plan, day, q, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsStandby: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **routeId** | **String**| Filter by route identity, not its display name. | [optional]
 **state** | **String**| Application state. Omit for all states. | [optional]
 **plan** | **String**| Requested plan. | [optional]
 **day** | **int**| Travel weekday: Monday=1, Sunday=7. | [optional]
 **q** | **String**| Literal partial rider name. Route demand totals respect these filters except routeId and pagination. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StandbyApplicationPage**](StandbyApplicationPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsStops**
> StopPage listOpsStops(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Stops

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsStops(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsStops: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StopPage**](StopPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsTeam**
> OpsTeamEntryPage listOpsTeam(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Team

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsTeam(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsTeam: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsTeamEntryPage**](OpsTeamEntryPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsTrips**
> OpsTripPage listOpsTrips(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, routeId, xTrotxiPlatform)

list Ops Trips

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String routeId = routeId_example; // String | Filter within caller scope; never expands authorization.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsTrips(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, routeId, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsTrips: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **fromDate** | **Date**| Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days. | [optional]
 **toDate** | **Date**| Inclusive; paired with fromDate. | [optional]
 **routeId** | **String**| Filter within caller scope; never expands authorization. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsTripPage**](OpsTripPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listOpsVehicles**
> VehiclePage listOpsVehicles(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Vehicles

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listOpsVehicles(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listOpsVehicles: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**VehiclePage**](VehiclePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPatternVersions**
> PatternVersionPage listPatternVersions(id, xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Pattern Versions

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listPatternVersions(id, xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listPatternVersions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PatternVersionPage**](PatternVersionPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPatterns**
> PatternPage listPatterns(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Patterns

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listPatterns(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listPatterns: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PatternPage**](PatternPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPaymentReviews**
> PaymentReviewPage listPaymentReviews(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Payment Reviews

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String status = status_example; // String | Must match the resource state enum; unknown values return 400.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listPaymentReviews(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listPaymentReviews: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **status** | **String**| Must match the resource state enum; unknown values return 400. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PaymentReviewPage**](PaymentReviewPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPlanPricing**
> PlanPricingPage listPlanPricing(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Plan Pricing

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listPlanPricing(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listPlanPricing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PlanPricingPage**](PlanPricingPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRefundInitiations**
> RefundInitiationCollectionResponse listRefundInitiations(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

list Refund Initiations

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listRefundInitiations(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listRefundInitiations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RefundInitiationCollectionResponse**](RefundInitiationCollectionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listSchedules**
> SchedulePage listSchedules(xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, xTrotxiPlatform)

list Schedules

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String routeId = routeId_example; // String | Filter within caller scope; never expands authorization.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listSchedules(xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listSchedules: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **routeId** | **String**| Filter within caller scope; never expands authorization. | [optional]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**SchedulePage**](SchedulePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTraceHolds**
> TraceHoldPage listTraceHolds(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Trace Holds

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listTraceHolds(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->listTraceHolds: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**TraceHoldPage**](TraceHoldPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **offerStandby**
> StandbyApplicationResponse offerStandby(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, standbyOfferInput, xTrotxiPlatform)

offer Standby

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final StandbyOfferInput standbyOfferInput = ; // StandbyOfferInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.offerStandby(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, standbyOfferInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->offerStandby: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **standbyOfferInput** | [**StandbyOfferInput**](StandbyOfferInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StandbyApplicationResponse**](StandbyApplicationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishPatternVersion**
> PatternVersionResponse publishPatternVersion(id, versionId, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, publishVersionInput, xTrotxiPlatform)

publish Pattern Version

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String versionId = versionId_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PublishVersionInput publishVersionInput = ; // PublishVersionInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.publishPatternVersion(id, versionId, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, publishVersionInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->publishPatternVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **versionId** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **publishVersionInput** | [**PublishVersionInput**](PublishVersionInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PatternVersionResponse**](PatternVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **releaseAccountRestriction**
> RestrictionResponse releaseAccountRestriction(id, restrictionId, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

release Account Restriction

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String restrictionId = restrictionId_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.releaseAccountRestriction(id, restrictionId, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->releaseAccountRestriction: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **restrictionId** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RestrictionResponse**](RestrictionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **releaseTraceHold**
> TraceHoldResponse releaseTraceHold(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

release Trace Hold

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.releaseTraceHold(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->releaseTraceHold: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**TraceHoldResponse**](TraceHoldResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rescheduleTrip**
> OpsTripResponse rescheduleTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, tripEdit, xTrotxiPlatform)

reschedule Trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final TripEdit tripEdit = ; // TripEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.rescheduleTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, tripEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->rescheduleTrip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **tripEdit** | [**TripEdit**](TripEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OpsTripResponse**](OpsTripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendOperatorInvitation**
> OperatorCommandResultResponse resendOperatorInvitation(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

resend Operator Invitation

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.resendOperatorInvitation(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->resendOperatorInvitation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OperatorCommandResultResponse**](OperatorCommandResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetDriverPin**
> CredentialSecretResponse resetDriverPin(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, pinResetInput, xTrotxiPlatform)

reset Driver Pin

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PinResetInput pinResetInput = ; // PinResetInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.resetDriverPin(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, pinResetInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->resetDriverPin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **pinResetInput** | [**PinResetInput**](PinResetInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**CredentialSecretResponse**](CredentialSecretResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetOperatorPasskeys**
> resetOperatorPasskeys(id, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

reset Operator Passkeys

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.resetOperatorPasskeys(id, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling OpsApi->resetOperatorPasskeys: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resolvePaymentReview**
> PaymentReviewResponse resolvePaymentReview(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reviewDecision, xTrotxiPlatform)

resolve Payment Review

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReviewDecision reviewDecision = ; // ReviewDecision |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.resolvePaymentReview(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reviewDecision, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->resolvePaymentReview: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reviewDecision** | [**ReviewDecision**](ReviewDecision.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PaymentReviewResponse**](PaymentReviewResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **retireCommuteSlot**
> CommuteSlotResponse retireCommuteSlot(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

retire Commute Slot

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.retireCommuteSlot(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->retireCommuteSlot: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**CommuteSlotResponse**](CommuteSlotResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runPersonalPauseResumes**
> MaintenanceResultResponse runPersonalPauseResumes(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform)

run Personal Pause Resumes

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MaintenanceInput maintenanceInput = ; // MaintenanceInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runPersonalPauseResumes(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->runPersonalPauseResumes: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **maintenanceInput** | [**MaintenanceInput**](MaintenanceInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setFlag**
> FlagResponse setFlag(key, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, flagEdit, xTrotxiPlatform)

set Flag

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String key = key_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final FlagEdit flagEdit = ; // FlagEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.setFlag(key, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, flagEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->setFlag: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **flagEdit** | [**FlagEdit**](FlagEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**FlagResponse**](FlagResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setMinimumVersion**
> MinimumVersionResponse setMinimumVersion(app, platform, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, minimumVersionEdit, xTrotxiPlatform)

set Minimum Version

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String app = app_example; // String |
final String platform = platform_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MinimumVersionEdit minimumVersionEdit = ; // MinimumVersionEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.setMinimumVersion(app, platform, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, minimumVersionEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->setMinimumVersion: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **app** | **String**|  |
 **platform** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **minimumVersionEdit** | [**MinimumVersionEdit**](MinimumVersionEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**MinimumVersionResponse**](MinimumVersionResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateDriver**
> DriverResponse updateDriver(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, driverEdit, xTrotxiPlatform)

update Driver

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final DriverEdit driverEdit = ; // DriverEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updateDriver(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, driverEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->updateDriver: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **driverEdit** | [**DriverEdit**](DriverEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**DriverResponse**](DriverResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateOperatorAccess**
> OperatorCommandResultResponse updateOperatorAccess(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, operatorAccessInput, xTrotxiPlatform)

update Operator Access

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final OperatorAccessInput operatorAccessInput = ; // OperatorAccessInput |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updateOperatorAccess(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, operatorAccessInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->updateOperatorAccess: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **operatorAccessInput** | [**OperatorAccessInput**](OperatorAccessInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**OperatorCommandResultResponse**](OperatorCommandResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePlanPricing**
> PlanPricingResponse updatePlanPricing(plan, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, pricingEdit, xTrotxiPlatform)

update Plan Pricing

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String plan = plan_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PricingEdit pricingEdit = ; // PricingEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updatePlanPricing(plan, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, pricingEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->updatePlanPricing: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plan** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **pricingEdit** | [**PricingEdit**](PricingEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PlanPricingResponse**](PlanPricingResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRoute**
> RouteResponse updateRoute(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, routeEdit, xTrotxiPlatform)

update Route

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final RouteEdit routeEdit = ; // RouteEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updateRoute(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, routeEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->updateRoute: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **routeEdit** | [**RouteEdit**](RouteEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateStop**
> StopResponse updateStop(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, stopEdit, xTrotxiPlatform)

update Stop

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final StopEdit stopEdit = ; // StopEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updateStop(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, stopEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->updateStop: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **stopEdit** | [**StopEdit**](StopEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StopResponse**](StopResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateVehicle**
> VehicleResponse updateVehicle(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, vehicleEdit, xTrotxiPlatform)

update Vehicle

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsApi();
final String id = id_example; // String |
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = ops; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final VehicleEdit vehicleEdit = ; // VehicleEdit |
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updateVehicle(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, vehicleEdit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsApi->updateVehicle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **ifMatch** | **String**| Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization. |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **vehicleEdit** | [**VehicleEdit**](VehicleEdit.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**VehicleResponse**](VehicleResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

