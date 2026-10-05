# trotxi_api_client.api.RiderOwnApi

## Load the API package
```dart
import 'package:trotxi_api_client/api.dart';
```

All URIs are relative to *https://trotxi-api-staging.onrender.com*

Method | HTTP request | Description
------------- | ------------- | -------------
[**acceptStandbyOffer**](RiderOwnApi.md#acceptstandbyoffer) | **POST** /v1/me/standby/{id}/accept | accept Standby Offer
[**confirmPhoneVerification**](RiderOwnApi.md#confirmphoneverification) | **POST** /v1/me/phone-verification/confirm | confirm Phone Verification
[**createCommuteRequest**](RiderOwnApi.md#createcommuterequest) | **POST** /v1/me/commute-requests | create Commute Request
[**createPersonalPause**](RiderOwnApi.md#createpersonalpause) | **POST** /v1/me/membership/pauses | create Personal Pause
[**createPurchase**](RiderOwnApi.md#createpurchase) | **POST** /v1/me/purchases | create Purchase
[**decideReservation**](RiderOwnApi.md#decidereservation) | **POST** /v1/me/reservation-decisions | decide Reservation
[**getAutoRenewal**](RiderOwnApi.md#getautorenewal) | **GET** /v1/me/auto-renewal | get Auto Renewal
[**getMembership**](RiderOwnApi.md#getmembership) | **GET** /v1/me/membership | get Membership
[**getNotificationPreferences**](RiderOwnApi.md#getnotificationpreferences) | **GET** /v1/me/notification-preferences | get Notification Preferences
[**getPersonalPause**](RiderOwnApi.md#getpersonalpause) | **GET** /v1/me/membership/pause | get Personal Pause
[**getPurchase**](RiderOwnApi.md#getpurchase) | **GET** /v1/me/purchases/{id} | get Purchase
[**getReservation**](RiderOwnApi.md#getreservation) | **GET** /v1/me/reservations/{id} | get Reservation
[**getVerification**](RiderOwnApi.md#getverification) | **GET** /v1/me/verification | get Verification
[**issuePass**](RiderOwnApi.md#issuepass) | **POST** /v1/me/reservations/{id}/pass | issue Pass
[**joinStandby**](RiderOwnApi.md#joinstandby) | **POST** /v1/me/standby | join Standby
[**listCommuteRequests**](RiderOwnApi.md#listcommuterequests) | **GET** /v1/me/commute-requests | list Commute Requests
[**listCreditEntries**](RiderOwnApi.md#listcreditentries) | **GET** /v1/me/credit-entries | list Credit Entries
[**listMyStandby**](RiderOwnApi.md#listmystandby) | **GET** /v1/me/standby | list My Standby
[**listNotifications**](RiderOwnApi.md#listnotifications) | **GET** /v1/me/notifications | list Notifications
[**listPurchases**](RiderOwnApi.md#listpurchases) | **GET** /v1/me/purchases | list Purchases
[**listReservations**](RiderOwnApi.md#listreservations) | **GET** /v1/me/reservations | list Reservations
[**listRideEntries**](RiderOwnApi.md#listrideentries) | **GET** /v1/me/ride-entries | list Ride Entries
[**markAllNotificationsRead**](RiderOwnApi.md#markallnotificationsread) | **POST** /v1/me/notifications/read | mark All Notifications Read
[**markNotificationRead**](RiderOwnApi.md#marknotificationread) | **POST** /v1/me/notifications/{id}/read | mark Notification Read
[**previewPersonalPause**](RiderOwnApi.md#previewpersonalpause) | **POST** /v1/me/membership/pause-preview | preview Personal Pause
[**previewPurchase**](RiderOwnApi.md#previewpurchase) | **POST** /v1/me/purchase-quotes | preview Purchase
[**removeAutoRenewalCard**](RiderOwnApi.md#removeautorenewalcard) | **DELETE** /v1/me/auto-renewal/card | remove Auto Renewal Card
[**resumePersonalPause**](RiderOwnApi.md#resumepersonalpause) | **POST** /v1/me/membership/pauses/{id}/resume | resume Personal Pause
[**setAutoRenewal**](RiderOwnApi.md#setautorenewal) | **PUT** /v1/me/auto-renewal | set Auto Renewal
[**startPhoneVerification**](RiderOwnApi.md#startphoneverification) | **POST** /v1/me/phone-verification/start | start Phone Verification
[**updateNotificationPreferences**](RiderOwnApi.md#updatenotificationpreferences) | **PATCH** /v1/me/notification-preferences | update Notification Preferences
[**withdrawCommuteRequest**](RiderOwnApi.md#withdrawcommuterequest) | **POST** /v1/me/commute-requests/{id}/withdraw | withdraw Commute Request
[**withdrawStandby**](RiderOwnApi.md#withdrawstandby) | **POST** /v1/me/standby/{id}/withdraw | withdraw Standby


# **acceptStandbyOffer**
> PurchaseResponse acceptStandbyOffer(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

accept Standby Offer

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String |
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.acceptStandbyOffer(id, idempotencyKey, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->acceptStandbyOffer: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PurchaseResponse**](PurchaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **confirmPhoneVerification**
> PhoneVerificationResultResponse confirmPhoneVerification(xTrotxiClient, xTrotxiBuild, phoneVerificationConfirm, xTrotxiPlatform)

confirm Phone Verification

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PhoneVerificationConfirm phoneVerificationConfirm = ; // PhoneVerificationConfirm |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.confirmPhoneVerification(xTrotxiClient, xTrotxiBuild, phoneVerificationConfirm, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->confirmPhoneVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **phoneVerificationConfirm** | [**PhoneVerificationConfirm**](PhoneVerificationConfirm.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PhoneVerificationResultResponse**](PhoneVerificationResultResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createCommuteRequest**
> CommuteRequestResponse createCommuteRequest(idempotencyKey, xTrotxiClient, xTrotxiBuild, commuteRequestInput, xTrotxiPlatform)

create Commute Request

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final CommuteRequestInput commuteRequestInput = ; // CommuteRequestInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PersonalPauseInput personalPauseInput = ; // PersonalPauseInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PurchaseInput purchaseInput = ; // PurchaseInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final ReservationDecision reservationDecision = ; // ReservationDecision |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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

# **getAutoRenewal**
> AutoRenewalResponse getAutoRenewal(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Auto Renewal

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getAutoRenewal(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->getAutoRenewal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**AutoRenewalResponse**](AutoRenewalResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMembership**
> MembershipResponse getMembership(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Membership

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**MembershipResponse**](MembershipResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getNotificationPreferences**
> NotificationPreferencesResponse getNotificationPreferences(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Notification Preferences

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getNotificationPreferences(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->getNotificationPreferences: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**NotificationPreferencesResponse**](NotificationPreferencesResponse.md)

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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PurchaseResponse**](PurchaseResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getReservation**
> ReservationDetailResponse getReservation(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Reservation

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String |
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getReservation(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->getReservation: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**ReservationDetailResponse**](ReservationDetailResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getVerification**
> VerificationStatusResponse getVerification(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

get Verification

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.getVerification(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->getVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**VerificationStatusResponse**](VerificationStatusResponse.md)

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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PassResponse**](PassResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **joinStandby**
> StandbyApplicationResponse joinStandby(idempotencyKey, xTrotxiClient, xTrotxiBuild, standbyJoinInput, xTrotxiPlatform)

join Standby

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String idempotencyKey = idempotencyKey_example; // String | Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final StandbyJoinInput standbyJoinInput = ; // StandbyJoinInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.joinStandby(idempotencyKey, xTrotxiClient, xTrotxiBuild, standbyJoinInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->joinStandby: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idempotencyKey** | **String**| Caller + operation + target scoped; payload mismatch = 409. Never log secrets. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **standbyJoinInput** | [**StandbyJoinInput**](StandbyJoinInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StandbyApplicationResponse**](StandbyApplicationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCommuteRequests**
> CommuteRequestPage listCommuteRequests(xTrotxiClient, xTrotxiBuild, cursor, limit, status, xTrotxiPlatform)

list Commute Requests

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String status = status_example; // String | Must match the resource state enum; unknown values return 400.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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

# **listMyStandby**
> StandbyApplicationPage listMyStandby(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform)

list My Standby

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listMyStandby(xTrotxiClient, xTrotxiBuild, cursor, limit, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->listMyStandby: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 50]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StandbyApplicationPage**](StandbyApplicationPage.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listNotifications**
> RiderNotificationPage listNotifications(xTrotxiClient, xTrotxiBuild, cursor, limit, unreadOnly, xTrotxiPlatform)

list Notifications

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final bool unreadOnly = true; // bool | Only unread notifications.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.listNotifications(xTrotxiClient, xTrotxiBuild, cursor, limit, unreadOnly, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->listNotifications: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **cursor** | **String**| Opaque cursor bound to caller, sort and filters. | [optional]
 **limit** | **int**| Page size. No silent truncation. | [optional] [default to 30]
 **unreadOnly** | **bool**| Only unread notifications. | [optional] [default to false]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RiderNotificationPage**](RiderNotificationPage.md)

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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Optional inclusive Africa/Accra purchase-creation day. With no date filters, returns all purchase history, including unresolved purchases. No default recency cutoff.
final Date toDate = 2013-10-20; // Date | Optional inclusive purchase-creation day; if both bounds are supplied, toDate must not precede fromDate.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String cursor = cursor_example; // String | Opaque cursor bound to caller, sort and filters.
final int limit = 56; // int | Page size. No silent truncation.
final Date fromDate = 2013-10-20; // Date | Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
final Date toDate = 2013-10-20; // Date | Inclusive; paired with fromDate.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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

# **markAllNotificationsRead**
> NotificationReadCountResponse markAllNotificationsRead(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

mark All Notifications Read

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.markAllNotificationsRead(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->markAllNotificationsRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**NotificationReadCountResponse**](NotificationReadCountResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markNotificationRead**
> RiderNotificationResponse markNotificationRead(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

mark Notification Read

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String |
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.markNotificationRead(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->markNotificationRead: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**RiderNotificationResponse**](RiderNotificationResponse.md)

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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PersonalPauseInput personalPauseInput = ; // PersonalPauseInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PurchaseQuoteInput purchaseQuoteInput = ; // PurchaseQuoteInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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

# **removeAutoRenewalCard**
> removeAutoRenewalCard(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

remove Auto Renewal Card

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    api.removeAutoRenewalCard(xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->removeAutoRenewalCard: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PersonalResumeInput personalResumeInput = ; // PersonalResumeInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
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

# **setAutoRenewal**
> AutoRenewalResponse setAutoRenewal(xTrotxiClient, xTrotxiBuild, autoRenewalInput, xTrotxiPlatform)

set Auto Renewal

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final AutoRenewalInput autoRenewalInput = ; // AutoRenewalInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.setAutoRenewal(xTrotxiClient, xTrotxiBuild, autoRenewalInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->setAutoRenewal: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **autoRenewalInput** | [**AutoRenewalInput**](AutoRenewalInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**AutoRenewalResponse**](AutoRenewalResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startPhoneVerification**
> PhoneChallengeResponse startPhoneVerification(xTrotxiClient, xTrotxiBuild, phoneVerificationStart, xTrotxiPlatform)

start Phone Verification

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final PhoneVerificationStart phoneVerificationStart = ; // PhoneVerificationStart |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.startPhoneVerification(xTrotxiClient, xTrotxiBuild, phoneVerificationStart, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->startPhoneVerification: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **phoneVerificationStart** | [**PhoneVerificationStart**](PhoneVerificationStart.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**PhoneChallengeResponse**](PhoneChallengeResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateNotificationPreferences**
> NotificationPreferencesResponse updateNotificationPreferences(ifMatch, xTrotxiClient, xTrotxiBuild, notificationPreferencesInput, xTrotxiPlatform)

update Notification Preferences

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String ifMatch = ifMatch_example; // String | Missing = 428; stale = 412. Reload the current preferences and retry with its ETag.
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final NotificationPreferencesInput notificationPreferencesInput = ; // NotificationPreferencesInput |
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.updateNotificationPreferences(ifMatch, xTrotxiClient, xTrotxiBuild, notificationPreferencesInput, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->updateNotificationPreferences: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ifMatch** | **String**| Missing = 428; stale = 412. Reload the current preferences and retry with its ETag. |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **notificationPreferencesInput** | [**NotificationPreferencesInput**](NotificationPreferencesInput.md)|  |
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**NotificationPreferencesResponse**](NotificationPreferencesResponse.md)

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
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

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
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**CommuteRequestResponse**](CommuteRequestResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **withdrawStandby**
> StandbyApplicationResponse withdrawStandby(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform)

withdraw Standby

### Example
```dart
import 'package:trotxi_api_client/api.dart';

final api = TrotxiApiClient().getRiderOwnApi();
final String id = id_example; // String |
final String xTrotxiClient = commuter; // String | Compatibility metadata only, never grants a role.
final int xTrotxiBuild = 1; // int | Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
final String xTrotxiPlatform = ios; // String | Required for commuter/driver, absent for ops/worker.

try {
    final response = api.withdrawStandby(id, xTrotxiClient, xTrotxiBuild, xTrotxiPlatform);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RiderOwnApi->withdrawStandby: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **xTrotxiClient** | **String**| Compatibility metadata only, never grants a role. |
 **xTrotxiBuild** | **int**| Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable. | [default to 1]
 **xTrotxiPlatform** | **String**| Required for commuter/driver, absent for ops/worker. | [optional]

### Return type

[**StandbyApplicationResponse**](StandbyApplicationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
