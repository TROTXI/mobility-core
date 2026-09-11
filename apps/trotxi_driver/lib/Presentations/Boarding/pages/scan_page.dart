import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/board_by_code_page.dart';
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
  final _scanner = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Scan rider pass')),
      body: SafeArea(
        child: _result == null ? _viewfinder(context) : _outcome(context, _result!),
      ),
    );
  }

  Widget _viewfinder(BuildContext context) {
    final colors = context.driverColors;
    return Column(
      children: [
        Expanded(
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
              IgnorePointer(
                child: Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.onAction, width: 3),
                      borderRadius: AppRadii.circular(AppRadii.xl),
                    ),
                  ),
                ),
              ),
              if (_busy) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Column(
            children: [
              Text(
                'Hold the rider’s QR inside the frame.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space12),
              OutlinedButton(
                onPressed: () => _openCodeEntry(context),
                child: const Text('Enter code instead'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _outcome(BuildContext context, BoardingResult result) {
    final colors = context.driverColors;
    final tone = switch (result.outcome) {
      BoardingOutcome.ok => colors.success,
      BoardingOutcome.alreadyBoarded => colors.warning,
      BoardingOutcome.expired => colors.warning,
      _ => colors.danger,
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            child: Icon(
              result.isAccepted ? Icons.check : Icons.close,
              size: 56,
              color: colors.textInverse,
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          Text(
            result.title,
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(color: tone),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            result.detail,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
          const Spacer(),
          ElevatedButton(onPressed: _scanAgain, child: const Text('Scan next rider')),
          const SizedBox(height: AppSpacing.space12),
          OutlinedButton(
            onPressed: () => _openCodeEntry(context),
            child: const Text('Board by code instead'),
          ),
        ],
      ),
    );
  }

  void _openCodeEntry(BuildContext context) {
    final run = context.read<RunController>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: run,
          child: const BoardByCodePage(),
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
            Icon(Icons.no_photography_outlined, size: 48, color: colors.textSecondary),
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
