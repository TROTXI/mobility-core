import 'package:test/test.dart';
import 'package:trotxi_api_client_next/trotxi_api_client_next.dart';


/// tests for PublicApi
void main() {
  final instance = TrotxiApiClientNext().getPublicApi();

  group(PublicApi, () {
    // get Bootstrap
    //
    //Future<Bootstrap> getBootstrap() async
    test('test getBootstrap', () async {
      // TODO
    });

    // get Build
    //
    //Future<Build> getBuild() async
    test('test getBuild', () async {
      // TODO
    });

    // get Geometry
    //
    //Future<GeometryResponse> getGeometry(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getGeometry', () async {
      // TODO
    });

    // get Health
    //
    //Future<Health> getHealth() async
    test('test getHealth', () async {
      // TODO
    });

    // get Pattern
    //
    //Future<PatternResponse> getPattern(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getPattern', () async {
      // TODO
    });

    // get Pattern Version
    //
    //Future<PatternVersionResponse> getPatternVersion(String id, String versionId, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getPatternVersion', () async {
      // TODO
    });

    // get Readiness
    //
    //Future<Health> getReadiness() async
    test('test getReadiness', () async {
      // TODO
    });

    // get Root
    //
    //Future<Root> getRoot() async
    test('test getRoot', () async {
      // TODO
    });

    // get Route
    //
    //Future<RouteResponse> getRoute(String id, String xTrotxiClient, int xTrotxiBuild, { String xTrotxiPlatform }) async
    test('test getRoute', () async {
      // TODO
    });

    // list Route Schedules
    //
    //Future<SchedulePage> listRouteSchedules(String id, String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String routeId, String xTrotxiPlatform }) async
    test('test listRouteSchedules', () async {
      // TODO
    });

    // list Routes
    //
    //Future<RoutePage> listRoutes(String xTrotxiClient, int xTrotxiBuild, { String cursor, int limit, String xTrotxiPlatform }) async
    test('test listRoutes', () async {
      // TODO
    });

    // logout Session
    //
    //Future logoutSession(String xTrotxiClient, int xTrotxiBuild, RefreshInput refreshInput, { String xTrotxiPlatform }) async
    test('test logoutSession', () async {
      // TODO
    });

    // refresh Session
    //
    //Future<TokensResponse> refreshSession(String xTrotxiClient, int xTrotxiBuild, RefreshInput refreshInput, { String xTrotxiPlatform }) async
    test('test refreshSession', () async {
      // TODO
    });

    // sign In Apple
    //
    //Future<TokensResponse> signInApple(String xTrotxiClient, int xTrotxiBuild, AppleSignIn appleSignIn, { String xTrotxiPlatform }) async
    test('test signInApple', () async {
      // TODO
    });

    // sign In Driver
    //
    //Future<DriverTokensResponse> signInDriver(String xTrotxiClient, int xTrotxiBuild, DriverSignIn driverSignIn, { String xTrotxiPlatform }) async
    test('test signInDriver', () async {
      // TODO
    });

    // sign In Google
    //
    //Future<TokensResponse> signInGoogle(String xTrotxiClient, int xTrotxiBuild, GoogleSignIn googleSignIn, { String xTrotxiPlatform }) async
    test('test signInGoogle', () async {
      // TODO
    });

  });
}
