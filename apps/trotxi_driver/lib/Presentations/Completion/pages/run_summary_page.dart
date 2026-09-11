import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// What the run did (prototype frames 47 and 48).
///
/// Reports "not boarded" rather than "no-shows deducted", matching the API's
/// own wording: the deduction is the operations cutoff's decision and has not
/// happened yet, so a driver must not read one here.
class RunSummaryPage extends StatefulWidget {
  const RunSummaryPage({super.key});

  @override
  State<RunSummaryPage> createState() => _RunSummaryPageState();
}

class _RunSummaryPageState extends State<RunSummaryPage> {
  RunSummary? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final run = context.read<RunController>().detail.valueOrNull?.run;
    if (run == null) return;
    try {
      final summary = await context.read<TripsRepository>().summary(run.id);
      if (mounted) setState(() => _summary = summary);
    } on TrotxiException catch (err) {
      if (mounted) setState(() => _error = err.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final run = context.watch<RunController>().detail.valueOrNull?.run;
    final summary = _summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space20),
          children: [
            Icon(Icons.check_circle, size: 64, color: colors.success),
            const SizedBox(height: AppSpacing.space16),
            Text(
              'Trip completed',
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            ),
            if (run != null) ...[
              const SizedBox(height: AppSpacing.space4),
              Text(
                '${CorridorTime.hhmm(run.scheduledAt)}  ${run.routeName}',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.space32),

            if (_error != null)
              _Note(
                text: 'Could not load the summary: $_error',
                tone: colors.warning,
                colors: colors,
              )
            else if (summary == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              _Stat(
                label: 'Boarded',
                value: '${summary.boarded}',
                colors: colors,
              ),
              _Stat(
                label: 'Not boarded',
                value: '${summary.notBoarded}',
                colors: colors,
              ),
              if (summary.duration != null)
                _Stat(
                  label: 'Time on the road',
                  value: _minutes(summary.duration!),
                  colors: colors,
                ),
              if (summary.boarded > 0)
                _Stat(
                  label: 'Boarded by',
                  value: '${summary.byQr} scanned, ${summary.byPin} by code',
                  colors: colors,
                ),
              const SizedBox(height: AppSpacing.space16),
              _Note(
                text:
                    'Riders who never boarded stay on the manifest as not boarded. '
                    'Operations decides what happens to their seat.',
                tone: colors.border,
                colors: colors,
              ),
            ],

            const SizedBox(height: AppSpacing.space32),
            ElevatedButton(
              // popUntil rather than pop: the run screen behind this belongs to
              // a trip that is now finished, and dropping the driver back onto
              // it would offer actions the API will refuse.
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Back to today'),
            ),
          ],
        ),
      ),
    );
  }

  /// A duration as whole minutes, which is the only precision a driver cares
  /// about when reading how long a run took.
  ///
  /// @param duration - the run's length.
  /// @returns a human string.
  static String _minutes(Duration duration) {
    final total = duration.inMinutes;
    if (total < 60) return '$total min';
    return '${total ~/ 60}h ${total % 60}m';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.colors});

  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
          Text(
            value,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.tone, required this.colors});

  final String text;
  final Color tone;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: tone),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
