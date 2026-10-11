import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'Trips/trip_details_page.dart';
import 'Trips/confirm_ride_page.dart';
import '../pages/home_page_provider.dart';

void refreshHomeOverview(WidgetRef ref, CommuterApi client) {
  ref.invalidate(homeDetailProvider);
  ref.invalidate(homeMembershipProvider(client));
  ref.invalidate(homeUpcomingProvider(client));
  ref.invalidate(homeUpcomingDetailProvider(client));
  ref.invalidate(rideLifecycleProvider);
}

// Supplemental requests stay independent of the authoritative ride state.
// Session checks prevent late data from a previous sign-in being displayed.
final homeMembershipProvider = FutureProvider.autoDispose
    .family<wire.Membership, CommuterApi>((ref, client) async {
      final generation = client.sessionGeneration;
      final result = await client.membership();
      client.ensureSession(generation);
      return result;
    });

final homeUpcomingProvider = FutureProvider.autoDispose
    .family<wire.Reservation?, CommuterApi>((ref, client) async {
      final generation = client.sessionGeneration;
      final today = DateTime.now().toUtc();
      final rows = await client.reservations(
        from: today.toDate(),
        to: today.add(const Duration(days: 30)).toDate(),
      );
      client.ensureSession(generation);
      final active =
          rows
              .where(
                (r) =>
                    r.travelDate.compareTo(today.toDate()) >= 0 &&
                    (r.status == wire.ReservationStatusEnum.reserved ||
                        r.status == wire.ReservationStatusEnum.pending),
              )
              .toList()
            ..sort((a, b) {
              final date = a.travelDate.compareTo(b.travelDate);
              return date != 0
                  ? date
                  : a.direction.name.compareTo(b.direction.name);
            });
      return active.isEmpty ? null : active.first;
    });

final homeUpcomingDetailProvider = FutureProvider.autoDispose
    .family<wire.ReservationDetail?, CommuterApi>((ref, client) async {
      final generation = client.sessionGeneration;
      final reservation = await ref.watch(homeUpcomingProvider(client).future);
      if (reservation == null) return null;
      final detail = await ref.watch(
        homeDetailProvider((client, reservation.id)).future,
      );
      client.ensureSession(generation);
      return detail;
    });

class HomePlanSummary extends ConsumerWidget {
  const HomePlanSummary({super.key, required this.client, this.onOpen});
  final CommuterApi client;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final value = ref.watch(homeMembershipProvider(client));
    final membership = value.asData?.value;
    final active =
        membership?.coverage?.state == wire.MembershipCoverageStateEnum.open;
    final blocked =
        (membership?.access.blocks.isNotEmpty ?? false) ||
        (membership?.coverage?.paused ?? false);
    final title = value.isLoading
        ? 'Loading your plan…'
        : value.hasError
        ? 'Plan unavailable'
        : active
        ? (blocked ? 'Check your commute plan' : 'Commute plan active')
        : membership?.upcomingCoverage != null
        ? 'Your next plan is ready'
        : 'Plan your commute';
    final subtitle = value.hasError
        ? 'Tap to try again'
        : membership == null
        ? 'Your balance will appear here'
        : active
        ? '${membership.entitlements.remainingRides} rides remaining'
        : membership.upcomingCoverage != null
        ? 'View your upcoming coverage'
        : 'Choose a route and request an offer';
    return Material(
      color: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.borderSubtle),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: value.hasError
            ? () => ref.invalidate(homeMembershipProvider(client))
            : onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: colors.backgroundSubtle,
                child: Icon(
                  active && !blocked
                      ? Icons.check_rounded
                      : Icons.directions_bus_outlined,
                  size: 18,
                  color: colors.actionSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                value.hasError
                    ? Icons.refresh_rounded
                    : Icons.chevron_right_rounded,
                color: colors.actionSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeUpcoming extends ConsumerWidget {
  const HomeUpcoming({
    super.key,
    required this.client,
    this.onSeeAll,
    this.title = 'Upcoming',
  });
  final CommuterApi client;
  final VoidCallback? onSeeAll;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final upcoming = ref.watch(homeUpcomingProvider(client));
    final reservation = upcoming.asData?.value;
    final detail = reservation == null
        ? null
        : ref.watch(homeUpcomingDetailProvider(client)).asData?.value;
    final date = reservation?.travelDate.toDateTime();
    final scheduled = detail?.trip?.scheduledAt.toUtc();
    final cancelled =
        detail?.trip?.status == wire.ReservationDetailTripStatusEnum.cancelled;
    final pending = reservation?.status == wire.ReservationStatusEnum.pending;
    final subtitle = upcoming.isLoading
        ? 'Loading your upcoming trips…'
        : upcoming.hasError
        ? 'Could not load upcoming trips. Tap to retry.'
        : reservation == null
        ? 'Your next reservation will appear here.'
        : cancelled
        ? 'Trip cancelled'
        : pending
        ? 'Awaiting confirmation'
        : 'Seat confirmed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.label.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Material(
          color: colors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.borderSubtle),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: upcoming.hasError
                ? () => ref.invalidate(homeUpcomingProvider(client))
                : reservation == null
                ? onSeeAll
                : () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => pending && !cancelled
                            ? ConfirmRidePage(
                                client: client,
                                reservationId: reservation.id,
                              )
                            : TripDetailsPage(
                                client: client,
                                reservationId: reservation.id,
                              ),
                      ),
                    );
                    if (context.mounted) refreshHomeOverview(ref, client);
                  },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (date != null) ...[
                    Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.backgroundSubtle,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEE').format(date).toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: colors.actionSecondary,
                            ),
                          ),
                          Text(
                            DateFormat('d').format(date),
                            style: AppTypography.title.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail?.route?.name ??
                              (reservation == null
                                  ? upcoming.isLoading
                                        ? 'Finding your next trip'
                                        : upcoming.hasError
                                        ? 'Trips unavailable'
                                        : 'No trip to show yet'
                                  : reservation.direction ==
                                        wire.ReservationDirectionEnum.outbound
                                  ? 'Outbound commute'
                                  : 'Return commute'),
                          style: AppTypography.label.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (scheduled != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Departs ${DateFormat('h:mm a').format(scheduled)}',
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTypography.caption.copyWith(
                            color: cancelled
                                ? colors.error
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    upcoming.hasError
                        ? Icons.refresh_rounded
                        : Icons.chevron_right_rounded,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
