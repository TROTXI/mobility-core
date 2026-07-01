# trotxi_api_client.api.SystemApi

## Load the API package

```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to _http://localhost_

| Method                                    | HTTP request     | Description                              |
| ----------------------------------------- | ---------------- | ---------------------------------------- |
| [**healthzGet**](SystemApi.md#healthzget) | **GET** /healthz | Liveness probe                           |
| [**readyzGet**](SystemApi.md#readyzget)   | **GET** /readyz  | Readiness probe (pings backing services) |
| [**rootGet**](SystemApi.md#rootget)       | **GET** /        | Service metadata and useful links        |
| [**versionGet**](SystemApi.md#versionget) | **GET** /version | Build version and commit                 |

# **healthzGet**

> HealthzGet200Response healthzGet()

Liveness probe

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSystemApi();

try {
    final response = api.healthzGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->healthzGet: $e\n');
}
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**HealthzGet200Response**](HealthzGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readyzGet**

> ReadyzGet200Response readyzGet()

Readiness probe (pings backing services)

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSystemApi();

try {
    final response = api.readyzGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->readyzGet: $e\n');
}
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**ReadyzGet200Response**](ReadyzGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rootGet**

> Get200Response rootGet()

Service metadata and useful links

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSystemApi();

try {
    final response = api.rootGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->rootGet: $e\n');
}
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**Get200Response**](Get200Response.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **versionGet**

> VersionGet200Response versionGet()

Build version and commit

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getSystemApi();

try {
    final response = api.versionGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->versionGet: $e\n');
}
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**VersionGet200Response**](VersionGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
