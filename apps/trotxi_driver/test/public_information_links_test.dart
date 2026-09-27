import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:trotxi_driver/core/widgets/public_information_links.dart';

void main() {
  testWidgets('public links open the correct pages without authentication', (
    tester,
  ) async {
    final opened = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PublicInformationLinks(
            open: (uri) async {
              opened.add(uri);
              return true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Privacy notice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request account deletion'));
    await tester.pumpAndSettle();
    expect(opened, [
      TrotxiPublicInformation.privacy,
      TrotxiPublicInformation.deletion,
    ]);
  });

  testWidgets('failed browser launch leaves a copyable page address', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PublicInformationLinks(open: (_) async => false)),
      ),
    );
    await tester.tap(find.text('Request account deletion'));
    await tester.pumpAndSettle();
    expect(find.text('Open in your browser'), findsOneWidget);
    expect(
      find.text(TrotxiPublicInformation.deletion.toString()),
      findsOneWidget,
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
