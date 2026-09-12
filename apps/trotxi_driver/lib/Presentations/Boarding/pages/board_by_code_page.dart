import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/rider_row.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Board a rider by the code they read out (prototype frames 32 to 34).
///
/// The rider is picked off the manifest FIRST, then the code is typed. That is
/// the order the API enforces too: a code is only ever checked against one
/// named seat, which is what stops four characters from being a guessable key
/// to the whole run.
class BoardByCodePage extends StatefulWidget {
  const BoardByCodePage({super.key, this.preselected});

  /// Skips the picker when the manifest already named who is boarding.
  final ManifestRider? preselected;

  @override
  State<BoardByCodePage> createState() => _BoardByCodePageState();
}

class _BoardByCodePageState extends State<BoardByCodePage> {
  late ManifestRider? _rider = widget.preselected;
  final _codeController = TextEditingController();
  BoardingResult? _result;
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rider = _rider;
    if (rider == null || _codeController.text.length != 4 || _busy) return;

    setState(() => _busy = true);
    final outcome = await context.read<TripsRepository>().boardByCode(
      reservationId: rider.reservationId,
      code: _codeController.text,
    );
    if (!mounted) return;
    if (outcome.isAccepted) {
      await context.read<RunController>().refreshManifest();
    }
    if (!mounted) return;
    setState(() {
      _result = outcome;
      _busy = false;
      if (outcome.isAccepted) _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final detail = context.watch<RunController>().detail.valueOrNull;
    final waiting = detail?.waiting ?? const <ManifestRider>[];
    // The whole manifest, so a rider's number here is the same one the manifest
    // screen shows them. Numbering against `waiting` would renumber everybody
    // each time someone boards.
    final all = detail?.riders ?? const <ManifestRider>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Board by code')),
      body: SafeArea(
        child: _rider == null
            ? _pickRider(waiting, all, colors)
            : _enterCode(context, _rider!, colors),
      ),
    );
  }

  Widget _pickRider(
    List<ManifestRider> waiting,
    List<ManifestRider> all,
    AppColors colors,
  ) {
    if (waiting.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space32),
          child: Text(
            'Everyone with a confirmed seat is already aboard.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      children: [
        Text(
          'Who is boarding?',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space16),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.circular(AppRadii.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              for (final rider in waiting)
                RiderRow(
                  rider: rider,
                  position: all.indexOf(rider) + 1,
                  total: all.length,
                  onTap: () => setState(() {
                    _rider = rider;
                    _result = null;
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _enterCode(
    BuildContext context,
    ManifestRider rider,
    AppColors colors,
  ) {
    final result = _result;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space20),
      children: [
        Text(
          rider.name ?? 'Unnamed rider',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          'Ask for their four-character boarding code.',
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.circular(AppRadii.md),
              border: Border.all(
                color: result.isAccepted ? colors.success : colors.danger,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: AppTypography.label.copyWith(
                    color: result.isAccepted ? colors.success : colors.danger,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  result.detail,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.space24),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Board rider'),
        ),
        const SizedBox(height: AppSpacing.space12),
        OutlinedButton(
          onPressed: () => setState(() {
            _rider = null;
            _result = null;
            _codeController.clear();
          }),
          child: const Text('Pick someone else'),
        ),
      ],
    );
  }
}
