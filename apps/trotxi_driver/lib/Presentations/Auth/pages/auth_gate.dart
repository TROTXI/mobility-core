import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/account_linked_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/confirm_account_page.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/sign_in_page.dart';
import 'package:trotxi_driver/Presentations/Onboarding/pages/first_launch_page.dart';
import 'package:trotxi_driver/Presentations/Readiness/pages/device_readiness_page.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/data/device_readiness.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';
import 'package:trotxi_driver/data/first_launch_store.dart';

/// Renders whichever screen the session is currently on.
///
/// The stage machine moved to [SessionController] under ADR-0016; this is now
/// only the mapping from stage to screen. Sign-out reaches the controller from
/// anywhere, so a profile screen does not need a callback threaded down to it.
class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.home,
    this.firstLaunchStore = const SecureFirstLaunchStore(),
    this.readinessService = const NativeDeviceReadinessService(),
    this.splashDuration = const Duration(seconds: 4),
  });

  /// What to show once the driver is through.
  final WidgetBuilder home;
  final FirstLaunchStore firstLaunchStore;
  final DeviceReadinessService readinessService;

  /// Kept injectable so widget tests do not spend four seconds on a clock.
  final Duration splashDuration;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  _FirstLaunchStage _firstLaunch = _FirstLaunchStage.loading;
  bool _finishingWelcome = false;

  @override
  void initState() {
    super.initState();
    // After the first frame: restore() notifies, and notifying a listener that
    // is still building is what produces "setState during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _boot();
    });
  }

  Future<void> _boot() async {
    final session = context.read<SessionController>();
    final completionCheck = () async {
      try {
        return await widget.firstLaunchStore.hasCompleted();
      } catch (_) {
        // Storage trouble must not lock a driver outside their work.
        return true;
      }
    }();
    // Both are local secure-storage reads. Start them together so adding the
    // first-launch marker does not double the restore delay for returning
    // drivers.
    await session.restore();
    final completed = await completionCheck;
    if (!mounted) return;

    // An existing signed-in installation is not a first launch merely because
    // this version introduced the marker.
    if (completed || session.stage == SessionStage.ready) {
      setState(() => _firstLaunch = _FirstLaunchStage.complete);
      return;
    }

    if (widget.splashDuration > Duration.zero) {
      await Future<void>.delayed(widget.splashDuration);
      if (!mounted) return;
    }
    setState(() => _firstLaunch = _FirstLaunchStage.welcome);
  }

  Future<void> _completeWelcome() async {
    if (_finishingWelcome) return;
    setState(() => _finishingWelcome = true);
    try {
      await widget.firstLaunchStore.complete();
    } catch (_) {
      // Continue in this launch even when persistence is unavailable.
    }
    if (!mounted) return;
    setState(() {
      _finishingWelcome = false;
      _firstLaunch = _FirstLaunchStage.complete;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final auth = context.read<DriverAuthRepository>();

    if (session.stage != SessionStage.ready) {
      if (_firstLaunch == _FirstLaunchStage.loading) {
        return const DriverLaunchSplash();
      }
      if (_firstLaunch == _FirstLaunchStage.welcome) {
        return DriverFirstLaunchPage(
          onContinue: _finishingWelcome ? () async {} : _completeWelcome,
        );
      }
    }

    return switch (session.stage) {
      SessionStage.restoring => const DriverLaunchSplash(),
      SessionStage.signedOut => SignInPage(
        auth: auth,
        onSignedIn: session.onSignedIn,
      ),
      SessionStage.confirming => ConfirmAccountPage(
        session: session.session!,
        onConfirmed: session.confirm,
        onRejected: session.signOut,
      ),
      SessionStage.linked => AccountLinkedPage(
        session: session.session!,
        onContinue: session.completeLinking,
      ),
      SessionStage.readiness => DeviceReadinessPage(
        onContinue: session.completeReadiness,
        service: widget.readinessService,
      ),
      SessionStage.ready => widget.home(context),
    };
  }
}

enum _FirstLaunchStage { loading, welcome, complete }
