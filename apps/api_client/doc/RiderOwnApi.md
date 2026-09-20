# trotxi_api_client.api.RiderOwnApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createCommuteRequest**](RiderOwnApi.md#createcommuterequest) | **POST** /v1/me/commute-requests | create Commute Request
[**createPersonalPause**](RiderOwnApi.md#createpersonalpause) | **POST** /v1/me/membership/pauses | create Personal Pause
[**createPurchase**](RiderOwnApi.md#createpurchase) | **POST** /v1/me/purchases | create Purchase
[**decideReservation**](RiderOwnApi.md#decidereservation) | **POST** /v1/me/reservation-decisions | decide Reservation
[**getMembership**](RiderOwnApi.md#getmembership) | **GET** /v1/me/membership | get Membership
[**getPersonalPause**](RiderOwnApi.md#getpersonalpause) | **GET** /v1/me/membership/pause | get Personal Pause
[**getPurchase**](RiderOwnApi.md#getpurchase) | **GET** /v1/me/purchases/{id} | get Purchase
[**issuePass**](RiderOwnApi.md#issuepass) | **POST** /v1/me/reservations/{id}/pass | issue Pass
[**listCommuteRequests**](RiderOwnApi.md#listcommuterequests) | **GET** /v1/me/commute-requests | list Commute Requests
[**listCreditEntries**](RiderOwnApi.md#listcreditentries) | **GET** /v1/me/credit-entries | list Credit Entries
[**listPurchases**](RiderOwnApi.md#listpurchases) | **GET** /v1/me/purchases | list Purchases
[**listReservations**](RiderOwnApi.md#listreservations) | **GET** /v1/me/reservations | list Reservations
[**listRideEntries**](RiderOwnApi.md#listrideentries) | **GET** /v1/me/ride-entries | list Ride Entries
[**previewPersonalPause**](RiderOwnApi.md#previewpersonalpause) | **POST** /v1/me/membership/pause-preview | preview Personal Pause
[**previewPurchase**](RiderOwnApi.md#previewpurchase) | **POST** /v1/me/purchase-quotes | preview Purchase
[**resumePersonalPause**](RiderOwnApi.md#resumepersonalpause) | **POST** /v1/me/membership/pauses/{id}/resume | resume Personal Pause
[**withdrawCommuteRequest**](RiderOwnApi.md#withdrawcommuterequest) | **POST** /v1/me/commute-requests/{id}/withdraw | withdraw Commute Request


# **createCommuteRequest**
> CommuteRequestResponse createCommuteRequest(idempotencyKey, xTrotxiClient, xTrotxiBuild, commuteRequestInput, xTrotxiPlatform)

create Commute Request

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final CommuteRequestInput commuteRequestInput = ; // CommuteRequestInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createCommuteRequest(idempotencyKey, xTrotxiClient, xTrotxiBuild, commuteRequestInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->createCommuteRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **commuteRequestInput** | [**CommuteRequestInput**](CommuteRequestInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**CommuteRequestResponse**](CommuteRequestResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPersonalPause**
> PersonalPauseResponse createPersonalPause(idempotencyKey, xTrotxiClient, xTrotxiBuild, personalPauseInput, xTrotxiPlatform)

create Personal Pause

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PersonalPauseInput personalPauseInput = ; // PersonalPauseInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createPersonalPause(idempotencyKey, xTrotxiClient, xTrotxiBuild, personalPauseInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->createPersonalPause: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **personalPauseInput** | [**PersonalPauseInput**](PersonalPauseInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PersonalPauseResponse**](PersonalPauseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPurchase**
> PurchaseResponse createPurchase(idempotencyKey, xTrotxiClient, xTrotxiBuild, purchaseInput, xTrotxiPlatform)

create Purchase

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PurchaseInput purchaseInput = ; // PurchaseInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.createPurchase(idempotencyKey, xTrotxiClient, xTrotxiBuild, purchaseInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->createPurchase: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **purchaseInput** | [**PurchaseInput**](PurchaseInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PurchaseResponse**](PurchaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **decideReservation**
> ReservationDecisionResultResponse decideReservation(idempotencyKey, xTrotxiClient, xTrotxiBuild, reservationDecision, xTrotxiPlatform)

decide Reservation

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReservationDecision reservationDecision = ; // ReservationDecision | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.decideReservation(idempotencyKey, xTrotxiClient, xTrotxiBuild, reservationDecision, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->decideReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **reservationDecision** | [**ReservationDecision**](ReservationDecision.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**ReservationDecisionResultResponse**](ReservationDecisionResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMembership**
> MembershipResponse getMembership(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Membership

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getMembership(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->getMembership: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**MembershipResponse**](MembershipResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPersonalPause**
> OptionalPersonalPauseResponse getPersonalPause(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Personal Pause

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getPersonalPause(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->getPersonalPause: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**OptionalPersonalPauseResponse**](OptionalPersonalPauseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPurchase**
> PurchaseResponse getPurchase(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Purchase

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String | 
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getPurchase(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->getPurchase: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PurchaseResponse**](PurchaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **issuePass**
> PassResponse issuePass(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

issue Pass

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.issuePass(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->issuePass: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PassResponse**](PassResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCommuteRequests**
> CommuteRequestPage listCommuteRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Commute Requests

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String status = status_example; // String | Must match the resource state enum; unknown values return 400.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listCommuteRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->listCommuteRequests: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional] 
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **status** | **String**| Must match the resource state enum; unknown values return 400. | [optional] 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**CommuteRequestPage**](CommuteRequestPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCreditEntries**
> CreditEntryPage listCreditEntries(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform)

list Credit Entries

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listCreditEntries(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->listCreditEntries: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional] 
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **fromDate** | **Date**| Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days. | [optional] 
 **toDate** | **Date**| Inclusive; paired with fromDate. | [optional] 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**CreditEntryPage**](CreditEntryPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPurchases**
> PurchasePage listPurchases(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform)

list Purchases

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Optional inclusive Africa/Accra purchase-creation day. With no date filters, returns all purchase history, including unresolved purchases. No default recency cutoff.
final Date toDate = 2013-10-20; // Date | Optional inclusive purchase-creation day; if both bounds are supplied, toDate must not precede fromDate.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listPurchases(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->listPurchases: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional] 
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **fromDate** | **Date**| Optional inclusive Africa/Accra purchase-creation day. With no date filters, returns all purchase history, including unresolved purchases. No default recency cutoff. | [optional] 
 **toDate** | **Date**| Optional inclusive purchase-creation day; if both bounds are supplied, toDate must not precede fromDate. | [optional] 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PurchasePage**](PurchasePage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listReservations**
> ReservationPage listReservations(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform)

list Reservations

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listReservations(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->listReservations: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional] 
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **fromDate** | **Date**| Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days. | [optional] 
 **toDate** | **Date**| Inclusive; paired with fromDate. | [optional] 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**ReservationPage**](ReservationPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listRideEntries**
> RideEntryPage listRideEntries(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform)

list Ride Entries

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listRideEntries(xTrotxiClient, xTrotxiBuild, cursor, limit, fromDate, toDate, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->listRideEntries: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional] 
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **fromDate** | **Date**| Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days. | [optional] 
 **toDate** | **Date**| Inclusive; paired with fromDate. | [optional] 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**RideEntryPage**](RideEntryPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewPersonalPause**
> PersonalPausePreviewResponse previewPersonalPause(xTrotxiClient, xTrotxiBuild, personalPauseInput, xTrotxiPlatform)

preview Personal Pause

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PersonalPauseInput personalPauseInput = ; // PersonalPauseInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.previewPersonalPause(xTrotxiClient, xTrotxiBuild, personalPauseInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->previewPersonalPause: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **personalPauseInput** | [**PersonalPauseInput**](PersonalPauseInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PersonalPausePreviewResponse**](PersonalPausePreviewResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **previewPurchase**
> PurchaseQuoteResponse previewPurchase(xTrotxiClient, xTrotxiBuild, purchaseQuoteInput, xTrotxiPlatform)

preview Purchase

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PurchaseQuoteInput purchaseQuoteInput = ; // PurchaseQuoteInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.previewPurchase(xTrotxiClient, xTrotxiBuild, purchaseQuoteInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->previewPurchase: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **purchaseQuoteInput** | [**PurchaseQuoteInput**](PurchaseQuoteInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PurchaseQuoteResponse**](PurchaseQuoteResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resumePersonalPause**
> PersonalPauseResponse resumePersonalPause(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, personalResumeInput, xTrotxiPlatform)

resume Personal Pause

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PersonalResumeInput personalResumeInput = ; // PersonalResumeInput | 
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.resumePersonalPause(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, personalResumeInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->resumePersonalPause: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **personalResumeInput** | [**PersonalResumeInput**](PersonalResumeInput.md)|  | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**PersonalPauseResponse**](PersonalPauseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **withdrawCommuteRequest**
> CommuteRequestResponse withdrawCommuteRequest(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

withdraw Commute Request

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String | 
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = xTrotxiClient_example; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 56; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = xTrotxiPlatform_example; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.withdrawCommuteRequest(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->withdrawCommuteRequest: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. | 
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. | 
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | 
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional] 

### Return type

[**CommuteRequestResponse**](CommuteRequestResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

