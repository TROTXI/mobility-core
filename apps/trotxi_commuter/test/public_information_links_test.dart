import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/public_information.dart';
import 'package:trotxi_commuter/core/widgets/public_information_links.dart';

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
    await tester.tap(find.text('Terms and Conditions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy notice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Request account deletion'));
    await tester.pumpAndSettle();
    expect(opened, [
      TrotxiPublicInformation.terms,
      TrotxiPublicInformation.privacy,
      TrotxiPublicInformation.deletion,
    ]);
  });

  testWidgets('browser exceptions leave Terms readable as a copyable URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PublicInformationLinks(
            open: (_) async => throw Exception('No browser'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Terms and Conditions'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.text(TrotxiPublicInformation.terms.toString()), findsOneWidget);
  });

  testWidgets(
    'legal links have labelled 48-pixel targets at large text sizes',
    (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const Scaffold(
              body: SingleChildScrollView(child: PublicInformationLinks()),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        find.bySemanticsLabel('Terms and Conditions, opens in browser'),
        findsOneWidget,
      );
      for (final button in find.byType(TextButton).evaluate()) {
        expect(
          tester.getSize(find.byWidget(button.widget)).height,
          greaterThanOrEqualTo(48),
        );
      }
    },
  );

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
