//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

<<<<<<< HEAD
import 'package:built_value/json_object.dart';
=======
>>>>>>> origin/main
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:trotxi_api_client/src/api_util.dart';
<<<<<<< HEAD
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/reservations_api.dart
import 'package:trotxi_api_client/src/model/me_reservations_get200_response.dart';
import 'package:trotxi_api_client/src/model/me_reservations_get200_response_reservations_inner.dart';
import 'package:trotxi_api_client/src/model/me_reservations_post_request.dart';

class ReservationsApi {
========
>>>>>>> origin/main
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:trotxi_api_client/src/model/error_response.dart';
import 'package:trotxi_api_client/src/model/trip_page.dart';
import 'package:trotxi_api_client/src/model/trip_response.dart';

class SignedInCatalogApi {
<<<<<<< HEAD

=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/signed_in_catalog_api.dart
>>>>>>> origin/main
  final Dio _dio;

  final Serializers _serializers;

  const SignedInCatalogApi(this._dio, this._serializers);

<<<<<<< HEAD
  /// get Trip
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/reservations_api.dart
  /// List the rider&#39;s reservations (newest travel day first)
  ///
  ///
  /// Parameters:
  /// * [from]
========
  /// get Trip
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/signed_in_catalog_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<TripResponse>> getTrip({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/reservations_api.dart
  Future<Response<MeReservationsGet200Response>> meReservationsGet({
    String? from,
========
  Future<Response<TripResponse>> getTrip({
>>>>>>> origin/main
    required String id,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/signed_in_catalog_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/trips/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/trips/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'X-Trotxi-Client': xTrotxiClient,
        r'X-Trotxi-Build': xTrotxiBuild,
        if (xTrotxiPlatform != null) r'X-Trotxi-Platform': xTrotxiPlatform,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripResponse),
      ) as TripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TripResponse),
            ) as TripResponse;
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

    return Response<TripResponse>(
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

  /// list Trips
<<<<<<< HEAD
  /// 
=======
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [cursor] - Opaque cursor bound to caller, sort and filters.
  /// * [limit] - Page size. No silent truncation.
  /// * [fromDate] - Africa/Accra day; paired with toDate. Default last/current 7 days; maximum 31 days.
  /// * [toDate] - Inclusive; paired with fromDate.
  /// * [routeId] - Filter within caller scope; never expands authorization.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<TripPage>> listTrips({ 
=======
  Future<Response<TripPage>> listTrips({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    Date? fromDate,
    Date? toDate,
    String? routeId,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/trips';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'X-Trotxi-Client': xTrotxiClient,
        r'X-Trotxi-Build': xTrotxiBuild,
        if (xTrotxiPlatform != null) r'X-Trotxi-Platform': xTrotxiPlatform,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
<<<<<<< HEAD
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (fromDate != null) r'fromDate': encodeQueryParameter(_serializers, fromDate, const FullType(Date)),
      if (toDate != null) r'toDate': encodeQueryParameter(_serializers, toDate, const FullType(Date)),
      if (routeId != null) r'routeId': encodeQueryParameter(_serializers, routeId, const FullType(String)),
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/reservations_api.dart
      if (from != null)
        r'from':
            encodeQueryParameter(_serializers, from, const FullType(String)),
========
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (fromDate != null)
        r'fromDate':
            encodeQueryParameter(_serializers, fromDate, const FullType(Date)),
      if (toDate != null)
        r'toDate':
            encodeQueryParameter(_serializers, toDate, const FullType(Date)),
      if (routeId != null)
        r'routeId':
            encodeQueryParameter(_serializers, routeId, const FullType(String)),
>>>>>>>> origin/main:apps/api_client/lib/src/api/signed_in_catalog_api.dart
>>>>>>> origin/main
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TripPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripPage),
      ) as TripPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/reservations_api.dart
              specifiedType: const FullType(MeReservationsGet200Response),
            ) as MeReservationsGet200Response;
========
              specifiedType: const FullType(TripPage),
            ) as TripPage;
>>>>>>>> origin/main:apps/api_client/lib/src/api/signed_in_catalog_api.dart
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

    return Response<TripPage>(
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
<<<<<<<< HEAD:apps/api_client/lib/src/api/reservations_api.dart

  /// Confirm or decline the daily ride (upsert per day + direction)
  /// Confirming requires an active membership with a ride left on the corridor the run belongs to; 402 says which of the three is missing. Declining is always allowed.
  ///
  /// Parameters:
  /// * [meReservationsPostRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MeReservationsGet200ResponseReservationsInner] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MeReservationsGet200ResponseReservationsInner>>
      meReservationsPost({
    required MeReservationsPostRequest meReservationsPostRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/me/reservations';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(MeReservationsPostRequest);
      _bodyData = _serializers.serialize(meReservationsPostRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
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

    MeReservationsGet200ResponseReservationsInner? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType:
                  const FullType(MeReservationsGet200ResponseReservationsInner),
            ) as MeReservationsGet200ResponseReservationsInner;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MeReservationsGet200ResponseReservationsInner>(
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
========
>>>>>>>> origin/main:apps/api_client/lib/src/api/signed_in_catalog_api.dart
>>>>>>> origin/main
}
