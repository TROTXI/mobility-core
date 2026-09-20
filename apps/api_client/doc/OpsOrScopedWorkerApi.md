# trotxi_api_client.api.OpsOrScopedWorkerApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**runAskDispatch**](OpsOrScopedWorkerApi.md#runaskdispatch) | **POST** /v1/ops/maintenance/ask-dispatch | run Ask Dispatch
[**runGpsRetention**](OpsOrScopedWorkerApi.md#rungpsretention) | **POST** /v1/ops/maintenance/gps-retention | run Gps Retention
[**runNoShows**](OpsOrScopedWorkerApi.md#runnoshows) | **POST** /v1/ops/maintenance/no-shows | run No Shows
[**runPaymentInbox**](OpsOrScopedWorkerApi.md#runpaymentinbox) | **POST** /v1/ops/maintenance/payment-inbox | run Payment Inbox
[**runPaymentReconciliation**](OpsOrScopedWorkerApi.md#runpaymentreconciliation) | **POST** /v1/ops/maintenance/payment-reconciliation | run Payment Reconciliation
[**runPayments**](OpsOrScopedWorkerApi.md#runpayments) | **POST** /v1/ops/maintenance/payments | run Payments
[**runPeriodClose**](OpsOrScopedWorkerApi.md#runperiodclose) | **POST** /v1/ops/maintenance/period-close | run Period Close
[**runReservationDefaults**](OpsOrScopedWorkerApi.md#runreservationdefaults) | **POST** /v1/ops/maintenance/reservation-defaults | run Reservation Defaults
[**runRouteLearning**](OpsOrScopedWorkerApi.md#runroutelearning) | **POST** /v1/ops/maintenance/route-learning | run Route Learning
[**runTripGeneration**](OpsOrScopedWorkerApi.md#runtripgeneration) | **POST** /v1/ops/maintenance/trip-generation | run Trip Generation


# **runAskDispatch**
> MaintenanceResultResponse runAskDispatch(xTrotxiClient, xTrotxiBuild, serviceDayInput, xTrotxiPlatform)

run Ask Dispatch

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ServiceDayInput serviceDayInput = ; // ServiceDayInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runAskDispatch(xTrotxiClient, xTrotxiBuild, serviceDayInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runAskDispatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **serviceDayInput** | [**ServiceDayInput**](ServiceDayInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runGpsRetention**
> MaintenanceResultResponse runGpsRetention(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform)

run Gps Retention

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MaintenanceInput maintenanceInput = ; // MaintenanceInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runGpsRetention(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runGpsRetention: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **maintenanceInput** | [**MaintenanceInput**](MaintenanceInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runNoShows**
> MaintenanceResultResponse runNoShows(xTrotxiClient, xTrotxiBuild, serviceDayInput, xTrotxiPlatform)

run No Shows

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ServiceDayInput serviceDayInput = ; // ServiceDayInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runNoShows(xTrotxiClient, xTrotxiBuild, serviceDayInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runNoShows: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **serviceDayInput** | [**ServiceDayInput**](ServiceDayInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runPaymentInbox**
> MaintenanceResultResponse runPaymentInbox(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform)

run Payment Inbox

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MaintenanceInput maintenanceInput = ; // MaintenanceInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runPaymentInbox(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runPaymentInbox: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **maintenanceInput** | [**MaintenanceInput**](MaintenanceInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runPaymentReconciliation**
> MaintenanceResultResponse runPaymentReconciliation(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform)

run Payment Reconciliation

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MaintenanceInput maintenanceInput = ; // MaintenanceInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runPaymentReconciliation(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runPaymentReconciliation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **maintenanceInput** | [**MaintenanceInput**](MaintenanceInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runPayments**
> PaymentMaintenanceResultResponse runPayments(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform)

run Payments

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MaintenanceInput maintenanceInput = ; // MaintenanceInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runPayments(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runPayments: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **maintenanceInput** | [**MaintenanceInput**](MaintenanceInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PaymentMaintenanceResultResponse**](PaymentMaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runPeriodClose**
> MaintenanceResultResponse runPeriodClose(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform)

run Period Close

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MaintenanceInput maintenanceInput = ; // MaintenanceInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runPeriodClose(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runPeriodClose: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **maintenanceInput** | [**MaintenanceInput**](MaintenanceInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runReservationDefaults**
> MaintenanceResultResponse runReservationDefaults(xTrotxiClient, xTrotxiBuild, serviceDayInput, xTrotxiPlatform)

run Reservation Defaults

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ServiceDayInput serviceDayInput = ; // ServiceDayInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runReservationDefaults(xTrotxiClient, xTrotxiBuild, serviceDayInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runReservationDefaults: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **serviceDayInput** | [**ServiceDayInput**](ServiceDayInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runRouteLearning**
> MaintenanceResultResponse runRouteLearning(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform)

run Route Learning

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final MaintenanceInput maintenanceInput = ; // MaintenanceInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runRouteLearning(xTrotxiClient, xTrotxiBuild, maintenanceInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runRouteLearning: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **maintenanceInput** | [**MaintenanceInput**](MaintenanceInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runTripGeneration**
> MaintenanceResultResponse runTripGeneration(xTrotxiClient, xTrotxiBuild, tripGenerationInput, xTrotxiPlatform)

run Trip Generation

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getOpsOrScopedWorkerApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final TripGenerationInput tripGenerationInput = ; // TripGenerationInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.runTripGeneration(xTrotxiClient, xTrotxiBuild, tripGenerationInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling OpsOrScopedWorkerApi->runTripGeneration: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **tripGenerationInput** | [**TripGenerationInput**](TripGenerationInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MaintenanceResultResponse**](MaintenanceResultResponse.md)

### Authorization

[workerAuth](../README.md#workerAuth), [bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

