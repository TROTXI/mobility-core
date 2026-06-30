import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/main.dart';

void main() {
  late TrotxiApiClient client;

  setUp(() {
    client = TrotxiClientFactory.create(baseUrl: 'https://string.com');
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