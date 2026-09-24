# trotxi_api_client.model.OpsPurchase

## Load the model package
```dart
import 'package:trotxi_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** |  | 
**plan** | **String** |  | 
**state** | **String** |  | 
**collectionState** | **String** |  | 
**price** | [**Money**](Money.md) |  | 
**appliedCredit** | [**Money**](Money.md) |  | 
**cashDue** | [**Money**](Money.md) |  | 
**checkout** | [**OpsPurchaseCheckout**](OpsPurchaseCheckout.md) |  | 
**billingPeriodId** | **String** |  | 
**failureCode** | **String** |  | 
**createdAt** | [**DateTime**](DateTime.md) |  | 
**riderId** | **String** |  | 
**attempts** | [**BuiltList&lt;OpsPurchaseAttemptsInner&gt;**](OpsPurchaseAttemptsInner.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


