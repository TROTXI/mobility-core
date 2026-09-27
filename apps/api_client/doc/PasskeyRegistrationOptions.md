# trotxi_api_client.model.PasskeyRegistrationOptions

## Load the model package
```dart
import 'package:trotxi_api_client/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**rp** | [**PasskeyRegistrationOptionsRp**](PasskeyRegistrationOptionsRp.md) |  | 
**user** | [**PasskeyRegistrationOptionsUser**](PasskeyRegistrationOptionsUser.md) |  | 
**challenge** | **String** |  | 
**pubKeyCredParams** | [**BuiltList&lt;PasskeyRegistrationOptionsPubKeyCredParamsInner&gt;**](PasskeyRegistrationOptionsPubKeyCredParamsInner.md) |  | 
**timeout** | **num** |  | [optional] 
**excludeCredentials** | [**BuiltList&lt;PasskeyAuthenticationOptionsAllowCredentialsInner&gt;**](PasskeyAuthenticationOptionsAllowCredentialsInner.md) |  | [optional] 
**authenticatorSelection** | [**PasskeyRegistrationOptionsAuthenticatorSelection**](PasskeyRegistrationOptionsAuthenticatorSelection.md) |  | [optional] 
**hints** | **BuiltList&lt;String&gt;** |  | [optional] 
**attestation** | **String** |  | [optional] 
**attestationFormats** | **BuiltList&lt;String&gt;** |  | [optional] 
**extensions** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


