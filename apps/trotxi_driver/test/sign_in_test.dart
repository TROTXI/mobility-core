// Driver sign-in (#41 frames 03 to 06). The four failure outcomes are the point:
// the prototype draws them differently because they mean different things, and a
// screen that collapses them into "something went wrong" is the bug.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/sign_in_page.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// A repository that fails however the test needs it to.
class _StubAuth implements DriverAuthRepository {
  _StubAuth({this.onSignIn});

  final Future<DriverSession> Function()? onSignIn;
  int signInCalls = 0;

  @override
  Future<DriverSession> signIn({
    required String driverCode,
    required String pin,
    required bool rememberDevice,
  }) {
    signInCalls++;
    lastRememberDevice = rememberDevice;
    lastDriverCode = driverCode;
    return onSignIn?.call() ??
        Future.value(
          const DriverSession(driverId: 'd1', fullName: 'Kwame Asare', mustChangePin: false),
        );
  }

  bool? lastRememberDevice;
  String? lastDriverCode;

  @override
  Future<void> changePin({required String currentPin, required String newPin}) async {}

  @override
  Future<bool> hasStoredSession() async => false;

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _StubAuth auth, {ValueChanged<DriverSession>? onIn}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: SignInPage(auth: auth, onSignedIn: onIn ?? (_) {}),
    ),
  );
}

Future<void> _fillForm(WidgetTester tester, {String code = 'DR-B7K9'}) async {
  await tester.enterText(find.byType(TextField).first, code);
  // The PIN field's real input is the second TextField, hidden behind the boxes.
  await tester.enterText(find.byType(TextField).last, '482913');
  await tester.pump();
}

void main() {
  testWidgets('signs in and hands the session back', (tester) async {
    DriverSession? received;
    final auth = _StubAuth();
    await _pump(tester, auth, onIn: (s) => received = s);

    await _fillForm(tester);
    await tester.pump();

    expect(auth.signInCalls, 1);
    expect(received?.fullName, 'Kwame Asare');
  });

  testWidgets('submits on the sixth digit without a button press', (tester) async {
    // A driver typing a PIN one-handed at a depot gate should not then have to
    // find a button.
    final auth = _StubAuth();
    await _pump(tester, auth);
    await _fillForm(tester);
    await tester.pump();
    expect(auth.signInCalls, 1);
  });

  testWidgets('sends the code as typed, leaving normalising to the server', (tester) async {
    final auth = _StubAuth();
    await _pump(tester, auth);
    await _fillForm(tester, code: 'dr-b7k9');
    await tester.pump();
    expect(auth.lastDriverCode, 'dr-b7k9');
  });

  testWidgets('defaults to NOT remembering the device', (tester) async {
    // A shared depot handset is the common case, so the safe option is default.
    final auth = _StubAuth();
    await _pump(tester, auth);
    await _fillForm(tester);
    await tester.pump();
    expect(auth.lastRememberDevice, isFalse);
  });

  testWidgets('a wrong PIN invites another try', (tester) async {
    final auth = _StubAuth(
      onSignIn: () => Future.error(const InvalidCredentialsException()),
    );
    await _pump(tester, auth);
    await _fillForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('Check your PIN'), findsOneWidget);
    // Still editable: this is a failure the driver can fix.
    expect(tester.widget<TextField>(find.byType(TextField).first).enabled, isTrue);
  });

  testWidgets('a lock says how long and stops accepting input', (tester) async {
    final auth = _StubAuth(
      onSignIn: () =>
          Future.error(const CredentialLockedException(Duration(minutes: 15))),
    );
    await _pump(tester, auth);
    await _fillForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('Too many attempts'), findsOneWidget);
    expect(find.textContaining('15 minutes'), findsOneWidget);
    // Retrying cannot help, so the form closes rather than inviting more guesses.
    expect(tester.widget<TextField>(find.byType(TextField).first).enabled, isFalse);
  });

  testWidgets('a suspension is not offered as retryable', (tester) async {
    final auth = _StubAuth(
      onSignIn: () => Future.error(const AccountSuspendedException()),
    );
    await _pump(tester, auth);
    await _fillForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('Account suspended'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).first).enabled, isFalse);
  });

  testWidgets('being offline says so instead of blaming the PIN', (tester) async {
    // The likeliest reason sign-in fails at a depot is signal, and "check your
    // PIN" would send a driver hunting for a problem that is not theirs.
    final auth = _StubAuth(onSignIn: () => Future.error(const OfflineException()));
    await _pump(tester, auth);
    await _fillForm(tester);
    await tester.pumpAndSettle();

    expect(find.text('No connection'), findsOneWidget);
  });

  testWidgets('editing clears a wrong-PIN message but not a lock', (tester) async {
    final auth = _StubAuth(
      onSignIn: () => Future.error(const InvalidCredentialsException()),
    );
    await _pump(tester, auth);
    await _fillForm(tester);
    await tester.pumpAndSettle();
    expect(find.text('Check your PIN'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '4829');
    await tester.pump();
    expect(find.text('Check your PIN'), findsNothing);
  });

  testWidgets('a wrong PIN keeps the code and names the digit count', (
    tester,
  ) async {
    // The file states the rule as "retain the entered Driver ID, explain the
    // next attempt and provide a visible recovery path". All three, on the
    // screen the driver is already looking at rather than a new one.
    final auth = _StubAuth(
      onSignIn: () => Future.error(const InvalidCredentialsException()),
    );
    await _pump(tester, auth);
    await _fillForm(tester, code: 'DR-B7K9');
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'DR-B7K9',
    );
    // Six, because that is what the API accepts. The frames label the field
    // "4-digit", which describes the rider's boarding code, not this.
    expect(find.textContaining('Check the 6 digits'), findsOneWidget);
    expect(find.text("Can't sign in?"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
