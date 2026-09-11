import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/board_by_code_page.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/rider_row.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// The passenger manifest (prototype page 13).
///
/// One list in manifest order, not grouped into waiting and aboard. Grouping
/// was the earlier build's invention and it fights the way the screen is used:
/// a driver is looking for one named person at a door, and moving someone
/// between sections the moment they board makes the row they were just reading
/// jump somewhere else.
///
/// Search exists for the same reason. Eighteen rows is more than anyone scans
/// while a queue waits.
class ManifestPage extends StatefulWidget {
  const ManifestPage({super.key});

  @override
  State<ManifestPage> createState() => _ManifestPageState();
}

class _ManifestPageState extends State<ManifestPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final controller = context.watch<RunController>();
    final data = controller.detail.valueOrNull;

    if (data == null) return const Center(child: CircularProgressIndicator());

    final riders = _filter(data.riders, _query);

    return RefreshIndicator(
      onRefresh: controller.refreshManifest,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        children: [
          Text(
            'Passenger manifest',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            data.run.routeName,
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space16),

          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search passenger by name or boarding code',
              prefixIcon: Icon(Icons.search, color: colors.textSecondary),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: AppRadii.circular(AppRadii.full),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space12),

          _Progress(boarded: data.boarded, expected: data.expected, colors: colors),
          const SizedBox(height: AppSpacing.space12),

          if (data.riders.isEmpty)
            _Empty(
              text: 'Nobody has confirmed a seat on this run yet.',
              colors: colors,
            )
          else if (riders.isEmpty)
            _Empty(text: 'No passenger matches "$_query".', colors: colors)
          else
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.circular(AppRadii.lg),
              ),
              child: Column(
                children: [
                  for (final rider in riders)
                    RiderRow(
                      rider: rider,
                      // Boarding needs the rider's code, so the pill opens the
                      // code screen on that person rather than pretending a tap
                      // alone can board them.
                      onAction: rider.boarded ? null : () => _board(context, controller, rider),
                      onTap: rider.boarded ? null : () => _board(context, controller, rider),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _board(BuildContext context, RunController controller, ManifestRider rider) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: BoardByCodePage(preselected: rider),
        ),
      ),
    );
  }

  /// Match on name, since that is what a driver has in front of them. Boarding
  /// codes are hashed server-side, so searching one is not possible and the
  /// hint promises only what the field can do.
  static List<ManifestRider> _filter(List<ManifestRider> riders, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return riders;
    return riders.where((r) => (r.name ?? '').toLowerCase().contains(q)).toList();
  }
}

/// "12 of 18 boarded · 6 remaining", with a bar behind it.
class _Progress extends StatelessWidget {
  const _Progress({required this.boarded, required this.expected, required this.colors});

  final int boarded;
  final int expected;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final remaining = expected - boarded;
    final fraction = expected == 0 ? 0.0 : boarded / expected;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        borderRadius: AppRadii.circular(AppRadii.full),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$boarded of $expected boarded',
                  style: AppTypography.label.copyWith(color: colors.textPrimary),
                ),
              ),
              Text(
                remaining == 0 ? 'all aboard' : '$remaining remaining',
                style: AppTypography.caption.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          ClipRRect(
            borderRadius: AppRadii.circular(AppRadii.full),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(colors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space48),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.body.copyWith(color: colors.textSecondary),
    ),
  );
}
