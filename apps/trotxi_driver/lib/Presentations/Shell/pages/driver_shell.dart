import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/scan_page.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/profile_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/manifest_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/run_page.dart';
import 'package:trotxi_driver/Presentations/Shell/widgets/driver_header.dart';
import 'package:trotxi_driver/Presentations/Shell/widgets/driver_nav.dart';
import 'package:trotxi_driver/Presentations/Today/pages/today_page.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// The app's frame: identity header on top, the five-tab bar underneath.
///
/// The tabs are kept alive across switches rather than rebuilt. A driver moves
/// between Trip, Scan and Manifest repeatedly at a single stop, and rebuilding
/// each one would re-fetch a manifest they were reading a second ago.
class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  DriverTab _tab = DriverTab.today;

  /// One controller for the run the driver is on, shared by Trip, Scan and
  /// Manifest. Those three are views of the SAME run: giving each its own
  /// would have a boarding on one tab leave the other two showing a manifest
  /// from before it happened.
  RunController? _run;
  String? _runId;

  void _onRunChanged() {
    if (mounted) setState(() {});
  }

  void _disposeRun() {
    _run?.removeListener(_onRunChanged);
    _run?.dispose();
    _run = null;
    _runId = null;
  }

  /// Build or reuse the controller for whichever run is active.
  ///
  /// @param run - the active run, or null when none is.
  /// @returns the controller, or null when there is nothing to show.
  RunController? _controllerFor(DriverRun? run) {
    if (run == null) {
      _disposeRun();
      return null;
    }
    if (_runId != run.id) {
      _disposeRun();
      final controller = RunController(
        trips: context.read<TripsRepository>(),
        run: run,
      );
      // load() notifies synchronously before its first await. Start it before
      // subscribing so creating the controller during build cannot schedule a
      // setState inside that same build; later results and lifecycle changes
      // still rebuild the shell.
      controller.load();
      controller.addListener(_onRunChanged);
      _run = controller;
      _runId = run.id;
    }
    return _run;
  }

  @override
  void dispose() {
    _disposeRun();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final board = context.watch<TodayController>().board.valueOrNull;
    // Trip and Manifest follow whichever run the day leads with, started or
    // not. Scan needs one actually under way.
    final leading = board?.active ?? board?.next;
    // RunController owns the latest accepted start/complete response. Today is
    // a separate cached roster and can still say "scheduled" for a frame (or
    // until its next refresh), which previously left Scan disabled after the
    // driver had successfully started the trip.
    final observed = _runId == leading?.id ? _run?.currentRun : null;
    final isRunning = observed?.isActive ?? (board?.active != null);

    return Scaffold(
      backgroundColor: colors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DriverHeader(vehicleRegistration: leading?.vehicleRegistration),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  // Page 21 gives mount and tablet surfaces a deliberate
                  // working width. Without this, list rows and map controls
                  // drift to opposite edges of a 12-inch display.
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: _body(leading),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DriverNav(
        current: _tab,
        hasRun: leading != null,
        canScan: isRunning,
        // The file's navigation rule, stated in as many words: "Trip retains a
        // live blue indicator during an active run even when another
        // destination is selected". A driver who has wandered to Manifest or Me
        // should be able to see at a glance that a run is still going.
        tripHasAlert: isRunning,
        onSelect: (tab) => setState(() => _tab = tab),
      ),
    );
  }

  Widget _body(DriverRun? leading) {
    if (_tab == DriverTab.today) return const TodayPage();
    if (_tab == DriverTab.me) return const ProfilePage();

    final run = _controllerFor(leading);
    // The nav disables these without a run, so this only happens if the day's
    // last run finishes while the driver is standing on one of its tabs.
    if (run == null) return const TodayPage();

    return ChangeNotifierProvider<RunController>.value(
      value: run,
      child: switch (_tab) {
        DriverTab.trip => RunPage(run: leading!),
        DriverTab.scan => ScanPage(runId: leading!.id),
        _ => const ManifestPage(),
      },
    );
  }
}
