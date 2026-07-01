# trotxi_api_client.api.PaymentsApi

## Load the API package

```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to _http://localhost_

| Method                                                            | HTTP request                 | Description                                                             |
| ----------------------------------------------------------------- | ---------------------------- | ----------------------------------------------------------------------- |
| [**paymentsSubscribePost**](PaymentsApi.md#paymentssubscribepost) | **POST** /payments/subscribe | Start a Paystack checkout for the platform membership fee               |
| [**paymentsTopupPost**](PaymentsApi.md#paymentstopuppost)         | **POST** /payments/topup     | Start a Paystack checkout to load ride tokens (pesewas) into the wallet |
| [**webhooksPaystackPost**](PaymentsApi.md#webhookspaystackpost)   | **POST** /webhooks/paystack  | Paystack payment webhook (signature-verified)                           |

# **paymentsSubscribePost**

> PaymentsSubscribePost200Response paymentsSubscribePost(paymentsSubscribePostRequest)

Start a Paystack checkout for the platform membership fee

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPaymentsApi();
final PaymentsSubscribePostRequest paymentsSubscribePostRequest = ; // PaymentsSubscribePostRequest |

try {
    final response = api.paymentsSubscribePost(paymentsSubscribePostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PaymentsApi->paymentsSubscribePost: $e\n');
}
```

### Parameters

| Name                             | Type                                                                | Description | Notes |
| -------------------------------- | ------------------------------------------------------------------- | ----------- | ----- |
| **paymentsSubscribePostRequest** | [**PaymentsSubscribePostRequest**](PaymentsSubscribePostRequest.md) |             |

### Return type

[**PaymentsSubscribePost200Response**](PaymentsSubscribePost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **paymentsTopupPost**

> PaymentsSubscribePost200Response paymentsTopupPost(paymentsTopupPostRequest)

Start a Paystack checkout to load ride tokens (pesewas) into the wallet

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPaymentsApi();
final PaymentsTopupPostRequest paymentsTopupPostRequest = ; // PaymentsTopupPostRequest |

try {
    final response = api.paymentsTopupPost(paymentsTopupPostRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PaymentsApi->paymentsTopupPost: $e\n');
}
```

### Parameters

| Name                         | Type                                                        | Description | Notes |
| ---------------------------- | ----------------------------------------------------------- | ----------- | ----- |
| **paymentsTopupPostRequest** | [**PaymentsTopupPostRequest**](PaymentsTopupPostRequest.md) |             |

### Return type

[**PaymentsSubscribePost200Response**](PaymentsSubscribePost200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **webhooksPaystackPost**

> WebhooksPaystackPost200Response webhooksPaystackPost()

Paystack payment webhook (signature-verified)

### Example

```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getPaymentsApi();

try {
    final response = api.webhooksPaystackPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PaymentsApi->webhooksPaystackPost: $e\n');
}
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**WebhooksPaystackPost200Response**](WebhooksPaystackPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
