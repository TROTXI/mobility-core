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
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
import 'package:trotxi_api_client/src/model/routes_get200_response_inner.dart';
import 'package:trotxi_api_client/src/model/routes_id_geometry_get200_response.dart';
import 'package:trotxi_api_client/src/model/routes_id_get200_response.dart';
import 'package:trotxi_api_client/src/model/trips_get200_response.dart';
import 'package:trotxi_api_client/src/model/trips_get200_response_trips_inner.dart';
import 'package:trotxi_api_client/src/model/trips_id_arrive_post_request.dart';
import 'package:trotxi_api_client/src/model/trips_id_get200_response.dart';
import 'package:trotxi_api_client/src/model/trips_id_position_get200_response.dart';
import 'package:trotxi_api_client/src/model/trips_id_position_post200_response.dart';
import 'package:trotxi_api_client/src/model/trips_id_position_post_request.dart';
import 'package:trotxi_api_client/src/model/trips_id_summary_get200_response.dart';

class MobilityApi {
========
>>>>>>> origin/main
import 'package:trotxi_api_client/src/model/arrival_input.dart';
import 'package:trotxi_api_client/src/model/boarding_input.dart';
import 'package:trotxi_api_client/src/model/boarding_result_response.dart';
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:trotxi_api_client/src/model/driver_trip_page.dart';
import 'package:trotxi_api_client/src/model/driver_trip_response.dart';
import 'package:trotxi_api_client/src/model/error_response.dart';
import 'package:trotxi_api_client/src/model/manifest_response.dart';
import 'package:trotxi_api_client/src/model/position_input.dart';
import 'package:trotxi_api_client/src/model/position_receipt_response.dart';
import 'package:trotxi_api_client/src/model/trip_summary_response.dart';

class DriverAssignedOrOwnApi {
<<<<<<< HEAD

=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
  final Dio _dio;

  final Serializers _serializers;

  const DriverAssignedOrOwnApi(this._dio, this._serializers);

  /// board Rider
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [boardingInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  ///
  ///
  /// Parameters:
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  /// * [date]
  /// * [from]
  /// * [to]
========
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [boardingInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BoardingResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<BoardingResultResponse>> boardRider({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  Future<Response<TripsGet200Response>> meTripsGet({
    String? date,
    String? from,
    String? to,
========
  Future<Response<BoardingResultResponse>> boardRider({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required BoardingInput boardingInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/boardings'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/driver/trips/{id}/boardings'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'Idempotency-Key': idempotencyKey,
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(BoardingInput);
      _bodyData = _serializers.serialize(boardingInput, specifiedType: _type);
<<<<<<< HEAD

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
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

    BoardingResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(BoardingResultResponse),
      ) as BoardingResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BoardingResultResponse),
            ) as BoardingResultResponse;
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

    return Response<BoardingResultResponse>(
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

  /// complete Trip
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
>>>>>>> origin/main
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [DriverTripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverTripResponse>> completeTrip({ 
=======
  Future<Response<DriverTripResponse>> completeTrip({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/complete'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/driver/trips/{id}/complete'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'Idempotency-Key': idempotencyKey,
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

<<<<<<< HEAD
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
    final _queryParameters = <String, dynamic>{
      if (date != null)
        r'date':
            encodeQueryParameter(_serializers, date, const FullType(String)),
      if (from != null)
        r'from':
            encodeQueryParameter(_serializers, from, const FullType(String)),
      if (to != null)
        r'to': encodeQueryParameter(_serializers, to, const FullType(String)),
    };

========
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    DriverTripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverTripResponse),
      ) as DriverTripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
              specifiedType: const FullType(TripsGet200Response),
            ) as TripsGet200Response;
========
              specifiedType: const FullType(DriverTripResponse),
            ) as DriverTripResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    return Response<DriverTripResponse>(
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
  /// get Manifest
  /// 
  ///
  /// Parameters:
  /// * [id] 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  /// List all routes
========
  /// get Manifest
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
  ///
  ///
  /// Parameters:
  /// * [id]
>>>>>>> origin/main
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ManifestResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<ManifestResponse>> getManifest({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  Future<Response<BuiltList<RoutesGet200ResponseInner>>> routesGet({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/routes';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
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

    BuiltList<RoutesGet200ResponseInner>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  BuiltList, [FullType(RoutesGet200ResponseInner)]),
            ) as BuiltList<RoutesGet200ResponseInner>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltList<RoutesGet200ResponseInner>>(
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

  /// The path a route follows, for drawing it on a map
  /// Returns the road-following path learned from completed runs (#179) when we have one, and a straight line through the stops when we do not. &#x60;source&#x60; tells you which you got, so a client can render the fallback differently rather than pretending it follows the road.
  ///
  /// Parameters:
  /// * [id]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [RoutesIdGeometryGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<RoutesIdGeometryGet200Response>> routesIdGeometryGet({
========
  Future<Response<ManifestResponse>> getManifest({
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    required String id,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/manifest'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
    final _path = r'/routes/{id}/geometry'.replaceAll(
========
    final _path = r'/v1/driver/trips/{id}/manifest'.replaceAll(
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    ManifestResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(ManifestResponse),
      ) as ManifestResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
              specifiedType: const FullType(RoutesIdGeometryGet200Response),
            ) as RoutesIdGeometryGet200Response;
========
              specifiedType: const FullType(ManifestResponse),
            ) as ManifestResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    return Response<ManifestResponse>(
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
  /// get Trip Summary
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  /// Get a route with its stops in order
========
  /// get Trip Summary
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
  ///
  ///
  /// Parameters:
  /// * [id]
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
========
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripSummaryResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<TripSummaryResponse>> getTripSummary({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  Future<Response<RoutesIdGet200Response>> routesIdGet({
========
  Future<Response<TripSummaryResponse>> getTripSummary({
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    required String id,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/summary'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
    final _path = r'/routes/{id}'.replaceAll(
========
    final _path = r'/v1/driver/trips/{id}/summary'.replaceAll(
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    TripSummaryResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TripSummaryResponse),
      ) as TripSummaryResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
              specifiedType: const FullType(RoutesIdGet200Response),
            ) as RoutesIdGet200Response;
========
              specifiedType: const FullType(TripSummaryResponse),
            ) as TripSummaryResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    return Response<TripSummaryResponse>(
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
  /// list Driver Trips
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  /// List trips, optionally filtered by route
  ///
  ///
  /// Parameters:
  /// * [routeId]
========
  /// list Driver Trips
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
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [DriverTripPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverTripPage>> listDriverTrips({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  Future<Response<TripsGet200Response>> tripsGet({
========
  Future<Response<DriverTripPage>> listDriverTrips({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    Date? fromDate,
    Date? toDate,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    String? routeId,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/driver/trips';
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
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
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
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
      if (routeId != null)
        r'routeId':
            encodeQueryParameter(_serializers, routeId, const FullType(String)),
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

    DriverTripPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverTripPage),
      ) as DriverTripPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
              specifiedType: const FullType(TripsGet200Response),
            ) as TripsGet200Response;
========
              specifiedType: const FullType(DriverTripPage),
            ) as DriverTripPage;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    return Response<DriverTripPage>(
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

  /// mark No Show
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [reservationId] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  /// * [tripsIdArrivePostRequest]
========
  /// * [reservationId]
>>>>>>> origin/main
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BoardingResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<BoardingResultResponse>> markNoShow({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  Future<Response<TripsGet200ResponseTripsInner>> tripsIdArrivePost({
========
  Future<Response<BoardingResultResponse>> markNoShow({
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    required String id,
    required String reservationId,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/reservations/{reservationId}/no-show'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString()).replaceAll('{' r'reservationId' '}', encodeQueryParameter(_serializers, reservationId, const FullType(String)).toString());
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
    final _path = r'/trips/{id}/arrive'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
========
    final _path = r'/v1/driver/trips/{id}/reservations/{reservationId}/no-show'
        .replaceAll(
            '{' r'id' '}',
            encodeQueryParameter(_serializers, id, const FullType(String))
                .toString())
        .replaceAll(
            '{' r'reservationId' '}',
            encodeQueryParameter(
                    _serializers, reservationId, const FullType(String))
                .toString());
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'Idempotency-Key': idempotencyKey,
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

    BoardingResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(BoardingResultResponse),
      ) as BoardingResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BoardingResultResponse),
            ) as BoardingResultResponse;
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

    return Response<BoardingResultResponse>(
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

  /// record Arrival
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
>>>>>>> origin/main
  /// * [ifMatch] - Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [arrivalInput] 
=======
  /// * [arrivalInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [DriverTripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverTripResponse>> recordArrival({ 
=======
  Future<Response<DriverTripResponse>> recordArrival({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ArrivalInput arrivalInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/arrivals'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/driver/trips/{id}/arrivals'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'If-Match': ifMatch,
        r'Idempotency-Key': idempotencyKey,
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
<<<<<<< HEAD
      const _type = FullType(ArrivalInput);
      _bodyData = _serializers.serialize(arrivalInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
      const _type = FullType(TripsIdArrivePostRequest);
      _bodyData = _serializers.serialize(tripsIdArrivePostRequest,
          specifiedType: _type);
========
      const _type = FullType(ArrivalInput);
      _bodyData = _serializers.serialize(arrivalInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    DriverTripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverTripResponse),
      ) as DriverTripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
              specifiedType: const FullType(TripsGet200ResponseTripsInner),
            ) as TripsGet200ResponseTripsInner;
========
              specifiedType: const FullType(DriverTripResponse),
            ) as DriverTripResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    return Response<DriverTripResponse>(
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

  /// record Position
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [positionInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  ///
  ///
  /// Parameters:
  /// * [id]
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
========
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [positionInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PositionReceiptResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PositionReceiptResponse>> recordPosition({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  Future<Response<TripsGet200ResponseTripsInner>> tripsIdCompletePost({
========
  Future<Response<PositionReceiptResponse>> recordPosition({
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    required String id,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required PositionInput positionInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/positions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
    final _path = r'/trips/{id}/complete'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
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
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TripsGet200ResponseTripsInner? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TripsGet200ResponseTripsInner),
            ) as TripsGet200ResponseTripsInner;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripsGet200ResponseTripsInner>(
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

  /// Get a trip by id
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripsIdGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripsIdGet200Response>> tripsIdGet({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/trips/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
    final _options = Options(
      method: r'GET',
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
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TripsIdGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TripsIdGet200Response),
            ) as TripsIdGet200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripsIdGet200Response>(
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

  /// Get a trip&#39;s latest position with a deterministic ETA to each upcoming stop
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripsIdPositionGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripsIdPositionGet200Response>> tripsIdPositionGet({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/trips/{id}/position'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
    final _options = Options(
      method: r'GET',
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
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TripsIdPositionGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TripsIdPositionGet200Response),
            ) as TripsIdPositionGet200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripsIdPositionGet200Response>(
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

  /// Report a GPS fix for a trip (assigned driver only)
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [tripsIdPositionPostRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripsIdPositionPost200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripsIdPositionPost200Response>> tripsIdPositionPost({
    required String id,
    required TripsIdPositionPostRequest tripsIdPositionPostRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/trips/{id}/position'.replaceAll(
========
    final _path = r'/v1/driver/trips/{id}/positions'.replaceAll(
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'POST',
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
<<<<<<< HEAD
      const _type = FullType(PositionInput);
      _bodyData = _serializers.serialize(positionInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
      const _type = FullType(TripsIdPositionPostRequest);
      _bodyData = _serializers.serialize(tripsIdPositionPostRequest,
          specifiedType: _type);
========
      const _type = FullType(PositionInput);
      _bodyData = _serializers.serialize(positionInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    PositionReceiptResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PositionReceiptResponse),
      ) as PositionReceiptResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
              specifiedType: const FullType(TripsIdPositionPost200Response),
            ) as TripsIdPositionPost200Response;
========
              specifiedType: const FullType(PositionReceiptResponse),
            ) as PositionReceiptResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    return Response<PositionReceiptResponse>(
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

  /// start Trip
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
========
>>>>>>> origin/main
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [DriverTripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverTripResponse>> startTrip({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
  Future<Response<TripsGet200ResponseTripsInner>> tripsIdStartPost({
========
  Future<Response<DriverTripResponse>> startTrip({
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/trips/{id}/start'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
    final _path = r'/trips/{id}/start'.replaceAll(
========
    final _path = r'/v1/driver/trips/{id}/start'.replaceAll(
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'Idempotency-Key': idempotencyKey,
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

    DriverTripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverTripResponse),
      ) as DriverTripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart
              specifiedType: const FullType(TripsGet200ResponseTripsInner),
            ) as TripsGet200ResponseTripsInner;
========
              specifiedType: const FullType(DriverTripResponse),
            ) as DriverTripResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
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

    return Response<DriverTripResponse>(
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
<<<<<<<< HEAD:apps/api_client/lib/src/api/mobility_api.dart

  /// What my run did — boarded, not boarded, and by which method
  /// Reports notBoarded rather than \&quot;no-shows deducted\&quot;: the debit is the ops cutoff’s decision, not this screen’s, and a driver should not read a deduction that has not happened yet.
  ///
  /// Parameters:
  /// * [id]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TripsIdSummaryGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<TripsIdSummaryGet200Response>> tripsIdSummaryGet({
    required String id,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/trips/{id}/summary'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
    final _options = Options(
      method: r'GET',
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
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    TripsIdSummaryGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TripsIdSummaryGet200Response),
            ) as TripsIdSummaryGet200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<TripsIdSummaryGet200Response>(
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
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_assigned_or_own_api.dart
>>>>>>> origin/main
}
