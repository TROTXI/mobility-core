import 'package:flutter/foundation.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Where the driver is on the way to their runs.
enum SessionStage {
  /// Reading the stored token. A disk hit, so this is measured in milliseconds.
  restoring,

  /// No session. Show sign-in.
  signedOut,

  /// Signed in, waiting for the driver to confirm the account is theirs.
  confirming,

  /// Signed in, but still on the PIN operations issued.
  mustChangePin,

  /// Through. Show the app.
  ready,
}

/// The signed-in session, as app state rather than screen state.
///
/// The first controller under ADR-0016. Session is the clearest case for one:
/// sign-in sets it, the profile screen clears it, and an expired token will
/// clear it from a network callback with no widget involved. Held in a
/// `StatefulWidget` it would belong to whichever screen happened to be mounted.
///
/// Holds no `BuildContext`, so it is testable as a plain Dart object.
class SessionController extends ChangeNotifier {
  SessionController({required DriverAuthRepository auth}) : _auth = auth;

  final DriverAuthRepository _auth;

  SessionStage _stage = SessionStage.restoring;
  DriverSession? _session;

  SessionStage get stage => _stage;
  DriverSession? get session => _session;

  bool _busy = false;

  /// True while a sign-out is in flight, so the button cannot be tapped twice
  /// on a depot connection that takes its time.
  bool get isBusy => _busy;

  /// Decide the opening screen from what is stored on the device.
  ///
  /// Asks only whether a token EXISTS, never whether it still works. A driver
  /// starting a shift in a yard with no signal should reach their screen and
  /// see stale data rather than be held on a spinner by a reachability check.
  /// A revoked session surfaces when the first real call answers 401.
  Future<void> restore() async {
    final signedIn = await _auth.hasStoredSession();
    _set(signedIn ? SessionStage.ready : SessionStage.signedOut);
    if (!signedIn) return;

    // Fill in WHO, after opening the app rather than before. The stage is
    // already decided, so this cannot hold a driver on a splash screen; it just
    // means the profile knows their name a moment later instead of calling them
    // "Driver" for the rest of the shift.
    final driver = await _auth.currentDriver();
    if (driver != null) {
      _session = driver;
      notifyListeners();
    }
  }

  /// Sign-in succeeded. The driver confirms the account before going further,
  /// because depot handsets get passed around and a code one character off
  /// should be caught here rather than at the roadside.
  ///
  /// @param session - the session just issued.
  void onSignedIn(DriverSession session) {
    _session = session;
    _set(SessionStage.confirming);
  }

  /// The driver confirmed the account is theirs.
  void confirm() {
    _set(
      (_session?.mustChangePin ?? false) ? SessionStage.mustChangePin : SessionStage.ready,
    );
  }

  /// The forced PIN change is done.
  void onPinChanged() => _set(SessionStage.ready);

  /// Discard the session, whether from "Not my account", an explicit sign-out,
  /// or a token the server has stopped honouring.
  ///
  /// Clears locally whatever the server says: a depot with no signal is exactly
  /// when someone hands the phone to the next driver.
  Future<void> signOut() async {
    _busy = true;
    notifyListeners();
    try {
      await _auth.signOut();
    } finally {
      _busy = false;
      _session = null;
      _set(SessionStage.signedOut);
      // _set only notifies on a stage CHANGE, and signing out from the
      // signed-out stage is a no-op there, so the busy flag needs its own.
      notifyListeners();
    }
  }

  /// Move to a stage, notifying only on a real change so a rebuild is never
  /// scheduled for nothing.
  ///
  /// @param stage - the stage to move to.
  void _set(SessionStage stage) {
    if (_stage == stage) return;
    _stage = stage;
    notifyListeners();
  }
}
