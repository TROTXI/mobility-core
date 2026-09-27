import 'package:flutter/foundation.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Where the driver is on the way to their runs.
enum SessionStage {
  /// Reading the stored token. A disk hit, so this is measured in milliseconds.
  restoring,

  /// Secure storage could not be read; do not guess an identity or erase it.
  storageFailed,

  /// No session. Show sign-in.
  signedOut,

  /// Signed in, waiting for the driver to confirm the account is theirs.
  confirming,

  /// Signed in with a temporary PIN from operations. The server refuses all
  /// assigned work until the driver chooses a private PIN here.
  pinSetup,

  /// Identity confirmed; acknowledge that this device is now linked.
  linked,

  /// Device linked; review trip permissions without starting any tracking.
  readiness,

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
  SessionController({required this._auth});

  final DriverAuthRepository _auth;

  SessionStage _stage = SessionStage.restoring;
  DriverSession? _session;
  String? _temporaryPin;
  String? _notice;

  SessionStage get stage => _stage;
  DriverSession? get session => _session;

  /// The temporary PIN just typed at sign-in, held in memory only so the setup
  /// screen need not ask for it twice. Never written to storage; dropped as
  /// soon as the driver leaves setup. Null after a restored session.
  String? get temporaryPin => _temporaryPin;

  /// One line for the sign-in screen after the session ended on purpose, such
  /// as a successful PIN change. Cleared by the next sign-in.
  String? get notice => _notice;

  bool _busy = false;
  int _revision = 0;
  bool _disposed = false;

  /// True while a sign-out is in flight, so the button cannot be tapped twice
  /// on a depot connection that takes its time.
  bool get isBusy => _busy;

  /// The session was taken away underneath us (#235).
  ///
  /// Called when the token store is cleared, which the client does only after a
  /// refresh has actually failed — a proven 401, not a reachability check. That
  /// distinction is the point: a driver in a yard with no signal must still
  /// reach their screen, so this fires on evidence rather than on suspicion.
  ///
  /// Before this, a revoked session (an operations PIN reset does exactly that)
  /// left the app in the shell with the header showing "Driver", every call
  /// failing quietly, and nothing telling the driver to sign in again.
  void onSessionRevoked() {
    _revision++;
    if (_stage == SessionStage.signedOut) return;
    _session = null;
    _temporaryPin = null;
    _set(SessionStage.signedOut);
  }

  /// Decide the opening screen from what is stored on the device.
  ///
  /// Asks only whether a token EXISTS, never whether it still works. A driver
  /// starting a shift in a yard with no signal should reach their screen and
  /// see stale data rather than be held on a spinner by a reachability check.
  /// A revoked session surfaces when the first real call answers 401.
  Future<void> restore() async {
    final revision = ++_revision;
    late final bool signedIn;
    try {
      signedIn = await _auth.hasStoredSession();
    } catch (_) {
      if (revision == _revision) _set(SessionStage.storageFailed);
      return;
    }
    if (revision != _revision) return;
    _set(signedIn ? SessionStage.ready : SessionStage.signedOut);
    if (!signedIn) return;

    // Fill in WHO, after opening the app rather than before. The stage is
    // already decided, so this cannot hold a driver on a splash screen; it just
    // means the profile knows their name a moment later instead of calling them
    // "Driver" for the rest of the shift.
    try {
      final driver = await _auth.currentDriver();
      if (revision == _revision && driver != null) {
        _session = driver;
        // The server refuses work to a temporary PIN whatever this app does;
        // going to setup is how a reopened app stays useful, not the guard.
        if (driver.mustChangePin == true) {
          _set(SessionStage.pinSetup);
        } else {
          notifyListeners();
        }
      }
    } on TrotxiException {
      // Offline/5xx do not revoke a session; only the store's conditional
      // clear callback does. A 426 is displayed by the root update gate.
    } catch (_) {
      if (revision == _revision) _set(SessionStage.storageFailed);
    }
  }

  /// Sign-in succeeded. The driver confirms the account before going further,
  /// because depot handsets get passed around and a code one character off
  /// should be caught here rather than at the roadside.
  ///
  /// @param session - the session just issued.
  void onSignedIn(DriverSession session) {
    _revision++;
    _session = session;
    _notice = null;
    if (session.mustChangePin != true) _temporaryPin = null;
    _set(SessionStage.confirming);
  }

  /// Keep the temporary PIN for the setup screen. Called by sign-in only when
  /// the server said this PIN must be changed.
  void holdTemporaryPin(String pin) {
    _temporaryPin = pin;
  }

  /// The driver confirmed the account is theirs. A temporary PIN from
  /// operations goes to PIN setup first; the server requires it either way.
  void confirm() {
    _set(
      _session?.mustChangePin == true
          ? SessionStage.pinSetup
          : SessionStage.linked,
    );
  }

  /// The new PIN is set. The server signs out every session when a PIN
  /// changes, this one included, so the app clears its copy and asks the
  /// driver to sign in with the PIN they just chose.
  Future<void> onPinChanged() =>
      _endSetup('PIN changed. Sign in with your driver code and your new PIN.');

  /// A change may have gone through without the answer arriving, and the
  /// session was then refused: the driver cannot know which PIN works now.
  Future<void> onPinChangeUncertain() => _endSetup(
    'Your session ended before the PIN change was confirmed. Try your new PIN '
    'first; if it is refused, sign in with your temporary PIN.',
  );

  Future<void> _endSetup(String notice) async {
    _revision++;
    _temporaryPin = null;
    try {
      await _auth.signOut();
    } catch (_) {
      // The server has already revoked the session; a local clear that failed
      // still leaves nothing usable behind, and the next request says so.
    }
    _session = null;
    _notice = notice;
    _set(SessionStage.signedOut);
    notifyListeners();
  }

  /// Finish the link acknowledgement and review device readiness.
  void completeLinking() {
    _set(SessionStage.readiness);
  }

  /// Finish the non-blocking readiness review and open assigned work.
  /// Location is enforced again at the actual trip-start boundary.
  void completeReadiness() {
    _set(SessionStage.ready);
  }

  /// Discard the session, whether from "Not my account", an explicit sign-out,
  /// or a token the server has stopped honouring.
  ///
  /// Clears locally whatever the server says: a depot with no signal is exactly
  /// when someone hands the phone to the next driver.
  Future<void> signOut() async {
    if (_busy) return;
    final previous = _session;
    _revision++;
    _busy = true;
    notifyListeners();
    var cleared = false;
    try {
      await _auth.signOut();
      cleared = true;
    } catch (_) {
      throw const ApiException(
        0,
        'Could not remove the saved session from this device. Please try signing out again.',
      );
    } finally {
      _busy = false;
      if (cleared && (_session == previous || _session == null)) {
        _session = null;
        _temporaryPin = null;
        _set(SessionStage.signedOut);
      }
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

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    super.dispose();
  }
}
