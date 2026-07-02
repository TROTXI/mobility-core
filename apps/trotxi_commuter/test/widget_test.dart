import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/authentication_client.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/main.dart';

void main() {
  late TrotxiApiClient client;
  late AuthenticationClient authClient;

  setUp(() {
    (client: client, authClient: authClient) = TrotxiClientFactory.create(
      baseUrl: 'https://string.com',
    );
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      TrotxiCommuterApp(client: client, authClient: authClient),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Theme uses Material3', (WidgetTester tester) async {
    await tester.pumpWidget(
      TrotxiCommuterApp(client: client, authClient: authClient),
    );
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });
}