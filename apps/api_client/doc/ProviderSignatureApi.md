# trotxi_api_client.api.ProviderSignatureApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**receivePaystackWebhook**](ProviderSignatureApi.md#receivepaystackwebhook) | **POST** /webhooks/paystack | receive Paystack Webhook


# **receivePaystackWebhook**
> WebhookAck receivePaystackWebhook(xPaystackSignature, receivePaystackWebhookRequest)

receive Paystack Webhook

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getProviderSignatureApi();
final String xPaystackSignature = xPaystackSignature_example; // String | 
final ReceivePaystackWebhookRequest receivePaystackWebhookRequest = ; // ReceivePaystackWebhookRequest | Provider-controlled JSON. HMAC exact raw bytes BEFORE parsing. Persist signed unknown events for inspection, not guessed fulfilment.

try {
    final response = api.receivePaystackWebhook(xPaystackSignature, receivePaystackWebhookRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProviderSignatureApi->receivePaystackWebhook: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xPaystackSignature** | **String**|  | 
 **receivePaystackWebhookRequest** | [**ReceivePaystackWebhookRequest**](ReceivePaystackWebhookRequest.md)| Provider-controlled JSON. HMAC exact raw bytes BEFORE parsing. Persist signed unknown events for inspection, not guessed fulfilment. | 

### Return type

[**WebhookAck**](WebhookAck.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

