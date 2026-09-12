# trotxi_api_client.api.WorkApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**meWorkRequestsGet**](WorkApi.md#meworkrequestsget) | **GET** /me/work/requests | My requests and what operations decided
[**meWorkRequestsIdWithdrawPost**](WorkApi.md#meworkrequestsidwithdrawpost) | **POST** /me/work/requests/{id}/withdraw | Take back a request operations has not answered yet
[**meWorkRequestsPost**](WorkApi.md#meworkrequestspost) | **POST** /me/work/requests | Ask operations for a route change or leave
[**meWorkRoutesGet**](WorkApi.md#meworkroutesget) | **GET** /me/work/routes | Routes operations will accept reassignment requests for


# **meWorkRequestsGet**
> MeWorkRequestsGet200Response meWorkRequestsGet()

My requests and what operations decided

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getWorkApi();

try {
    final response = api.meWorkRequestsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkApi->meWorkRequestsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeWorkRequestsGet200Response**](MeWorkRequestsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meWorkRequestsIdWithdrawPost**
> MeWorkRequestsGet200ResponseRequestsInner meWorkRequestsIdWithdrawPost(id)

Take back a request operations has not answered yet

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getWorkApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.meWorkRequestsIdWithdrawPost(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkApi->meWorkRequestsIdWithdrawPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**MeWorkRequestsGet200ResponseRequestsInner**](MeWorkRequestsGet200ResponseRequestsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meWorkRequestsPost**
> MeWorkRequestsGet200ResponseRequestsInner meWorkRequestsPost(meWorkRequestsPostRequest)

Ask operations for a route change or leave

A proposal, not an edit. Nothing about the driver’s published assignment changes when this succeeds, or when it is later approved.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getWorkApi();
final MeWorkRequestsPostRequest meWorkRequestsPostRequest = ; // MeWorkRequestsPostRequest | 

try {
    final response = api.meWorkRequestsPost(meWorkRequestsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkApi->meWorkRequestsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meWorkRequestsPostRequest** | [**MeWorkRequestsPostRequest**](MeWorkRequestsPostRequest.md)|  | 

### Return type

[**MeWorkRequestsGet200ResponseRequestsInner**](MeWorkRequestsGet200ResponseRequestsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meWorkRoutesGet**
> MeWorkRoutesGet200Response meWorkRoutesGet()

Routes operations will accept reassignment requests for

Not every corridor. A route appears only once operations opens it, so a driver never asks for something that could only ever be declined.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getWorkApi();

try {
    final response = api.meWorkRoutesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WorkApi->meWorkRoutesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeWorkRoutesGet200Response**](MeWorkRoutesGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

