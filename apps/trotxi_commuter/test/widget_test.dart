import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TrotxiCommuterApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Theme uses Material3', (WidgetTester tester) async {
    await tester.pumpWidget(const TrotxiCommuterApp());
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
  });
}
