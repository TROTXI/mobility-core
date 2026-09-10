// SessionController (ADR-0016). A plain Dart object, so no widget is pumped:
// that testability is most of the reason session state left the widget tree.

import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

class _StubAuth implements DriverAuthRepository {
  _StubAuth({this.stored = false});

  bool stored;
  int signOutCalls = 0;

  @override
  Future<bool> hasStoredSession() async => stored;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    stored = false;
  }

  @override
  Future<DriverSession> signIn({
    required String driverCode,
    required String pin,
    required bool rememberDevice,
  }) async => const DriverSession(driverId: 'd1', fullName: 'Kwame', mustChangePin: false);

  @override
  Future<void> changePin({required String currentPin, required String newPin}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _fresh = DriverSession(driverId: 'd1', fullName: 'Kwame Asare', mustChangePin: true);
const _settled = DriverSession(driverId: 'd1', fullName: 'Kwame Asare', mustChangePin: false);

void main() {
  test('starts by restoring, not by assuming signed out', () {
    // Opening on the sign-in screen and then swapping it out would flash a
    // log-in form at a driver who is already signed in.
    final controller = SessionController(auth: _StubAuth());
    expect(controller.stage, SessionStage.restoring);
  });

  test('a stored token opens the app', () async {
    final controller = SessionController(auth: _StubAuth(stored: true));
    await controller.restore();
    expect(controller.stage, SessionStage.ready);
  });

  test('no stored token opens sign-in', () async {
    final controller = SessionController(auth: _StubAuth());
    await controller.restore();
    expect(controller.stage, SessionStage.signedOut);
  });

  test('sign-in asks the driver to confirm the account first', () {
    final controller = SessionController(auth: _StubAuth());
    controller.onSignedIn(_settled);
    expect(controller.stage, SessionStage.confirming);
    expect(controller.session?.fullName, 'Kwame Asare');
  });

  test('confirming forces a PIN change when the PIN is still the issued one', () {
    final controller = SessionController(auth: _StubAuth());
    controller.onSignedIn(_fresh);
    controller.confirm();
    expect(controller.stage, SessionStage.mustChangePin);

    controller.onPinChanged();
    expect(controller.stage, SessionStage.ready);
  });

  test('confirming goes straight through on a PIN the driver already chose', () {
    final controller = SessionController(auth: _StubAuth());
    controller.onSignedIn(_settled);
    controller.confirm();
    expect(controller.stage, SessionStage.ready);
  });

  test('signing out clears the session and returns to sign-in', () async {
    final auth = _StubAuth(stored: true);
    final controller = SessionController(auth: auth);
    controller.onSignedIn(_settled);

    await controller.signOut();

    expect(auth.signOutCalls, 1);
    expect(controller.session, isNull);
    expect(controller.stage, SessionStage.signedOut);
  });

  test('does not notify when the stage has not actually changed', () async {
    // Every spurious notify is a rebuild of the whole app shell.
    final controller = SessionController(auth: _StubAuth());
    await controller.restore();

    var notifications = 0;
    controller.addListener(() => notifications++);
    await controller.restore();
    expect(notifications, 0);

    controller.onSignedIn(_settled);
    expect(notifications, 1);
  });
}
