# trotxi_api_client.api.BoardingApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**boardingManifestGet**](BoardingApi.md#boardingmanifestget) | **GET** /boarding/manifest | A trip&#39;s manifest — confirmed riders with name + photo (assigned driver only)
[**boardingScanPost**](BoardingApi.md#boardingscanpost) | **POST** /boarding/scan | Verify a scanned rider pass (driver only) and record the scan
[**boardingVerifyPinPost**](BoardingApi.md#boardingverifypinpost) | **POST** /boarding/verify-pin | Board a rider via their daily 4-digit PIN (driver only)
[**mePassGet**](BoardingApi.md#mepassget) | **GET** /me/pass | Issue the rider a short-lived boarding pass (render as a QR)


# **boardingManifestGet**
> BoardingManifestGet200Response boardingManifestGet(tripId)

A trip's manifest — confirmed riders with name + photo (assigned driver only)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getBoardingApi();
final String tripId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.boardingManifestGet(tripId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BoardingApi->boardingManifestGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tripId** | **String**|  | 

### Return type

[**BoardingManifestGet200Response**](BoardingManifestGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **boardingScanPost**
> BoardingScanPost200Response boardingScanPost(boardingScanPostRequest)

Verify a scanned rider pass (driver only) and record the scan

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getBoardingApi();
final BoardingScanPostRequest boardingScanPostRequest = ; // BoardingScanPostRequest | 

try {
    final response = api.boardingScanPost(boardingScanPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BoardingApi->boardingScanPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **boardingScanPostRequest** | [**BoardingScanPostRequest**](BoardingScanPostRequest.md)|  | 

### Return type

[**BoardingScanPost200Response**](BoardingScanPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **boardingVerifyPinPost**
> BoardingVerifyPinPost200Response boardingVerifyPinPost(boardingVerifyPinPostRequest)

Board a rider via their daily 4-digit PIN (driver only)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getBoardingApi();
final BoardingVerifyPinPostRequest boardingVerifyPinPostRequest = ; // BoardingVerifyPinPostRequest | 

try {
    final response = api.boardingVerifyPinPost(boardingVerifyPinPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BoardingApi->boardingVerifyPinPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **boardingVerifyPinPostRequest** | [**BoardingVerifyPinPostRequest**](BoardingVerifyPinPostRequest.md)|  | 

### Return type

[**BoardingVerifyPinPost200Response**](BoardingVerifyPinPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **mePassGet**
> MePassGet200Response mePassGet()

Issue the rider a short-lived boarding pass (render as a QR)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getBoardingApi();

try {
    final response = api.mePassGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling BoardingApi->mePassGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MePassGet200Response**](MePassGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

