// Session restore (#41). A restored session proves a token exists; it carries
// no name, and the profile screen needs one.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

class _StubAuth implements DriverAuthRepository {
  _StubAuth({this.stored = true, this.driver});

  bool stored;
  DriverSession? driver;
  int currentDriverCalls = 0;
  int signOutCalls = 0;
  Future<DriverSession?>? pendingDriver;
  Future<void>? pendingLogout;
  Object? storageError;
  Object? identityError;
  Object? logoutError;

  @override
  Future<bool> hasStoredSession() async {
    if (storageError != null) throw storageError!;
    return stored;
  }

  @override
  Future<DriverSession?> currentDriver() async {
    currentDriverCalls++;
    if (identityError != null) throw identityError!;
    return pendingDriver == null ? driver : await pendingDriver;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (logoutError != null) throw logoutError!;
    stored = false;
    await pendingLogout;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'failed secure-storage clearing does not pretend sign-out succeeded',
    () async {
      final auth = _StubAuth()..logoutError = StateError('Storage unavailable');
      final controller = SessionController(auth: auth);
      await controller.restore();
      await expectLater(controller.signOut(), throwsA(isA<ApiException>()));
      expect(controller.stage, SessionStage.ready);
      expect(controller.isBusy, isFalse);
    },
  );
  const newer = DriverSession(
    driverId: 'new',
    fullName: 'New driver',
    mustChangePin: false,
  );
  test('late identity hydration cannot overwrite a new sign-in', () async {
    final delayed = Completer<DriverSession?>();
    final auth = _StubAuth()..pendingDriver = delayed.future;
    final controller = SessionController(auth: auth);
    final restoring = controller.restore();
    await Future<void>.delayed(Duration.zero);
    controller.onSignedIn(newer);
    delayed.complete(
      const DriverSession(
        driverId: 'old',
        fullName: 'Old driver',
        mustChangePin: false,
      ),
    );
    await restoring;
    expect(controller.session, newer);
    expect(controller.stage, SessionStage.confirming);
  });

  test(
    'offline identity hydration leaves a stored session available',
    () async {
      final auth = _StubAuth()..identityError = const OfflineException();
      final controller = SessionController(auth: auth);
      await controller.restore();
      expect(controller.stage, SessionStage.ready);
      expect(auth.signOutCalls, 0);
    },
  );

  test(
    'unreadable storage fails visibly and can be retried without erasure',
    () async {
      final auth = _StubAuth(stored: false)
        ..storageError = const FormatException('Invalid');
      final controller = SessionController(auth: auth);
      await controller.restore();
      expect(controller.stage, SessionStage.storageFailed);
      expect(auth.signOutCalls, 0);
      auth.storageError = null;
      await controller.restore();
      expect(controller.stage, SessionStage.signedOut);
    },
  );

  test('late logout completion cannot dismiss a newer sign-in', () async {
    final delayed = Completer<void>();
    final auth = _StubAuth()..pendingLogout = delayed.future;
    final controller = SessionController(auth: auth);
    final logout = controller.signOut();
    controller.onSignedIn(newer);
    delayed.complete();
    await logout;
    expect(controller.session, newer);
    expect(controller.stage, SessionStage.confirming);
    expect(controller.isBusy, isFalse);
  });
  test(
    'a stored token opens the app and then fills in who it belongs to',
    () async {
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
    },
  );

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

  test(
    'signing out clears the session and reports busy while it runs',
    () async {
      final auth = _StubAuth(
        driver: const DriverSession(
          driverId: 'u1',
          fullName: 'Kwame',
          mustChangePin: false,
        ),
      );
      final controller = SessionController(auth: auth);
      await controller.restore();

      final pending = controller.signOut();
      expect(controller.isBusy, isTrue);
      await pending;

      expect(controller.isBusy, isFalse);
      expect(controller.session, isNull);
      expect(controller.stage, SessionStage.signedOut);
    },
  );

  for (final operatorIssued in [true, false]) {
    test(
      'account confirmation acknowledges linking before opening the app, operator-issued=$operatorIssued',
      () {
        final controller = SessionController(auth: _StubAuth());
        controller.onSignedIn(
          DriverSession(
            driverId: 'd1',
            fullName: 'Kwame',
            mustChangePin: operatorIssued,
          ),
        );
        expect(controller.stage, SessionStage.confirming);
        controller.confirm();
        expect(controller.stage, SessionStage.linked);
        controller.completeLinking();
        expect(controller.stage, SessionStage.readiness);
        controller.completeReadiness();
        expect(controller.stage, SessionStage.ready);
        expect(controller.session?.fullName, 'Kwame');
      },
    );
  }

  test(
    'a session revoked server-side returns the app to sign-in (#235)',
    () async {
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
    },
  );

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
