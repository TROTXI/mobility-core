//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:trotxi_api_client/src/date_serializer.dart';
import 'package:trotxi_api_client/src/model/date.dart';

import 'package:trotxi_api_client/src/model/auth_google_post200_response.dart';
import 'package:trotxi_api_client/src/model/auth_google_post_request.dart';
import 'package:trotxi_api_client/src/model/auth_refresh_post200_response.dart';
import 'package:trotxi_api_client/src/model/auth_refresh_post_request.dart';
import 'package:trotxi_api_client/src/model/get200_response.dart';
import 'package:trotxi_api_client/src/model/healthz_get200_response.dart';
import 'package:trotxi_api_client/src/model/me_balance_get200_response.dart';
import 'package:trotxi_api_client/src/model/me_get200_response.dart';
import 'package:trotxi_api_client/src/model/me_get401_response.dart';
import 'package:trotxi_api_client/src/model/payments_subscribe_post200_response.dart';
import 'package:trotxi_api_client/src/model/payments_subscribe_post_request.dart';
import 'package:trotxi_api_client/src/model/payments_topup_post_request.dart';
import 'package:trotxi_api_client/src/model/readyz_get200_response.dart';
import 'package:trotxi_api_client/src/model/readyz_get503_response.dart';
import 'package:trotxi_api_client/src/model/version_get200_response.dart';
import 'package:trotxi_api_client/src/model/webhooks_paystack_post200_response.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthGooglePost200Response,
  AuthGooglePostRequest,
  AuthRefreshPost200Response,
  AuthRefreshPostRequest,
  Get200Response,
  HealthzGet200Response,
  MeBalanceGet200Response,
  MeGet200Response,
  MeGet401Response,
  PaymentsSubscribePost200Response,
  PaymentsSubscribePostRequest,
  PaymentsTopupPostRequest,
  ReadyzGet200Response,
  ReadyzGet503Response,
  VersionGet200Response,
  WebhooksPaystackPost200Response,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
