//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

<<<<<<< HEAD
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

=======
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

<<<<<<<< HEAD:apps/api_client/lib/src/api/flags_api.dart
import 'package:trotxi_api_client/src/model/flags_get200_response.dart';

class FlagsApi {
========
>>>>>>> origin/main
import 'package:trotxi_api_client/src/model/error_response.dart';
import 'package:trotxi_api_client/src/model/receive_paystack_webhook_request.dart';
import 'package:trotxi_api_client/src/model/webhook_ack.dart';

class ProviderSignatureApi {
<<<<<<< HEAD

=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/provider_signature_api.dart
>>>>>>> origin/main
  final Dio _dio;

  final Serializers _serializers;

  const ProviderSignatureApi(this._dio, this._serializers);

<<<<<<< HEAD
  /// receive Paystack Webhook
  /// 
  ///
  /// Parameters:
  /// * [xPaystackSignature] 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/flags_api.dart
  /// Feature flags, minimum supported app version, basemap and operations contact
========
  /// receive Paystack Webhook
>>>>>>>> origin/main:apps/api_client/lib/src/api/provider_signature_api.dart
  ///
  ///
  /// Parameters:
  /// * [xPaystackSignature]
>>>>>>> origin/main
  /// * [receivePaystackWebhookRequest] - Provider-controlled JSON. HMAC exact raw bytes BEFORE parsing. Persist signed unknown events for inspection, not guessed fulfilment.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [WebhookAck] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<WebhookAck>> receivePaystackWebhook({ 
    required String xPaystackSignature,
    required ReceivePaystackWebhookRequest receivePaystackWebhookRequest,
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/flags_api.dart
  Future<Response<FlagsGet200Response>> flagsGet({
========
  Future<Response<WebhookAck>> receivePaystackWebhook({
    required String xPaystackSignature,
    required ReceivePaystackWebhookRequest receivePaystackWebhookRequest,
>>>>>>>> origin/main:apps/api_client/lib/src/api/provider_signature_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/webhooks/paystack';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'x-paystack-signature': xPaystackSignature,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(ReceivePaystackWebhookRequest);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(receivePaystackWebhookRequest, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData = _serializers.serialize(receivePaystackWebhookRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
>>>>>>> origin/main
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    WebhookAck? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(WebhookAck),
      ) as WebhookAck;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/flags_api.dart
              specifiedType: const FullType(FlagsGet200Response),
            ) as FlagsGet200Response;
========
              specifiedType: const FullType(WebhookAck),
            ) as WebhookAck;
>>>>>>>> origin/main:apps/api_client/lib/src/api/provider_signature_api.dart
>>>>>>> origin/main
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<WebhookAck>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
<<<<<<< HEAD

=======
>>>>>>> origin/main
}
