# trotxi_api_client.api.MobilityApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**meTripsGet**](MobilityApi.md#metripsget) | **GET** /me/trips | The signed-in driver&#39;s assigned runs
[**routesGet**](MobilityApi.md#routesget) | **GET** /routes | List all routes
[**routesIdGeometryGet**](MobilityApi.md#routesidgeometryget) | **GET** /routes/{id}/geometry | The path a route follows, for drawing it on a map
[**routesIdGet**](MobilityApi.md#routesidget) | **GET** /routes/{id} | Get a route with its stops in order
[**tripsGet**](MobilityApi.md#tripsget) | **GET** /trips | List trips, optionally filtered by route
[**tripsIdCompletePost**](MobilityApi.md#tripsidcompletepost) | **POST** /trips/{id}/complete | End my assigned run
[**tripsIdGet**](MobilityApi.md#tripsidget) | **GET** /trips/{id} | Get a trip by id
[**tripsIdPositionGet**](MobilityApi.md#tripsidpositionget) | **GET** /trips/{id}/position | Get a trip&#39;s latest position with a deterministic ETA to each upcoming stop
[**tripsIdPositionPost**](MobilityApi.md#tripsidpositionpost) | **POST** /trips/{id}/position | Report a GPS fix for a trip (assigned driver only)
[**tripsIdStartPost**](MobilityApi.md#tripsidstartpost) | **POST** /trips/{id}/start | Start my assigned run
[**tripsIdSummaryGet**](MobilityApi.md#tripsidsummaryget) | **GET** /trips/{id}/summary | What my run did — boarded, not boarded, and by which method


# **meTripsGet**
> TripsGet200Response meTripsGet(date)

The signed-in driver's assigned runs

Scoped to the caller rather than taking a driver id, so one driver cannot enumerate another’s schedule.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String date = date_example; // String | 

try {
    final response = api.meTripsGet(date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->meTripsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **date** | **String**|  | [optional] 

### Return type

[**TripsGet200Response**](TripsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

# **routesIdGeometryGet**
> RoutesIdGeometryGet200Response routesIdGeometryGet(id)

The path a route follows, for drawing it on a map

Returns the road-following path learned from completed runs (#179) when we have one, and a straight line through the stops when we do not. `source` tells you which you got, so a client can render the fallback differently rather than pretending it follows the road.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.routesIdGeometryGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->routesIdGeometryGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**RoutesIdGeometryGet200Response**](RoutesIdGeometryGet200Response.md)

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

# **tripsIdCompletePost**
> TripsGet200ResponseTripsInner tripsIdCompletePost(id)

End my assigned run

Refuses a trip that never started — that means the wrong run was tapped, and a completed trip with no GPS trace would poison route learning.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tripsIdCompletePost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->tripsIdCompletePost: $e\n');
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

# **tripsIdGet**
> TripsIdGet200Response tripsIdGet(id)

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

[**TripsIdGet200Response**](TripsIdGet200Response.md)

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

# **tripsIdStartPost**
> TripsGet200ResponseTripsInner tripsIdStartPost(id)

Start my assigned run

Idempotent: starting an already-active trip succeeds. A driver whose phone dropped mid-tap will press it again, and an error at the roadside is a worse answer than \"yes, it is running\".

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tripsIdStartPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->tripsIdStartPost: $e\n');
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

# **tripsIdSummaryGet**
> TripsIdSummaryGet200Response tripsIdSummaryGet(id)

What my run did — boarded, not boarded, and by which method

Reports notBoarded rather than \"no-shows deducted\": the debit is the ops cutoff’s decision, not this screen’s, and a driver should not read a deduction that has not happened yet.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getMobilityApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tripsIdSummaryGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling MobilityApi->tripsIdSummaryGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**TripsIdSummaryGet200Response**](TripsIdSummaryGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

