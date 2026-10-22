import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/terms.dart';
import 'package:trotxi_client/trotxi_client.dart' show ApiException, Date;

TermsCheck check({required bool required, Date? accepted, Date? current}) =>
    TermsCheck(
      currentVersion: current ?? Date(2026, 10, 22),
      acceptedVersion: accepted,
      acceptanceRequired: required,
    );

Widget gate({
  required Future<TermsCheck> Function() load,
  Future<TermsCheck> Function(Date)? accept,
  Future<void> Function()? onSignOut,
}) =>
    MaterialApp(
      home: TermsGate(
        load: load,
        accept: accept ?? (_) async => check(required: false),
        termsName: 'Driver Terms',
        onReadTerms: (_) async {},
        onSignOut: onSignOut,
        child: const Scaffold(body: Text('Home')),
      ),
    );

void main() {
  testWidgets('a user who accepted the current version goes straight in',
      (tester) async {
    await tester.pumpWidget(gate(
      load: () async => check(required: false, accepted: Date(2026, 10, 22)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Accept and continue'), findsNothing);
  });

  testWidgets('a first acceptance blocks the app until agreed and saved',
      (tester) async {
    Date? accepted;
    await tester.pumpWidget(gate(
      load: () async => check(required: true),
      accept: (version) async {
        accepted = version;
        return check(required: false, accepted: version);
      },
    ));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing);
    expect(find.text('Accept the Driver Terms'), findsOneWidget);
    expect(find.text('Version 2026-10-22'), findsOneWidget);
    final button = find.widgetWithText(FilledButton, 'Accept and continue');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(accepted, Date(2026, 10, 22));
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a new version is presented as an update', (tester) async {
    await tester.pumpWidget(gate(
      load: () async => check(required: true, accepted: Date(2026, 1, 1)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('We have updated the Driver Terms'), findsOneWidget);
  });

  testWidgets('an unreachable server never locks the user out', (tester) async {
    await tester.pumpWidget(gate(
      load: () async => throw const ApiException(0, 'offline'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a version published while reading is fetched and shown',
      (tester) async {
    var loads = 0;
    await tester.pumpWidget(gate(
      load: () async {
        loads++;
        return check(
          required: true,
          current: loads == 1 ? Date(2026, 10, 22) : Date(2026, 11, 1),
        );
      },
      accept: (_) async => throw const ApiException(
        409,
        'outdated',
        code: 'terms_version_outdated',
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Accept and continue'));
    await tester.pumpAndSettle();
    expect(find.text('Version 2026-11-01'), findsOneWidget);
    expect(find.textContaining('were just updated'), findsOneWidget);
    // The new text has to be agreed to again.
    expect(
      tester
          .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Accept and continue'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a user who does not accept can sign out', (tester) async {
    var signedOut = false;
    await tester.pumpWidget(gate(
      load: () async => check(required: true),
      onSignOut: () async => signedOut = true,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    expect(signedOut, isTrue);
  });
}
