# trotxi_api_client.api.ReservationsApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**meReservationsGet**](ReservationsApi.md#mereservationsget) | **GET** /me/reservations | List the rider&#39;s reservations (newest travel day first)
[**meReservationsPost**](ReservationsApi.md#mereservationspost) | **POST** /me/reservations | Confirm or decline the daily ride (upsert per day + direction)


# **meReservationsGet**
> MeReservationsGet200Response meReservationsGet(from)

List the rider's reservations (newest travel day first)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getReservationsApi();
final String from = from_example; // String | 

try {
    final response = api.meReservationsGet(from);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReservationsApi->meReservationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **from** | **String**|  | [optional] 

### Return type

[**MeReservationsGet200Response**](MeReservationsGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meReservationsPost**
> MeReservationsGet200ResponseReservationsInner meReservationsPost(meReservationsPostRequest)

Confirm or decline the daily ride (upsert per day + direction)

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getReservationsApi();
final MeReservationsPostRequest meReservationsPostRequest = ; // MeReservationsPostRequest | 

try {
    final response = api.meReservationsPost(meReservationsPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReservationsApi->meReservationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **meReservationsPostRequest** | [**MeReservationsPostRequest**](MeReservationsPostRequest.md)|  | 

### Return type

[**MeReservationsGet200ResponseReservationsInner**](MeReservationsGet200ResponseReservationsInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

