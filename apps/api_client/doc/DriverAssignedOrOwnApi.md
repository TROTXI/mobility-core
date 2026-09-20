# trotxi_api_client.api.DriverAssignedOrOwnApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**boardRider**](DriverAssignedOrOwnApi.md#boardrider) | **POST** /v1/driver/trips/{id}/boardings | board Rider
[**completeTrip**](DriverAssignedOrOwnApi.md#completetrip) | **POST** /v1/driver/trips/{id}/complete | complete Trip
[**getManifest**](DriverAssignedOrOwnApi.md#getmanifest) | **GET** /v1/driver/trips/{id}/manifest | get Manifest
[**getTripSummary**](DriverAssignedOrOwnApi.md#gettripsummary) | **GET** /v1/driver/trips/{id}/summary | get Trip Summary
[**listDriverTrips**](DriverAssignedOrOwnApi.md#listdrivertrips) | **GET** /v1/driver/trips | list Driver Trips
[**markNoShow**](DriverAssignedOrOwnApi.md#marknoshow) | **POST** /v1/driver/trips/{id}/reservations/{reservationId}/no-show | mark No Show
[**recordArrival**](DriverAssignedOrOwnApi.md#recordarrival) | **POST** /v1/driver/trips/{id}/arrivals | record Arrival
[**recordPosition**](DriverAssignedOrOwnApi.md#recordposition) | **POST** /v1/driver/trips/{id}/positions | record Position
[**startTrip**](DriverAssignedOrOwnApi.md#starttrip) | **POST** /v1/driver/trips/{id}/start | start Trip


# **boardRider**
> BoardingResultResponse boardRider(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, boardingInput, xTrotxiPlatform)

board Rider

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final BoardingInput boardingInput = ; // BoardingInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.boardRider(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, boardingInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->boardRider: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **boardingInput** | [**BoardingInput**](BoardingInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**BoardingResultResponse**](BoardingResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **completeTrip**
> DriverTripResponse completeTrip(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

complete Trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.completeTrip(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->completeTrip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**DriverTripResponse**](DriverTripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getManifest**
> ManifestResponse getManifest(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Manifest

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getManifest(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->getManifest: $e\n');
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

[**ManifestResponse**](ManifestResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getTripSummary**
> TripSummaryResponse getTripSummary(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Trip Summary

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getTripSummary(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->getTripSummary: $e\n');
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

[**TripSummaryResponse**](TripSummaryResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDriverTrips**
> DriverTripPage listDriverTrips(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, routeId, xTrotxiPlatform)

list Driver Trips

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String routeId = routeId_example; // String | Filter within caller scope; never expands authorization.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listDriverTrips(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, routeId, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->listDriverTrips: $e\n');
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

[**DriverTripPage**](DriverTripPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markNoShow**
> BoardingResultResponse markNoShow(id, reservationId, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

mark No Show

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String reservationId = reservationId_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.markNoShow(id, reservationId, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->markNoShow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **reservationId** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**BoardingResultResponse**](BoardingResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordArrival**
> DriverTripResponse recordArrival(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, arrivalInput, xTrotxiPlatform)

record Arrival

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ArrivalInput arrivalInput = ; // ArrivalInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.recordArrival(id, ifMatch, idempotencyKey, xTrotxiClient, xTrotxiBuild, arrivalInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->recordArrival: $e\n');
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
 **arrivalInput** | [**ArrivalInput**](ArrivalInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**DriverTripResponse**](DriverTripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **recordPosition**
> PositionReceiptResponse recordPosition(id, xTrotxiClient, xTrotxiBuild, positionInput, xTrotxiPlatform)

record Position

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PositionInput positionInput = ; // PositionInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.recordPosition(id, xTrotxiClient, xTrotxiBuild, positionInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->recordPosition: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **positionInput** | [**PositionInput**](PositionInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PositionReceiptResponse**](PositionReceiptResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startTrip**
> DriverTripResponse startTrip(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

start Trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getDriverAssignedOrOwnApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.startTrip(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DriverAssignedOrOwnApi->startTrip: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**DriverTripResponse**](DriverTripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

