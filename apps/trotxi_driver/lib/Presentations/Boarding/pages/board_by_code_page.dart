import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
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
/// [preselected] keeps the old order for the one place it belongs: the manifest
/// detail sheet, where the driver has already identified the person and just
/// wants the code as confirmation.
class BoardByCodePage extends StatefulWidget {
  const BoardByCodePage({super.key, required this.runId, this.preselected});

  /// The run being boarded.
  final String runId;

  /// A rider already identified on the manifest. Null is the normal case.
  final ManifestRider? preselected;

  @override
  State<BoardByCodePage> createState() => _BoardByCodePageState();
}

class _BoardByCodePageState extends State<BoardByCodePage> {
  late final ManifestRider? _rider = widget.preselected;
  final _codeController = TextEditingController();
  BoardingResult? _result;
  bool _busy = false;

  /// Who the last accepted code turned out to be, resolved from the manifest.
  ///
  /// The whole risk of typing a code with nobody selected is boarding the wrong
  /// person, so the result has to say the name back. "Boarded" alone would
  /// leave the driver no way to notice.
  String? _boardedName;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_codeController.text.length != 4 || _busy) return;
    setState(() => _busy = true);

    final trips = context.read<TripsRepository>();
    final run = context.read<RunController>();
    final rider = _rider;

    // Two paths on purpose. With a rider already named, the code confirms that
    // person; without one, it names them. The second is the door flow.
    final outcome = rider == null
        ? await trips.boardByCodeOnRun(
            runId: widget.runId,
            code: _codeController.text,
          )
        : await trips.boardByCode(
            reservationId: rider.reservationId,
            code: _codeController.text,
          );

    if (outcome.isAccepted ||
        outcome.outcome == BoardingOutcome.alreadyBoarded) {
      await run.refreshManifest();
    }
    if (!mounted) return;

    setState(() {
      _result = outcome;
      _boardedName = _nameFor(run, outcome.riderId) ?? rider?.name;
      _busy = false;
      if (outcome.isAccepted) _codeController.clear();
    });
  }

  /// Look a rider id up in the manifest already on the device.
  ///
  /// Done here rather than server-side because the manifest is loaded anyway,
  /// and an extra round trip at a door buys nothing.
  ///
  /// @param run - the run controller holding the manifest.
  /// @param riderId - the id the server returned, if any.
  /// @returns their name, or null when the manifest cannot place them.
  static String? _nameFor(RunController run, String? riderId) {
    if (riderId == null) return null;
    final riders = run.detail.valueOrNull?.riders ?? const <ManifestRider>[];
    for (final rider in riders) {
      if (rider.userId == riderId) return rider.name;
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
    final rider = _rider;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space20),
      children: [
        Text(
          rider?.name ?? 'Enter the boarding code',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          rider == null
              ? 'Four characters, read out by the rider. You do not need to find '
                    'them on the manifest first.'
              : 'Ask for their four-character boarding code.',
          style: AppTypography.body.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space24),

        TextField(
          controller: _codeController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          autocorrect: false,
          maxLength: 4,
          style: AppTypography.boardingCode.copyWith(color: colors.textPrimary),
          decoration: const InputDecoration(counterText: '', hintText: 'B7K9'),
          inputFormatters: [
            // Uppercased on the way in so the field shows what the server will
            // compare. The code alphabet has no O or I, so a driver typing a
            // letter where a digit belongs gets a clean rejection rather than a
            // silent mismatch.
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            TextInputFormatter.withFunction(
              (_, next) => next.copyWith(text: next.text.toUpperCase()),
            ),
          ],
          onChanged: (_) => setState(() => _result = null),
          onSubmitted: (_) => _submit(),
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

        const SizedBox(height: AppSpacing.space24),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Board rider'),
        ),
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
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
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
