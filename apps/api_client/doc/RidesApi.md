# trotxi_api_client.api.RidesApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**meRidesGet**](RidesApi.md#meridesget) | **GET** /me/rides | Remaining ride entitlement + Ride Credit balance


# **meRidesGet**
> MeRidesGet200Response meRidesGet()

Remaining ride entitlement + Ride Credit balance

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRidesApi();

try {
    final response = api.meRidesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RidesApi->meRidesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeRidesGet200Response**](MeRidesGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

