# trotxi_api_client.api.WalletApi

## Load the API package

```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to _http://localhost_

| Method                                        | HTTP request        | Description                                         |
| --------------------------------------------- | ------------------- | --------------------------------------------------- |
| [**meBalanceGet**](WalletApi.md#mebalanceget) | **GET** /me/balance | Get the authenticated rider token balance (pesewas) |

# **meBalanceGet**

> MeBalanceGet200Response meBalanceGet()

Get the authenticated rider token balance (pesewas)

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getWalletApi();

try {
    final response = api.meBalanceGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling WalletApi->meBalanceGet: $e\n');
}
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**MeBalanceGet200Response**](MeBalanceGet200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
