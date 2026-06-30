# trotxi_api_client.api.AuthApi

## Load the API package

```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to _http://localhost_

| Method                                            | HTTP request           | Description                                                         |
| ------------------------------------------------- | ---------------------- | ------------------------------------------------------------------- |
| [**authGooglePost**](AuthApi.md#authgooglepost)   | **POST** /auth/google  | Sign in with a Google ID token (creates the account on first use)   |
| [**authLogoutPost**](AuthApi.md#authlogoutpost)   | **POST** /auth/logout  | Revoke a refresh token (idempotent)                                 |
| [**authRefreshPost**](AuthApi.md#authrefreshpost) | **POST** /auth/refresh | Exchange a refresh token for a new token pair (rotates the session) |
| [**meGet**](AuthApi.md#meget)                     | **GET** /me            | Get the currently authenticated user                                |

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

| Name                      | Type                                                  | Description | Notes |
| ------------------------- | ----------------------------------------------------- | ----------- | ----- |
| **authGooglePostRequest** | [**AuthGooglePostRequest**](AuthGooglePostRequest.md) |             |

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

| Name                       | Type                                                    | Description | Notes |
| -------------------------- | ------------------------------------------------------- | ----------- | ----- |
| **authRefreshPostRequest** | [**AuthRefreshPostRequest**](AuthRefreshPostRequest.md) |             |

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

| Name                       | Type                                                    | Description | Notes |
| -------------------------- | ------------------------------------------------------- | ----------- | ----- |
| **authRefreshPostRequest** | [**AuthRefreshPostRequest**](AuthRefreshPostRequest.md) |             |

### Return type

[**AuthRefreshPost200Response**](AuthRefreshPost200Response.md)

### Authorization

No authorization required

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
