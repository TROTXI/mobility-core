import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Completion/pages/run_summary_page.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';

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
  static const _checks = [
    'Vehicle is safely stopped',
    'All riders have alighted',
    'No belongings left on board',
  ];

  final _done = <String>{};
  bool _ending = false;

  bool get _ready => _done.length == _checks.length;

  Future<void> _end() async {
    if (!_ready || _ending) return;
    setState(() => _ending = true);
    final controller = context.read<RunController>();
    await controller.complete();
    if (!mounted) return;
    setState(() => _ending = false);

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
    final waiting = context.watch<RunController>().detail.valueOrNull?.waiting.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('End trip?')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space20),
          children: [
            Text(
              'Ending a trip cannot be undone.',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            if (waiting > 0) ...[
              const SizedBox(height: AppSpacing.space16),
              Container(
                padding: const EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadii.circular(AppRadii.md),
                  border: Border.all(color: colors.warning),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      waiting == 1 ? '1 rider never boarded' : '$waiting riders never boarded',
                      style: AppTypography.label.copyWith(color: colors.warning),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      // Deliberately not "they will be charged". Whether a seat
                      // is deducted is the ops cutoff's decision, not this
                      // screen's, and a driver should not read a deduction that
                      // has not happened.
                      'They stay on the manifest as not boarded. Operations decides '
                      'what happens to their seat.',
                      style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space24),
            Text(
              'BEFORE YOU FINISH',
              style: AppTypography.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space8),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.circular(AppRadii.lg),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  for (final check in _checks)
                    CheckboxListTile(
                      value: _done.contains(check),
                      onChanged: (on) => setState(() {
                        if (on ?? false) {
                          _done.add(check);
                        } else {
                          _done.remove(check);
                        }
                      }),
                      title: Text(
                        check,
                        style: AppTypography.body.copyWith(color: colors.textPrimary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            ElevatedButton(
              onPressed: _ready && !_ending ? _end : null,
              child: _ending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('End trip'),
            ),
            const SizedBox(height: AppSpacing.space12),
            OutlinedButton(
              onPressed: _ending ? null : () => Navigator.of(context).pop(),
              child: const Text('Keep trip active'),
            ),
          ],
        ),
      ),
    );
  }
}
