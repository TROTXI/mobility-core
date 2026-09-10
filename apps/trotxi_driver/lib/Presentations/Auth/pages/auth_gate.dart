import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/change_pin_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/confirm_account_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/sign_in_page.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Renders whichever screen the session is currently on.
///
/// The stage machine moved to [SessionController] under ADR-0016; this is now
/// only the mapping from stage to screen. Sign-out reaches the controller from
/// anywhere, so a profile screen does not need a callback threaded down to it.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.home});

  /// What to show once the driver is through.
  final WidgetBuilder home;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // After the first frame: restore() notifies, and notifying a listener that
    // is still building is what produces "setState during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SessionController>().restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final auth = context.read<DriverAuthRepository>();

    return switch (session.stage) {
      SessionStage.restoring => const _Splash(),
      SessionStage.signedOut => SignInPage(auth: auth, onSignedIn: session.onSignedIn),
      SessionStage.confirming => ConfirmAccountPage(
        session: session.session!,
        auth: auth,
        onConfirmed: session.confirm,
        onRejected: session.signOut,
      ),
      SessionStage.mustChangePin => ChangePinPage(
        auth: auth,
        isForced: true,
        onChanged: session.onPinChanged,
      ),
      SessionStage.ready => widget.home(context),
    };
  }
}

/// Shown only while the stored token is read from disk.
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
