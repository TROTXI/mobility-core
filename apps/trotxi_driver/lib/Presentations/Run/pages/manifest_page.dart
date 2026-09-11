import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/rider_row.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';

/// The passenger manifest (prototype frames 35 and 36).
///
/// Waiting riders first. The manifest is consulted while people are boarding,
/// so the useful half is who is still expected, not who is already aboard.
class ManifestPage extends StatelessWidget {
  const ManifestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final controller = context.watch<RunController>();
    final data = controller.detail.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Passenger manifest')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshManifest,
          child: data == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: AppSpacing.space16,
                  ),
                  children: [
                    Text(
                      '${data.boarded} of ${data.expected} aboard',
                      style: AppTypography.heading3.copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.space20),
                    if (data.riders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space48),
                        child: Text(
                          'Nobody has confirmed a seat on this run yet.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(color: colors.textSecondary),
                        ),
                      )
                    else ...[
                      if (data.waiting.isNotEmpty) ...[
                        _GroupLabel(text: 'Waiting', colors: colors),
                        _Group(
                          colors: colors,
                          children: [for (final r in data.waiting) RiderRow(rider: r)],
                        ),
                        const SizedBox(height: AppSpacing.space24),
                      ],
                      if (data.boarded > 0) ...[
                        _GroupLabel(text: 'Aboard', colors: colors),
                        _Group(
                          colors: colors,
                          children: [
                            for (final r in data.riders.where((r) => r.boarded))
                              RiderRow(rider: r),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.caption.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children, required this.colors});

  final List<Widget> children;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(children: children),
    );
  }
}
