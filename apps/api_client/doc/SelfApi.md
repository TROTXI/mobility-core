# trotxi_api_client.api.SelfApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteAvatar**](SelfApi.md#deleteavatar) | **DELETE** /v1/me/avatar | delete Avatar
[**eraseAccount**](SelfApi.md#eraseaccount) | **DELETE** /v1/me | erase Account
<<<<<<< HEAD
[**getAccount**](SelfApi.md#getaccount) | **GET** /v1/me | get Account
[**getAvatar**](SelfApi.md#getavatar) | **GET** /v1/me/avatar | get Avatar
[**listSessions**](SelfApi.md#listsessions) | **GET** /v1/me/sessions | list Sessions
[**registerDevice**](SelfApi.md#registerdevice) | **POST** /v1/me/devices | register Device
[**revokeSession**](SelfApi.md#revokesession) | **DELETE** /v1/me/sessions/{id} | revoke Session
=======
[**finishPasskeyAuthentication**](SelfApi.md#finishpasskeyauthentication) | **POST** /v1/auth/passkeys/authentication/verification | finish Passkey Authentication
[**finishPasskeyRegistration**](SelfApi.md#finishpasskeyregistration) | **POST** /v1/auth/passkeys/registration/verification | finish Passkey Registration
[**getAccount**](SelfApi.md#getaccount) | **GET** /v1/me | get Account
[**getAvatar**](SelfApi.md#getavatar) | **GET** /v1/me/avatar | get Avatar
[**getPasskeyStatus**](SelfApi.md#getpasskeystatus) | **GET** /v1/auth/passkeys | get Passkey Status
[**listSessions**](SelfApi.md#listsessions) | **GET** /v1/me/sessions | list Sessions
[**registerDevice**](SelfApi.md#registerdevice) | **POST** /v1/me/devices | register Device
[**revokeSession**](SelfApi.md#revokesession) | **DELETE** /v1/me/sessions/{id} | revoke Session
[**startPasskeyAuthentication**](SelfApi.md#startpasskeyauthentication) | **POST** /v1/auth/passkeys/authentication/options | start Passkey Authentication
[**startPasskeyRegistration**](SelfApi.md#startpasskeyregistration) | **POST** /v1/auth/passkeys/registration/options | start Passkey Registration
>>>>>>> origin/main
[**updateAccount**](SelfApi.md#updateaccount) | **PATCH** /v1/me | update Account
[**uploadAvatar**](SelfApi.md#uploadavatar) | **PUT** /v1/me/avatar | upload Avatar


# **deleteAvatar**
> deleteAvatar(idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

delete Avatar

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.deleteAvatar(idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling SelfApi->deleteAvatar: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eraseAccount**
> eraseAccount(idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

erase Account

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.eraseAccount(idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling SelfApi->eraseAccount: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<<<<<<< HEAD
=======
# **finishPasskeyAuthentication**
> finishPasskeyAuthentication(xTrotxiClient, xTrotxiBuild, passkeyAuthenticationResponse, xTrotxiPlatform)

finish Passkey Authentication

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PasskeyAuthenticationResponse passkeyAuthenticationResponse = ; // PasskeyAuthenticationResponse | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.finishPasskeyAuthentication(xTrotxiClient, xTrotxiBuild, passkeyAuthenticationResponse, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling SelfApi->finishPasskeyAuthentication: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **passkeyAuthenticationResponse** | [**PasskeyAuthenticationResponse**](PasskeyAuthenticationResponse.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **finishPasskeyRegistration**
> finishPasskeyRegistration(xTrotxiClient, xTrotxiBuild, passkeyRegistrationResponse, xTrotxiPlatform)

finish Passkey Registration

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PasskeyRegistrationResponse passkeyRegistrationResponse = ; // PasskeyRegistrationResponse | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.finishPasskeyRegistration(xTrotxiClient, xTrotxiBuild, passkeyRegistrationResponse, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling SelfApi->finishPasskeyRegistration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **passkeyRegistrationResponse** | [**PasskeyRegistrationResponse**](PasskeyRegistrationResponse.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

>>>>>>> origin/main
# **getAccount**
> AccountResponse getAccount(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Account

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getAccount(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->getAccount: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**AccountResponse**](AccountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAvatar**
> AvatarResponse getAvatar(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Avatar

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getAvatar(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->getAvatar: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**AvatarResponse**](AvatarResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<<<<<<< HEAD
=======
# **getPasskeyStatus**
> PasskeyStatusResponse getPasskeyStatus(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Passkey Status

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getPasskeyStatus(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->getPasskeyStatus: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PasskeyStatusResponse**](PasskeyStatusResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

>>>>>>> origin/main
# **listSessions**
> SessionPage listSessions(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list Sessions

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listSessions(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->listSessions: $e\n');
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

[**SessionPage**](SessionPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerDevice**
> DeviceResponse registerDevice(idempotencyKey, xTrotxiClient, xTrotxiBuild, deviceInput, xTrotxiPlatform)

register Device

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final DeviceInput deviceInput = ; // DeviceInput | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.registerDevice(idempotencyKey, xTrotxiClient, xTrotxiBuild, deviceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->registerDevice: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **deviceInput** | [**DeviceInput**](DeviceInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**DeviceResponse**](DeviceResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revokeSession**
> revokeSession(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

revoke Session

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.revokeSession(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling SelfApi->revokeSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

<<<<<<< HEAD
=======
# **startPasskeyAuthentication**
> PasskeyAuthenticationOptionsResponse startPasskeyAuthentication(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

start Passkey Authentication

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.startPasskeyAuthentication(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->startPasskeyAuthentication: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PasskeyAuthenticationOptionsResponse**](PasskeyAuthenticationOptionsResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startPasskeyRegistration**
> PasskeyRegistrationOptionsResponse startPasskeyRegistration(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

start Passkey Registration

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.startPasskeyRegistration(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->startPasskeyRegistration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PasskeyRegistrationOptionsResponse**](PasskeyRegistrationOptionsResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

>>>>>>> origin/main
# **updateAccount**
> AccountResponse updateAccount(idempotencyKey, xTrotxiClient, xTrotxiBuild, profileUpdate, xTrotxiPlatform)

update Account

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ProfileUpdate profileUpdate = ; // ProfileUpdate | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updateAccount(idempotencyKey, xTrotxiClient, xTrotxiBuild, profileUpdate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->updateAccount: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **profileUpdate** | [**ProfileUpdate**](ProfileUpdate.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**AccountResponse**](AccountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadAvatar**
> AvatarResponse uploadAvatar(idempotencyKey, xTrotxiClient, xTrotxiBuild, file, xTrotxiPlatform)

upload Avatar

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSelfApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | 
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.uploadAvatar(idempotencyKey, xTrotxiClient, xTrotxiBuild, file, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SelfApi->uploadAvatar: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **file** | **MultipartFile**|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**AvatarResponse**](AvatarResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

