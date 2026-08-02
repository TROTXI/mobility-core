# trotxi_api_client.api.AdminApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminAskDispatchPost**](AdminApi.md#adminaskdispatchpost) | **POST** /admin/ask-dispatch | Prompt a day&#39;s route subscribers to confirm (seed pending + push)
[**adminConvertCreditsPost**](AdminApi.md#adminconvertcreditspost) | **POST** /admin/convert-credits | Month-end: convert every active rider&#39;s unused rides to Ride Credits
[**adminDriversGet**](AdminApi.md#admindriversget) | **GET** /admin/drivers | List all drivers
[**adminDriversIdPatch**](AdminApi.md#admindriversidpatch) | **PATCH** /admin/drivers/{id} | Update a driver
[**adminDriversPost**](AdminApi.md#admindriverspost) | **POST** /admin/drivers | Create a driver
[**adminFlagsGet**](AdminApi.md#adminflagsget) | **GET** /admin/flags | List all feature flags
[**adminFlagsKeyPut**](AdminApi.md#adminflagskeyput) | **PUT** /admin/flags/{key} | Create or update a feature flag
[**adminMinVersionsGet**](AdminApi.md#adminminversionsget) | **GET** /admin/min-versions | List the minimum supported app version per platform
[**adminMinVersionsPlatformPut**](AdminApi.md#adminminversionsplatformput) | **PUT** /admin/min-versions/{platform} | Set the minimum supported app version for a platform
[**adminResolveDefaultsPost**](AdminApi.md#adminresolvedefaultspost) | **POST** /admin/resolve-defaults | Cutoff default-yes: flip still-pending reservations to reserved
[**adminResolveNoShowsPost**](AdminApi.md#adminresolvenoshowspost) | **POST** /admin/resolve-no-shows | Cutoff: deduct confirmed-but-unboarded seats as no-shows
[**adminRoutesGet**](AdminApi.md#adminroutesget) | **GET** /admin/routes | List all routes
[**adminRoutesIdPatch**](AdminApi.md#adminroutesidpatch) | **PATCH** /admin/routes/{id} | Update a route
[**adminRoutesIdStopsPost**](AdminApi.md#adminroutesidstopspost) | **POST** /admin/routes/{id}/stops | Attach a stop to a route at a sequence position
[**adminRoutesPost**](AdminApi.md#adminroutespost) | **POST** /admin/routes | Create a route
[**adminStopsGet**](AdminApi.md#adminstopsget) | **GET** /admin/stops | List all stops
[**adminStopsIdPatch**](AdminApi.md#adminstopsidpatch) | **PATCH** /admin/stops/{id} | Update a stop
[**adminStopsPost**](AdminApi.md#adminstopspost) | **POST** /admin/stops | Create a stop
[**adminTripsGet**](AdminApi.md#admintripsget) | **GET** /admin/trips | List trips, filterable by route, status, and UTC day
[**adminTripsIdAssignmentPut**](AdminApi.md#admintripsidassignmentput) | **PUT** /admin/trips/{id}/assignment | Assign a vehicle and/or driver to a trip
[**adminTripsIdPatch**](AdminApi.md#admintripsidpatch) | **PATCH** /admin/trips/{id} | Update a trip (status / schedule)
[**adminTripsPost**](AdminApi.md#admintripspost) | **POST** /admin/trips | Create a trip
[**adminUsersIdRolePatch**](AdminApi.md#adminusersidrolepatch) | **PATCH** /admin/users/{id}/role | Change a user&#39;s role (commuter | driver | admin)
[**adminVehiclesGet**](AdminApi.md#adminvehiclesget) | **GET** /admin/vehicles | List all vehicles
[**adminVehiclesIdPatch**](AdminApi.md#adminvehiclesidpatch) | **PATCH** /admin/vehicles/{id} | Update a vehicle
[**adminVehiclesPost**](AdminApi.md#adminvehiclespost) | **POST** /admin/vehicles | Create a vehicle


# **adminAskDispatchPost**
> AdminAskDispatchPost200Response adminAskDispatchPost(adminAskDispatchPostRequest)

Prompt a day's route subscribers to confirm (seed pending + push)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminAskDispatchPostRequest adminAskDispatchPostRequest = ; // AdminAskDispatchPostRequest | 

try {
    final response = api.adminAskDispatchPost(adminAskDispatchPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminAskDispatchPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminAskDispatchPostRequest** | [**AdminAskDispatchPostRequest**](AdminAskDispatchPostRequest.md)|  | 

### Return type

[**AdminAskDispatchPost200Response**](AdminAskDispatchPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminConvertCreditsPost**
> AdminConvertCreditsPost200Response adminConvertCreditsPost()

Month-end: convert every active rider's unused rides to Ride Credits

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();

try {
    final response = api.adminConvertCreditsPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminConvertCreditsPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AdminConvertCreditsPost200Response**](AdminConvertCreditsPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDriversGet**
> BuiltList<AdminDriversGet200ResponseInner> adminDriversGet()

List all drivers

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();

try {
    final response = api.adminDriversGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDriversGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AdminDriversGet200ResponseInner&gt;**](AdminDriversGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDriversIdPatch**
> AdminDriversGet200ResponseInner adminDriversIdPatch(id, adminDriversIdPatchRequest)

Update a driver

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminDriversIdPatchRequest adminDriversIdPatchRequest = ; // AdminDriversIdPatchRequest | 

try {
    final response = api.adminDriversIdPatch(id, adminDriversIdPatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDriversIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminDriversIdPatchRequest** | [**AdminDriversIdPatchRequest**](AdminDriversIdPatchRequest.md)|  | 

### Return type

[**AdminDriversGet200ResponseInner**](AdminDriversGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminDriversPost**
> AdminDriversGet200ResponseInner adminDriversPost(adminDriversPostRequest)

Create a driver

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminDriversPostRequest adminDriversPostRequest = ; // AdminDriversPostRequest | 

try {
    final response = api.adminDriversPost(adminDriversPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminDriversPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminDriversPostRequest** | [**AdminDriversPostRequest**](AdminDriversPostRequest.md)|  | 

### Return type

[**AdminDriversGet200ResponseInner**](AdminDriversGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminFlagsGet**
> BuiltList<AdminFlagsGet200ResponseInner> adminFlagsGet()

List all feature flags

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();

try {
    final response = api.adminFlagsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminFlagsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AdminFlagsGet200ResponseInner&gt;**](AdminFlagsGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminFlagsKeyPut**
> AdminFlagsGet200ResponseInner adminFlagsKeyPut(key, adminFlagsKeyPutRequest)

Create or update a feature flag

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String key = key_example; // String | 
final AdminFlagsKeyPutRequest adminFlagsKeyPutRequest = ; // AdminFlagsKeyPutRequest | 

try {
    final response = api.adminFlagsKeyPut(key, adminFlagsKeyPutRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminFlagsKeyPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **key** | **String**|  | 
 **adminFlagsKeyPutRequest** | [**AdminFlagsKeyPutRequest**](AdminFlagsKeyPutRequest.md)|  | 

### Return type

[**AdminFlagsGet200ResponseInner**](AdminFlagsGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminMinVersionsGet**
> BuiltList<AdminMinVersionsGet200ResponseInner> adminMinVersionsGet()

List the minimum supported app version per platform

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();

try {
    final response = api.adminMinVersionsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMinVersionsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AdminMinVersionsGet200ResponseInner&gt;**](AdminMinVersionsGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminMinVersionsPlatformPut**
> AdminMinVersionsGet200ResponseInner adminMinVersionsPlatformPut(platform, adminMinVersionsPlatformPutRequest)

Set the minimum supported app version for a platform

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String platform = platform_example; // String | 
final AdminMinVersionsPlatformPutRequest adminMinVersionsPlatformPutRequest = ; // AdminMinVersionsPlatformPutRequest | 

try {
    final response = api.adminMinVersionsPlatformPut(platform, adminMinVersionsPlatformPutRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminMinVersionsPlatformPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **platform** | **String**|  | 
 **adminMinVersionsPlatformPutRequest** | [**AdminMinVersionsPlatformPutRequest**](AdminMinVersionsPlatformPutRequest.md)|  | 

### Return type

[**AdminMinVersionsGet200ResponseInner**](AdminMinVersionsGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminResolveDefaultsPost**
> AdminResolveDefaultsPost200Response adminResolveDefaultsPost(adminAskDispatchPostRequest)

Cutoff default-yes: flip still-pending reservations to reserved

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminAskDispatchPostRequest adminAskDispatchPostRequest = ; // AdminAskDispatchPostRequest | 

try {
    final response = api.adminResolveDefaultsPost(adminAskDispatchPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminResolveDefaultsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminAskDispatchPostRequest** | [**AdminAskDispatchPostRequest**](AdminAskDispatchPostRequest.md)|  | 

### Return type

[**AdminResolveDefaultsPost200Response**](AdminResolveDefaultsPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminResolveNoShowsPost**
> AdminResolveNoShowsPost200Response adminResolveNoShowsPost(adminAskDispatchPostRequest)

Cutoff: deduct confirmed-but-unboarded seats as no-shows

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminAskDispatchPostRequest adminAskDispatchPostRequest = ; // AdminAskDispatchPostRequest | 

try {
    final response = api.adminResolveNoShowsPost(adminAskDispatchPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminResolveNoShowsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminAskDispatchPostRequest** | [**AdminAskDispatchPostRequest**](AdminAskDispatchPostRequest.md)|  | 

### Return type

[**AdminResolveNoShowsPost200Response**](AdminResolveNoShowsPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminRoutesGet**
> BuiltList<RoutesGet200ResponseInner> adminRoutesGet()

List all routes

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();

try {
    final response = api.adminRoutesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminRoutesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;RoutesGet200ResponseInner&gt;**](RoutesGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminRoutesIdPatch**
> RoutesGet200ResponseInner adminRoutesIdPatch(id, adminRoutesIdPatchRequest)

Update a route

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminRoutesIdPatchRequest adminRoutesIdPatchRequest = ; // AdminRoutesIdPatchRequest | 

try {
    final response = api.adminRoutesIdPatch(id, adminRoutesIdPatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminRoutesIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminRoutesIdPatchRequest** | [**AdminRoutesIdPatchRequest**](AdminRoutesIdPatchRequest.md)|  | 

### Return type

[**RoutesGet200ResponseInner**](RoutesGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminRoutesIdStopsPost**
> AdminRoutesIdStopsPost200Response adminRoutesIdStopsPost(id, adminRoutesIdStopsPostRequest)

Attach a stop to a route at a sequence position

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminRoutesIdStopsPostRequest adminRoutesIdStopsPostRequest = ; // AdminRoutesIdStopsPostRequest | 

try {
    final response = api.adminRoutesIdStopsPost(id, adminRoutesIdStopsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminRoutesIdStopsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminRoutesIdStopsPostRequest** | [**AdminRoutesIdStopsPostRequest**](AdminRoutesIdStopsPostRequest.md)|  | 

### Return type

[**AdminRoutesIdStopsPost200Response**](AdminRoutesIdStopsPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminRoutesPost**
> RoutesGet200ResponseInner adminRoutesPost(adminRoutesPostRequest)

Create a route

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminRoutesPostRequest adminRoutesPostRequest = ; // AdminRoutesPostRequest | 

try {
    final response = api.adminRoutesPost(adminRoutesPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminRoutesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminRoutesPostRequest** | [**AdminRoutesPostRequest**](AdminRoutesPostRequest.md)|  | 

### Return type

[**RoutesGet200ResponseInner**](RoutesGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminStopsGet**
> BuiltList<AdminStopsGet200ResponseInner> adminStopsGet()

List all stops

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();

try {
    final response = api.adminStopsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminStopsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AdminStopsGet200ResponseInner&gt;**](AdminStopsGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminStopsIdPatch**
> AdminStopsGet200ResponseInner adminStopsIdPatch(id, adminStopsIdPatchRequest)

Update a stop

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminStopsIdPatchRequest adminStopsIdPatchRequest = ; // AdminStopsIdPatchRequest | 

try {
    final response = api.adminStopsIdPatch(id, adminStopsIdPatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminStopsIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminStopsIdPatchRequest** | [**AdminStopsIdPatchRequest**](AdminStopsIdPatchRequest.md)|  | 

### Return type

[**AdminStopsGet200ResponseInner**](AdminStopsGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminStopsPost**
> AdminStopsGet200ResponseInner adminStopsPost(adminStopsPostRequest)

Create a stop

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminStopsPostRequest adminStopsPostRequest = ; // AdminStopsPostRequest | 

try {
    final response = api.adminStopsPost(adminStopsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminStopsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminStopsPostRequest** | [**AdminStopsPostRequest**](AdminStopsPostRequest.md)|  | 

### Return type

[**AdminStopsGet200ResponseInner**](AdminStopsGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTripsGet**
> BuiltList<TripsGet200ResponseTripsInner> adminTripsGet(routeId, status, date)

List trips, filterable by route, status, and UTC day

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String routeId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String status = status_example; // String | 
final String date = date_example; // String | 

try {
    final response = api.adminTripsGet(routeId, status, date);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminTripsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeId** | **String**|  | [optional] 
 **status** | **String**|  | [optional] 
 **date** | **String**|  | [optional] 

### Return type

[**BuiltList&lt;TripsGet200ResponseTripsInner&gt;**](TripsGet200ResponseTripsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTripsIdAssignmentPut**
> TripsGet200ResponseTripsInner adminTripsIdAssignmentPut(id, adminTripsIdAssignmentPutRequest)

Assign a vehicle and/or driver to a trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminTripsIdAssignmentPutRequest adminTripsIdAssignmentPutRequest = ; // AdminTripsIdAssignmentPutRequest | 

try {
    final response = api.adminTripsIdAssignmentPut(id, adminTripsIdAssignmentPutRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminTripsIdAssignmentPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminTripsIdAssignmentPutRequest** | [**AdminTripsIdAssignmentPutRequest**](AdminTripsIdAssignmentPutRequest.md)|  | 

### Return type

[**TripsGet200ResponseTripsInner**](TripsGet200ResponseTripsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTripsIdPatch**
> TripsGet200ResponseTripsInner adminTripsIdPatch(id, adminTripsIdPatchRequest)

Update a trip (status / schedule)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminTripsIdPatchRequest adminTripsIdPatchRequest = ; // AdminTripsIdPatchRequest | 

try {
    final response = api.adminTripsIdPatch(id, adminTripsIdPatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminTripsIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminTripsIdPatchRequest** | [**AdminTripsIdPatchRequest**](AdminTripsIdPatchRequest.md)|  | 

### Return type

[**TripsGet200ResponseTripsInner**](TripsGet200ResponseTripsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminTripsPost**
> TripsGet200ResponseTripsInner adminTripsPost(adminTripsPostRequest)

Create a trip

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminTripsPostRequest adminTripsPostRequest = ; // AdminTripsPostRequest | 

try {
    final response = api.adminTripsPost(adminTripsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminTripsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminTripsPostRequest** | [**AdminTripsPostRequest**](AdminTripsPostRequest.md)|  | 

### Return type

[**TripsGet200ResponseTripsInner**](TripsGet200ResponseTripsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminUsersIdRolePatch**
> AdminUsersIdRolePatch200Response adminUsersIdRolePatch(id, adminUsersIdRolePatchRequest)

Change a user's role (commuter | driver | admin)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminUsersIdRolePatchRequest adminUsersIdRolePatchRequest = ; // AdminUsersIdRolePatchRequest | 

try {
    final response = api.adminUsersIdRolePatch(id, adminUsersIdRolePatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminUsersIdRolePatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminUsersIdRolePatchRequest** | [**AdminUsersIdRolePatchRequest**](AdminUsersIdRolePatchRequest.md)|  | 

### Return type

[**AdminUsersIdRolePatch200Response**](AdminUsersIdRolePatch200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminVehiclesGet**
> BuiltList<AdminVehiclesGet200ResponseInner> adminVehiclesGet()

List all vehicles

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();

try {
    final response = api.adminVehiclesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminVehiclesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;AdminVehiclesGet200ResponseInner&gt;**](AdminVehiclesGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminVehiclesIdPatch**
> AdminVehiclesGet200ResponseInner adminVehiclesIdPatch(id, adminVehiclesIdPatchRequest)

Update a vehicle

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final AdminVehiclesIdPatchRequest adminVehiclesIdPatchRequest = ; // AdminVehiclesIdPatchRequest | 

try {
    final response = api.adminVehiclesIdPatch(id, adminVehiclesIdPatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminVehiclesIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **adminVehiclesIdPatchRequest** | [**AdminVehiclesIdPatchRequest**](AdminVehiclesIdPatchRequest.md)|  | 

### Return type

[**AdminVehiclesGet200ResponseInner**](AdminVehiclesGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminVehiclesPost**
> AdminVehiclesGet200ResponseInner adminVehiclesPost(adminVehiclesPostRequest)

Create a vehicle

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAdminApi();
final AdminVehiclesPostRequest adminVehiclesPostRequest = ; // AdminVehiclesPostRequest | 

try {
    final response = api.adminVehiclesPost(adminVehiclesPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->adminVehiclesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **adminVehiclesPostRequest** | [**AdminVehiclesPostRequest**](AdminVehiclesPostRequest.md)|  | 

### Return type

[**AdminVehiclesGet200ResponseInner**](AdminVehiclesGet200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

