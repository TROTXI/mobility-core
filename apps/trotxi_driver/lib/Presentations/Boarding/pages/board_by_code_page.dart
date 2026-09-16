import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/Presentations/Boarding/widgets/boarding_keypad.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Board by code (prototype frames 32 to 34).
///
/// Opens on the keypad, with nobody picked. A rider reads out four characters
/// and the driver types them — that is the whole job, and the earlier build
/// made it two by demanding a name off the manifest first. At a door with a
/// queue, hunting for "Akosua Frimpong-Boateng" before you may type the code
/// she just said is the wrong order.
///
/// The server searches the run's open seats (#241). Safe because the caller is
/// already the assigned driver, who can board anyone on their manifest with no
/// code at all.
///
/// Codes identify a reservation across the run; they do not confirm a
/// preselected passenger. Only the returned reservation supplies the name.
class BoardByCodePage extends StatefulWidget {
  const BoardByCodePage({super.key, required this.runId});

  /// The run being boarded.
  final String runId;

  @override
  State<BoardByCodePage> createState() => _BoardByCodePageState();
}

class _BoardByCodePageState extends State<BoardByCodePage> {
  /// What has been keyed so far. A plain string rather than a controller: the
  /// keypad owns input now, so there is no text field to drive.
  String _code = '';

  BoardingResult? _result;
  bool _busy = false;

  /// Who the last accepted code turned out to be, resolved from the manifest.
  ///
  /// The whole risk of typing a code with nobody selected is boarding the wrong
  /// person, so the result has to say the name back. "Boarded" alone would
  /// leave the driver no way to notice.
  String? _boardedName;

  Future<void> _submit() async {
    if (_code.length != 4 || _busy) return;
    setState(() => _busy = true);

    final trips = context.read<TripsRepository>();
    final run = context.read<RunController>();
    final outcome = await trips.boardByCodeOnRun(
      runId: widget.runId,
      code: _code,
    );

    if (outcome.isAccepted ||
        outcome.outcome == BoardingOutcome.alreadyBoarded) {
      await run.refreshManifest();
    }
    if (!mounted) return;

    setState(() {
      _result = outcome;
      _boardedName = _nameFor(run, outcome.reservationId);
      _busy = false;
      // Cleared on success so the next rider can be keyed straight away, and
      // kept on failure so a driver can correct one character rather than
      // retype all four.
      if (outcome.isAccepted) _code = '';
    });
  }

  /// Look a rider id up in the manifest already on the device.
  ///
  /// Done here rather than server-side because the manifest is loaded anyway,
  /// and an extra round trip at a door buys nothing.
  ///
  /// @param run - the run controller holding the manifest.
  /// @param reservationId - the id the server returned, if any.
  /// @returns their name, or null when the manifest cannot place them.
  static String? _nameFor(RunController run, String? reservationId) {
    if (reservationId == null) return null;
    final riders = run.detail.valueOrNull?.riders ?? const <ManifestRider>[];
    for (final rider in riders) {
      if (rider.reservationId == reservationId) return rider.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Board by code')),
      body: SafeArea(child: _body(context, colors)),
    );
  }

  Widget _body(BuildContext context, AppColors colors) {
    final result = _result;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space20),
      children: [
        Text(
          'Board by code',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          'Four characters, read out by the rider. The code identifies their '
          'reservation on this run.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space20),

        BoardingCodeDisplay(code: _code),
        const SizedBox(height: AppSpacing.space8),
        Text(
          "Enter the rider's 4-character boarding code",
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),

        if (result != null) ...[
          const SizedBox(height: AppSpacing.space16),
          _ResultCard(
            result: result,
            name: _boardedName,
            colors: colors,
            onOpenManifest: result.needsManifest
                ? () => Navigator.of(context).pop()
                : null,
          ),
        ],

        const SizedBox(height: AppSpacing.space20),
        BoardingKeypad(
          enabled: !_busy,
          canSubmit: _code.length == 4,
          onKey: (key) => setState(() {
            if (_code.length < 4) _code += key;
            // Any new keystroke means the driver has moved on from the last
            // answer, so the old result stops applying.
            _result = null;
          }),
          onClear: () => setState(() {
            _code = '';
            _result = null;
          }),
          onSubmit: _submit,
        ),

        if (_busy) ...[
          const SizedBox(height: AppSpacing.space16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

/// What the code did, named.
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.name,
    required this.colors,
    required this.onOpenManifest,
  });

  final BoardingResult result;

  /// Who it turned out to be. The point of showing it: a driver who typed a
  /// code with nobody selected needs to see the name to know it was the person
  /// standing in front of them.
  final String? name;

  final AppColors colors;
  final VoidCallback? onOpenManifest;

  @override
  Widget build(BuildContext context) {
    final tone = result.isAccepted ? colors.success : colors.danger;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: tone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name == null ? result.title : '${result.title} — $name',
            style: AppTypography.label.copyWith(color: tone),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            result.detail,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (onOpenManifest != null) ...[
            const SizedBox(height: AppSpacing.space12),
            OutlinedButton(
              onPressed: onOpenManifest,
              child: const Text('Find them on the manifest'),
            ),
          ],
        ],
      ),
    );
  }
}
