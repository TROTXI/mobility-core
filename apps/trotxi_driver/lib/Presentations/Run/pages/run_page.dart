import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:provider/provider.dart';
// The generated client exports wire models named TripSummary and StopEta;
// this page means the widget in pre_trip.dart and the view model in
// route_map_repository.dart.
import 'package:trotxi_client/trotxi_client.dart' hide TripSummary, StopEta;
import 'package:trotxi_driver/Presentations/Boarding/pages/board_by_code_page.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/scan_page.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/end_run_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/manifest_page.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/pre_trip.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/run_map.dart';
import 'package:trotxi_driver/core/widgets/driver_chip.dart';
import 'package:trotxi_driver/core/widgets/driver_tiles.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/route_map_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// A run's screen (prototype frames 19 to 24).
///
/// One screen across the run's whole life rather than one per state. The
/// prototype draws pre-trip, active, arrived and ready-to-depart as separate
/// frames, but they are the same layout with a different call to action, and
/// splitting them would mean a driver navigating between screens to do the one
/// thing the run needs next.
class RunPage extends StatefulWidget {
  const RunPage({super.key, required this.run});

  final DriverRun run;

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  late final PositionPublisher _positions = PositionPublisher(
    client: context.read<TrotxiApiClient>(),
  );

  /// Why location sharing is not running, when it is not.
  PositionBlock? _positionBlock;

  /// The API's distance and ETA to each stop still ahead (design page 10).
  /// Null until the run reports a position, which is most of a run's first
  /// minutes and every run in a dead zone.
  VehicleFix? _fix;

  /// The corridor's stops with their coordinates, for handing one to the
  /// phone's navigation app. Cached for the session by the repository.
  RouteShape? _shape;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<RunController>().load();
      if (mounted) await _syncPublishing();
      if (mounted) await _loadFix();
    });
  }

  /// Read the vehicle's position for its stop ETAs.
  ///
  /// Shares the repository's short-lived cache with the map, so the two
  /// surfaces on this screen that want a fix make one call between them.
  Future<void> _loadFix() async {
    final run = context.read<RunController>().detail.valueOrNull?.run;
    if (run == null || !run.isActive) return;
    final maps = context.read<RouteMapRepository>();
    final fix = await maps.vehicleOn(run.id);
    final shape = await maps.shapeFor(run.routeId);
    if (mounted) {
      setState(() {
        _fix = fix;
        _shape = shape;
      });
    }
  }

  /// The stop a NAVIGATE tap should open, or null when nothing can be opened.
  ///
  /// Needs both halves: the API's next stop, and that stop's coordinates off
  /// the corridor shape. Either missing and the control is not offered rather
  /// than offered and dead.
  MappedStop? get _navigationTarget {
    final next = _fix?.nextStop;
    final stops = _shape?.stops;
    if (next == null || stops == null) return null;
    for (final stop in stops) {
      if (stop.seq == next.seq) return stop;
    }
    return null;
  }

  /// Hand a stop to whatever the phone navigates with.
  ///
  /// Turn-by-turn is out of scope for this app (#237) and the device already
  /// does it better. `geo:` is Android's; iOS takes the Apple Maps URL, and
  /// `launchUrl` falls through to whichever the platform can open.
  Future<void> _navigateTo(MappedStop stop) async {
    final lat = stop.position.latitude;
    final lng = stop.position.longitude;
    final label = Uri.encodeComponent(stop.name);
    for (final url in [
      Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)'),
      Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d'),
    ]) {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return;
      }
    }
  }

  @override
  void dispose() {
    // Publishing stops with the screen. The permission asked for is "while in
    // use", and holding a location stream open behind a closed run would be
    // tracking the driver rather than the bus.
    _positions.stop();
    super.dispose();
  }

  /// Start or stop publishing to match the run's state.
  Future<void> _syncPublishing() async {
    final run = context.read<RunController>().detail.valueOrNull?.run;
    if (run == null) return;

    if (run.isActive && !_positions.isPublishing) {
      final block = await _positions.start(run.id);
      if (mounted) setState(() => _positionBlock = block);
    } else if (!run.isActive && _positions.isPublishing) {
      await _positions.stop();
      if (mounted) setState(() => _positionBlock = null);
    }
  }

  /// Push a screen that normally lives as a shell tab.
  ///
  /// The Scaffold is not decoration. Manifest and Scan are written as tabs —
  /// bare ListViews, because the shell owns the header and nav bar — so pushed
  /// as a plain route they have no Material ancestor, and the manifest's search
  /// field threw "No Material widget found" the moment it built. That made the
  /// Manifest button on this screen a crash rather than a screen.
  ///
  /// [title] is null for a page that brings its own Scaffold, so it does not
  /// end up with two app bars, and empty for one that prints its own heading —
  /// the manifest says "Passenger manifest" in the body already, and repeating
  /// it in the bar is a stutter that costs a line of a small screen.
  ///
  /// @param context - the navigator's context.
  /// @param controller - the run, provided to the pushed page.
  /// @param page - the screen to open.
  /// @param title - app-bar title; empty for chrome only, null for a page that
  ///   already has its own Scaffold.
  void _open(
    BuildContext context,
    RunController controller,
    Widget page, {
    String? title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: title == null
              ? page
              : Scaffold(
                  appBar: AppBar(title: title.isEmpty ? null : Text(title)),
                  body: SafeArea(child: page),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final controller = context.watch<RunController>();
    final detail = controller.detail;

    // A tab on the shell, which already owns the header and the nav bar.
    return RefreshIndicator(
      onRefresh: () async {
        await controller.load();
        await _loadFix();
      },
      child: detail.isInitialLoad
          ? const Center(child: CircularProgressIndicator())
          : _body(context, controller, detail, colors),
    );
  }

  Widget _body(
    BuildContext context,
    RunController controller,
    Loadable<RunDetail> detail,
    AppColors colors,
  ) {
    final data = detail.valueOrNull;
    if (data == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.space24),
        children: [
          Text(
            detail is Failure<RunDetail>
                ? detail.message
                : 'Could not load this run.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
        ],
      );
    }

    final run = data.run;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space20,
        vertical: AppSpacing.space16,
      ),
      children: [
        if (detail is Failure<RunDetail>) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.circular(AppRadii.md),
              border: Border.all(color: colors.warning),
            ),
            child: Text(
              detail.message,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
        ],

        // Before departure the screen is page 08, not a quieter page 09.
        // The driver is confirming an assignment they have not started, so the
        // run leads as a filled summary and the check under it says what that
        // confirmation rests on. Once the run is active the same space has to
        // carry what is happening now, and the hero takes over.
        if (!run.isActive) ...[
          Text(
            'Pre-trip check',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'Confirm the run is ready before departure',
            style: AppTypography.screenContext.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space12),
          TripSummary(data: data),
          const SizedBox(height: AppSpacing.space12),
          ReadinessCard(data: data),
          const SizedBox(height: AppSpacing.space12),
          // Page 08 carries the same indicator as the active screen. Location
          // is a readiness fact before departure, and finding out it is off
          // after pulling away costs the run its trace.
          GpsIndicator(
            state: _gpsState(_positionBlock),
            detail: _gpsDetail(_positionBlock),
          ),
        ] else ...[
          // The Active Trip Hero (Components / Active Trip Hero): one dominant
          // operating surface that answers what the driver must do next. The
          // earlier build spread these parts down a flat list, which is the same
          // information and a different screen.
          Container(
            padding: const EdgeInsets.all(AppSpacing.space20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.circular(AppRadii.hero),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${CorridorTime.hhmm(run.scheduledAt)} ${run.routeName}',
                            style: AppTypography.runTitle.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            // "GT 4821-22 · ACTIVE RUN" in the file. The plate is
                            // dropped rather than invented when no vehicle is
                            // assigned yet.
                            [
                              if (data.vehicleRegistration != null)
                                data.vehicleRegistration!,
                              _runState(run),
                            ].join(' · '),
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    DriverChip(
                      // Short in the chip, long in the caption — which is how the
                      // file has it: "ACTIVE" beside "GT 4821-22 · ACTIVE RUN".
                      label: _chipLabel(run),
                      status: switch (run.status) {
                        RunStatus.active => DriverStatus.active,
                        RunStatus.completed => DriverStatus.boarded,
                        RunStatus.cancelled => DriverStatus.error,
                        RunStatus.scheduled => DriverStatus.neutral,
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),

                Row(
                  children: [
                    Expanded(
                      // Against the van's seat ceiling when the API gives one
                      // (#230), and confirmed riders when it does not. The
                      // caption says which, so the number is never read as
                      // something it is not.
                      child: DriverStatTile(
                        label: 'Boarded',
                        value: '${data.boarded} / ${data.ceiling}',
                        caption: data.hasCapacity
                            ? '${data.waiting.length} remaining · seats'
                            : '${data.waiting.length} remaining',
                        tone: data.boarded >= data.ceiling && data.ceiling > 0
                            ? colors.success
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    Expanded(
                      // Zero until the driver reports an arrival (#230). The API
                      // does not guess from GPS and neither does this.
                      child: DriverStatTile(
                        label: 'Stop',
                        value:
                            '${data.currentStopSeq ?? 0} of ${data.stops.length}',
                        caption: _stopCaption(data),
                      ),
                    ),
                  ],
                ),

                // The corridor (#237). Above the next-stop card rather than
                // below it: the design leads the active-trip frame with the map,
                // and a driver glancing down wants where they are before what is
                // next.
                const SizedBox(height: AppSpacing.space16),
                RunMap(
                  routeId: run.routeId,
                  runId: run.id,
                  isActive: run.isActive,
                  onExpand: () => _openMap(context, run),
                ),

                if (data.stops.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.space16),
                  NextStopCard(
                    label: data.currentStopName == null
                        ? 'Next stop'
                        : 'At stop',
                    stop: data.currentStopName ?? data.stops.first,
                    // The file's "1.2 km · ~4 min", from the API rather than
                    // computed here: the server derives both from the
                    // corridor's learned geometry. Null until the run has
                    // reported a position, because a made-up number on the one
                    // card a driver navigates by is worse than an absent one.
                    detail: _fix?.nextStop?.summary,
                    onNavigate: _navigationTarget == null
                        ? null
                        : () => _navigateTo(_navigationTarget!),
                  ),
                ],

                // Boarding is only offered on a run actually under way. Scanning
                // riders onto a trip nobody has started produces boardings
                // against a run with no GPS trace and no start time, which is the
                // state the lifecycle refuses to complete.
                if (run.isActive) ...[
                  const SizedBox(height: AppSpacing.space16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _open(
                            context,
                            controller,
                            ScanPage(runId: run.id),
                            title: 'Scan a pass',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(53),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.circular(AppRadii.full),
                            ),
                          ),
                          child: const Text('SCAN RIDER'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _open(
                            context,
                            controller,
                            const ManifestPage(),
                            title: '',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(53),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.circular(AppRadii.full),
                            ),
                          ),
                          child: const Text('MANIFEST'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  OutlinedButton.icon(
                    onPressed: () => _open(
                      context,
                      controller,
                      BoardByCodePage(runId: run.id),
                    ),
                    icon: const Icon(Icons.dialpad),
                    label: const Text('Board by code'),
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.space16),
                  OutlinedButton.icon(
                    onPressed: () => _open(
                      context,
                      controller,
                      const ManifestPage(),
                      title: '',
                    ),
                    icon: const Icon(Icons.people_outline),
                    label: Text('Manifest (${data.waiting.length} waiting)'),
                  ),
                ],

                if (run.isActive) ...[
                  const SizedBox(height: AppSpacing.space16),
                  // The file's GPS & Connectivity component, whose whole rule is
                  // "never imply live accuracy when GPS is weak, queued offline
                  // or disabled". The earlier build had one line that said
                  // "sharing" whatever was actually happening underneath.
                  GpsIndicator(
                    state: _gpsState(_positionBlock),
                    detail: _gpsDetail(_positionBlock),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.space16),

        _PrimaryAction(
          controller: controller,
          run: run,
          onChanged: _syncPublishing,
        ),

        const SizedBox(height: AppSpacing.space16),
        // The file's stop-sequence card (design page 10): the whole corridor in
        // one panel rather than a bare list under a caption, so the three
        // states read as one thing a driver scans down.
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space8,
            AppSpacing.space16,
            AppSpacing.space8,
            AppSpacing.space8,
          ),
          decoration: BoxDecoration(
            color: colors.field,
            borderRadius: AppRadii.circular(AppRadii.xl),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Stop sequence',
                        style: AppTypography.label.copyWith(
                          fontSize: 15,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (run.isActive && data.stops.isNotEmpty)
                      Text(
                        data.currentStopName == null
                            ? 'Tap one when you reach it'
                            : 'At ${data.currentStopName}',
                        style: AppTypography.tileCaption.copyWith(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              if (data.stops.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.space10),
                  child: Text(
                    'This corridor has no stops recorded yet.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
              else
                for (final (index, stop) in data.stops.indexed)
                  _StopRow(
                    seq: index + 1,
                    name: stop,
                    eta: _etaFor(index + 1),
                    // Passed rather than "done": the driver said they reached
                    // stop 4, which means 1 to 3 are behind them.
                    passed:
                        data.currentStopSeq != null &&
                        index + 1 < data.currentStopSeq!,
                    current: data.currentStopSeq == index + 1,
                    // Only on a run that is under way. Reporting arrivals on a
                    // trip nobody has started would record progress along a
                    // route the van is not on.
                    onArrive: run.isActive
                        ? () => _arrive(context, controller, index + 1)
                        : null,
                    colors: colors,
                  ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
      ],
    );
  }

  /// This stop's figure from the API, or null when it is behind the van or the
  /// run has reported nothing.
  ///
  /// @param seq - the stop's one-based position.
  /// @returns the ETA, or null.
  StopEta? _etaFor(int seq) {
    for (final eta in _fix?.etas ?? const <StopEta>[]) {
      if (eta.seq == seq) return eta;
    }
    return null;
  }

  /// The run's state in the words the file uses on the hero's second line.
  ///
  /// @param run - the run.
  /// @returns the state label.
  static String _runState(DriverRun run) => switch (run.status) {
    RunStatus.active => 'Active run',
    RunStatus.completed => 'Completed',
    RunStatus.cancelled => 'Cancelled',
    RunStatus.scheduled => 'Scheduled',
  };

  /// Which of the file's four telemetry states the run is in.
  ///
  /// The app has no weak-signal or queued-fix reporting yet, so only two of the
  /// four are reachable. They are mapped rather than collapsed because a driver
  /// reading "location is turned off" needs a different thing from one reading
  /// "sharing live", and the component draws both honestly.
  ///
  /// @param block - why publishing is not running, when it is not.
  /// @returns the state to draw.
  static GpsState _gpsState(PositionBlock? block) =>
      block == null ? GpsState.live : GpsState.disabled;

  /// The second line under the state.
  ///
  /// @param block - why publishing is not running, when it is not.
  /// @returns what to say about it.
  static String _gpsDetail(PositionBlock? block) => switch (block) {
    null => 'Riders can see the bus approaching',
    PositionBlock.servicesOff => 'Location is off for the whole device',
    PositionBlock.deniedForever => 'Turn it on in device settings',
    PositionBlock.denied => 'Access was declined',
    PositionBlock.notRequested => 'Not asked for yet',
  };

  /// The one word inside the chip.
  ///
  /// @param run - the run.
  /// @returns the chip label.
  static String _chipLabel(DriverRun run) => switch (run.status) {
    RunStatus.active => 'Active',
    RunStatus.completed => 'Done',
    RunStatus.cancelled => 'Cancelled',
    RunStatus.scheduled => 'Scheduled',
  };

  /// What the stop counter's caption says.
  ///
  /// The file writes "Shiashie next" here, but in the file the next-stop card
  /// is a separate frame; on a 402pt phone the card sits directly beneath this
  /// tile and already names the stop in 18/700. Repeating it in a 11px caption
  /// only truncated it — "Circle Interchange fi…" — so the caption counts what
  /// is left instead, which the card does not say.
  ///
  /// @param data - the loaded run.
  /// @returns the caption.
  static String _stopCaption(RunDetail data) {
    if (data.stops.isEmpty) return 'No stops recorded';
    final seq = data.currentStopSeq;
    if (seq == null) return '${data.stops.length} to go';
    final left = data.stops.length - seq;
    if (left <= 0) return 'Last stop';
    return left == 1 ? '1 to go' : '$left to go';
  }

  /// Open the corridor full-screen.
  ///
  /// The design makes the active-trip map expandable, and the reason is
  /// practical: a 220pt strip is enough to confirm you are on the right road
  /// and not enough to work out where a stop is.
  ///
  /// @param context - the navigator's context.
  /// @param run - the run to draw.
  void _openMap(BuildContext context, DriverRun run) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(run.routeName)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space12),
              child: RunMap(
                routeId: run.routeId,
                runId: run.id,
                isActive: run.isActive,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Report reaching a stop (#230).
  ///
  /// @param context - for the failure message.
  /// @param controller - the run.
  /// @param seq - the stop reached.
  Future<void> _arrive(
    BuildContext context,
    RunController controller,
    int seq,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await controller.arriveAtStop(seq);
    final detail = controller.detail;
    if (detail is Failure<RunDetail>) {
      messenger.showSnackBar(SnackBar(content: Text(detail.message)));
    }
  }
}

/// One stop on the corridor, and the control that advances the counter.
///
/// Tappable on an active run, because the API takes any stop on the route
/// rather than only the next one: a driver who missed a tap two stops back
/// should be able to put the counter right instead of living with it wrong.
/// One row of the file's stop sequence (design page 10).
///
/// Three states, and each says what it means rather than only how it looks: a
/// stop behind the van reads DONE, the one it is working reads CURRENT, and the
/// rest read NEXT with whatever the API can say about when.
class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.seq,
    required this.name,
    required this.passed,
    required this.current,
    required this.onArrive,
    required this.colors,
    this.eta,
  });

  final int seq;
  final String name;
  final bool passed;
  final bool current;
  final VoidCallback? onArrive;
  final AppColors colors;

  /// The API's figure for this stop, when the run has reported a position.
  final StopEta? eta;

  @override
  Widget build(BuildContext context) {
    final (badge, tone) = passed
        ? ('DONE', colors.success)
        : current
        ? ('CURRENT', colors.surfaceStrong)
        : ('NEXT', colors.page);

    final sub = passed
        ? 'Reported'
        : (eta?.summary ?? (current ? 'Working this stop' : 'Ahead'));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: InkWell(
        onTap: onArrive,
        borderRadius: AppRadii.circular(AppRadii.field),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space14,
            vertical: AppSpacing.space10,
          ),
          decoration: BoxDecoration(
            color: current ? colors.surface : Colors.transparent,
            borderRadius: AppRadii.circular(AppRadii.field),
            border: Border.all(
              color: current ? colors.border : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: passed
                      ? colors.success
                      : (current ? colors.surfaceStrong : colors.page),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$seq',
                  style: AppTypography.screenContext.copyWith(
                    fontWeight: FontWeight.w600,
                    color: passed ? colors.textInverse : colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.fieldLabel.copyWith(
                        fontSize: 13,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      sub,
                      style: AppTypography.tileCaption.copyWith(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              Container(
                height: 27,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space10,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tone,
                  borderRadius: AppRadii.circular(AppRadii.full),
                  border: Border.all(color: passed ? tone : colors.border),
                ),
                child: Text(
                  badge,
                  style: AppTypography.tileLabel.copyWith(
                    color: passed ? colors.textInverse : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one thing this run needs next, which is entirely a function of its state.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.controller,
    required this.run,
    required this.onChanged,
  });

  final RunController controller;
  final DriverRun run;

  /// Called after the run's state moves, so location publishing can follow it.
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    if (run.isFinished) {
      return Text(
        'This run is finished.',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(
          color: context.driverColors.textSecondary,
        ),
      );
    }

    final busy = controller.isTransitioning;
    return ElevatedButton(
      onPressed: busy
          ? null
          : () async {
              // Ending goes through the confirmation flow; starting does not.
              // Completing is the one irreversible action here, and a stray tap
              // at the kerb should not close a run with riders still aboard.
              if (run.isActive) {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: controller,
                      child: const EndRunPage(),
                    ),
                  ),
                );
              } else {
                await controller.start();
              }
              await onChanged();
            },
      child: busy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(run.isActive ? 'End trip' : 'Start trip'),
    );
  }
}
