// Session restore (#41). A restored session proves a token exists; it carries
// no name, and the profile screen needs one.

import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

class _StubAuth implements DriverAuthRepository {
  _StubAuth({this.stored = true, this.driver});

  bool stored;
  DriverSession? driver;
  int currentDriverCalls = 0;
  int signOutCalls = 0;

  @override
  Future<bool> hasStoredSession() async => stored;

  @override
  Future<DriverSession?> currentDriver() async {
    currentDriverCalls++;
    return driver;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    stored = false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a stored token opens the app and then fills in who it belongs to', () async {
    // Order matters: the stage is decided first so a slow depot connection
    // cannot hold a driver on a splash screen.
    final auth = _StubAuth(
      driver: const DriverSession(
        driverId: 'u1',
        fullName: 'Kwame Boateng',
        mustChangePin: false,
      ),
    );
    final controller = SessionController(auth: auth);

    await controller.restore();

    expect(controller.stage, SessionStage.ready);
    expect(controller.session?.fullName, 'Kwame Boateng');
  });

  test('no stored token means sign-in, and asks nobody who they are', () async {
    final auth = _StubAuth(stored: false);
    final controller = SessionController(auth: auth);

    await controller.restore();

    expect(controller.stage, SessionStage.signedOut);
    expect(auth.currentDriverCalls, 0);
  });

  test('a token the server no longer honours still opens the app', () async {
    // The stage stays ready and the first real call surfaces the 401. Blocking
    // here would strand a driver in a yard with no signal.
    final auth = _StubAuth(driver: null);
    final controller = SessionController(auth: auth);

    await controller.restore();

    expect(controller.stage, SessionStage.ready);
    expect(controller.session, isNull);
  });

  test('signing out clears the session and reports busy while it runs', () async {
    final auth = _StubAuth(
      driver: const DriverSession(driverId: 'u1', fullName: 'Kwame', mustChangePin: false),
    );
    final controller = SessionController(auth: auth);
    await controller.restore();

    final pending = controller.signOut();
    expect(controller.isBusy, isTrue);
    await pending;

    expect(controller.isBusy, isFalse);
    expect(controller.session, isNull);
    expect(controller.stage, SessionStage.signedOut);
  });

  test('a forced PIN change is only asked for when the sign-in says so', () async {
    final controller = SessionController(auth: _StubAuth());

    controller.onSignedIn(
      const DriverSession(driverId: 'd1', fullName: 'Kwame', mustChangePin: true),
    );
    expect(controller.stage, SessionStage.confirming);
    controller.confirm();
    expect(controller.stage, SessionStage.mustChangePin);

    controller.onPinChanged();
    expect(controller.stage, SessionStage.ready);
  });

  test('a session revoked server-side returns the app to sign-in (#235)', () async {
    // An operations PIN reset revokes sessions. Before this the app stayed in
    // the shell, the header fell back to "Driver", every call failed quietly,
    // and nothing told the driver to sign in again.
    final controller = SessionController(
      auth: _StubAuth(
        driver: const DriverSession(
          driverId: 'd1',
          fullName: 'Kofi Anum Quartey',
          mustChangePin: false,
        ),
      ),
    );
    await controller.restore();
    expect(controller.stage, SessionStage.ready);
    expect(controller.session, isNotNull);

    controller.onSessionRevoked();

    expect(controller.stage, SessionStage.signedOut);
    expect(controller.session, isNull);
  });

  test('a revocation while already signed out changes nothing', () async {
    // Signing out clears tokens too, so the same callback arrives on the
    // ordinary path. It has to be a no-op there rather than a second rebuild.
    final controller = SessionController(auth: _StubAuth(stored: false));
    await controller.restore();
    expect(controller.stage, SessionStage.signedOut);

    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.onSessionRevoked();

    expect(notifications, 0);
  });
}
