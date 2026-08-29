import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/main.dart';

/// In-memory implementation of [TokenStore] for widget testing.
class FakeTokenStore implements TokenStore {
  String? _accessToken;
  String? _refreshToken;

  FakeTokenStore({this._accessToken, this._refreshToken});

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

void main() {
  late TrotxiApiClient client;

  setUp(() {
    client = TrotxiClientFactory.create(
      baseUrl: 'https://api.trotxi.com',
      tokenStore: FakeTokenStore(),
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(TrotxiCommuterApp(client: client));
  }

  group('TrotxiCommuterApp Initialization Tests', () {
    testWidgets('App renders without crashing', (WidgetTester tester) async {
      await pumpApp(tester);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Theme uses Material3', (WidgetTester tester) async {
      await pumpApp(tester);

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });
  });
}
