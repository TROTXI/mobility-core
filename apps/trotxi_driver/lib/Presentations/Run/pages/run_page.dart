import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/board_by_code_page.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/scan_page.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/end_run_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/manifest_page.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/boarding_counter.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<RunController>().load();
      if (mounted) await _syncPublishing();
    });
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

  /// Push a screen that needs this run's controller.
  ///
  /// @param context - the calling context.
  /// @param controller - the run's controller, passed down rather than rebuilt.
  /// @param page - the screen to open.
  void _open(BuildContext context, RunController controller, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChangeNotifierProvider.value(value: controller, child: page),
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
      onRefresh: controller.load,
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

        Row(
          children: [
            Text(
              CorridorTime.hhmm(run.scheduledAt),
              style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.space12),
            _RunStatusPill(run: run, colors: colors),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),

        Row(
          children: [
            Expanded(
              child: BoardingCounter(
                label: 'Boarded',
                value: data.boarded,
                of: data.expected,
                tone: data.boarded == data.expected && data.expected > 0
                    ? colors.success
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: BoardingCounter(
                label: 'Stops',
                value: data.stops.isEmpty ? 0 : 1,
                of: data.stops.length,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),

        // Boarding is only offered on a run that is actually under way. Scanning
        // riders onto a trip nobody has started produces boardings against a
        // run with no GPS trace and no start time, which is the state the
        // lifecycle refuses to complete.
        if (run.isActive) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _open(context, controller, ScanPage(runId: run.id)),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan'),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _open(context, controller, const BoardByCodePage()),
                  icon: const Icon(Icons.dialpad),
                  label: const Text('By code'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
        ],

        OutlinedButton.icon(
          onPressed: () => _open(context, controller, const ManifestPage()),
          icon: const Icon(Icons.people_outline),
          label: Text('Manifest (${data.waiting.length} waiting)'),
        ),
        const SizedBox(height: AppSpacing.space12),

        if (run.isActive)
          _LocationNotice(block: _positionBlock, colors: colors),

        _PrimaryAction(
          controller: controller,
          run: run,
          onChanged: _syncPublishing,
        ),

        const SizedBox(height: AppSpacing.space32),
        Text(
          'STOPS',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space8),
        if (data.stops.isEmpty)
          Text(
            'This corridor has no stops recorded yet.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          )
        else
          for (final (index, stop) in data.stops.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.surfaceSelected,
                      borderRadius: AppRadii.circular(AppRadii.full),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: AppTypography.caption.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Text(
                      stop,
                      style: AppTypography.body.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
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

class _RunStatusPill extends StatelessWidget {
  const _RunStatusPill({required this.run, required this.colors});

  final DriverRun run;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final (label, tone) = switch (run.status) {
      RunStatus.active => ('RUNNING', colors.live),
      RunStatus.completed => ('COMPLETED', colors.textSecondary),
      RunStatus.cancelled => ('CANCELLED', colors.danger),
      RunStatus.scheduled => ('SCHEDULED', colors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadii.circular(AppRadii.full),
        border: Border.all(color: tone),
      ),
      child: Text(label, style: AppTypography.caption.copyWith(color: tone)),
    );
  }
}

/// Tells the driver whether riders can see the bus, and what to do when they
/// cannot.
///
/// Worth a line on screen rather than failing quietly: riders watching a stale
/// marker will ring the depot, and the driver is the only one who can fix it.
class _LocationNotice extends StatelessWidget {
  const _LocationNotice({required this.block, required this.colors});

  final PositionBlock? block;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final (tone, message) = switch (block) {
      null => (
        colors.live,
        'Sharing your location with riders while this trip runs.',
      ),
      PositionBlock.servicesOff => (
        colors.warning,
        'Location is switched off on this device, so riders cannot see the bus.',
      ),
      PositionBlock.deniedForever => (
        colors.warning,
        'Location access is off for Trotxi Driver. Turn it on in device settings '
            'so riders can see the bus approaching.',
      ),
      _ => (
        colors.warning,
        'Location access was declined, so riders cannot see the bus approaching.',
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        children: [
          Icon(
            block == null ? Icons.location_on : Icons.location_off,
            size: 18,
            color: tone,
          ),
          const SizedBox(width: AppSpacing.space8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
