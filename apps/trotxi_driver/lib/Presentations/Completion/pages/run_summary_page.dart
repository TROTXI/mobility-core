import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
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
    final detail = context.watch<RunController>().detail.valueOrNull;
    final run = detail?.run;
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
            Text(
              'Trip completed',
              style: AppTypography.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              run == null
                  ? 'Saved to today'
                  : '${CorridorTime.hhmm(run.scheduledAt)} ${run.routeName} · '
                        'saved to today',
              style: AppTypography.screenContext.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.space16),
              decoration: BoxDecoration(
                color: colors.surfaceStrong,
                borderRadius: AppRadii.circular(AppRadii.hero),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 36,
                      color: colors.textInverse,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space10),
                  Text(
                    'Run closed',
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Boarding is closed for this run.',
                    textAlign: TextAlign.center,
                    style: AppTypography.screenContext.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space14),

            if (_error != null)
              _Note(
                text: 'Could not load the summary: $_error',
                tone: colors.warning,
                colors: colors,
              )
            else if (summary == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              // The file's 2x2 grid. Four figures a driver reads at a glance
              // instead of four rows they read one at a time.
              Row(
                children: [
                  _Metric(
                    value: summary.duration == null
                        ? '—'
                        : _minutes(summary.duration!),
                    label: 'Duration',
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  _Metric(value: _stops(detail), label: 'Stops completed'),
                ],
              ),
              const SizedBox(height: AppSpacing.space12),
              Row(
                children: [
                  _Metric(
                    value: '${summary.boarded}',
                    label: 'Passengers boarded',
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  // "Not boarded", not "No-shows", which is what the file
                  // prints. A no-show is a mark a driver makes and the cutoff
                  // settles; nothing has been deducted for these riders, and
                  // calling them no-shows here would report a charge that has
                  // not happened.
                  _Metric(value: '${summary.notBoarded}', label: 'Not boarded'),
                ],
              ),
              const SizedBox(height: AppSpacing.space12),
              if (summary.boarded > 0)
                _Record(
                  heading: 'Boarded by',
                  value:
                      '${summary.byQr} scanned · ${summary.byPin} by code · '
                      '${summary.byPhoto} from manifest',
                  note:
                      'Riders who never boarded stay on the manifest as not '
                      'boarded, and nothing has been deducted for them. The '
                      'cutoff settles any you did not mark as a no-show.',
                )
              else
                _Note(
                  text:
                      'Riders who never boarded stay on the manifest as not '
                      'boarded, and nothing has been deducted for them. The '
                      'cutoff settles any you did not mark as a no-show.',
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

  /// "11 / 11", or what is knowable when the driver reported no arrivals.
  ///
  /// @param detail - the run and its stops.
  /// @returns the grid's stop figure.
  static String _stops(RunDetail? detail) {
    if (detail == null || detail.stops.isEmpty) return '—';
    return '${detail.currentStopNumber ?? 0} / ${detail.stops.length}';
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

/// One figure in the completion grid.
class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Expanded(
      child: Container(
        height: 66,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.field,
          borderRadius: AppRadii.circular(AppRadii.lg),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: AppTypography.title.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.tileCaption.copyWith(
                fontSize: 11,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The trip-record strip under the grid: one fact, and what it means.
class _Record extends StatelessWidget {
  const _Record({
    required this.heading,
    required this.value,
    required this.note,
  });

  final String heading;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                heading,
                style: AppTypography.fieldLabel.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppTypography.tileLabel.copyWith(
                    fontSize: 11,
                    letterSpacing: 0,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            note,
            style: AppTypography.tileCaption.copyWith(
              fontSize: 11,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
