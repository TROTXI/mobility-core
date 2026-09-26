# trotxi_api_client.api.PublicApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getBootstrap**](PublicApi.md#getbootstrap) | **GET** /flags | get Bootstrap
[**getBuild**](PublicApi.md#getbuild) | **GET** /version | get Build
[**getGeometry**](PublicApi.md#getgeometry) | **GET** /v1/route-geometries/{id} | get Geometry
[**getHealth**](PublicApi.md#gethealth) | **GET** /healthz | get Health
[**getPattern**](PublicApi.md#getpattern) | **GET** /v1/route-patterns/{id} | get Pattern
[**getPatternVersion**](PublicApi.md#getpatternversion) | **GET** /v1/route-patterns/{id}/versions/{versionId} | get Pattern Version
[**getReadiness**](PublicApi.md#getreadiness) | **GET** /readyz | get Readiness
[**getRoot**](PublicApi.md#getroot) | **GET** / | get Root
[**getRoute**](PublicApi.md#getroute) | **GET** /v1/routes/{id} | get Route
[**listRouteSchedules**](PublicApi.md#listrouteschedules) | **GET** /v1/routes/{id}/schedules | list Route Schedules
[**listRoutes**](PublicApi.md#listroutes) | **GET** /v1/routes | list Routes
[**logoutSession**](PublicApi.md#logoutsession) | **POST** /v1/auth/logout | logout Session
[**refreshSession**](PublicApi.md#refreshsession) | **POST** /v1/auth/refresh | refresh Session
[**signInDriver**](PublicApi.md#signindriver) | **POST** /v1/auth/driver | sign In Driver
[**signInGoogle**](PublicApi.md#signingoogle) | **POST** /v1/auth/google | sign In Google


# **getBootstrap**
> Bootstrap getBootstrap()

get Bootstrap

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();

try {
    final response = api.getBootstrap();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getBootstrap: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Bootstrap**](Bootstrap.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBuild**
> Build getBuild()

get Build

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();

try {
    final response = api.getBuild();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getBuild: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Build**](Build.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getGeometry**
> GeometryResponse getGeometry(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Geometry

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String id = id_example; // String | 
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getGeometry(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getGeometry: $e\n');
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

[**GeometryResponse**](GeometryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHealth**
> Health getHealth()

get Health

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();

try {
    final response = api.getHealth();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getHealth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Health**](Health.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPattern**
> PatternResponse getPattern(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Pattern

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String id = id_example; // String | 
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getPattern(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getPattern: $e\n');
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

[**PatternResponse**](PatternResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPatternVersion**
> PatternVersionResponse getPatternVersion(id, versionId, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Pattern Version

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String id = id_example; // String | 
final String versionId = versionId_example; // String | 
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getPatternVersion(id, versionId, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getPatternVersion: $e\n');
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

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReadiness**
> Health getReadiness()

get Readiness

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();

try {
    final response = api.getReadiness();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getReadiness: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Health**](Health.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRoot**
> Root getRoot()

get Root

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();

try {
    final response = api.getRoot();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getRoot: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Root**](Root.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRoute**
> RouteResponse getRoute(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Route

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String id = id_example; // String | 
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getRoute(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->getRoute: $e\n');
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

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRouteSchedules**
> SchedulePage listRouteSchedules(id, xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, xTrotxiPlatform)

list Route Schedules

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String id = id_example; // String | 
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String routeId = routeId_example; // String | Filter within caller scope; never expands authorization.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listRouteSchedules(id, xTrotxiClient, xTrotxiBuild, cursor, limit, routeId, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->listRouteSchedules: $e\n');
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
 **routeId** | **String**| Filter within caller scope; never expands authorization. | [optional] 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**SchedulePage**](SchedulePage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRoutes**
> RoutePage listRoutes(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Routes

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listRoutes(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->listRoutes: $e\n');
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

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutSession**
> logoutSession(xTrotxiClient, xTrotxiBuild, refreshInput, xTrotxiPlatform)

logout Session

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final RefreshInput refreshInput = ; // RefreshInput | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.logoutSession(xTrotxiClient, xTrotxiBuild, refreshInput, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling PublicApi->logoutSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **refreshInput** | [**RefreshInput**](RefreshInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshSession**
> TokensResponse refreshSession(xTrotxiClient, xTrotxiBuild, refreshInput, xTrotxiPlatform)

refresh Session

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final RefreshInput refreshInput = ; // RefreshInput | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.refreshSession(xTrotxiClient, xTrotxiBuild, refreshInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->refreshSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **refreshInput** | [**RefreshInput**](RefreshInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**TokensResponse**](TokensResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signInDriver**
> DriverTokensResponse signInDriver(xTrotxiClient, xTrotxiBuild, driverSignIn, xTrotxiPlatform)

sign In Driver

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final DriverSignIn driverSignIn = ; // DriverSignIn | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.signInDriver(xTrotxiClient, xTrotxiBuild, driverSignIn, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->signInDriver: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **driverSignIn** | [**DriverSignIn**](DriverSignIn.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**DriverTokensResponse**](DriverTokensResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signInGoogle**
> TokensResponse signInGoogle(xTrotxiClient, xTrotxiBuild, googleSignIn, xTrotxiPlatform)

sign In Google

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPublicApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final GoogleSignIn googleSignIn = ; // GoogleSignIn | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.signInGoogle(xTrotxiClient, xTrotxiBuild, googleSignIn, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublicApi->signInGoogle: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **googleSignIn** | [**GoogleSignIn**](GoogleSignIn.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**TokensResponse**](TokensResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

