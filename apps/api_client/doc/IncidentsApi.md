# trotxi_api_client.api.IncidentsApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**meIncidentsGet**](IncidentsApi.md#meincidentsget) | **GET** /me/incidents | My incident reports and what operations did with them (driver)
[**meIncidentsPost**](IncidentsApi.md#meincidentspost) | **POST** /me/incidents | File an incident report (driver)


# **meIncidentsGet**
> MeIncidentsGet200Response meIncidentsGet()

My incident reports and what operations did with them (driver)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getIncidentsApi();

try {
    final response = api.meIncidentsGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IncidentsApi->meIncidentsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeIncidentsGet200Response**](MeIncidentsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meIncidentsPost**
> MeIncidentsGet200ResponseIncidentsInner meIncidentsPost(meIncidentsPostRequest)

File an incident report (driver)

The server attaches the vehicle from the named trip rather than trusting the app to send it. A report with no trip is accepted — a fault found in the yard is exactly the one worth filing.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getIncidentsApi();
final MeIncidentsPostRequest meIncidentsPostRequest = ; // MeIncidentsPostRequest | 

try {
    final response = api.meIncidentsPost(meIncidentsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IncidentsApi->meIncidentsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meIncidentsPostRequest** | [**MeIncidentsPostRequest**](MeIncidentsPostRequest.md)|  | 

### Return type

[**MeIncidentsGet200ResponseIncidentsInner**](MeIncidentsGet200ResponseIncidentsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

