import 'package:flutter/material.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/change_pin_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/confirm_account_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/sign_in_page.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Which screen the app is on before a driver reaches their runs.
enum _Stage { checking, signIn, confirm, changePin, ready }

/// Decides what the app opens on: sign in, or straight to today's runs.
///
/// Only asks whether a token is STORED, never whether it still works. A driver
/// starting a shift in a yard with no signal should reach their screen and see
/// stale data, not be held on a spinner by a reachability check. A revoked
/// session surfaces when the first real call answers 401, which the client
/// already handles.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth, required this.home});

  final DriverAuthRepository auth;

  /// What to show once the driver is through. Takes a sign-out callback so the
  /// profile screen can hand control back here.
  final Widget Function(BuildContext context, VoidCallback signOut) home;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  _Stage _stage = _Stage.checking;
  DriverSession? _session;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final signedIn = await widget.auth.hasStoredSession();
    if (!mounted) return;
    setState(() => _stage = signedIn ? _Stage.ready : _Stage.signIn);
  }

  void _onSignedIn(DriverSession session) {
    setState(() {
      _session = session;
      _stage = _Stage.confirm;
    });
  }

  void _onConfirmed() {
    // A driver still on the PIN operations read out at the depot has to replace
    // it before they can do anything else.
    setState(() {
      _stage = (_session?.mustChangePin ?? false) ? _Stage.changePin : _Stage.ready;
    });
  }

  void _backToSignIn() {
    setState(() {
      _session = null;
      _stage = _Stage.signIn;
    });
  }

  Future<void> _signOut() async {
    await widget.auth.signOut();
    if (!mounted) return;
    _backToSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.checking => const _Splash(),
      _Stage.signIn => SignInPage(auth: widget.auth, onSignedIn: _onSignedIn),
      _Stage.confirm => ConfirmAccountPage(
        session: _session!,
        auth: widget.auth,
        onConfirmed: _onConfirmed,
        onRejected: _backToSignIn,
      ),
      _Stage.changePin => ChangePinPage(
        auth: widget.auth,
        isForced: true,
        onChanged: () => setState(() => _stage = _Stage.ready),
      ),
      _Stage.ready => widget.home(context, _signOut),
    };
  }
}

/// Shown only while the stored token is read, which is a disk hit rather than a
/// network one, so this is measured in milliseconds.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trotxi Driver',
              style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space16),
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
