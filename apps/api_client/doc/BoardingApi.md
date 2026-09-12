# trotxi_api_client.api.BoardingApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**boardingBoardPost**](BoardingApi.md#boardingboardpost) | **POST** /boarding/board | Board a rider identified from the manifest photo (assigned driver only)
[**boardingManifestGet**](BoardingApi.md#boardingmanifestget) | **GET** /boarding/manifest | A trip&#39;s manifest — confirmed riders with name + photo (assigned driver only)
[**boardingNoShowPost**](BoardingApi.md#boardingnoshowpost) | **POST** /boarding/no-show | Mark one rider as not having turned up (assigned driver only)
[**boardingScanPost**](BoardingApi.md#boardingscanpost) | **POST** /boarding/scan | Verify a scanned rider pass (driver only) and record the scan
[**boardingVerifyCodePost**](BoardingApi.md#boardingverifycodepost) | **POST** /boarding/verify-code | Board whoever holds this code on this run (assigned driver only)
[**boardingVerifyPinPost**](BoardingApi.md#boardingverifypinpost) | **POST** /boarding/verify-pin | Board a rider via their daily boarding code (driver only)
[**mePassGet**](BoardingApi.md#mepassget) | **GET** /me/pass | Issue the rider a short-lived boarding pass (render as a QR)


# **boardingBoardPost**
> BoardingBoardPost200Response boardingBoardPost(boardingBoardPostRequest)

Board a rider identified from the manifest photo (assigned driver only)

The fallback for when a code will not scan or the rider cannot produce one. Idempotent per reservation, and shares boarding’s ledger key, so a rider previously marked a no-show is charged once rather than twice.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getBoardingApi();
final BoardingBoardPostRequest boardingBoardPostRequest = ; // BoardingBoardPostRequest | 

try {
    final response = api.boardingBoardPost(boardingBoardPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BoardingApi->boardingBoardPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **boardingBoardPostRequest** | [**BoardingBoardPostRequest**](BoardingBoardPostRequest.md)|  | 

### Return type

[**BoardingBoardPost200Response**](BoardingBoardPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

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

# **boardingNoShowPost**
> BoardingNoShowPost200Response boardingNoShowPost(boardingBoardPostRequest)

Mark one rider as not having turned up (assigned driver only)

Deducts the ride now rather than at the cutoff. Reversible by boarding the rider afterwards — the shared ledger key means that costs nothing extra.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getBoardingApi();
final BoardingBoardPostRequest boardingBoardPostRequest = ; // BoardingBoardPostRequest | 

try {
    final response = api.boardingNoShowPost(boardingBoardPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BoardingApi->boardingNoShowPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **boardingBoardPostRequest** | [**BoardingBoardPostRequest**](BoardingBoardPostRequest.md)|  | 

### Return type

[**BoardingNoShowPost200Response**](BoardingNoShowPost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
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

# **boardingVerifyCodePost**
> BoardingVerifyCodePost200Response boardingVerifyCodePost(boardingVerifyCodePostRequest)

Board whoever holds this code on this run (assigned driver only)

Searches the run’s open seats for the code rather than checking one named seat. Safe because the caller is already the assigned driver, who can board any rider on their manifest with no code at all (POST /boarding/board). Two seats holding one code is refused rather than guessed.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getBoardingApi();
final BoardingVerifyCodePostRequest boardingVerifyCodePostRequest = ; // BoardingVerifyCodePostRequest | 

try {
    final response = api.boardingVerifyCodePost(boardingVerifyCodePostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling BoardingApi->boardingVerifyCodePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **boardingVerifyCodePostRequest** | [**BoardingVerifyCodePostRequest**](BoardingVerifyCodePostRequest.md)|  | 

### Return type

[**BoardingVerifyCodePost200Response**](BoardingVerifyCodePost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **boardingVerifyPinPost**
> BoardingVerifyPinPost200Response boardingVerifyPinPost(boardingVerifyPinPostRequest)

Board a rider via their daily boarding code (driver only)

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

