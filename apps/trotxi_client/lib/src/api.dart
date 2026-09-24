import 'package:trotxi_api_client/trotxi_api_client.dart';

/// The API groups the generator emitted after `TrotxiApiClient` was last
/// generated, reached the same way as the built-in ones.
///
/// These live here rather than in `api_client/lib/src/api.dart` because that
/// file carries an AUTO-GENERATED header: anything added to it is lost the
/// next time the client is regenerated from the OpenAPI spec. An extension in
/// this package survives regeneration, and call sites read identically —
/// `client.getPublicApi()` resolves through it as long as the caller imports
/// `package:trotxi_client/trotxi_client.dart`, which every app already does.
///
/// Each group takes the client's own `dio` and `serializers`, so calls made
/// through them still pass the auth and error interceptors the factory
/// installed.
///
/// `this.serializers` is qualified deliberately. The generated client also
/// exports a top-level `serializers`, and that one is built *without* the
/// `StandardJsonPlugin` — an unqualified `serializers` here binds to it, and
/// every response then fails to deserialize with "type '_Map<String, dynamic>'
/// is not a subtype of type 'Iterable<Object?>'". The client's own field is
/// `standardSerializers`, which has the plugin.
extension TrotxiApiClientGroups on TrotxiApiClient {
  DriverAssignedOrOwnApi getDriverAssignedOrOwnApi() =>
      DriverAssignedOrOwnApi(dio, this.serializers);

  DriverOwnApi getDriverOwnApi() => DriverOwnApi(dio, this.serializers);

  LiveEligibleApi getLiveEligibleApi() => LiveEligibleApi(dio, this.serializers);

  OpsApi getOpsApi() => OpsApi(dio, this.serializers);

  OpsOrScopedWorkerApi getOpsOrScopedWorkerApi() =>
      OpsOrScopedWorkerApi(dio, this.serializers);

  ProviderSignatureApi getProviderSignatureApi() =>
      ProviderSignatureApi(dio, this.serializers);

  PublicApi getPublicApi() => PublicApi(dio, this.serializers);

  RiderOwnApi getRiderOwnApi() => RiderOwnApi(dio, this.serializers);

  SelfApi getSelfApi() => SelfApi(dio, this.serializers);

  SignedInCatalogApi getSignedInCatalogApi() =>
      SignedInCatalogApi(dio, this.serializers);
}
