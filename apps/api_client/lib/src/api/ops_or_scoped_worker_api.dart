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

<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
import 'package:trotxi_api_client/src/api_util.dart';
import 'package:trotxi_api_client/src/model/auth_apple_post_request.dart';
import 'package:trotxi_api_client/src/model/auth_driver_pin_post_request.dart';
import 'package:trotxi_api_client/src/model/auth_driver_post200_response.dart';
import 'package:trotxi_api_client/src/model/auth_driver_post_request.dart';
import 'package:trotxi_api_client/src/model/auth_google_post200_response.dart';
import 'package:trotxi_api_client/src/model/auth_google_post_request.dart';
import 'package:trotxi_api_client/src/model/auth_refresh_post200_response.dart';
import 'package:trotxi_api_client/src/model/auth_refresh_post_request.dart';
import 'package:trotxi_api_client/src/model/me_avatar_get200_response.dart';
import 'package:trotxi_api_client/src/model/me_devices_post200_response.dart';
import 'package:trotxi_api_client/src/model/me_devices_post_request.dart';
import 'package:trotxi_api_client/src/model/me_get200_response.dart';
import 'package:trotxi_api_client/src/model/me_patch_request.dart';
import 'package:trotxi_api_client/src/model/me_sessions_get200_response.dart';

class AuthApi {
========
>>>>>>> origin/main
import 'package:trotxi_api_client/src/model/error_response.dart';
import 'package:trotxi_api_client/src/model/maintenance_input.dart';
import 'package:trotxi_api_client/src/model/maintenance_result_response.dart';
import 'package:trotxi_api_client/src/model/payment_maintenance_result_response.dart';
import 'package:trotxi_api_client/src/model/service_day_input.dart';
import 'package:trotxi_api_client/src/model/trip_generation_input.dart';

class OpsOrScopedWorkerApi {
<<<<<<< HEAD

=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  final Dio _dio;

  final Serializers _serializers;

  const OpsOrScopedWorkerApi(this._dio, this._serializers);

  /// run Ask Dispatch
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [serviceDayInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  ///
  ///
  /// Parameters:
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// * [authApplePostRequest]
========
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [serviceDayInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runAskDispatch({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<AuthGooglePost200Response>> authApplePost({
    required AuthApplePostRequest authApplePostRequest,
========
  Future<Response<MaintenanceResultResponse>> runAskDispatch({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ServiceDayInput serviceDayInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/ask-dispatch';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(AuthApplePostRequest);
      _bodyData =
          _serializers.serialize(authApplePostRequest, specifiedType: _type);
========
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
              specifiedType: const FullType(AuthGooglePost200Response),
            ) as AuthGooglePost200Response;
========
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<MaintenanceResultResponse>(
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

  /// run Gps Retention
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  ///
  ///
  /// Parameters:
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// * [authDriverPinPostRequest]
========
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runGpsRetention({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<String>> authDriverPinPost({
    required AuthDriverPinPostRequest authDriverPinPostRequest,
========
  Future<Response<MaintenanceResultResponse>> runGpsRetention({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/gps-retention';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(MaintenanceInput);
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(AuthDriverPinPostRequest);
      _bodyData = _serializers.serialize(authDriverPinPostRequest,
          specifiedType: _type);
========
      const _type = FullType(MaintenanceInput);
      _bodyData =
          _serializers.serialize(maintenanceInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      _responseData = rawResponse == null ? null : rawResponse as String;
========
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<MaintenanceResultResponse>(
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

  /// run No Shows
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [serviceDayInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  ///
  ///
  /// Parameters:
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// * [authDriverPostRequest]
========
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [serviceDayInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runNoShows({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<AuthDriverPost200Response>> authDriverPost({
    required AuthDriverPostRequest authDriverPostRequest,
========
  Future<Response<MaintenanceResultResponse>> runNoShows({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ServiceDayInput serviceDayInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/no-shows';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(AuthDriverPostRequest);
      _bodyData =
          _serializers.serialize(authDriverPostRequest, specifiedType: _type);
========
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
              specifiedType: const FullType(AuthDriverPost200Response),
            ) as AuthDriverPost200Response;
========
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<MaintenanceResultResponse>(
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
  /// run Payment Inbox
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// Sign in with a Google ID token (creates the account on first use)
  ///
  ///
  /// Parameters:
  /// * [authGooglePostRequest]
========
  /// run Payment Inbox
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [maintenanceInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  /// * [maintenanceInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runPaymentInbox({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<AuthGooglePost200Response>> authGooglePost({
    required AuthGooglePostRequest authGooglePostRequest,
========
  Future<Response<MaintenanceResultResponse>> runPaymentInbox({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/payment-inbox';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(MaintenanceInput);
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(AuthGooglePostRequest);
      _bodyData =
          _serializers.serialize(authGooglePostRequest, specifiedType: _type);
========
      const _type = FullType(MaintenanceInput);
      _bodyData =
          _serializers.serialize(maintenanceInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
              specifiedType: const FullType(AuthGooglePost200Response),
            ) as AuthGooglePost200Response;
========
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<MaintenanceResultResponse>(
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
  /// run Payment Reconciliation
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// Revoke a refresh token (idempotent)
  ///
  ///
  /// Parameters:
  /// * [authRefreshPostRequest]
========
  /// run Payment Reconciliation
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [maintenanceInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  /// * [maintenanceInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runPaymentReconciliation({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<void>> authLogoutPost({
    required AuthRefreshPostRequest authRefreshPostRequest,
========
  Future<Response<MaintenanceResultResponse>> runPaymentReconciliation({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/payment-reconciliation';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(MaintenanceInput);
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(AuthRefreshPostRequest);
      _bodyData =
          _serializers.serialize(authRefreshPostRequest, specifiedType: _type);
========
      const _type = FullType(MaintenanceInput);
      _bodyData =
          _serializers.serialize(maintenanceInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
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

    return Response<MaintenanceResultResponse>(
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
  /// run Payments
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// Exchange a refresh token for a new token pair (rotates the session)
  ///
  ///
  /// Parameters:
  /// * [authRefreshPostRequest]
========
  /// run Payments
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [maintenanceInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  /// * [maintenanceInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PaymentMaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PaymentMaintenanceResultResponse>> runPayments({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<AuthRefreshPost200Response>> authRefreshPost({
    required AuthRefreshPostRequest authRefreshPostRequest,
========
  Future<Response<PaymentMaintenanceResultResponse>> runPayments({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/payments';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(MaintenanceInput);
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(AuthRefreshPostRequest);
      _bodyData =
          _serializers.serialize(authRefreshPostRequest, specifiedType: _type);
========
      const _type = FullType(MaintenanceInput);
      _bodyData =
          _serializers.serialize(maintenanceInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    PaymentMaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PaymentMaintenanceResultResponse),
      ) as PaymentMaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
              specifiedType: const FullType(AuthRefreshPost200Response),
            ) as AuthRefreshPost200Response;
========
              specifiedType: const FullType(PaymentMaintenanceResultResponse),
            ) as PaymentMaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<PaymentMaintenanceResultResponse>(
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
  /// run Period Close
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// Get a short-lived signed URL for the authenticated user avatar
========
  /// run Period Close
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [maintenanceInput] 
=======
  /// * [maintenanceInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runPeriodClose({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<MeAvatarGet200Response>> meAvatarGet({
========
  Future<Response<MaintenanceResultResponse>> runPeriodClose({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/period-close';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
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

    MeAvatarGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MeAvatarGet200Response),
            ) as MeAvatarGet200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MeAvatarGet200Response>(
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

  /// Upload the authenticated user avatar (resized + EXIF-stripped server-side)
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
  /// Returns a [Future] containing a [Response] with a [MeAvatarGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MeAvatarGet200Response>> meAvatarPost({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/me/avatar';
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

    MeAvatarGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MeAvatarGet200Response),
            ) as MeAvatarGet200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MeAvatarGet200Response>(
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

  /// Register this device FCM push token for the authenticated user
  ///
  ///
  /// Parameters:
  /// * [meDevicesPostRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MeDevicesPost200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MeDevicesPost200Response>> meDevicesPost({
    required MeDevicesPostRequest meDevicesPostRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/me/devices';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
========
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
          {
>>>>>>> origin/main
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
      const _type = FullType(MaintenanceInput);
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(MeDevicesPostRequest);
      _bodyData =
          _serializers.serialize(meDevicesPostRequest, specifiedType: _type);
========
      const _type = FullType(MaintenanceInput);
      _bodyData =
          _serializers.serialize(maintenanceInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
              specifiedType: const FullType(MeDevicesPost200Response),
            ) as MeDevicesPost200Response;
========
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<MaintenanceResultResponse>(
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
  /// run Reservation Defaults
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// Get the currently authenticated user
========
  /// run Reservation Defaults
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [serviceDayInput] 
=======
  /// * [serviceDayInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runReservationDefaults({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<MeGet200Response>> meGet({
========
  Future<Response<MaintenanceResultResponse>> runReservationDefaults({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ServiceDayInput serviceDayInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/reservation-defaults';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
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

    MeGet200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MeGet200Response),
            ) as MeGet200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<MeGet200Response>(
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

  /// Update the authenticated user&#39;s profile
  ///
  ///
  /// Parameters:
  /// * [mePatchRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MeGet200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<MeGet200Response>> mePatch({
    required MePatchRequest mePatchRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/me';
    final _options = Options(
      method: r'PATCH',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
========
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
          {
>>>>>>> origin/main
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
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
      const _type = FullType(MePatchRequest);
      _bodyData = _serializers.serialize(mePatchRequest, specifiedType: _type);
========
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
              specifiedType: const FullType(MeGet200Response),
            ) as MeGet200Response;
========
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<MaintenanceResultResponse>(
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
  /// run Route Learning
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// List the authenticated user&#39;s active sessions (devices)
========
  /// run Route Learning
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [maintenanceInput] 
=======
  /// * [maintenanceInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runRouteLearning({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<MeSessionsGet200Response>> meSessionsGet({
========
  Future<Response<MaintenanceResultResponse>> runRouteLearning({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/route-learning';
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(MaintenanceInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(maintenanceInput, specifiedType: _type);
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
              specifiedType: const FullType(MeSessionsGet200Response),
            ) as MeSessionsGet200Response;
========
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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

    return Response<MaintenanceResultResponse>(
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
  /// run Trip Generation
  /// 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  /// Revoke one of your sessions (log out that device)
  ///
  ///
  /// Parameters:
  /// * [id]
========
  /// run Trip Generation
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [tripGenerationInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
=======
  /// * [tripGenerationInput]
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MaintenanceResultResponse>> runTripGeneration({ 
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
  Future<Response<void>> meSessionsIdDelete({
    required String id,
========
  Future<Response<MaintenanceResultResponse>> runTripGeneration({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required TripGenerationInput tripGenerationInput,
    String? xTrotxiPlatform,
<<<<<<< HEAD
=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
>>>>>>> origin/main
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/maintenance/trip-generation';
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
    final _path = r'/me/sessions/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
========
    final _path = r'/v1/ops/maintenance/trip-generation';
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
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
            'name': 'workerAuth',
<<<<<<< HEAD
          },{
=======
          },
          {
>>>>>>> origin/main
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
      const _type = FullType(TripGenerationInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(tripGenerationInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(tripGenerationInput, specifiedType: _type);
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

<<<<<<< HEAD
=======
<<<<<<<< HEAD:apps/api_client/lib/src/api/auth_api.dart
    return _response;
========
>>>>>>> origin/main
    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MaintenanceResultResponse),
            ) as MaintenanceResultResponse;
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

    return Response<MaintenanceResultResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
<<<<<<< HEAD
  }

=======
>>>>>>>> origin/main:apps/api_client/lib/src/api/ops_or_scoped_worker_api.dart
  }
>>>>>>> origin/main
}
