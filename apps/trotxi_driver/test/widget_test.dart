import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/authentication_client.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/main.dart';

void main() {
  late TrotxiApiClient client;
  late AuthenticationClient authClient;

  setUp(() {
    final (client: c, authClient: a) = TrotxiClientFactory.create(
      baseUrl: 'https://string.com',
    );
    client = c;
    authClient = a;
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      TrotxiDriverApp(client: client, authClient: authClient),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Theme uses Material3', (WidgetTester tester) async {
    await tester.pumpWidget(
      TrotxiDriverApp(client: client, authClient: authClient),
    );
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });
}