# trotxi_api_client.api.AuthApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authGooglePost**](AuthApi.md#authgooglepost) | **POST** /auth/google | Sign in with a Google ID token (creates the account on first use)
[**authLogoutPost**](AuthApi.md#authlogoutpost) | **POST** /auth/logout | Revoke a refresh token (idempotent)
[**authRefreshPost**](AuthApi.md#authrefreshpost) | **POST** /auth/refresh | Exchange a refresh token for a new token pair (rotates the session)
[**meAvatarGet**](AuthApi.md#meavatarget) | **GET** /me/avatar | Get a short-lived signed URL for the authenticated user avatar
[**meAvatarPost**](AuthApi.md#meavatarpost) | **POST** /me/avatar | Upload the authenticated user avatar (resized + EXIF-stripped server-side)
[**meDevicesPost**](AuthApi.md#medevicespost) | **POST** /me/devices | Register this device FCM push token for the authenticated user
[**meGet**](AuthApi.md#meget) | **GET** /me | Get the currently authenticated user
[**mePatch**](AuthApi.md#mepatch) | **PATCH** /me | Update the authenticated user&#39;s profile
[**meSessionsGet**](AuthApi.md#mesessionsget) | **GET** /me/sessions | List the authenticated user&#39;s active sessions (devices)
[**meSessionsIdDelete**](AuthApi.md#mesessionsiddelete) | **DELETE** /me/sessions/{id} | Revoke one of your sessions (log out that device)


# **authGooglePost**
> AuthGooglePost200Response authGooglePost(authGooglePostRequest)

Sign in with a Google ID token (creates the account on first use)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();
final AuthGooglePostRequest authGooglePostRequest = ; // AuthGooglePostRequest | 

try {
    final response = api.authGooglePost(authGooglePostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authGooglePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authGooglePostRequest** | [**AuthGooglePostRequest**](AuthGooglePostRequest.md)|  | 

### Return type

[**AuthGooglePost200Response**](AuthGooglePost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLogoutPost**
> authLogoutPost(authRefreshPostRequest)

Revoke a refresh token (idempotent)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();
final AuthRefreshPostRequest authRefreshPostRequest = ; // AuthRefreshPostRequest | 

try {
    api.authLogoutPost(authRefreshPostRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authLogoutPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authRefreshPostRequest** | [**AuthRefreshPostRequest**](AuthRefreshPostRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRefreshPost**
> AuthRefreshPost200Response authRefreshPost(authRefreshPostRequest)

Exchange a refresh token for a new token pair (rotates the session)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();
final AuthRefreshPostRequest authRefreshPostRequest = ; // AuthRefreshPostRequest | 

try {
    final response = api.authRefreshPost(authRefreshPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authRefreshPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authRefreshPostRequest** | [**AuthRefreshPostRequest**](AuthRefreshPostRequest.md)|  | 

### Return type

[**AuthRefreshPost200Response**](AuthRefreshPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meAvatarGet**
> MeAvatarGet200Response meAvatarGet()

Get a short-lived signed URL for the authenticated user avatar

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();

try {
    final response = api.meAvatarGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->meAvatarGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeAvatarGet200Response**](MeAvatarGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meAvatarPost**
> MeAvatarGet200Response meAvatarPost()

Upload the authenticated user avatar (resized + EXIF-stripped server-side)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();

try {
    final response = api.meAvatarPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->meAvatarPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeAvatarGet200Response**](MeAvatarGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meDevicesPost**
> MeDevicesPost200Response meDevicesPost(meDevicesPostRequest)

Register this device FCM push token for the authenticated user

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();
final MeDevicesPostRequest meDevicesPostRequest = ; // MeDevicesPostRequest | 

try {
    final response = api.meDevicesPost(meDevicesPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->meDevicesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meDevicesPostRequest** | [**MeDevicesPostRequest**](MeDevicesPostRequest.md)|  | 

### Return type

[**MeDevicesPost200Response**](MeDevicesPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meGet**
> MeGet200Response meGet()

Get the currently authenticated user

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();

try {
    final response = api.meGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->meGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeGet200Response**](MeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **mePatch**
> MeGet200Response mePatch(mePatchRequest)

Update the authenticated user's profile

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();
final MePatchRequest mePatchRequest = ; // MePatchRequest | 

try {
    final response = api.mePatch(mePatchRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->mePatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **mePatchRequest** | [**MePatchRequest**](MePatchRequest.md)|  | 

### Return type

[**MeGet200Response**](MeGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meSessionsGet**
> MeSessionsGet200Response meSessionsGet()

List the authenticated user's active sessions (devices)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();

try {
    final response = api.meSessionsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->meSessionsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeSessionsGet200Response**](MeSessionsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meSessionsIdDelete**
> meSessionsIdDelete(id)

Revoke one of your sessions (log out that device)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getAuthApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.meSessionsIdDelete(id);
} on DioException catch (e) {
    print('Exception when calling AuthApi->meSessionsIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

