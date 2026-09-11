import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/profile_page.dart';
import 'package:trotxi_driver/Presentations/Shell/widgets/driver_header.dart';
import 'package:trotxi_driver/Presentations/Shell/widgets/driver_nav.dart';
import 'package:trotxi_driver/Presentations/Today/pages/today_page.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    // The run-scoped tabs are only reachable while something is running, and
    // the header only knows a vehicle once a run has named one.
    final active = context.watch<TodayController>().board.valueOrNull?.active;

    return Scaffold(
      backgroundColor: colors.page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DriverHeader(vehicleRegistration: active?.vehicleRegistration),
            Expanded(child: _body()),
          ],
        ),
      ),
      bottomNavigationBar: DriverNav(
        current: _tab,
        hasActiveRun: active != null,
        onSelect: (tab) => setState(() => _tab = tab),
      ),
    );
  }

  Widget _body() {
    return switch (_tab) {
      DriverTab.today => const TodayPage(),
      DriverTab.me => const ProfilePage(),
      // Trip, Scan and Manifest are reached through the run they belong to, and
      // are wired as the run screens land on this shell.
      _ => const TodayPage(),
    };
  }
}
