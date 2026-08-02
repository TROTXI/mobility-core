# trotxi_api_client.api.FlagsApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**flagsGet**](FlagsApi.md#flagsget) | **GET** /flags | Feature flags + minimum supported app version (fetched on launch)


# **flagsGet**
> FlagsGet200Response flagsGet()

Feature flags + minimum supported app version (fetched on launch)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getFlagsApi();

try {
    final response = api.flagsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling FlagsApi->flagsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**FlagsGet200Response**](FlagsGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

