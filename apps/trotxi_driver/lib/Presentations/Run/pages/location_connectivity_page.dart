import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/run_map.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/driver_tiles.dart';
import 'package:trotxi_driver/data/position_publisher.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Detailed, actionable location state for a live run (design page 14).
class LocationConnectivityPage extends StatelessWidget {
  const LocationConnectivityPage({super.key, required this.run});

  final DriverRun run;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final positions = context.watch<PositionPublisher>();
    final state = _gpsState(positions);
    final weak = positions.state == PositionSharing.weak;
    return Scaffold(
      appBar: AppBar(title: const Text('Location & connectivity')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.space20),
              children: [
                Text(
                  run.routeName,
                  style: AppTypography.heading2.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Live trip location status',
                  style: AppTypography.screenContext.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                GpsIndicator(state: state, detail: _gpsDetail(positions)),
                if (positions.expiredFixes > 0)
                  ListTile(
                    title: Text(
                      '${positions.expiredFixes} saved GPS positions expired before upload.',
                    ),
                    subtitle: const Text(
                      'Positions are kept on this phone for at most 24 hours. These positions were not uploaded.',
                    ),
                    trailing: TextButton(
                      onPressed: positions.acknowledgeExpiry,
                      child: const Text('Understood'),
                    ),
                  ),
                if (positions.queuedFixes > 0 || positions.queueError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      positions.queueError ??
                          '${positions.queuedFixes} GPS positions saved on this phone, waiting to upload. Keep this account signed in.',
                    ),
                  ),
                const SizedBox(height: AppSpacing.space16),
                RunMap(
                  routeId: run.routeId,
                  runId: run.id,
                  isActive: run.isActive,
                  height: 320,
                ),
                const SizedBox(height: AppSpacing.space16),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: AppRadii.circular(AppRadii.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weak
                            ? 'GPS signal is weak'
                            : _explanationTitle(positions),
                        style: AppTypography.tileLabel.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        weak
                            ? 'You are online, but location accuracy is reduced. Riders may see an approximate bus position.'
                            : _explanation(positions),
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space20),
                OutlinedButton(
                  onPressed: run.isActive ? positions.retry : null,
                  child: const Text('Retry GPS'),
                ),
                const SizedBox(height: AppSpacing.space12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static GpsState _gpsState(PositionPublisher positions) =>
      switch (positions.state) {
        PositionSharing.live => GpsState.live,
        PositionSharing.weak => GpsState.weak,
        PositionSharing.checking || PositionSharing.waiting => GpsState.waiting,
        PositionSharing.stale => GpsState.stale,
        PositionSharing.failed => GpsState.failed,
        PositionSharing.idle || PositionSharing.blocked => GpsState.disabled,
      };

  static String _gpsDetail(
    PositionPublisher positions,
  ) => switch (positions.state) {
    PositionSharing.live => 'A recent position was received by the API',
    PositionSharing.weak =>
      'Accuracy reduced${positions.lastAccuracyMeters == null ? '' : ' · approximately ±${positions.lastAccuracyMeters!.round()}m'}',
    PositionSharing.checking => 'Checking location access',
    PositionSharing.waiting => 'Waiting for the first confirmed position',
    PositionSharing.stale => 'No recent position confirmed',
    PositionSharing.failed => 'Update not confirmed · retrying',
    PositionSharing.idle => 'No position is being shared',
    PositionSharing.blocked => 'Location access needs attention',
  };

  static String _explanationTitle(PositionPublisher positions) =>
      switch (positions.state) {
        PositionSharing.live => 'Location is current',
        PositionSharing.checking ||
        PositionSharing.waiting => 'Waiting for a confirmed fix',
        PositionSharing.stale => 'Location is out of date',
        PositionSharing.failed => 'The last update did not reach Trotxi',
        PositionSharing.idle ||
        PositionSharing.blocked => 'Location sharing is stopped',
        PositionSharing.weak => 'GPS signal is weak',
      };

  static String _explanation(
    PositionPublisher positions,
  ) => switch (positions.state) {
    PositionSharing.live => 'Trotxi recently received this vehicle’s position.',
    PositionSharing.checking || PositionSharing.waiting =>
      'Keep this screen open while the device finds and confirms a position.',
    PositionSharing.stale =>
      'Riders may see an older position until a new fix is confirmed.',
    PositionSharing.failed =>
      'The app will try the next fresh position. You can also retry now.',
    PositionSharing.idle || PositionSharing.blocked =>
      'Check device location and app permission before retrying.',
    PositionSharing.weak => 'You are online, but location accuracy is reduced.',
  };
}
