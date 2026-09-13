import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/run_summary_page.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/core/state/loadable.dart';

/// Ending a run (prototype frames 45 and 46).
///
/// A confirmation and a checklist before the trip closes, because completing is
/// the one action on this screen that cannot be undone: the API refuses to
/// reopen a completed run, and riders still aboard lose their live position.
///
/// The checks are local, not sent anywhere. There is no API for a pre-departure
/// inspection record and inventing one client-side would be a checklist nobody
/// reads and nobody can audit. What they do earn is a beat between the tap and
/// the irreversible part.
class EndRunPage extends StatefulWidget {
  const EndRunPage({super.key});

  @override
  State<EndRunPage> createState() => _EndRunPageState();
}

class _EndRunPageState extends State<EndRunPage> {
  /// Label and the line under it, as the file pairs them. The fourth is the
  /// file's and worth having: it is the one check that points at something the
  /// app can actually show the driver, a rider who never boarded.
  static const _checks = [
    ('Vehicle safely parked', 'Parking brake applied'),
    ('All passengers exited', 'Vehicle checked'),
    ('No items left onboard', 'Cabin checked'),
    ('Trip records reviewed', 'Boarding and no-shows'),
  ];

  final _done = <String>{};
  bool _ending = false;

  bool get _ready => _done.length == _checks.length;

  Future<void> _end() async {
    if (!_ready || _ending) return;
    setState(() => _ending = true);
    final controller = context.read<RunController>();
    final completed = await controller.complete();
    if (!mounted) return;
    setState(() => _ending = false);
    if (!completed) {
      final detail = controller.detail;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            detail is Failure<RunDetail>
                ? detail.message
                : 'Trip not completed. Try again.',
          ),
        ),
      );
      return;
    }

    // Straight to the summary: the driver has just finished and the next thing
    // they want is what the run did, not the screen they started from.
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const RunSummaryPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final data = context.watch<RunController>().detail.valueOrNull;
    final waiting = data?.waiting.length ?? 0;
    final noShows = data?.riders.where((r) => r.noShow).length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('End trip?')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            Text(
              'End trip?',
              style: AppTypography.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              _where(data),
              style: AppTypography.screenContext.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space14),

            // The file's safe-stop card. It reads as an instruction rather than
            // a state, because the app cannot tell whether a van is parked and
            // a badge saying it is would be the screen asserting something it
            // does not know.
            _Card(
              tint: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(text: 'STOPPED', tone: colors.warning),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Confirm the vehicle is safely stopped',
                    style: AppTypography.label.copyWith(
                      fontSize: 15,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Continue only after reaching the final stop and parking '
                    'safely.',
                    style: AppTypography.screenContext.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space14),

            if (data != null)
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE RUN',
                      style: AppTypography.tileLabel.copyWith(
                        fontSize: 11,
                        color: colors.borderStrong,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      '${CorridorTime.hhmm(data.run.scheduledAt)} '
                      '${data.run.routeName}',
                      style: AppTypography.stopName.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space14),
                    _Row(
                      label: 'Final stop',
                      value: data.currentStopName == null
                          ? 'None reported'
                          : '${data.currentStopName} · '
                                '${data.currentStopNumber} of ${data.stops.length}',
                    ),
                    _Row(
                      label: 'Passengers',
                      value: noShows == 0
                          ? '${data.boarded} boarded'
                          : '${data.boarded} boarded · $noShows no-shows',
                    ),
                    _Row(
                      label: 'Vehicle',
                      value: data.vehicleRegistration ?? 'Not assigned',
                    ),
                  ],
                ),
              ),

            if (waiting > 0) ...[
              const SizedBox(height: AppSpacing.space14),
              _Card(
                border: colors.warning,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      waiting == 1
                          ? '1 rider never boarded'
                          : '$waiting riders never boarded',
                      style: AppTypography.label.copyWith(
                        color: colors.warning,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      // Accurate since #227 gave the driver the no-show action.
                      // Still not "they will be charged": these riders have not
                      // been marked, so nothing has been deducted for them, and
                      // the cutoff is what decides if the driver leaves it.
                      'Nothing has been deducted for them. Mark a no-show on '
                      'the manifest if they did not turn up, or leave it and '
                      'the cutoff will settle it.',
                      style: AppTypography.screenContext.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space14),

            for (final (label, detail) in _checks) ...[
              _CheckRow(
                label: label,
                detail: detail,
                done: _done.contains(label),
                onTap: () => setState(() {
                  _done.contains(label)
                      ? _done.remove(label)
                      : _done.add(label);
                }),
              ),
              const SizedBox(height: AppSpacing.space8),
            ],
            const SizedBox(height: AppSpacing.space8),

            _Card(
              tint: true,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _ready ? 'Ready to review' : 'Work through the checks',
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  _Badge(
                    text: _ready
                        ? 'READY'
                        : '${_done.length}/${_checks.length}',
                    tone: _ready ? colors.success : colors.borderStrong,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space10),
            Text(
              'Ending a trip closes boarding and cannot be undone.',
              textAlign: TextAlign.center,
              style: AppTypography.tileCaption.copyWith(
                fontSize: 11,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.space20),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _ready && !_ending ? _end : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.action,
                        foregroundColor: colors.onAction,
                        textStyle: AppTypography.actionLabel,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.circular(AppRadii.pill),
                        ),
                      ),
                      child: _ending
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.onAction,
                              ),
                            )
                          : const Text('END TRIP'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _ending
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        backgroundColor: colors.field,
                        side: BorderSide(color: colors.border),
                        textStyle: AppTypography.actionLabel.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.circular(AppRadii.pill),
                        ),
                      ),
                      child: const Text('KEEP ACTIVE'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// "Circle · final stop · safely parked", as far as the run actually knows.
  ///
  /// @param data - the run, or null while it loads.
  /// @returns the line under the title.
  static String _where(RunDetail? data) {
    if (data == null) return 'Review before closing the run';
    final seq = data.currentStopNumber;
    final name = data.currentStopName;
    if (name == null) return 'No arrival reported on this run yet';
    final last = seq == data.stops.length;
    return last
        ? '$name · final stop'
        : '$name · stop $seq of ${data.stops.length}';
  }
}

/// The rounded panel every block on this screen sits in.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.tint = false, this.border});

  final Widget child;

  /// The heavier of the two fills the file uses here, for the two cards that
  /// frame the decision rather than report it.
  final bool tint;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: tint ? colors.surfaceStrong : colors.field,
        borderRadius: AppRadii.circular(AppRadii.note),
        border: Border.all(color: border ?? colors.border),
      ),
      child: child,
    );
  }
}

/// A small filled status pill.
class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.tone});

  final String text;
  final Color tone;

  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: tone,
      borderRadius: AppRadii.circular(AppRadii.button),
    ),
    child: Text(
      text,
      style: AppTypography.tileLabel.copyWith(
        fontSize: 11,
        color: context.driverColors.textInverse,
      ),
    ),
  );
}

/// A label on the left, its value on the right.
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.tileCaption.copyWith(
              fontSize: 11,
              color: colors.textSecondary,
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
    );
  }
}

/// One of the final checks.
///
/// The file draws all four already DONE. They are the driver's to tick: the app
/// cannot see a parking brake, and a check that marks itself is not a check.
class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.detail,
    required this.done,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Semantics(
      checked: done,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space14,
            vertical: AppSpacing.space8,
          ),
          decoration: BoxDecoration(
            color: colors.field,
            borderRadius: AppRadii.circular(AppRadii.lg),
            border: Border.all(color: done ? colors.success : colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.fieldLabel.copyWith(
                        fontSize: 13,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      detail,
                      style: AppTypography.tileCaption.copyWith(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              _Badge(
                text: done ? 'DONE' : 'TAP',
                tone: done ? colors.success : colors.borderStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
