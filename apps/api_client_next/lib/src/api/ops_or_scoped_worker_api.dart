//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:trotxi_api_client_next/src/model/error_response.dart';
import 'package:trotxi_api_client_next/src/model/maintenance_input.dart';
import 'package:trotxi_api_client_next/src/model/maintenance_result_response.dart';
import 'package:trotxi_api_client_next/src/model/payment_maintenance_result_response.dart';
import 'package:trotxi_api_client_next/src/model/service_day_input.dart';

class OpsOrScopedWorkerApi {

  final Dio _dio;

  final Serializers _serializers;

  const OpsOrScopedWorkerApi(this._dio, this._serializers);

  /// run Ask Dispatch
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [serviceDayInput] 
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
  Future<Response<MaintenanceResultResponse>> runAskDispatch({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required ServiceDayInput serviceDayInput,
    String? xTrotxiPlatform,
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
          },{
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
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput] 
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
  Future<Response<MaintenanceResultResponse>> runGpsRetention({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
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
          },{
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
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [serviceDayInput] 
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
  Future<Response<MaintenanceResultResponse>> runNoShows({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required ServiceDayInput serviceDayInput,
    String? xTrotxiPlatform,
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
          },{
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
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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

  /// run Payment Inbox
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput] 
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
  Future<Response<MaintenanceResultResponse>> runPaymentInbox({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
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
          },{
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
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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

  /// run Payment Reconciliation
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput] 
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
  Future<Response<MaintenanceResultResponse>> runPaymentReconciliation({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
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
          },{
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
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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

  /// run Payments
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput] 
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PaymentMaintenanceResultResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PaymentMaintenanceResultResponse>> runPayments({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
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
          },{
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
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    PaymentMaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PaymentMaintenanceResultResponse),
      ) as PaymentMaintenanceResultResponse;

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

  /// run Period Close
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput] 
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
  Future<Response<MaintenanceResultResponse>> runPeriodClose({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
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
          },{
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
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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

  /// run Reservation Defaults
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [serviceDayInput] 
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
  Future<Response<MaintenanceResultResponse>> runReservationDefaults({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required ServiceDayInput serviceDayInput,
    String? xTrotxiPlatform,
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
          },{
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
      const _type = FullType(ServiceDayInput);
      _bodyData = _serializers.serialize(serviceDayInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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

  /// run Route Learning
  /// 
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [maintenanceInput] 
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
  Future<Response<MaintenanceResultResponse>> runRouteLearning({ 
    required String xTrotxiClient,
    required int xTrotxiBuild,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
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
          },{
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
      _bodyData = _serializers.serialize(maintenanceInput, specifiedType: _type);

    } catch(error, stackTrace) {
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

    MaintenanceResultResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MaintenanceResultResponse),
      ) as MaintenanceResultResponse;

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

}
