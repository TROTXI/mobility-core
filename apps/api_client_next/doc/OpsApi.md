# trotxi_api_client_next.api.OpsApi

## Load the API package
```dart
import 'package:trotxi_api_client_next/api.dart';
```

All URIs are relative to *https://api.example.invalid*

Method | HTTP request | Description
------------- | ------------- | -------------
[**assignTrip**](OpsApi.md#assigntrip) | **PUT** /v1/ops/trips/{id}/assignment | assign Trip
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
[**getOpsPatternVersion**](OpsApi.md#getopspatternversion) | **GET** /v1/ops/route-patterns/{id}/versions/{versionId} | get Ops Pattern Version
[**getOpsPurchase**](OpsApi.md#getopspurchase) | **GET** /v1/ops/purchases/{id} | get Ops Purchase
[**issueDriverCredential**](OpsApi.md#issuedrivercredential) | **POST** /v1/ops/drivers/{id}/credentials | issue Driver Credential
[**listCommuteEvents**](OpsApi.md#listcommuteevents) | **GET** /v1/ops/commute-requests/{id}/events | list Commute Events
[**listCommuteSlots**](OpsApi.md#listcommuteslots) | **GET** /v1/ops/commute-slots | list Commute Slots
[**listFares**](OpsApi.md#listfares) | **GET** /v1/ops/routes/{id}/fares | list Fares
[**listFlags**](OpsApi.md#listflags) | **GET** /v1/ops/flags | list Flags
[**listMinimumVersions**](OpsApi.md#listminimumversions) | **GET** /v1/ops/min-versions | list Minimum Versions
[**listOpsCommuteRequests**](OpsApi.md#listopscommuterequests) | **GET** /v1/ops/commute-requests | list Ops Commute Requests
[**listOpsDriverRequests**](OpsApi.md#listopsdriverrequests) | **GET** /v1/ops/driver-requests | list Ops Driver Requests
[**listOpsDrivers**](OpsApi.md#listopsdrivers) | **GET** /v1/ops/drivers | list Ops Drivers
[**listOpsIncidents**](OpsApi.md#listopsincidents) | **GET** /v1/ops/incidents | list Ops Incidents
[**listOpsPurchases**](OpsApi.md#listopspurchases) | **GET** /v1/ops/purchases | list Ops Purchases
[**listOpsRoutes**](OpsApi.md#listopsroutes) | **GET** /v1/ops/routes | list Ops Routes
[**listOpsStops**](OpsApi.md#listopsstops) | **GET** /v1/ops/stops | list Ops Stops
[**listOpsTrips**](OpsApi.md#listopstrips) | **GET** /v1/ops/trips | list Ops Trips
[**listOpsVehicles**](OpsApi.md#listopsvehicles) | **GET** /v1/ops/vehicles | list Ops Vehicles
[**listPatternVersions**](OpsApi.md#listpatternversions) | **GET** /v1/ops/route-patterns/{id}/versions | list Pattern Versions
[**listPatterns**](OpsApi.md#listpatterns) | **GET** /v1/ops/route-patterns | list Patterns
[**listPaymentReviews**](OpsApi.md#listpaymentreviews) | **GET** /v1/ops/payments/reviews | list Payment Reviews
[**listPlanPricing**](OpsApi.md#listplanpricing) | **GET** /v1/ops/plan-pricing | list Plan Pricing
[**listSchedules**](OpsApi.md#listschedules) | **GET** /v1/ops/service-schedules | list Schedules
[**listTraceHolds**](OpsApi.md#listtraceholds) | **GET** /v1/ops/trace-holds | list Trace Holds
[**publishPatternVersion**](OpsApi.md#publishpatternversion) | **POST** /v1/ops/route-patterns/{id}/versions/{versionId}/publish | publish Pattern Version
[**releaseAccountRestriction**](OpsApi.md#releaseaccountrestriction) | **POST** /v1/ops/users/{id}/restrictions/{restrictionId}/release | release Account Restriction
[**releaseTraceHold**](OpsApi.md#releasetracehold) | **POST** /v1/ops/trace-holds/{id}/release | release Trace Hold
[**rescheduleTrip**](OpsApi.md#rescheduletrip) | **PATCH** /v1/ops/trips/{id} | reschedule Trip
[**resetDriverPin**](OpsApi.md#resetdriverpin) | **POST** /v1/ops/drivers/{id}/credentials/reset-pin | reset Driver Pin
[**resolvePaymentReview**](OpsApi.md#resolvepaymentreview) | **POST** /v1/ops/payments/reviews/{id}/decisions | resolve Payment Review
[**retireCommuteSlot**](OpsApi.md#retirecommuteslot) | **POST** /v1/ops/commute-slots/{id}/retire | retire Commute Slot
[**setFlag**](OpsApi.md#setflag) | **PUT** /v1/ops/flags/{key} | set Flag
[**setMinimumVersion**](OpsApi.md#setminimumversion) | **PUT** /v1/ops/min-versions/{app}/{platform} | set Minimum Version
[**updateDriver**](OpsApi.md#updatedriver) | **PATCH** /v1/ops/drivers/{id} | update Driver
[**updatePlanPricing**](OpsApi.md#updateplanpricing) | **PATCH** /v1/ops/plan-pricing/{plan} | update Plan Pricing
[**updateRoute**](OpsApi.md#updateroute) | **PATCH** /v1/ops/routes/{id} | update Route
[**updateStop**](OpsApi.md#updatestop) | **PATCH** /v1/ops/stops/{id} | update Stop
[**updateVehicle**](OpsApi.md#updatevehicle) | **PATCH** /v1/ops/vehicles/{id} | update Vehicle


# **assignTrip**
> OpsTripResponse assignTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, tripAssignment, xTrotxiPlatform)

assign Trip

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **cancelTrip**
> OpsTripResponse cancelTrip(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

cancel Trip

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **getOpsPatternVersion**
> PatternVersionResponse getOpsPatternVersion(id, versionId, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Ops Pattern Version

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String versionId = versionId_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**OpsPurchaseResponse**](OpsPurchaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **issueDriverCredential**
> CredentialSecretResponse issueDriverCredential(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, credentialIssue, xTrotxiPlatform)

issue Driver Credential

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **listOpsCommuteRequests**
> OpsCommuteRequestPage listOpsCommuteRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Ops Commute Requests

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **listOpsDriverRequests**
> OpsWorkRequestPage listOpsDriverRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Ops Driver Requests

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **listOpsPurchases**
> OpsPurchasePage listOpsPurchases(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform)

list Ops Purchases

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **listOpsRoutes**
> RoutePage listOpsRoutes(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Routes

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **listOpsStops**
> StopPage listOpsStops(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Ops Stops

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **listOpsTrips**
> OpsTripPage listOpsTrips(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, routeId, xTrotxiPlatform)

list Ops Trips

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **listSchedules**
> SchedulePage listSchedules(xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, xTrotxiPlatform)

list Schedules

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **publishPatternVersion**
> PatternVersionResponse publishPatternVersion(id, versionId, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, publishVersionInput, xTrotxiPlatform)

publish Pattern Version

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String versionId = versionId_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String restrictionId = restrictionId_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **resetDriverPin**
> CredentialSecretResponse resetDriverPin(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform)

reset Driver Pin

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReasonInput reasonInput = ; // ReasonInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.resetDriverPin(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, reasonInput, xTrotxiPlatform);
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **reasonInput** | [**ReasonInput**](ReasonInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**CredentialSecretResponse**](CredentialSecretResponse.md)

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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **setFlag**
> FlagResponse setFlag(key, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, flagEdit, xTrotxiPlatform)

set Flag

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String key = key_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String app = app_example; // String | 
final String platform = platform_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

# **updatePlanPricing**
> PlanPricingResponse updatePlanPricing(plan, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, pricingEdit, xTrotxiPlatform)

update Plan Pricing

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String plan = plan_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getOpsApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
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

