import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/commuter_trip_tracking.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
import 'package:trotxi_commuter/core/widgets/figma_commuter_icon.dart';

String rideJourneyName(wire.ReservationDetail? detail) =>
    detail?.pickupStop != null && detail?.dropoffStop != null
    ? '${detail!.pickupStop!.name} → ${detail.dropoffStop!.name}'
    : detail?.route?.name ?? 'Your commute';

/// Figma 2444:1115. Only completed, boarded reservations reach this card.
/// Arrival time and ride duration are deliberately absent until the API
/// supplies them. The scheduled departure is not an arrival timestamp.
class CompletedRideSummary extends StatelessWidget {
  const CompletedRideSummary({
    super.key,
    required this.detail,
    required this.onDetails,
    this.remainingRides,
  });
  final wire.ReservationDetail? detail;
  final VoidCallback onDetails;
  final int? remainingRides;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RideHero(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: c.actionPrimaryDefault,
                  child: Text(
                    '✓',
                    style: TextStyle(color: c.actionOnPrimary, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'TRIP COMPLETED',
                    style: AppTypography.caption.copyWith(
                      color: c.onSurfaceStrong,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              rideJourneyName(detail),
              style: AppTypography.title.copyWith(
                color: c.onSurfaceStrong,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail == null
                  ? 'Thank you for riding with Trotxi.'
                  : DateFormat(
                      'EEE, d MMM',
                    ).format(detail!.reservation.travelDate.toDateTime()),
              style: AppTypography.caption.copyWith(
                color: c.onSurfaceStrong.withValues(alpha: .8),
              ),
            ),
            if (detail?.pickupStop != null && detail?.dropoffStop != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  _StopDot(color: c.actionSecondary),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: c.actionSecondary.withValues(alpha: .5),
                    ),
                  ),
                  _StopDot(color: c.actionSecondary),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      detail!.pickupStop!.name,
                      style: AppTypography.caption.copyWith(
                        color: c.onSurfaceStrong,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      detail!.dropoffStop!.name,
                      textAlign: TextAlign.right,
                      style: AppTypography.caption.copyWith(
                        color: c.onSurfaceStrong,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        AppSurface(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your ride',
                style: AppTypography.label.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _RideStat('Status', 'Completed'),
                  if (remainingRides != null)
                    _RideStat('Remaining', '$remainingRides rides'),
                  TextButton(
                    onPressed: onDetails,
                    child: const Text('View trip'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Figma 2444:836 and 2444:1014 with real, access-checked tracking data.
/// ETA zero/absence never means arrived. Missing ETAs never imply stops passed.
class LiveRideJourney extends StatelessWidget {
  const LiveRideJourney({
    super.key,
    required this.boarded,
    required this.detail,
    required this.snapshot,
    required this.map,
    required this.onBoardingPass,
    required this.onExpand,
    this.error,
    this.loading = false,
  });
  final bool boarded, loading;
  final wire.ReservationDetail? detail;
  final CommuterTripSnapshot? snapshot;
  final Widget? map;
  final String? error;
  final VoidCallback onBoardingPass, onExpand;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final live = snapshot;
    final ended = live?.live.state == wire.LiveTripStateEnum.ended;
    final pickupEta = live?.fresh == true ? live?.pickupEta : null;
    final approaching = !boarded && pickupEta != null && !ended;
    final stops = live?.stops ?? const <wire.StopOccurrence>[];
    final etas = live?.etas ?? const <wire.StopEta>[];
    final destination = detail?.dropoffStop?.occurrenceId;
    final destinationEta = etas
        .where((e) => e.stopOccurrenceId == destination)
        .firstOrNull;
    final nextEta = etas.isEmpty
        ? null
        : (etas.toList()..sort(
                (a, b) => a.durationSeconds.compareTo(b.durationSeconds),
              ))
              .first;
    final vehicle =
        detail?.trip?.vehiclePlate ??
        detail?.trip?.vehicleLabel ??
        live?.trip.vehicleLabel;
    final mapPanel = map == null
        ? null
        : ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: boarded ? 252 : 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  map!,
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 12,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            live?.fresh == true
                                ? boarded && destinationEta != null
                                      ? '~${(destinationEta.durationSeconds / 60).ceil()} min to your stop'
                                      : 'Live vehicle location'
                                : live?.hasPosition == true
                                ? 'Last known location'
                                : 'Route overview',
                            style: AppTypography.caption.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!boarded || mapPanel == null)
          _RideHero(
            children: [
              Text(
                ended
                    ? 'TRIP ENDED'
                    : approaching
                    ? 'VEHICLE APPROACHING'
                    : boarded
                    ? 'ON BOARD'
                    : 'RIDE CONFIRMED',
                style: AppTypography.caption.copyWith(
                  color: c.onSurfaceStrong,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                ended
                    ? 'Updating your trip'
                    : approaching
                    ? pickupEta.durationSeconds < 60
                          ? 'Less than 1 min away'
                          : '~${(pickupEta.durationSeconds / 60).ceil()} min away'
                    : boarded
                    ? 'Enjoy your ride'
                    : 'Your seat is reserved',
                style: AppTypography.title.copyWith(
                  color: c.onSurfaceStrong,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                approaching
                    ? 'Estimated arrival at ${detail?.pickupStop?.name ?? 'your pickup'}'
                    : rideJourneyName(detail),
                style: AppTypography.caption.copyWith(
                  color: c.onSurfaceStrong.withValues(alpha: .8),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vehicle ?? 'Vehicle details will appear here',
                      style: AppTypography.label.copyWith(
                        color: c.onSurfaceStrong,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!boarded && !ended)
                    IconButton.filled(
                      tooltip: 'View boarding pass',
                      onPressed: onBoardingPass,
                      style: IconButton.styleFrom(
                        backgroundColor: c.actionPrimaryDefault,
                        foregroundColor: c.actionOnPrimary,
                        minimumSize: const Size(54, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: FigmaCommuterIcon(
                        CommuterIcon.boardingCode,
                        color: c.actionOnPrimary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        if (loading && live == null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          ),
        if (error != null || live?.fresh != true) ...[
          const SizedBox(height: 12),
          Text(
            error ??
                (live?.hasPosition == true
                    ? 'Location updates are delayed. Arrival times may change.'
                    : 'Waiting for a live location update.'),
            style: AppTypography.caption.copyWith(color: c.textSecondary),
          ),
        ],
        if (!boarded && approaching) ...[
          const SizedBox(height: 16),
          const AppSurface(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Be ready at your pickup point',
                  style: AppTypography.label,
                ),
                SizedBox(height: 4),
                Text(
                  'Keep your boarding code ready.',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
        if (mapPanel != null) ...[
          if (!boarded) const SizedBox(height: 16),
          mapPanel,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onExpand,
              child: const Text('Expand map'),
            ),
          ),
        ],
        if (boarded && stops.isNotEmpty) ...[
          AppSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your journey', style: AppTypography.label),
                const SizedBox(height: 6),
                Text(
                  '${stops.length} stops on this route',
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 16),
                // This represents the published route, not guessed vehicle progress.
                for (final stop in stops)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        _StopDot(
                          color: stop.id == destination
                              ? c.actionSecondary
                              : c.borderSubtle,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(stop.name, style: AppTypography.caption),
                        ),
                        if (stop.id == destination)
                          Text(
                            'Your stop',
                            style: AppTypography.caption.copyWith(
                              color: c.actionSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (boarded && nextEta != null && live?.fresh == true) ...[
          const SizedBox(height: 16),
          AppSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next estimated stop',
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  '${live!.stopName(nextEta.stopOccurrenceId)} · ~${(nextEta.durationSeconds / 60).ceil()} min',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RideHero extends StatelessWidget {
  const _RideHero({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: context.appColors.surfaceStrong,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _StopDot extends StatelessWidget {
  const _StopDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _RideStat extends StatelessWidget {
  const _RideStat(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTypography.caption.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        value,
        style: AppTypography.label.copyWith(
          color: context.appColors.textPrimary,
        ),
      ),
    ],
  );
}
