# trotxi_api_client.api.MobilityApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**routesGet**](MobilityApi.md#routesget) | **GET** /routes | List all routes
[**routesIdGet**](MobilityApi.md#routesidget) | **GET** /routes/{id} | Get a route with its stops in order
[**tripsGet**](MobilityApi.md#tripsget) | **GET** /trips | List trips, optionally filtered by route
[**tripsIdGet**](MobilityApi.md#tripsidget) | **GET** /trips/{id} | Get a trip by id
[**tripsIdPositionGet**](MobilityApi.md#tripsidpositionget) | **GET** /trips/{id}/position | Get a trip&#39;s latest position with a deterministic ETA to each upcoming stop
[**tripsIdPositionPost**](MobilityApi.md#tripsidpositionpost) | **POST** /trips/{id}/position | Report a GPS fix for a trip (assigned driver only)


# **routesGet**
> BuiltList<RoutesGet200ResponseInner> routesGet()

List all routes

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();

try {
    final response = api.routesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->routesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;RoutesGet200ResponseInner&gt;**](RoutesGet200ResponseInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **routesIdGet**
> RoutesIdGet200Response routesIdGet(id)

Get a route with its stops in order

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.routesIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->routesIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**RoutesIdGet200Response**](RoutesIdGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsGet**
> TripsGet200Response tripsGet(routeId)

List trips, optionally filtered by route

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tripsGet(routeId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->tripsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | [optional] 

### Return type

[**TripsGet200Response**](TripsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsIdGet**
> TripsGet200ResponseTripsInner tripsIdGet(id)

Get a trip by id

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tripsIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->tripsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**TripsGet200ResponseTripsInner**](TripsGet200ResponseTripsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsIdPositionGet**
> TripsIdPositionGet200Response tripsIdPositionGet(id)

Get a trip's latest position with a deterministic ETA to each upcoming stop

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tripsIdPositionGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->tripsIdPositionGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**TripsIdPositionGet200Response**](TripsIdPositionGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsIdPositionPost**
> TripsIdPositionPost200Response tripsIdPositionPost(id, tripsIdPositionPostRequest)

Report a GPS fix for a trip (assigned driver only)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final TripsIdPositionPostRequest tripsIdPositionPostRequest = ; // TripsIdPositionPostRequest | 

try {
    final response = api.tripsIdPositionPost(id, tripsIdPositionPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->tripsIdPositionPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **tripsIdPositionPostRequest** | [**TripsIdPositionPostRequest**](TripsIdPositionPostRequest.md)|  | 

### Return type

[**TripsIdPositionPost200Response**](TripsIdPositionPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

