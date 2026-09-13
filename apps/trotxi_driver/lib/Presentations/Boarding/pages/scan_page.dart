import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/board_by_code_page.dart';
import 'package:trotxi_driver/Presentations/Boarding/widgets/scan_outcome.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Scan a rider's QR pass (prototype frames 27 to 31).
///
/// The result takes over the screen rather than appearing as a snackbar. A
/// driver is holding a phone at arm's length with a queue behind them, and a
/// message that fades after four seconds is a message that gets missed.
class ScanPage extends StatefulWidget {
  const ScanPage({super.key, required this.runId});

  final String runId;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  BoardingResult? _result;
  bool _busy = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy || _result != null) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _busy = true);

    // Both read BEFORE any await. Reaching for an inherited widget after an
    // async gap is reaching into a tree that may have been torn down while the
    // camera was working.
    final trips = context.read<TripsRepository>();
    final run = context.read<RunController>();

    await _scanner.stop();
    final outcome = await trips.scan(pass: code, runId: widget.runId);

    // Only a boarding that actually happened needs the manifest re-read.
    if (outcome.isAccepted) await run.refreshManifest();
    if (!mounted) return;
    setState(() {
      _result = outcome;
      _busy = false;
    });
  }

  Future<void> _scanAgain() async {
    setState(() => _result = null);
    await _scanner.start();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final data = context.watch<RunController>().detail.valueOrNull;
    final result = _result;

    final (tone, status) = switch (result?.outcome) {
      null => (colors.action, 'SCANNING'),
      BoardingOutcome.ok => (colors.success, 'BOARDED'),
      BoardingOutcome.alreadyBoarded => (colors.warning, 'ALREADY ABOARD'),
      BoardingOutcome.expired => (colors.warning, 'EXPIRED'),
      BoardingOutcome.offline => (colors.warning, 'NO CONNECTION'),
      _ => (colors.danger, 'NOT BOARDED'),
    };

    // A tab on the shell; no Scaffold or app bar of its own.
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space24,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Scan rider pass',
                style: AppTypography.heading3.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (data != null)
              Text(
                '${data.boarded} / ${data.ceiling}',
                style: AppTypography.label.copyWith(
                  fontSize: 15,
                  color: colors.textPrimary,
                ),
              ),
          ],
        ),
        if (data != null) ...[
          const SizedBox(height: AppSpacing.space4),
          Text(
            _whereabouts(data),
            style: AppTypography.screenContext.copyWith(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: colors.field,
            borderRadius: AppRadii.circular(AppRadii.xl),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // The file keeps one status line across all five states, so the
              // driver reads the same place every time rather than hunting for
              // where the answer moved to.
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: tone,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space10),
                  Text(
                    status,
                    style: AppTypography.screenContext.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space12),

              // The camera needs a box; a result does not. The file draws the
              // panel at a fixed 406, which is a mock's height — a long name
              // and a three-line refusal both have to fit, so this takes that
              // as a floor and grows.
              if (result == null)
                SizedBox(height: 396, child: _viewfinder(context, colors, tone))
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 396),
                  child: ScanOutcome(result: result, data: data, tone: tone),
                ),

              if (result != null) ...[
                const SizedBox(height: AppSpacing.space12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.space14),
                  decoration: BoxDecoration(
                    color: colors.field,
                    borderRadius: AppRadii.circular(AppRadii.field),
                    border: Border.all(color: tone),
                  ),
                  child: Text(
                    // The money line. A driver's first question after a refusal
                    // is whether the rider was charged anyway.
                    result.deducted ? 'One ride deducted' : 'No ride deducted',
                    textAlign: TextAlign.center,
                    style: AppTypography.screenContext.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tone,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.space12),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  onPressed: result == null
                      ? () => _openCodeEntry(context)
                      : _scanAgain,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.surfaceStrong,
                    foregroundColor: colors.textPrimary,
                    textStyle: AppTypography.fieldLabel.copyWith(fontSize: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.circular(26),
                    ),
                  ),
                  child: Text(
                    result == null ? 'ENTER CODE INSTEAD' : 'BACK TO SCANNER',
                  ),
                ),
              ),
              if (result != null && !result.isAccepted) ...[
                const SizedBox(height: AppSpacing.space8),
                TextButton(
                  onPressed: () => _openCodeEntry(context),
                  child: const Text('Board by code instead'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// "Shiashie · Stop 3 of 11", or what is knowable before the first arrival.
  ///
  /// @param data - the run and its manifest.
  /// @returns the line under the title.
  static String _whereabouts(RunDetail data) {
    final total = data.stops.length;
    final seq = data.currentStopNumber;
    if (seq == null || data.currentStopName == null) {
      return total == 0
          ? data.run.routeName
          : '$total stops · none reported yet';
    }
    return '${data.currentStopName} · Stop $seq of $total';
  }

  Widget _viewfinder(BuildContext context, AppColors colors, Color tone) {
    return ClipRRect(
      borderRadius: AppRadii.circular(AppRadii.xl),
      child: Container(
        decoration: BoxDecoration(
          color: colors.scanTrack,
          borderRadius: AppRadii.circular(AppRadii.xl),
          border: Border.all(color: tone, width: 2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _scanner,
              onDetect: _onDetect,
              // The camera can be unavailable for reasons the driver can act
              // on (permission) and reasons they cannot (no camera at all).
              // Either way this has to say so and offer the code path, not
              // leave a black rectangle.
              errorBuilder: (context, error) =>
                  _CameraUnavailable(error: error, colors: colors),
            ),
            // Four corner brackets rather than a closed rectangle, which is
            // what the file draws: a full box reads as a boundary the code has
            // to sit inside, and riders hold passes closer than that.
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space24),
                child: Stack(
                  children: [
                    for (final corner in const [
                      Alignment.topLeft,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                      Alignment.bottomRight,
                    ])
                      Align(
                        alignment: corner,
                        child: _ScanCorner(corner: corner),
                      ),
                  ],
                ),
              ),
            ),
            if (_busy) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _openCodeEntry(BuildContext context) {
    final run = context.read<RunController>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: run,
          child: BoardByCodePage(runId: widget.runId),
        ),
      ),
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable({required this.error, required this.colors});

  final MobileScannerException error;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: colors.page,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: 48,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              denied ? 'Camera access is off' : 'Camera unavailable',
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              denied
                  ? 'Turn the camera on for Trotxi Driver in device settings to scan passes. '
                        'You can still board riders by code.'
                  : 'This device cannot open its camera. Board riders by code instead.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// One L-shaped corner of the viewfinder.
class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.corner});

  final Alignment corner;

  @override
  Widget build(BuildContext context) {
    final top = corner.y < 0;
    final left = corner.x < 0;
    // White in both themes. The file draws these in ink over its white "QR
    // camera area" placeholder, but they sit over a live camera feed here, and
    // the feed is whatever the driver is pointing at — not a theme surface.
    // The dark theme's ink on a night-time street is invisible.
    const side = BorderSide(color: AppPrimitiveColors.white, width: 4);
    return SizedBox(
      width: 56,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : BorderSide.none,
            bottom: top ? BorderSide.none : side,
            left: left ? side : BorderSide.none,
            right: left ? BorderSide.none : side,
          ),
        ),
      ),
    );
  }
}
