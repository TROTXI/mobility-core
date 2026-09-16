//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:trotxi_api_client/src/serializers.dart';
import 'package:trotxi_api_client/src/auth/api_key_auth.dart';
import 'package:trotxi_api_client/src/auth/basic_auth.dart';
import 'package:trotxi_api_client/src/auth/bearer_auth.dart';
import 'package:trotxi_api_client/src/auth/oauth.dart';
import 'package:trotxi_api_client/src/api/driver_assigned_or_own_api.dart';
import 'package:trotxi_api_client/src/api/driver_own_api.dart';
import 'package:trotxi_api_client/src/api/live_eligible_api.dart';
import 'package:trotxi_api_client/src/api/ops_api.dart';
import 'package:trotxi_api_client/src/api/ops_or_scoped_worker_api.dart';
import 'package:trotxi_api_client/src/api/provider_signature_api.dart';
import 'package:trotxi_api_client/src/api/public_api.dart';
import 'package:trotxi_api_client/src/api/rider_own_api.dart';
import 'package:trotxi_api_client/src/api/self_api.dart';
import 'package:trotxi_api_client/src/api/signed_in_catalog_api.dart';

class TrotxiApiClient {
  static const String basePath = r'https://api.example.invalid';

  final Dio dio;
  final Serializers serializers;

  TrotxiApiClient({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens.remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens.remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo.remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys.remove(name);
    }
  }

  /// Get DriverAssignedOrOwnApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DriverAssignedOrOwnApi getDriverAssignedOrOwnApi() {
    return DriverAssignedOrOwnApi(dio, serializers);
  }

  /// Get DriverOwnApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DriverOwnApi getDriverOwnApi() {
    return DriverOwnApi(dio, serializers);
  }

  /// Get LiveEligibleApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  LiveEligibleApi getLiveEligibleApi() {
    return LiveEligibleApi(dio, serializers);
  }

  /// Get OpsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  OpsApi getOpsApi() {
    return OpsApi(dio, serializers);
  }

  /// Get OpsOrScopedWorkerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  OpsOrScopedWorkerApi getOpsOrScopedWorkerApi() {
    return OpsOrScopedWorkerApi(dio, serializers);
  }

  /// Get ProviderSignatureApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ProviderSignatureApi getProviderSignatureApi() {
    return ProviderSignatureApi(dio, serializers);
  }

  /// Get PublicApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PublicApi getPublicApi() {
    return PublicApi(dio, serializers);
  }

  /// Get RiderOwnApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RiderOwnApi getRiderOwnApi() {
    return RiderOwnApi(dio, serializers);
  }

  /// Get SelfApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SelfApi getSelfApi() {
    return SelfApi(dio, serializers);
  }

  /// Get SignedInCatalogApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SignedInCatalogApi getSignedInCatalogApi() {
    return SignedInCatalogApi(dio, serializers);
  }
}
