import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Run/pages/manifest_page.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/boarding_counter.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RunController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final controller = context.watch<RunController>();
    final detail = controller.detail;

    return Scaffold(
      appBar: AppBar(title: Text(widget.run.routeName)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: detail.isInitialLoad
              ? const Center(child: CircularProgressIndicator())
              : _body(context, controller, detail, colors),
        ),
      ),
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
            detail is Failure<RunDetail> ? detail.message : 'Could not load this run.',
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
              style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
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
                tone: data.boarded == data.expected && data.expected > 0 ? colors.success : null,
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

        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider.value(
                value: controller,
                child: const ManifestPage(),
              ),
            ),
          ),
          icon: const Icon(Icons.people_outline),
          label: Text('Manifest (${data.waiting.length} waiting)'),
        ),
        const SizedBox(height: AppSpacing.space12),

        _PrimaryAction(controller: controller, run: run),

        const SizedBox(height: AppSpacing.space32),
        Text('STOPS', style: AppTypography.caption.copyWith(color: colors.textSecondary)),
        const SizedBox(height: AppSpacing.space8),
        if (data.stops.isEmpty)
          Text(
            'This corridor has no stops recorded yet.',
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
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
                      style: AppTypography.caption.copyWith(color: colors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Text(
                      stop,
                      style: AppTypography.body.copyWith(color: colors.textPrimary),
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
  const _PrimaryAction({required this.controller, required this.run});

  final RunController controller;
  final DriverRun run;

  @override
  Widget build(BuildContext context) {
    if (run.isFinished) {
      return Text(
        'This run is finished.',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(color: context.driverColors.textSecondary),
      );
    }

    final busy = controller.isTransitioning;
    return ElevatedButton(
      onPressed: busy ? null : (run.isActive ? controller.complete : controller.start),
      child: busy
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
