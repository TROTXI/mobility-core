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
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
import 'package:trotxi_api_client/src/model/boarding_board_post200_response.dart';
import 'package:trotxi_api_client/src/model/boarding_board_post_request.dart';
import 'package:trotxi_api_client/src/model/boarding_manifest_get200_response.dart';
import 'package:trotxi_api_client/src/model/boarding_no_show_post200_response.dart';
import 'package:trotxi_api_client/src/model/boarding_scan_post200_response.dart';
import 'package:trotxi_api_client/src/model/boarding_scan_post_request.dart';
import 'package:trotxi_api_client/src/model/boarding_verify_code_post200_response.dart';
import 'package:trotxi_api_client/src/model/boarding_verify_code_post_request.dart';
import 'package:trotxi_api_client/src/model/boarding_verify_pin_post200_response.dart';
import 'package:trotxi_api_client/src/model/boarding_verify_pin_post_request.dart';
import 'package:trotxi_api_client/src/model/me_pass_get200_response.dart';

class BoardingApi {
========
>>>>>>> origin/main
import 'package:trotxi_api_client/src/model/driver_self_response.dart';
import 'package:trotxi_api_client/src/model/error_response.dart';
import 'package:trotxi_api_client/src/model/incident_input.dart';
import 'package:trotxi_api_client/src/model/incident_page.dart';
import 'package:trotxi_api_client/src/model/incident_response.dart';
import 'package:trotxi_api_client/src/model/pin_change.dart';
import 'package:trotxi_api_client/src/model/route_page.dart';
import 'package:trotxi_api_client/src/model/work_request_input.dart';
import 'package:trotxi_api_client/src/model/work_request_page.dart';
import 'package:trotxi_api_client/src/model/work_request_response.dart';

class DriverOwnApi {
<<<<<<< HEAD

=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
>>>>>>> origin/main
  final Dio _dio;

  final Serializers _serializers;

  const DriverOwnApi(this._dio, this._serializers);

  /// change Driver Pin
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [pinChange] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  ///
  ///
  /// Parameters:
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
  /// * [boardingBoardPostRequest]
========
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [pinChange]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<void>> changeDriverPin({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
  Future<Response<BoardingBoardPost200Response>> boardingBoardPost({
    required BoardingBoardPostRequest boardingBoardPostRequest,
========
  Future<Response<void>> changeDriverPin({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required PinChange pinChange,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/auth/driver/pin';
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
<<<<<<< HEAD
      const _type = FullType(PinChange);
      _bodyData = _serializers.serialize(pinChange, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
      const _type = FullType(BoardingBoardPostRequest);
      _bodyData = _serializers.serialize(boardingBoardPostRequest,
          specifiedType: _type);
========
      const _type = FullType(PinChange);
      _bodyData = _serializers.serialize(pinChange, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
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

    return _response;
  }

  /// create Driver Request
<<<<<<< HEAD
  /// 
=======
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [workRequestInput] 
=======
  /// * [workRequestInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [WorkRequestResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<WorkRequestResponse>> createDriverRequest({ 
=======
  Future<Response<WorkRequestResponse>> createDriverRequest({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required WorkRequestInput workRequestInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/driver/requests';
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
      const _type = FullType(WorkRequestInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(workRequestInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(workRequestInput, specifiedType: _type);
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

    WorkRequestResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(WorkRequestResponse),
      ) as WorkRequestResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
              specifiedType: const FullType(BoardingBoardPost200Response),
            ) as BoardingBoardPost200Response;
========
              specifiedType: const FullType(WorkRequestResponse),
            ) as WorkRequestResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
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

    return Response<WorkRequestResponse>(
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
  /// get Driver Self
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
  /// A trip&#39;s manifest — confirmed riders with name + photo (assigned driver only)
  ///
  ///
  /// Parameters:
  /// * [tripId]
========
  /// get Driver Self
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [DriverSelfResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverSelfResponse>> getDriverSelf({ 
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
  Future<Response<BoardingManifestGet200Response>> boardingManifestGet({
    required String tripId,
========
  Future<Response<DriverSelfResponse>> getDriverSelf({
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/driver/me';
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

    DriverSelfResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverSelfResponse),
      ) as DriverSelfResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(DriverSelfResponse),
            ) as DriverSelfResponse;
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

    return Response<DriverSelfResponse>(
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

  /// list Driver Available Routes
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
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [RoutePage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<RoutePage>> listDriverAvailableRoutes({ 
=======
  Future<Response<RoutePage>> listDriverAvailableRoutes({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/driver/available-routes';
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
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
      r'tripId':
          encodeQueryParameter(_serializers, tripId, const FullType(String)),
========
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
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

    RoutePage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(RoutePage),
      ) as RoutePage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
              specifiedType: const FullType(BoardingManifestGet200Response),
            ) as BoardingManifestGet200Response;
========
              specifiedType: const FullType(RoutePage),
            ) as RoutePage;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
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

    return Response<RoutePage>(
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

  /// list Driver Incidents
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
=======
  ///
  ///
  /// Parameters:
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
  /// * [boardingBoardPostRequest]
========
>>>>>>> origin/main
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [cursor] - Opaque cursor bound to caller, sort and filters.
  /// * [limit] - Page size. No silent truncation.
  /// * [status] - Must match the resource state enum; unknown values return 400.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [IncidentPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<IncidentPage>> listDriverIncidents({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
  Future<Response<BoardingNoShowPost200Response>> boardingNoShowPost({
    required BoardingBoardPostRequest boardingBoardPostRequest,
========
  Future<Response<IncidentPage>> listDriverIncidents({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? status,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/driver/incidents';
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
    final _path = r'/boarding/no-show';
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
      const _type = FullType(BoardingBoardPostRequest);
      _bodyData = _serializers.serialize(boardingBoardPostRequest,
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

    BoardingNoShowPost200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BoardingNoShowPost200Response),
            ) as BoardingNoShowPost200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BoardingNoShowPost200Response>(
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

  /// Verify a scanned rider pass (driver only) and record the scan
  ///
  ///
  /// Parameters:
  /// * [boardingScanPostRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BoardingScanPost200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BoardingScanPost200Response>> boardingScanPost({
    required BoardingScanPostRequest boardingScanPostRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/boarding/scan';
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
      const _type = FullType(BoardingScanPostRequest);
      _bodyData =
          _serializers.serialize(boardingScanPostRequest, specifiedType: _type);
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

    BoardingScanPost200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BoardingScanPost200Response),
            ) as BoardingScanPost200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BoardingScanPost200Response>(
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

  /// Board whoever holds this code on this run (assigned driver only)
  /// Searches the run’s open seats for the code rather than checking one named seat. Safe because the caller is already the assigned driver, who can board any rider on their manifest with no code at all (POST /boarding/board). Two seats holding one code is refused rather than guessed.
  ///
  /// Parameters:
  /// * [boardingVerifyCodePostRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BoardingVerifyCodePost200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BoardingVerifyCodePost200Response>> boardingVerifyCodePost({
    required BoardingVerifyCodePostRequest boardingVerifyCodePostRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/boarding/verify-code';
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
      const _type = FullType(BoardingVerifyCodePostRequest);
      _bodyData = _serializers.serialize(boardingVerifyCodePostRequest,
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

    BoardingVerifyCodePost200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BoardingVerifyCodePost200Response),
            ) as BoardingVerifyCodePost200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BoardingVerifyCodePost200Response>(
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

  /// Board a rider via their daily boarding code (driver only)
  ///
  ///
  /// Parameters:
  /// * [boardingVerifyPinPostRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BoardingVerifyPinPost200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BoardingVerifyPinPost200Response>> boardingVerifyPinPost({
    required BoardingVerifyPinPostRequest boardingVerifyPinPostRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/boarding/verify-pin';
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
      const _type = FullType(BoardingVerifyPinPostRequest);
      _bodyData = _serializers.serialize(boardingVerifyPinPostRequest,
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

    BoardingVerifyPinPost200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BoardingVerifyPinPost200Response),
            ) as BoardingVerifyPinPost200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BoardingVerifyPinPost200Response>(
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

  /// Issue the rider a short-lived boarding pass (render as a QR)
  ///
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MePassGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MePassGet200Response>> mePassGet({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/me/pass';
========
    final _path = r'/v1/driver/incidents';
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
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

    final _queryParameters = <String, dynamic>{
<<<<<<< HEAD
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (status != null) r'status': encodeQueryParameter(_serializers, status, const FullType(String)),
=======
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (status != null)
        r'status':
            encodeQueryParameter(_serializers, status, const FullType(String)),
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

    IncidentPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(IncidentPage),
      ) as IncidentPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(IncidentPage),
            ) as IncidentPage;
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

    return Response<IncidentPage>(
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

  /// list Driver Requests
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
  /// * [status] - Must match the resource state enum; unknown values return 400.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [WorkRequestPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<WorkRequestPage>> listDriverRequests({ 
=======
  Future<Response<WorkRequestPage>> listDriverRequests({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? status,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/driver/requests';
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
      if (status != null) r'status': encodeQueryParameter(_serializers, status, const FullType(String)),
=======
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (status != null)
        r'status':
            encodeQueryParameter(_serializers, status, const FullType(String)),
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

    WorkRequestPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(WorkRequestPage),
      ) as WorkRequestPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(WorkRequestPage),
            ) as WorkRequestPage;
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

    return Response<WorkRequestPage>(
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

  /// report Incident
<<<<<<< HEAD
  /// 
=======
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [incidentInput] 
=======
  /// * [incidentInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [IncidentResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<IncidentResponse>> reportIncident({ 
=======
  Future<Response<IncidentResponse>> reportIncident({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required IncidentInput incidentInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/driver/incidents';
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
      const _type = FullType(IncidentInput);
      _bodyData = _serializers.serialize(incidentInput, specifiedType: _type);
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

    IncidentResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(IncidentResponse),
      ) as IncidentResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(IncidentResponse),
            ) as IncidentResponse;
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

    return Response<IncidentResponse>(
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

  /// withdraw Driver Request
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
  /// Returns a [Future] containing a [Response] with a [WorkRequestResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<WorkRequestResponse>> withdrawDriverRequest({ 
=======
  Future<Response<WorkRequestResponse>> withdrawDriverRequest({
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
    final _path = r'/v1/driver/requests/{id}/withdraw'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/driver/requests/{id}/withdraw'.replaceAll(
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

    WorkRequestResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(WorkRequestResponse),
      ) as WorkRequestResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/boarding_api.dart
              specifiedType: const FullType(MePassGet200Response),
            ) as MePassGet200Response;
========
              specifiedType: const FullType(WorkRequestResponse),
            ) as WorkRequestResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/driver_own_api.dart
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

    return Response<WorkRequestResponse>(
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
