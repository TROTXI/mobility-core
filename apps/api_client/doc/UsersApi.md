# trotxi_api_client.api.UsersApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**meDelete**](UsersApi.md#medelete) | **DELETE** /me | Delete my account (erases personal data; keeps financial records)


# **meDelete**
> String meDelete()

Delete my account (erases personal data; keeps financial records)

Revokes every session, unregisters push devices, unlinks sign-in providers, deletes the avatar, and clears personal data. Payment and ride-ledger rows are retained in anonymised form because they are accounting records. Signing in again creates a new account.

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getUsersApi();

try {
    final response = api.meDelete();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->meDelete: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

**String**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

