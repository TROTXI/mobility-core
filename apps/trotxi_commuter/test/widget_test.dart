import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/main.dart';

class FakeTokenStore implements TokenStore {
  String? _refreshToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _refreshToken = null;
  }
}

void main() {
  late TrotxiApiClient client;

  setUp(() {
    client = TrotxiClientFactory.create(
      baseUrl: 'https://string.com',
      tokenStore: FakeTokenStore(),
    );
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(TrotxiCommuterApp(client: client));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Theme uses Material3', (WidgetTester tester) async {
    await tester.pumpWidget(TrotxiCommuterApp(client: client));
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });
}
