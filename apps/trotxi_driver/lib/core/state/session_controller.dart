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

  /// Decide the opening screen from what is stored on the device.
  ///
  /// Asks only whether a token EXISTS, never whether it still works. A driver
  /// starting a shift in a yard with no signal should reach their screen and
  /// see stale data rather than be held on a spinner by a reachability check.
  /// A revoked session surfaces when the first real call answers 401.
  Future<void> restore() async {
    final signedIn = await _auth.hasStoredSession();
    _set(signedIn ? SessionStage.ready : SessionStage.signedOut);
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
    await _auth.signOut();
    _session = null;
    _set(SessionStage.signedOut);
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
