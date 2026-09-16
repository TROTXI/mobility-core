# trotxi_api_client_next.api.SignedInCatalogApi

## Load the API package
```dart
import 'package:trotxi_api_client_next/api.dart';
```

All URIs are relative to *https://api.example.invalid*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getTrip**](SignedInCatalogApi.md#gettrip) | **GET** /v1/trips/{id} | get Trip
[**listTrips**](SignedInCatalogApi.md#listtrips) | **GET** /v1/trips | list Trips


# **getTrip**
> TripResponse getTrip(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Trip

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getSignedInCatalogApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getTrip(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SignedInCatalogApi->getTrip: $e\n');
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

[**TripResponse**](TripResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listTrips**
> TripPage listTrips(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, routeId, xTrotxiPlatform)

list Trips

### Example
```dart
import 'package:trotxi_api_client_next/api.dart';

final api = TrotxiApiClientNext().getSignedInCatalogApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String routeId = routeId_example; // String | Filter within caller scope; never expands authorization.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listTrips(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, routeId, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SignedInCatalogApi->listTrips: $e\n');
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

[**TripPage**](TripPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

