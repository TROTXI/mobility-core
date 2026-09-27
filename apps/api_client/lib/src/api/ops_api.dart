//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:trotxi_api_client/src/api_util.dart';
import 'package:trotxi_api_client/src/model/account_response.dart';
import 'package:trotxi_api_client/src/model/commute_decision.dart';
import 'package:trotxi_api_client/src/model/commute_slot_input.dart';
import 'package:trotxi_api_client/src/model/commute_slot_page.dart';
import 'package:trotxi_api_client/src/model/commute_slot_response.dart';
import 'package:trotxi_api_client/src/model/credential_action.dart';
import 'package:trotxi_api_client/src/model/credential_issue.dart';
import 'package:trotxi_api_client/src/model/credential_secret_response.dart';
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:trotxi_api_client/src/model/decision_event_page.dart';
import 'package:trotxi_api_client/src/model/driver_edit.dart';
import 'package:trotxi_api_client/src/model/driver_input.dart';
import 'package:trotxi_api_client/src/model/driver_page.dart';
import 'package:trotxi_api_client/src/model/driver_response.dart';
import 'package:trotxi_api_client/src/model/error_response.dart';
import 'package:trotxi_api_client/src/model/fare_input.dart';
import 'package:trotxi_api_client/src/model/fare_page.dart';
import 'package:trotxi_api_client/src/model/fare_response.dart';
import 'package:trotxi_api_client/src/model/flag_edit.dart';
import 'package:trotxi_api_client/src/model/flag_page.dart';
import 'package:trotxi_api_client/src/model/flag_response.dart';
import 'package:trotxi_api_client/src/model/incident_decision.dart';
import 'package:trotxi_api_client/src/model/maintenance_input.dart';
import 'package:trotxi_api_client/src/model/maintenance_result_response.dart';
<<<<<<< HEAD
import 'package:trotxi_api_client/src/model/minimum_version_edit.dart';
import 'package:trotxi_api_client/src/model/minimum_version_page.dart';
import 'package:trotxi_api_client/src/model/minimum_version_response.dart';
import 'package:trotxi_api_client/src/model/ops_commute_request_page.dart';
import 'package:trotxi_api_client/src/model/ops_commute_request_response.dart';
import 'package:trotxi_api_client/src/model/ops_incident_page.dart';
import 'package:trotxi_api_client/src/model/ops_incident_response.dart';
import 'package:trotxi_api_client/src/model/ops_overview_response.dart';
import 'package:trotxi_api_client/src/model/ops_purchase_page.dart';
import 'package:trotxi_api_client/src/model/ops_purchase_response.dart';
=======
import 'package:trotxi_api_client/src/model/manifest_response.dart';
import 'package:trotxi_api_client/src/model/minimum_version_edit.dart';
import 'package:trotxi_api_client/src/model/minimum_version_page.dart';
import 'package:trotxi_api_client/src/model/minimum_version_response.dart';
import 'package:trotxi_api_client/src/model/ops_audit_event_page.dart';
import 'package:trotxi_api_client/src/model/ops_commute_request_page.dart';
import 'package:trotxi_api_client/src/model/ops_commute_request_response.dart';
import 'package:trotxi_api_client/src/model/ops_delivery_page.dart';
import 'package:trotxi_api_client/src/model/ops_incident_page.dart';
import 'package:trotxi_api_client/src/model/ops_incident_response.dart';
import 'package:trotxi_api_client/src/model/ops_operator_page.dart';
import 'package:trotxi_api_client/src/model/ops_overview_response.dart';
import 'package:trotxi_api_client/src/model/ops_purchase_page.dart';
import 'package:trotxi_api_client/src/model/ops_purchase_response.dart';
import 'package:trotxi_api_client/src/model/ops_report_summary_response.dart';
import 'package:trotxi_api_client/src/model/ops_rider_detail_response.dart';
import 'package:trotxi_api_client/src/model/ops_rider_page.dart';
import 'package:trotxi_api_client/src/model/ops_rider_summary_response.dart';
>>>>>>> origin/main
import 'package:trotxi_api_client/src/model/ops_trip_page.dart';
import 'package:trotxi_api_client/src/model/ops_trip_response.dart';
import 'package:trotxi_api_client/src/model/ops_work_request_page.dart';
import 'package:trotxi_api_client/src/model/ops_work_request_response.dart';
import 'package:trotxi_api_client/src/model/pattern_input.dart';
import 'package:trotxi_api_client/src/model/pattern_page.dart';
import 'package:trotxi_api_client/src/model/pattern_response.dart';
import 'package:trotxi_api_client/src/model/pattern_version_input.dart';
import 'package:trotxi_api_client/src/model/pattern_version_page.dart';
import 'package:trotxi_api_client/src/model/pattern_version_response.dart';
import 'package:trotxi_api_client/src/model/payment_review_page.dart';
import 'package:trotxi_api_client/src/model/payment_review_response.dart';
<<<<<<< HEAD
=======
import 'package:trotxi_api_client/src/model/pin_reset_input.dart';
>>>>>>> origin/main
import 'package:trotxi_api_client/src/model/plan_pricing_page.dart';
import 'package:trotxi_api_client/src/model/plan_pricing_response.dart';
import 'package:trotxi_api_client/src/model/pricing_edit.dart';
import 'package:trotxi_api_client/src/model/publish_version_input.dart';
import 'package:trotxi_api_client/src/model/reason_input.dart';
import 'package:trotxi_api_client/src/model/refund_initiation_collection_response.dart';
import 'package:trotxi_api_client/src/model/refund_initiation_input.dart';
import 'package:trotxi_api_client/src/model/refund_initiation_response.dart';
import 'package:trotxi_api_client/src/model/restriction_input.dart';
import 'package:trotxi_api_client/src/model/restriction_response.dart';
import 'package:trotxi_api_client/src/model/review_decision.dart';
import 'package:trotxi_api_client/src/model/role_edit.dart';
import 'package:trotxi_api_client/src/model/route_edit.dart';
import 'package:trotxi_api_client/src/model/route_input.dart';
import 'package:trotxi_api_client/src/model/route_page.dart';
import 'package:trotxi_api_client/src/model/route_response.dart';
import 'package:trotxi_api_client/src/model/schedule_input.dart';
import 'package:trotxi_api_client/src/model/schedule_page.dart';
import 'package:trotxi_api_client/src/model/schedule_response.dart';
import 'package:trotxi_api_client/src/model/stop_edit.dart';
import 'package:trotxi_api_client/src/model/stop_input.dart';
import 'package:trotxi_api_client/src/model/stop_page.dart';
import 'package:trotxi_api_client/src/model/stop_response.dart';
import 'package:trotxi_api_client/src/model/trace_hold_input.dart';
import 'package:trotxi_api_client/src/model/trace_hold_page.dart';
import 'package:trotxi_api_client/src/model/trace_hold_response.dart';
import 'package:trotxi_api_client/src/model/trip_assignment.dart';
import 'package:trotxi_api_client/src/model/trip_edit.dart';
import 'package:trotxi_api_client/src/model/trip_input.dart';
import 'package:trotxi_api_client/src/model/vehicle_edit.dart';
import 'package:trotxi_api_client/src/model/vehicle_input.dart';
import 'package:trotxi_api_client/src/model/vehicle_page.dart';
import 'package:trotxi_api_client/src/model/vehicle_response.dart';
import 'package:trotxi_api_client/src/model/work_decision.dart';

class OpsApi {
<<<<<<< HEAD

=======
>>>>>>> origin/main
  final Dio _dio;

  final Serializers _serializers;

  const OpsApi(this._dio, this._serializers);

  /// assign Trip
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
  /// * [tripAssignment] 
=======
  /// * [tripAssignment]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsTripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsTripResponse>> assignTrip({ 
=======
  Future<Response<OpsTripResponse>> assignTrip({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required TripAssignment tripAssignment,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/trips/{id}/assignment'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/trips/{id}/assignment'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PUT',
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
      const _type = FullType(TripAssignment);
      _bodyData = _serializers.serialize(tripAssignment, specifiedType: _type);
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

    OpsTripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsTripResponse),
      ) as OpsTripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsTripResponse),
            ) as OpsTripResponse;
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

    return Response<OpsTripResponse>(
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

  /// cancel Trip
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
  /// * [reasonInput] 
=======
  /// * [reasonInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsTripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsTripResponse>> cancelTrip({ 
=======
  Future<Response<OpsTripResponse>> cancelTrip({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ReasonInput reasonInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/trips/{id}/cancel'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/trips/{id}/cancel'.replaceAll(
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
      const _type = FullType(ReasonInput);
      _bodyData = _serializers.serialize(reasonInput, specifiedType: _type);
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

    OpsTripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsTripResponse),
      ) as OpsTripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsTripResponse),
            ) as OpsTripResponse;
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

    return Response<OpsTripResponse>(
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

  /// change Credential State
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [credentialAction] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [credentialAction]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
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
  Future<Response<void>> changeCredentialState({ 
=======
  Future<Response<void>> changeCredentialState({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required CredentialAction credentialAction,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/drivers/{id}/credentials/actions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/drivers/{id}/credentials/actions'.replaceAll(
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
      const _type = FullType(CredentialAction);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(credentialAction, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(credentialAction, specifiedType: _type);
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

  /// change Role
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
  /// * [roleEdit] 
=======
  /// * [roleEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [AccountResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<AccountResponse>> changeRole({ 
=======
  Future<Response<AccountResponse>> changeRole({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required RoleEdit roleEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/users/{id}/role'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/users/{id}/role'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(RoleEdit);
      _bodyData = _serializers.serialize(roleEdit, specifiedType: _type);
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

    AccountResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(AccountResponse),
      ) as AccountResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(AccountResponse),
            ) as AccountResponse;
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

    return Response<AccountResponse>(
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

  /// create Account Restriction
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [restrictionInput] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [restrictionInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [RestrictionResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<RestrictionResponse>> createAccountRestriction({ 
=======
  Future<Response<RestrictionResponse>> createAccountRestriction({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required RestrictionInput restrictionInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/users/{id}/restrictions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/users/{id}/restrictions'.replaceAll(
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
      const _type = FullType(RestrictionInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(restrictionInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(restrictionInput, specifiedType: _type);
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

    RestrictionResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(RestrictionResponse),
      ) as RestrictionResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(RestrictionResponse),
            ) as RestrictionResponse;
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

    return Response<RestrictionResponse>(
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

  /// create Commute Slot
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
  /// * [commuteSlotInput] 
=======
  /// * [commuteSlotInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [CommuteSlotResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<CommuteSlotResponse>> createCommuteSlot({ 
=======
  Future<Response<CommuteSlotResponse>> createCommuteSlot({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required CommuteSlotInput commuteSlotInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/commute-slots';
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
      const _type = FullType(CommuteSlotInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(commuteSlotInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(commuteSlotInput, specifiedType: _type);
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

    CommuteSlotResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(CommuteSlotResponse),
      ) as CommuteSlotResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(CommuteSlotResponse),
            ) as CommuteSlotResponse;
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

    return Response<CommuteSlotResponse>(
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

  /// create Driver
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
  /// * [driverInput] 
=======
  /// * [driverInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [DriverResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverResponse>> createDriver({ 
=======
  Future<Response<DriverResponse>> createDriver({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required DriverInput driverInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/drivers';
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
      const _type = FullType(DriverInput);
      _bodyData = _serializers.serialize(driverInput, specifiedType: _type);
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

    DriverResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverResponse),
      ) as DriverResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(DriverResponse),
            ) as DriverResponse;
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

    return Response<DriverResponse>(
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

  /// create Fare
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [fareInput] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [fareInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [FareResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<FareResponse>> createFare({ 
=======
  Future<Response<FareResponse>> createFare({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required FareInput fareInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/routes/{id}/fares'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/routes/{id}/fares'.replaceAll(
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
      const _type = FullType(FareInput);
      _bodyData = _serializers.serialize(fareInput, specifiedType: _type);
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

    FareResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(FareResponse),
      ) as FareResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(FareResponse),
            ) as FareResponse;
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

    return Response<FareResponse>(
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

  /// create Pattern
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
  /// * [patternInput] 
=======
  /// * [patternInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PatternResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PatternResponse>> createPattern({ 
=======
  Future<Response<PatternResponse>> createPattern({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required PatternInput patternInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/route-patterns';
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
      const _type = FullType(PatternInput);
      _bodyData = _serializers.serialize(patternInput, specifiedType: _type);
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

    PatternResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PatternResponse),
      ) as PatternResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PatternResponse),
            ) as PatternResponse;
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

    return Response<PatternResponse>(
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

  /// create Pattern Version
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [patternVersionInput] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [patternVersionInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PatternVersionResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PatternVersionResponse>> createPatternVersion({ 
=======
  Future<Response<PatternVersionResponse>> createPatternVersion({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required PatternVersionInput patternVersionInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/route-patterns/{id}/versions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/route-patterns/{id}/versions'.replaceAll(
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
      const _type = FullType(PatternVersionInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(patternVersionInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(patternVersionInput, specifiedType: _type);
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

    PatternVersionResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PatternVersionResponse),
      ) as PatternVersionResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PatternVersionResponse),
            ) as PatternVersionResponse;
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

    return Response<PatternVersionResponse>(
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

  /// create Route
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
  /// * [routeInput] 
=======
  /// * [routeInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [RouteResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<RouteResponse>> createRoute({ 
=======
  Future<Response<RouteResponse>> createRoute({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required RouteInput routeInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/routes';
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
      const _type = FullType(RouteInput);
      _bodyData = _serializers.serialize(routeInput, specifiedType: _type);
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

    RouteResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(RouteResponse),
      ) as RouteResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(RouteResponse),
            ) as RouteResponse;
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

    return Response<RouteResponse>(
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

  /// create Schedule
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
  /// * [scheduleInput] 
=======
  /// * [scheduleInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ScheduleResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<ScheduleResponse>> createSchedule({ 
=======
  Future<Response<ScheduleResponse>> createSchedule({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ScheduleInput scheduleInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/service-schedules';
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
      const _type = FullType(ScheduleInput);
      _bodyData = _serializers.serialize(scheduleInput, specifiedType: _type);
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

    ScheduleResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(ScheduleResponse),
      ) as ScheduleResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ScheduleResponse),
            ) as ScheduleResponse;
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

    return Response<ScheduleResponse>(
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

  /// create Stop
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
  /// * [stopInput] 
=======
  /// * [stopInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [StopResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<StopResponse>> createStop({ 
=======
  Future<Response<StopResponse>> createStop({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required StopInput stopInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/stops';
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
      const _type = FullType(StopInput);
      _bodyData = _serializers.serialize(stopInput, specifiedType: _type);
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

    StopResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(StopResponse),
      ) as StopResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(StopResponse),
            ) as StopResponse;
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

    return Response<StopResponse>(
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

  /// create Trace Hold
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
  /// * [traceHoldInput] 
=======
  /// * [traceHoldInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TraceHoldResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<TraceHoldResponse>> createTraceHold({ 
=======
  Future<Response<TraceHoldResponse>> createTraceHold({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required TraceHoldInput traceHoldInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/trace-holds';
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
      const _type = FullType(TraceHoldInput);
      _bodyData = _serializers.serialize(traceHoldInput, specifiedType: _type);
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

    TraceHoldResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TraceHoldResponse),
      ) as TraceHoldResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TraceHoldResponse),
            ) as TraceHoldResponse;
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

    return Response<TraceHoldResponse>(
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

  /// create Trip
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
  /// * [tripInput] 
=======
  /// * [tripInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsTripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsTripResponse>> createTrip({ 
=======
  Future<Response<OpsTripResponse>> createTrip({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required TripInput tripInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/trips';
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
      const _type = FullType(TripInput);
      _bodyData = _serializers.serialize(tripInput, specifiedType: _type);
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

    OpsTripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsTripResponse),
      ) as OpsTripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsTripResponse),
            ) as OpsTripResponse;
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

    return Response<OpsTripResponse>(
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

  /// create Vehicle
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
  /// * [vehicleInput] 
=======
  /// * [vehicleInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [VehicleResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<VehicleResponse>> createVehicle({ 
=======
  Future<Response<VehicleResponse>> createVehicle({
>>>>>>> origin/main
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required VehicleInput vehicleInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/vehicles';
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
      const _type = FullType(VehicleInput);
      _bodyData = _serializers.serialize(vehicleInput, specifiedType: _type);
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

    VehicleResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(VehicleResponse),
      ) as VehicleResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(VehicleResponse),
            ) as VehicleResponse;
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

    return Response<VehicleResponse>(
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

  /// decide Commute Request
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
  /// * [commuteDecision] 
=======
  /// * [commuteDecision]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsCommuteRequestResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsCommuteRequestResponse>> decideCommuteRequest({ 
=======
  Future<Response<OpsCommuteRequestResponse>> decideCommuteRequest({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required CommuteDecision commuteDecision,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/commute-requests/{id}/decisions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/commute-requests/{id}/decisions'.replaceAll(
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
      const _type = FullType(CommuteDecision);
      _bodyData = _serializers.serialize(commuteDecision, specifiedType: _type);
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

    OpsCommuteRequestResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsCommuteRequestResponse),
      ) as OpsCommuteRequestResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsCommuteRequestResponse),
            ) as OpsCommuteRequestResponse;
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

    return Response<OpsCommuteRequestResponse>(
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

  /// decide Driver Request
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
  /// * [workDecision] 
=======
  /// * [workDecision]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsWorkRequestResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsWorkRequestResponse>> decideDriverRequest({ 
=======
  Future<Response<OpsWorkRequestResponse>> decideDriverRequest({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required WorkDecision workDecision,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/driver-requests/{id}/decisions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/driver-requests/{id}/decisions'.replaceAll(
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
      const _type = FullType(WorkDecision);
      _bodyData = _serializers.serialize(workDecision, specifiedType: _type);
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

    OpsWorkRequestResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsWorkRequestResponse),
      ) as OpsWorkRequestResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsWorkRequestResponse),
            ) as OpsWorkRequestResponse;
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

    return Response<OpsWorkRequestResponse>(
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

  /// decide Incident
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
  /// * [incidentDecision] 
=======
  /// * [incidentDecision]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsIncidentResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsIncidentResponse>> decideIncident({ 
=======
  Future<Response<OpsIncidentResponse>> decideIncident({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required IncidentDecision incidentDecision,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/incidents/{id}/decisions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/incidents/{id}/decisions'.replaceAll(
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
      const _type = FullType(IncidentDecision);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(incidentDecision, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(incidentDecision, specifiedType: _type);
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

    OpsIncidentResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsIncidentResponse),
      ) as OpsIncidentResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsIncidentResponse),
            ) as OpsIncidentResponse;
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

    return Response<OpsIncidentResponse>(
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
  /// get Ops Overview
  /// 
  ///
  /// Parameters:
  /// * [window] - Which service window the board shows. Stated by the caller, never inferred.
=======
  /// get Ops Manifest
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
<<<<<<< HEAD
  /// Returns a [Future] containing a [Response] with a [OpsOverviewResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsOverviewResponse>> getOpsOverview({ 
    required String window,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
=======
  /// Returns a [Future] containing a [Response] with a [ManifestResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ManifestResponse>> getOpsManifest({
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
    final _path = r'/v1/ops/trips/{id}/manifest'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
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
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ManifestResponse),
            ) as ManifestResponse;
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

  /// get Ops Overview
  ///
  ///
  /// Parameters:
  /// * [window] - Which service window the board shows. Stated by the caller, never inferred.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [date] - Service day to show. Defaults to today in Accra; set it to review a past day.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsOverviewResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsOverviewResponse>> getOpsOverview({
    required String window,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    Date? date,
>>>>>>> origin/main
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/overview';
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
      r'window': encodeQueryParameter(_serializers, window, const FullType(String)),
=======
      r'window':
          encodeQueryParameter(_serializers, window, const FullType(String)),
      if (date != null)
        r'date': encodeQueryParameter(_serializers, date, const FullType(Date)),
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

    OpsOverviewResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsOverviewResponse),
      ) as OpsOverviewResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsOverviewResponse),
            ) as OpsOverviewResponse;
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

    return Response<OpsOverviewResponse>(
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

  /// get Ops Pattern Version
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [versionId] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [versionId]
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
  /// Returns a [Future] containing a [Response] with a [PatternVersionResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PatternVersionResponse>> getOpsPatternVersion({ 
=======
  Future<Response<PatternVersionResponse>> getOpsPatternVersion({
>>>>>>> origin/main
    required String id,
    required String versionId,
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
    final _path = r'/v1/ops/route-patterns/{id}/versions/{versionId}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString()).replaceAll('{' r'versionId' '}', encodeQueryParameter(_serializers, versionId, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/route-patterns/{id}/versions/{versionId}'
        .replaceAll(
            '{' r'id' '}',
            encodeQueryParameter(_serializers, id, const FullType(String))
                .toString())
        .replaceAll(
            '{' r'versionId' '}',
            encodeQueryParameter(
                    _serializers, versionId, const FullType(String))
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

    PatternVersionResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PatternVersionResponse),
      ) as PatternVersionResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PatternVersionResponse),
            ) as PatternVersionResponse;
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

    return Response<PatternVersionResponse>(
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

  /// get Ops Purchase
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
  /// Returns a [Future] containing a [Response] with a [OpsPurchaseResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsPurchaseResponse>> getOpsPurchase({ 
=======
  Future<Response<OpsPurchaseResponse>> getOpsPurchase({
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
    final _path = r'/v1/ops/purchases/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/purchases/{id}'.replaceAll(
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

    OpsPurchaseResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsPurchaseResponse),
      ) as OpsPurchaseResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsPurchaseResponse),
            ) as OpsPurchaseResponse;
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

    return Response<OpsPurchaseResponse>(
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
  /// initiate Refund
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [refundInitiationInput] 
=======
  /// get Ops Report Summary
  ///
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [fromDate] - Inclusive reporting day.
  /// * [toDate] - Inclusive reporting day.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsReportSummaryResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsReportSummaryResponse>> getOpsReportSummary({
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    Date? fromDate,
    Date? toDate,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/reports/summary';
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
      if (fromDate != null)
        r'fromDate':
            encodeQueryParameter(_serializers, fromDate, const FullType(Date)),
      if (toDate != null)
        r'toDate':
            encodeQueryParameter(_serializers, toDate, const FullType(Date)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    OpsReportSummaryResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsReportSummaryResponse),
            ) as OpsReportSummaryResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<OpsReportSummaryResponse>(
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

  /// get Ops Rider Detail
  ///
  ///
  /// Parameters:
  /// * [id]
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
  /// Returns a [Future] containing a [Response] with a [OpsRiderDetailResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsRiderDetailResponse>> getOpsRiderDetail({
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
    final _path = r'/v1/ops/riders/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
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

    OpsRiderDetailResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsRiderDetailResponse),
            ) as OpsRiderDetailResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<OpsRiderDetailResponse>(
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

  /// get Ops Rider Summary
  ///
  ///
  /// Parameters:
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
  /// Returns a [Future] containing a [Response] with a [OpsRiderSummaryResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsRiderSummaryResponse>> getOpsRiderSummary({
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
    final _path = r'/v1/ops/riders/summary';
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

    OpsRiderSummaryResponse? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsRiderSummaryResponse),
            ) as OpsRiderSummaryResponse;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<OpsRiderSummaryResponse>(
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

  /// initiate Refund
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [refundInitiationInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [RefundInitiationResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<RefundInitiationResponse>> initiateRefund({ 
=======
  Future<Response<RefundInitiationResponse>> initiateRefund({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required RefundInitiationInput refundInitiationInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/purchases/{id}/refunds'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/purchases/{id}/refunds'.replaceAll(
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
      const _type = FullType(RefundInitiationInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(refundInitiationInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(refundInitiationInput, specifiedType: _type);
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

    RefundInitiationResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(RefundInitiationResponse),
      ) as RefundInitiationResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(RefundInitiationResponse),
            ) as RefundInitiationResponse;
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

    return Response<RefundInitiationResponse>(
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

  /// issue Driver Credential
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [credentialIssue] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [credentialIssue]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [CredentialSecretResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<CredentialSecretResponse>> issueDriverCredential({ 
=======
  Future<Response<CredentialSecretResponse>> issueDriverCredential({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required CredentialIssue credentialIssue,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/drivers/{id}/credentials'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/drivers/{id}/credentials'.replaceAll(
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
      const _type = FullType(CredentialIssue);
      _bodyData = _serializers.serialize(credentialIssue, specifiedType: _type);
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

    CredentialSecretResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(CredentialSecretResponse),
      ) as CredentialSecretResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(CredentialSecretResponse),
            ) as CredentialSecretResponse;
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

    return Response<CredentialSecretResponse>(
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

  /// list Commute Events
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
  /// Returns a [Future] containing a [Response] with a [DecisionEventPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DecisionEventPage>> listCommuteEvents({ 
=======
  Future<Response<DecisionEventPage>> listCommuteEvents({
>>>>>>> origin/main
    required String id,
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
<<<<<<< HEAD
    final _path = r'/v1/ops/commute-requests/{id}/events'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/commute-requests/{id}/events'.replaceAll(
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

    final _queryParameters = <String, dynamic>{
<<<<<<< HEAD
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
=======
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    DecisionEventPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DecisionEventPage),
      ) as DecisionEventPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(DecisionEventPage),
            ) as DecisionEventPage;
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

    return Response<DecisionEventPage>(
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

  /// list Commute Slots
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
  /// * [routeId] - Filter within caller scope; never expands authorization.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [CommuteSlotPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<CommuteSlotPage>> listCommuteSlots({ 
=======
  Future<Response<CommuteSlotPage>> listCommuteSlots({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? routeId,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/commute-slots';
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
      if (routeId != null) r'routeId': encodeQueryParameter(_serializers, routeId, const FullType(String)),
=======
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    CommuteSlotPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(CommuteSlotPage),
      ) as CommuteSlotPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(CommuteSlotPage),
            ) as CommuteSlotPage;
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

    return Response<CommuteSlotPage>(
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

  /// list Fares
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
  /// Returns a [Future] containing a [Response] with a [FarePage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<FarePage>> listFares({ 
=======
  Future<Response<FarePage>> listFares({
>>>>>>> origin/main
    required String id,
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
<<<<<<< HEAD
    final _path = r'/v1/ops/routes/{id}/fares'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/routes/{id}/fares'.replaceAll(
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

    final _queryParameters = <String, dynamic>{
<<<<<<< HEAD
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
=======
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    FarePage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(FarePage),
      ) as FarePage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(FarePage),
            ) as FarePage;
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

    return Response<FarePage>(
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

  /// list Flags
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
  /// Returns a [Future] containing a [Response] with a [FlagPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<FlagPage>> listFlags({ 
=======
  Future<Response<FlagPage>> listFlags({
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
    final _path = r'/v1/ops/flags';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    FlagPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(FlagPage),
      ) as FlagPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(FlagPage),
            ) as FlagPage;
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

    return Response<FlagPage>(
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

  /// list Minimum Versions
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
  /// Returns a [Future] containing a [Response] with a [MinimumVersionPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MinimumVersionPage>> listMinimumVersions({ 
=======
  Future<Response<MinimumVersionPage>> listMinimumVersions({
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
    final _path = r'/v1/ops/min-versions';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    MinimumVersionPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MinimumVersionPage),
      ) as MinimumVersionPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MinimumVersionPage),
            ) as MinimumVersionPage;
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

    return Response<MinimumVersionPage>(
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
  /// list Ops Commute Requests
  /// 
=======
  /// list Ops Audit Events
  ///
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [cursor] - Opaque cursor bound to caller, sort and filters.
  /// * [limit] - Page size. No silent truncation.
  /// * [area] - Audit domain.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsAuditEventPage] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsAuditEventPage>> listOpsAuditEvents({
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? area,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/audit-events';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (area != null)
        r'area':
            encodeQueryParameter(_serializers, area, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    OpsAuditEventPage? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsAuditEventPage),
            ) as OpsAuditEventPage;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<OpsAuditEventPage>(
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

  /// list Ops Commute Requests
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
  /// Returns a [Future] containing a [Response] with a [OpsCommuteRequestPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsCommuteRequestPage>> listOpsCommuteRequests({ 
=======
  Future<Response<OpsCommuteRequestPage>> listOpsCommuteRequests({
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
    final _path = r'/v1/ops/commute-requests';
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

    OpsCommuteRequestPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsCommuteRequestPage),
      ) as OpsCommuteRequestPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsCommuteRequestPage),
            ) as OpsCommuteRequestPage;
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

    return Response<OpsCommuteRequestPage>(
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
  /// list Ops Driver Requests
  /// 
=======
  /// list Ops Deliveries
  ///
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [cursor] - Opaque cursor bound to caller, sort and filters.
  /// * [limit] - Page size. No silent truncation.
  /// * [channel] - Delivery channel.
  /// * [state] - Provider delivery state.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsDeliveryPage] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsDeliveryPage>> listOpsDeliveries({
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? channel,
    String? state,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/deliveries';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (channel != null)
        r'channel':
            encodeQueryParameter(_serializers, channel, const FullType(String)),
      if (state != null)
        r'state':
            encodeQueryParameter(_serializers, state, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    OpsDeliveryPage? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsDeliveryPage),
            ) as OpsDeliveryPage;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<OpsDeliveryPage>(
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

  /// list Ops Driver Requests
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
  /// Returns a [Future] containing a [Response] with a [OpsWorkRequestPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsWorkRequestPage>> listOpsDriverRequests({ 
=======
  Future<Response<OpsWorkRequestPage>> listOpsDriverRequests({
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
    final _path = r'/v1/ops/driver-requests';
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

    OpsWorkRequestPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsWorkRequestPage),
      ) as OpsWorkRequestPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsWorkRequestPage),
            ) as OpsWorkRequestPage;
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

    return Response<OpsWorkRequestPage>(
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

  /// list Ops Drivers
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
  /// Returns a [Future] containing a [Response] with a [DriverPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverPage>> listOpsDrivers({ 
=======
  Future<Response<DriverPage>> listOpsDrivers({
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
    final _path = r'/v1/ops/drivers';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    DriverPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverPage),
      ) as DriverPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(DriverPage),
            ) as DriverPage;
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

    return Response<DriverPage>(
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

  /// list Ops Incidents
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
  /// Returns a [Future] containing a [Response] with a [OpsIncidentPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsIncidentPage>> listOpsIncidents({ 
=======
  Future<Response<OpsIncidentPage>> listOpsIncidents({
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
    final _path = r'/v1/ops/incidents';
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

    OpsIncidentPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsIncidentPage),
      ) as OpsIncidentPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsIncidentPage),
            ) as OpsIncidentPage;
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

    return Response<OpsIncidentPage>(
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
  /// list Ops Purchases
  /// 
=======
  /// list Ops Operators
  ///
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
  /// Returns a [Future] containing a [Response] with a [OpsOperatorPage] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsOperatorPage>> listOpsOperators({
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
    final _path = r'/v1/ops/operators';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    OpsOperatorPage? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsOperatorPage),
            ) as OpsOperatorPage;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<OpsOperatorPage>(
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

  /// list Ops Purchases
  ///
>>>>>>> origin/main
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [cursor] - Opaque cursor bound to caller, sort and filters.
  /// * [limit] - Page size. No silent truncation.
  /// * [fromDate] - Optional inclusive Africa/Accra purchase-creation day. With no date filters, returns all purchase history, including unresolved purchases. No default recency cutoff.
  /// * [toDate] - Optional inclusive purchase-creation day; if both bounds are supplied, toDate must not precede fromDate.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsPurchasePage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsPurchasePage>> listOpsPurchases({ 
=======
  Future<Response<OpsPurchasePage>> listOpsPurchases({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    Date? fromDate,
    Date? toDate,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/purchases';
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
=======
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

    OpsPurchasePage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsPurchasePage),
      ) as OpsPurchasePage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsPurchasePage),
            ) as OpsPurchasePage;
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

    return Response<OpsPurchasePage>(
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
  /// list Ops Routes
  /// 
=======
  /// list Ops Riders
  ///
  ///
  /// Parameters:
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [cursor] - Opaque cursor bound to caller, sort and filters.
  /// * [limit] - Page size. No silent truncation.
  /// * [q] - Name, phone or email, partial.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsRiderPage] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<OpsRiderPage>> listOpsRiders({
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? q,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/riders';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (q != null)
        r'q': encodeQueryParameter(_serializers, q, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    OpsRiderPage? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsRiderPage),
            ) as OpsRiderPage;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<OpsRiderPage>(
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

  /// list Ops Routes
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
  Future<Response<RoutePage>> listOpsRoutes({ 
=======
  Future<Response<RoutePage>> listOpsRoutes({
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
    final _path = r'/v1/ops/routes';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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
              specifiedType: const FullType(RoutePage),
            ) as RoutePage;
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

  /// list Ops Stops
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
  /// Returns a [Future] containing a [Response] with a [StopPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<StopPage>> listOpsStops({ 
=======
  Future<Response<StopPage>> listOpsStops({
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
    final _path = r'/v1/ops/stops';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    StopPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(StopPage),
      ) as StopPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(StopPage),
            ) as StopPage;
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

    return Response<StopPage>(
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

  /// list Ops Trips
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
  /// Returns a [Future] containing a [Response] with a [OpsTripPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsTripPage>> listOpsTrips({ 
=======
  Future<Response<OpsTripPage>> listOpsTrips({
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
    final _path = r'/v1/ops/trips';
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

    OpsTripPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsTripPage),
      ) as OpsTripPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsTripPage),
            ) as OpsTripPage;
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

    return Response<OpsTripPage>(
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

  /// list Ops Vehicles
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
  /// Returns a [Future] containing a [Response] with a [VehiclePage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<VehiclePage>> listOpsVehicles({ 
=======
  Future<Response<VehiclePage>> listOpsVehicles({
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
    final _path = r'/v1/ops/vehicles';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    VehiclePage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(VehiclePage),
      ) as VehiclePage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(VehiclePage),
            ) as VehiclePage;
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

    return Response<VehiclePage>(
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

  /// list Pattern Versions
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
  /// Returns a [Future] containing a [Response] with a [PatternVersionPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PatternVersionPage>> listPatternVersions({ 
=======
  Future<Response<PatternVersionPage>> listPatternVersions({
>>>>>>> origin/main
    required String id,
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
<<<<<<< HEAD
    final _path = r'/v1/ops/route-patterns/{id}/versions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/route-patterns/{id}/versions'.replaceAll(
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

    final _queryParameters = <String, dynamic>{
<<<<<<< HEAD
      if (cursor != null) r'cursor': encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(int)),
=======
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    PatternVersionPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PatternVersionPage),
      ) as PatternVersionPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PatternVersionPage),
            ) as PatternVersionPage;
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

    return Response<PatternVersionPage>(
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

  /// list Patterns
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
  /// Returns a [Future] containing a [Response] with a [PatternPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PatternPage>> listPatterns({ 
=======
  Future<Response<PatternPage>> listPatterns({
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
    final _path = r'/v1/ops/route-patterns';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    PatternPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PatternPage),
      ) as PatternPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PatternPage),
            ) as PatternPage;
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

    return Response<PatternPage>(
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

  /// list Payment Reviews
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
  /// Returns a [Future] containing a [Response] with a [PaymentReviewPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PaymentReviewPage>> listPaymentReviews({ 
=======
  Future<Response<PaymentReviewPage>> listPaymentReviews({
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
    final _path = r'/v1/ops/payments/reviews';
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

    PaymentReviewPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PaymentReviewPage),
      ) as PaymentReviewPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PaymentReviewPage),
            ) as PaymentReviewPage;
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

    return Response<PaymentReviewPage>(
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

  /// list Plan Pricing
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
  /// Returns a [Future] containing a [Response] with a [PlanPricingPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PlanPricingPage>> listPlanPricing({ 
=======
  Future<Response<PlanPricingPage>> listPlanPricing({
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
    final _path = r'/v1/ops/plan-pricing';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    PlanPricingPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlanPricingPage),
      ) as PlanPricingPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PlanPricingPage),
            ) as PlanPricingPage;
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

    return Response<PlanPricingPage>(
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

  /// list Refund Initiations
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
  /// Returns a [Future] containing a [Response] with a [RefundInitiationCollectionResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<RefundInitiationCollectionResponse>> listRefundInitiations({ 
=======
  Future<Response<RefundInitiationCollectionResponse>> listRefundInitiations({
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
    final _path = r'/v1/ops/purchases/{id}/refunds'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/purchases/{id}/refunds'.replaceAll(
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

    RefundInitiationCollectionResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(RefundInitiationCollectionResponse),
      ) as RefundInitiationCollectionResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(RefundInitiationCollectionResponse),
            ) as RefundInitiationCollectionResponse;
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

    return Response<RefundInitiationCollectionResponse>(
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

  /// list Schedules
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
  /// * [routeId] - Filter within caller scope; never expands authorization.
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SchedulePage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<SchedulePage>> listSchedules({ 
=======
  Future<Response<SchedulePage>> listSchedules({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? cursor,
    int? limit = 50,
    String? routeId,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/service-schedules';
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
      if (routeId != null) r'routeId': encodeQueryParameter(_serializers, routeId, const FullType(String)),
=======
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    SchedulePage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(SchedulePage),
      ) as SchedulePage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(SchedulePage),
            ) as SchedulePage;
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

    return Response<SchedulePage>(
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

  /// list Trace Holds
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
  /// Returns a [Future] containing a [Response] with a [TraceHoldPage] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<TraceHoldPage>> listTraceHolds({ 
=======
  Future<Response<TraceHoldPage>> listTraceHolds({
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
    final _path = r'/v1/ops/trace-holds';
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
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
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

    TraceHoldPage? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TraceHoldPage),
      ) as TraceHoldPage;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TraceHoldPage),
            ) as TraceHoldPage;
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

    return Response<TraceHoldPage>(
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

  /// publish Pattern Version
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [versionId] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [versionId]
>>>>>>> origin/main
  /// * [ifMatch] - Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [publishVersionInput] 
=======
  /// * [publishVersionInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PatternVersionResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PatternVersionResponse>> publishPatternVersion({ 
=======
  Future<Response<PatternVersionResponse>> publishPatternVersion({
>>>>>>> origin/main
    required String id,
    required String versionId,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required PublishVersionInput publishVersionInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/route-patterns/{id}/versions/{versionId}/publish'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString()).replaceAll('{' r'versionId' '}', encodeQueryParameter(_serializers, versionId, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/route-patterns/{id}/versions/{versionId}/publish'
        .replaceAll(
            '{' r'id' '}',
            encodeQueryParameter(_serializers, id, const FullType(String))
                .toString())
        .replaceAll(
            '{' r'versionId' '}',
            encodeQueryParameter(
                    _serializers, versionId, const FullType(String))
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
      const _type = FullType(PublishVersionInput);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(publishVersionInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(publishVersionInput, specifiedType: _type);
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

    PatternVersionResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PatternVersionResponse),
      ) as PatternVersionResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PatternVersionResponse),
            ) as PatternVersionResponse;
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

    return Response<PatternVersionResponse>(
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

  /// release Account Restriction
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [restrictionId] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [restrictionId]
>>>>>>> origin/main
  /// * [ifMatch] - Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [reasonInput] 
=======
  /// * [reasonInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [RestrictionResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<RestrictionResponse>> releaseAccountRestriction({ 
=======
  Future<Response<RestrictionResponse>> releaseAccountRestriction({
>>>>>>> origin/main
    required String id,
    required String restrictionId,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ReasonInput reasonInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/users/{id}/restrictions/{restrictionId}/release'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString()).replaceAll('{' r'restrictionId' '}', encodeQueryParameter(_serializers, restrictionId, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/users/{id}/restrictions/{restrictionId}/release'
        .replaceAll(
            '{' r'id' '}',
            encodeQueryParameter(_serializers, id, const FullType(String))
                .toString())
        .replaceAll(
            '{' r'restrictionId' '}',
            encodeQueryParameter(
                    _serializers, restrictionId, const FullType(String))
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
      const _type = FullType(ReasonInput);
      _bodyData = _serializers.serialize(reasonInput, specifiedType: _type);
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

    RestrictionResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(RestrictionResponse),
      ) as RestrictionResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(RestrictionResponse),
            ) as RestrictionResponse;
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

    return Response<RestrictionResponse>(
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

  /// release Trace Hold
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
  /// * [reasonInput] 
=======
  /// * [reasonInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [TraceHoldResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<TraceHoldResponse>> releaseTraceHold({ 
=======
  Future<Response<TraceHoldResponse>> releaseTraceHold({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ReasonInput reasonInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/trace-holds/{id}/release'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/trace-holds/{id}/release'.replaceAll(
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
      const _type = FullType(ReasonInput);
      _bodyData = _serializers.serialize(reasonInput, specifiedType: _type);
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

    TraceHoldResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(TraceHoldResponse),
      ) as TraceHoldResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(TraceHoldResponse),
            ) as TraceHoldResponse;
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

    return Response<TraceHoldResponse>(
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

  /// reschedule Trip
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
  /// * [tripEdit] 
=======
  /// * [tripEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [OpsTripResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<OpsTripResponse>> rescheduleTrip({ 
=======
  Future<Response<OpsTripResponse>> rescheduleTrip({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required TripEdit tripEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/trips/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/trips/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(TripEdit);
      _bodyData = _serializers.serialize(tripEdit, specifiedType: _type);
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

    OpsTripResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(OpsTripResponse),
      ) as OpsTripResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(OpsTripResponse),
            ) as OpsTripResponse;
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

    return Response<OpsTripResponse>(
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

  /// reset Driver Pin
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [id] 
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [reasonInput] 
=======
  ///
  ///
  /// Parameters:
  /// * [id]
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
  /// * [pinResetInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [CredentialSecretResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<CredentialSecretResponse>> resetDriverPin({ 
=======
  Future<Response<CredentialSecretResponse>> resetDriverPin({
>>>>>>> origin/main
    required String id,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
<<<<<<< HEAD
    required ReasonInput reasonInput,
=======
    required PinResetInput pinResetInput,
>>>>>>> origin/main
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/drivers/{id}/credentials/reset-pin'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/drivers/{id}/credentials/reset-pin'.replaceAll(
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
<<<<<<< HEAD
      const _type = FullType(ReasonInput);
      _bodyData = _serializers.serialize(reasonInput, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      const _type = FullType(PinResetInput);
      _bodyData = _serializers.serialize(pinResetInput, specifiedType: _type);
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

    CredentialSecretResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(CredentialSecretResponse),
      ) as CredentialSecretResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(CredentialSecretResponse),
            ) as CredentialSecretResponse;
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

    return Response<CredentialSecretResponse>(
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
  /// resolve Payment Review
  /// 
  ///
  /// Parameters:
  /// * [id] 
=======
  /// reset Operator Passkeys
  ///
  ///
  /// Parameters:
  /// * [id]
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
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> resetOperatorPasskeys({
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
    final _path = r'/v1/ops/users/{id}/passkeys/reset'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
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
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

  /// resolve Payment Review
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
  /// * [reviewDecision] 
=======
  /// * [reviewDecision]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PaymentReviewResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PaymentReviewResponse>> resolvePaymentReview({ 
=======
  Future<Response<PaymentReviewResponse>> resolvePaymentReview({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ReviewDecision reviewDecision,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/payments/reviews/{id}/decisions'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/payments/reviews/{id}/decisions'.replaceAll(
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
      const _type = FullType(ReviewDecision);
      _bodyData = _serializers.serialize(reviewDecision, specifiedType: _type);
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

    PaymentReviewResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PaymentReviewResponse),
      ) as PaymentReviewResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PaymentReviewResponse),
            ) as PaymentReviewResponse;
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

    return Response<PaymentReviewResponse>(
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

  /// retire Commute Slot
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
  /// * [reasonInput] 
=======
  /// * [reasonInput]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [CommuteSlotResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<CommuteSlotResponse>> retireCommuteSlot({ 
=======
  Future<Response<CommuteSlotResponse>> retireCommuteSlot({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required ReasonInput reasonInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/commute-slots/{id}/retire'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/commute-slots/{id}/retire'.replaceAll(
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
      const _type = FullType(ReasonInput);
      _bodyData = _serializers.serialize(reasonInput, specifiedType: _type);
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

    CommuteSlotResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(CommuteSlotResponse),
      ) as CommuteSlotResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(CommuteSlotResponse),
            ) as CommuteSlotResponse;
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

    return Response<CommuteSlotResponse>(
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

  /// run Personal Pause Resumes
<<<<<<< HEAD
  /// 
=======
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
  Future<Response<MaintenanceResultResponse>> runPersonalPauseResumes({ 
=======
  Future<Response<MaintenanceResultResponse>> runPersonalPauseResumes({
>>>>>>> origin/main
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MaintenanceInput maintenanceInput,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/ops/maintenance/personal-pause-resumes';
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

  /// set Flag
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [key] 
=======
  ///
  ///
  /// Parameters:
  /// * [key]
>>>>>>> origin/main
  /// * [ifMatch] - Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [flagEdit] 
=======
  /// * [flagEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [FlagResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<FlagResponse>> setFlag({ 
=======
  Future<Response<FlagResponse>> setFlag({
>>>>>>> origin/main
    required String key,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required FlagEdit flagEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/flags/{key}'.replaceAll('{' r'key' '}', encodeQueryParameter(_serializers, key, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/flags/{key}'.replaceAll(
        '{' r'key' '}',
        encodeQueryParameter(_serializers, key, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PUT',
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
      const _type = FullType(FlagEdit);
      _bodyData = _serializers.serialize(flagEdit, specifiedType: _type);
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

    FlagResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(FlagResponse),
      ) as FlagResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(FlagResponse),
            ) as FlagResponse;
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

    return Response<FlagResponse>(
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

  /// set Minimum Version
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [app] 
  /// * [platform] 
=======
  ///
  ///
  /// Parameters:
  /// * [app]
  /// * [platform]
>>>>>>> origin/main
  /// * [ifMatch] - Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [minimumVersionEdit] 
=======
  /// * [minimumVersionEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [MinimumVersionResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<MinimumVersionResponse>> setMinimumVersion({ 
=======
  Future<Response<MinimumVersionResponse>> setMinimumVersion({
>>>>>>> origin/main
    required String app,
    required String platform,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required MinimumVersionEdit minimumVersionEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/min-versions/{app}/{platform}'.replaceAll('{' r'app' '}', encodeQueryParameter(_serializers, app, const FullType(String)).toString()).replaceAll('{' r'platform' '}', encodeQueryParameter(_serializers, platform, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/min-versions/{app}/{platform}'
        .replaceAll(
            '{' r'app' '}',
            encodeQueryParameter(_serializers, app, const FullType(String))
                .toString())
        .replaceAll(
            '{' r'platform' '}',
            encodeQueryParameter(_serializers, platform, const FullType(String))
                .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PUT',
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
      const _type = FullType(MinimumVersionEdit);
<<<<<<< HEAD
      _bodyData = _serializers.serialize(minimumVersionEdit, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
=======
      _bodyData =
          _serializers.serialize(minimumVersionEdit, specifiedType: _type);
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

    MinimumVersionResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(MinimumVersionResponse),
      ) as MinimumVersionResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(MinimumVersionResponse),
            ) as MinimumVersionResponse;
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

    return Response<MinimumVersionResponse>(
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

  /// update Driver
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
  /// * [driverEdit] 
=======
  /// * [driverEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [DriverResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<DriverResponse>> updateDriver({ 
=======
  Future<Response<DriverResponse>> updateDriver({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required DriverEdit driverEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/drivers/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/drivers/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(DriverEdit);
      _bodyData = _serializers.serialize(driverEdit, specifiedType: _type);
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

    DriverResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(DriverResponse),
      ) as DriverResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(DriverResponse),
            ) as DriverResponse;
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

    return Response<DriverResponse>(
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

  /// update Plan Pricing
<<<<<<< HEAD
  /// 
  ///
  /// Parameters:
  /// * [plan] 
=======
  ///
  ///
  /// Parameters:
  /// * [plan]
>>>>>>> origin/main
  /// * [ifMatch] - Missing = 428; stale = 412. Completed idempotent replay is checked first after authorization.
  /// * [idempotencyKey] - Caller + operation + target scoped; payload mismatch = 409. Never log secrets.
  /// * [xTrotxiClient] - Compatibility metadata only, never grants a role.
  /// * [xTrotxiBuild] - Unsupported build: 426. Missing metadata: 400. Bootstrap remains reachable.
<<<<<<< HEAD
  /// * [pricingEdit] 
=======
  /// * [pricingEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PlanPricingResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<PlanPricingResponse>> updatePlanPricing({ 
=======
  Future<Response<PlanPricingResponse>> updatePlanPricing({
>>>>>>> origin/main
    required String plan,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required PricingEdit pricingEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/plan-pricing/{plan}'.replaceAll('{' r'plan' '}', encodeQueryParameter(_serializers, plan, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/plan-pricing/{plan}'.replaceAll(
        '{' r'plan' '}',
        encodeQueryParameter(_serializers, plan, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(PricingEdit);
      _bodyData = _serializers.serialize(pricingEdit, specifiedType: _type);
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

    PlanPricingResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(PlanPricingResponse),
      ) as PlanPricingResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PlanPricingResponse),
            ) as PlanPricingResponse;
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

    return Response<PlanPricingResponse>(
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

  /// update Route
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
  /// * [routeEdit] 
=======
  /// * [routeEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [RouteResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<RouteResponse>> updateRoute({ 
=======
  Future<Response<RouteResponse>> updateRoute({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required RouteEdit routeEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/routes/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/routes/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(RouteEdit);
      _bodyData = _serializers.serialize(routeEdit, specifiedType: _type);
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

    RouteResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(RouteResponse),
      ) as RouteResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(RouteResponse),
            ) as RouteResponse;
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

    return Response<RouteResponse>(
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

  /// update Stop
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
  /// * [stopEdit] 
=======
  /// * [stopEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [StopResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<StopResponse>> updateStop({ 
=======
  Future<Response<StopResponse>> updateStop({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required StopEdit stopEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/stops/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/stops/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(StopEdit);
      _bodyData = _serializers.serialize(stopEdit, specifiedType: _type);
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

    StopResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(StopResponse),
      ) as StopResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(StopResponse),
            ) as StopResponse;
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

    return Response<StopResponse>(
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

  /// update Vehicle
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
  /// * [vehicleEdit] 
=======
  /// * [vehicleEdit]
>>>>>>> origin/main
  /// * [xTrotxiPlatform] - Required for commuter/driver, absent for ops/worker.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [VehicleResponse] as data
  /// Throws [DioException] if API call or serialization fails
<<<<<<< HEAD
  Future<Response<VehicleResponse>> updateVehicle({ 
=======
  Future<Response<VehicleResponse>> updateVehicle({
>>>>>>> origin/main
    required String id,
    required String ifMatch,
    required String idempotencyKey,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    required VehicleEdit vehicleEdit,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
<<<<<<< HEAD
    final _path = r'/v1/ops/vehicles/{id}'.replaceAll('{' r'id' '}', encodeQueryParameter(_serializers, id, const FullType(String)).toString());
=======
    final _path = r'/v1/ops/vehicles/{id}'.replaceAll(
        '{' r'id' '}',
        encodeQueryParameter(_serializers, id, const FullType(String))
            .toString());
>>>>>>> origin/main
    final _options = Options(
      method: r'PATCH',
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
      const _type = FullType(VehicleEdit);
      _bodyData = _serializers.serialize(vehicleEdit, specifiedType: _type);
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

    VehicleResponse? _responseData;

    try {
      final rawResponse = _response.data;
<<<<<<< HEAD
      _responseData = rawResponse == null ? null : _serializers.deserialize(
        rawResponse,
        specifiedType: const FullType(VehicleResponse),
      ) as VehicleResponse;

=======
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(VehicleResponse),
            ) as VehicleResponse;
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

    return Response<VehicleResponse>(
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
