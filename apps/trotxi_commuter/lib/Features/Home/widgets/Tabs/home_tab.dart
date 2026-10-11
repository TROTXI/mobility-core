import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/notifications_inbox_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/home_overview.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_commuter/core/widgets/figma_commuter_icon.dart';
import '../Trips/ride_rating_card.dart';
import '../Trips/ride_journey_cards.dart';
import '../Trips/confirm_ride_page.dart';
import 'trip_tracking_page.dart';
import 'pass_tab.dart';

// ---------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------

class QuickAction {
  const QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.figmaIcon,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final CommuterIcon? figmaIcon;
}

// ---------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({
    super.key,
    required this.client,
    required this.userData,
    this.onShowBoardingPass,
    this.onShowTrips,
    this.onShowRoutes,
    this.onShowWallet,
    this.onShowSupport,
    this.onShowProfile,
    this.isActive = true,
  });

  final CommuterApi client;

  final Account userData;

  final VoidCallback? onShowBoardingPass;
  final VoidCallback? onShowTrips;
  final VoidCallback? onShowRoutes;
  final VoidCallback? onShowWallet;
  final VoidCallback? onShowSupport;
  final VoidCallback? onShowProfile;
  final bool isActive;

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> with WidgetsBindingObserver {
  Timer? _statusRefresh;
  bool _foreground = true;
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _statusRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted &&
          _foreground &&
          widget.isActive &&
          !_covered &&
          (ModalRoute.of(context)?.isCurrent ?? true) &&
          !ref.read(rideLifecycleProvider).isLoading) {
        ref.invalidate(homeDetailProvider);
        ref.invalidate(rideLifecycleProvider);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && widget.isActive) refreshHomeOverview(ref, widget.client);
  }

  @override
  void dispose() {
    _statusRefresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _openRidePage(Widget page) async {
    setState(() => _covered = true);
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    if (!mounted) return;
    setState(() => _covered = false);
    refreshHomeOverview(ref, widget.client);
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) refreshHomeOverview(ref, widget.client);
      });
    }
  }

  List<QuickAction> _quickActions(wire.ReservationDetail? detail) => [
    if (detail?.pickupStop != null)
      QuickAction(
        icon: Icons.info_outline,
        figmaIcon: CommuterIcon.info,
        label: 'Pickup info',
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TripDetailsPage(
                client: widget.client,
                reservationId: detail!.reservation.id,
              ),
            ),
          );
          if (mounted) refreshHomeOverview(ref, widget.client);
        },
      ),
    QuickAction(
      icon: Icons.route_outlined,
      label: 'Routes',
      onTap: widget.onShowRoutes,
    ),
    QuickAction(
      icon: Icons.notifications_none_rounded,
      label: 'Updates',
      onTap: _showInbox,
    ),
    QuickAction(
      icon: Icons.help_outline_rounded,
      label: 'Support',
      onTap: widget.onShowSupport,
    ),
  ];
  bool _deciding = false;

  Future<void> _showInbox() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsInboxPage(client: widget.client),
      ),
    );
    if (mounted) refreshHomeOverview(ref, widget.client);
  }

  Future<void> _refresh() async {
    refreshHomeOverview(ref, widget.client);
    await ref.read(rideLifecycleProvider.future);
  }

  String get _firstName {
    final displayName = widget.userData.displayName;
    if (displayName.trim().isEmpty) return 'there';
    return displayName.trim().split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _onShowBoardingPass() {
    if (widget.onShowBoardingPass != null) {
      widget.onShowBoardingPass!();
      return;
    }
    debugPrint(
      'Show boarding pass tapped, but no onShowBoardingPass callback '
      'was provided to HomeTab.',
    );
  }

  Future<void> _onEveningPromptResponse(bool travelingHome) async {
    if (_deciding) return;
    setState(() => _deciding = true);
    final direction = ref.read(selectedDirectionProvider);
    try {
      await widget.client.decideReservation(
        wire.ReservationDecision(
          (b) => b
            ..travelDate = wire.Date.now(utc: true)
            ..direction = direction == CommuteDirection.outbound
                ? wire.ReservationDecisionDirectionEnum.outbound
                : wire.ReservationDecisionDirectionEnum.return_
            ..decision = travelingHome
                ? wire.ReservationDecisionDecisionEnum.confirm
                : wire.ReservationDecisionDecisionEnum.decline,
        ),
      );
      if (mounted) {
        refreshHomeOverview(ref, widget.client);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is TrotxiException
                  ? e.message
                  : 'Could not update your reservation.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deciding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rideLifecycleProvider, (previous, next) {
      final current = next.asData?.value;
      if ((current is RideBoarded || current is RideCompleted) &&
          previous?.asData?.value.runtimeType != current.runtimeType) {
        ref.invalidate(homeMembershipProvider(widget.client));
      }
    });
    final lifecycleAsync = ref.watch(rideLifecycleProvider);
    final detail = ref.watch(homeReservationDetailProvider).asData?.value;

    return Scaffold(
      backgroundColor: context.appColors.backgroundDefault,
      // No TextField lives directly in this tab, so it never needs to shrink
      // for the keyboard — and a stuck/phantom bottom inset (seen on some
      // OEM ROMs after a dialog's keyboard closes) must not squash it either.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildGreetingHeader(lifecycleAsync.asData?.value),
                  const SizedBox(height: 20),
                  ...lifecycleAsync.when(
                    data: (state) => _buildLifecycleSection(state),
                    loading: () => [_buildLoadingCard()],
                    error: (err, st) => [_buildErrorCard()],
                  ),
                  const SizedBox(height: 16),
                  if (lifecycleAsync.asData?.value is! RideCompleted) ...[
                    HomePlanSummary(
                      client: widget.client,
                      onOpen: widget.onShowWallet,
                    ),
                    const SizedBox(height: 20),
                    _buildQuickActionsRow(detail),
                    const SizedBox(height: 16),
                  ],
                  HomeUpcoming(
                    client: widget.client,
                    onSeeAll: widget.onShowTrips,
                    title: lifecycleAsync.asData?.value is RideCompleted
                        ? 'Next commute'
                        : 'Upcoming',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Greeting header
  // ---------------------------------------------------------------------

  Widget _buildGreetingHeader(RideLifecycleState? state) {
    final colors = context.appColors;
    final subtitle = switch (state) {
      RideReserved() => 'Your seat is confirmed for this departure.',
      RideBoarded() => 'You are on your way.',
      RideCompleted() => 'Your commute is complete.',
      _ => 'Your commute at a glance.',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state is RideCompleted
                      ? "You've arrived, $_firstName"
                      : state is RideBoarded
                      ? 'Trip in progress'
                      : '$_greeting, $_firstName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading1.copyWith(
                    fontSize: 22,
                    letterSpacing: -.4,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (AppThemeControllerScope.maybeOf(context) case final controller?)
            IconButton(
              tooltip: Theme.of(context).brightness == Brightness.dark
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              onPressed: () => controller.toggle(Theme.of(context).brightness),
              icon: FigmaCommuterIcon(
                Theme.of(context).brightness == Brightness.dark
                    ? CommuterIcon.sun
                    : CommuterIcon.moon,
              ),
            ),
          if (widget.onShowProfile != null)
            IconButton(
              tooltip: 'Open profile',
              onPressed: widget.onShowProfile,
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: colors.actionPrimaryDefault,
                backgroundImage: widget.userData.avatarUrl?.isNotEmpty == true
                    ? NetworkImage(widget.userData.avatarUrl!)
                    : null,
                child: widget.userData.avatarUrl?.isNotEmpty == true
                    ? null
                    : Text(
                        _firstName[0].toUpperCase(),
                        style: AppTypography.label.copyWith(
                          color: colors.actionOnPrimary,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Lifecycle-driven section
  //
  // This is the piece that actually answers "render a given UI at a
  // particular time within the ride lifecycle": one card (or two, for
  // loading/error) per RideLifecycleState, sitting between the greeting
  // and the stats row.
  // ---------------------------------------------------------------------

  List<Widget> _buildLifecycleSection(RideLifecycleState? state) {
    final colors = context.appColors;
    return switch (state) {
      // No reservation exists yet for today's direction.
      null => [_buildNoReservationCard()],

      RidePending(:final reservationId) => [
        if (reservationId == null)
          _buildPendingCard()
        else
          _buildReviewCard(
            reservationId,
            ref.watch(homeReservationDetailProvider).asData?.value,
          ),
      ],

      RideReserved(:final etaPhase, :final reservationId) => [
        if (ref
                .watch(homeReservationDetailProvider)
                .asData
                ?.value
                ?.trip
                ?.status ==
            wire.ReservationDetailTripStatusEnum.active)
          _buildLiveJourney(state)
        else
          _buildReservedCard(
            etaPhase,
            reservationId == null
                ? null
                : ref.watch(homeReservationDetailProvider).asData?.value,
          ),
      ],

      RideBoarded() => [_buildLiveJourney(state)],
      RideCompleted(:final reservationId) => _buildCompletedSection(
        reservationId,
      ),

      RideDeclined() => [
        _buildStatusCard(
          icon: Icons.event_busy_rounded,
          title: 'Reservation declined',
          message: "This trip wasn't confirmed. Try reserving another slot.",
          accentColor: colors.actionSecondary,
        ),
      ],

      RideUnseated() => [
        _buildStatusCard(
          icon: Icons.airline_seat_recline_normal_rounded,
          title: 'No seat available',
          message: 'All seats were taken before your request was confirmed.',
          accentColor: colors.warning,
        ),
      ],

      RideNoShow() => [
        _buildStatusCard(
          icon: Icons.timer_off_rounded,
          title: 'Marked as no-show',
          message: "We didn't see you board for this trip.",
          accentColor: colors.error,
        ),
      ],

      RideReleased() => [
        _buildStatusCard(
          icon: Icons.event_available_rounded,
          title: 'Seat released',
          message: 'Your seat was released back to the pool.',
          accentColor: colors.textSecondary,
        ),
      ],

      RideOperatorCancelled() => [
        _buildStatusCard(
          icon: Icons.report_gmailerrorred_rounded,
          title: 'Trip cancelled',
          message:
              'The operator cancelled this trip. Sorry for the inconvenience.',
          accentColor: colors.error,
        ),
      ],
    };
  }

  Widget _buildLoadingCard() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(28),
      ),
      child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
    );
  }

  Widget _buildErrorCard() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Couldn't load your ride status",
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(rideLifecycleProvider),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  /// No reservation exists yet for today's direction — invites the user
  /// to reserve a seat. This replaces the old hardcoded "evening prompt".
  Widget _buildNoReservationCard() {
    final upcoming = ref
        .watch(homeUpcomingProvider(widget.client))
        .asData
        ?.value;
    if (upcoming != null &&
        upcoming.status == wire.ReservationStatusEnum.pending) {
      return _buildReviewCard(
        upcoming.id,
        ref.watch(homeUpcomingDetailProvider(widget.client)).asData?.value,
      );
    }
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReturn =
        ref.watch(selectedDirectionProvider) == CommuteDirection.returning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isReturn
                ? 'Traveling on your return leg today?'
                : 'Traveling outbound today?',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 17,
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Request a seat for today. We will confirm availability.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _pillButton(
                  label: 'Request seat',
                  filled: true,
                  onTap: () => _onEveningPromptResponse(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pillButton(
                  label: 'Not travelling',
                  filled: false,
                  onTap: () => _onEveningPromptResponse(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.actionPrimaryDefault.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.actionPrimaryDefault,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Confirming your reservation…',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservedCard(EtaPhase etaPhase, wire.ReservationDetail? detail) {
    final colors = context.appColors;
    final departure = detail?.trip?.scheduledAt;
    final etaLabel = etaPhase.eta == null
        ? 'Confirmed'
        : '${etaPhase.eta!.inMinutes} mins away';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                'Your seat is reserved',
                style: TextStyle(
                  color: colors.onSurfaceStrong,
                  fontSize: 17,
                  fontFamily: AppTypography.fontFamily,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              );
              if (constraints.maxWidth < 280 ||
                  MediaQuery.textScalerOf(context).scale(17) > 24) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 8),
                    _buildEtaChip(etaLabel),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  _buildEtaChip(etaLabel),
                ],
              );
            },
          ),
          if (departure != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Departs ${DateFormat('h:mm a').format(departure.toUtc())}',
                  style: AppTypography.title.copyWith(
                    color: colors.onSurfaceStrong,
                  ),
                ),
                Text(
                  DateFormat('EEE, d MMM').format(departure.toUtc()),
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceStrong.withValues(alpha: .8),
                  ),
                ),
              ],
            ),
          ],
          if (detail?.route?.name case final name?) ...[
            const SizedBox(height: 12),
            Text(
              name,
              style: AppTypography.title.copyWith(
                fontSize: 16,
                color: colors.onSurfaceStrong,
              ),
            ),
          ],
          if (detail?.pickupStop != null || detail?.dropoffStop != null) ...[
            const SizedBox(height: 6),
            for (final stop in [detail?.pickupStop, detail?.dropoffStop])
              if (stop != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radio_button_checked,
                        size: 14,
                        color: colors.onSurfaceStrong,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stop.name,
                          style: AppTypography.body.copyWith(
                            fontSize: 13,
                            color: colors.onSurfaceStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
          if (etaPhase.isEstimated && etaPhase.eta != null) ...[
            const SizedBox(height: 8),
            Text(
              'Live location is unavailable. Arrival time is estimated.',
              style: TextStyle(
                color: colors.onSurfaceStrong.withValues(alpha: 0.85),
                fontSize: 12,
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _onShowBoardingPass,
              style: FilledButton.styleFrom(
                backgroundColor: colors.actionPrimaryDefault,
                foregroundColor: colors.actionOnPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.qr_code_2_rounded, size: 20),
              label: const Text(
                'View boarding pass',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveJourney(RideLifecycleState state) {
    final tripId = switch (state) {
      RideBoarded(:final tripId) => tripId,
      RideReserved(:final tripId) => tripId,
      _ => null,
    };
    final detail = ref.watch(homeReservationDetailProvider).asData?.value;
    if (tripId == null) {
      return _buildReservedCard(const EtaPhase(isEstimated: true), detail);
    }
    return TripTrackingPage(
      key: ValueKey('home-tracking-$tripId'),
      client: widget.client,
      tripId: tripId,
      isActive: widget.isActive && !_covered,
      onTripEnded: () {
        // Re-read the reservation. An ended trip is not necessarily completed.
        ref.invalidate(homeMembershipProvider(widget.client));
        ref.invalidate(rideLifecycleProvider);
        ref.invalidate(homeDetailProvider);
      },
      contentBuilder: (snapshot, map, error, loading) => LiveRideJourney(
        boarded: state is RideBoarded,
        detail: detail,
        snapshot: snapshot,
        map: map,
        error: error,
        loading: loading,
        onExpand: () => _openRidePage(
          TripTrackingPage(client: widget.client, tripId: tripId),
        ),
        onBoardingPass: () => _openRidePage(
          PassTab(
            client: widget.client,
            initialReservationId: detail?.reservation.id,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(
    String reservationId,
    wire.ReservationDetail? detail,
  ) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceStrong,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail != null)
            Text(
              DateFormat(
                'EEE, d MMM',
              ).format(detail.reservation.travelDate.toDateTime()),
              style: AppTypography.caption.copyWith(
                color: c.onSurfaceStrong.withValues(alpha: .8),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Confirm your ride',
            style: AppTypography.title.copyWith(color: c.onSurfaceStrong),
          ),
          const SizedBox(height: 8),
          Text(
            rideJourneyName(detail),
            style: AppTypography.bodySmall.copyWith(color: c.onSurfaceStrong),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => _openRidePage(
              ConfirmRidePage(
                client: widget.client,
                reservationId: reservationId,
              ),
            ),
            child: const Text('Review ride'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCompletedSection(String reservationId) {
    final details = ref.watch(homeReservationDetailProvider);
    final detail = details.asData?.value;
    return [
      CompletedRideSummary(
        detail: detail,
        remainingRides: ref
            .watch(homeMembershipProvider(widget.client))
            .asData
            ?.value
            .entitlements
            .remainingRides,
        onDetails: () => _openRidePage(
          TripDetailsPage(client: widget.client, reservationId: reservationId),
        ),
      ),
      if (detail != null &&
          detail.reservation.id == reservationId &&
          detail.reservation.status == wire.ReservationStatusEnum.boarded &&
          detail.trip?.status ==
              wire.ReservationDetailTripStatusEnum.completed) ...[
        const SizedBox(height: 24),
        RideRatingCard(
          key: ValueKey(reservationId),
          client: widget.client,
          reservationId: reservationId,
          initialStars: detail.rating?.stars,
          onSubmitted: () => ref.invalidate(
            homeDetailProvider((widget.client, reservationId)),
          ),
        ),
      ] else if (details.hasError) ...[
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ref.invalidate(
            homeDetailProvider((widget.client, reservationId)),
          ),
          child: const Text('Load ride feedback'),
        ),
      ],
    ];
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String message,
    required Color accentColor,
  }) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A5933),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: AppTypography.fontFamily,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Material(
      color: filled ? colors.actionPrimaryDefault : colors.borderSubtle,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: filled ? colors.actionOnPrimary : colors.textPrimary,
              fontSize: 16,
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Quick Actions
  // ---------------------------------------------------------------------
  Widget _buildQuickActionsRow(wire.ReservationDetail? detail) {
    final colors = context.appColors;
    final actions = _quickActions(detail);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: AppTypography.label.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = MediaQuery.textScalerOf(context).scale(12) > 18
                ? 2
                : actions.length;
            final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in actions)
                  SizedBox(
                    width: width,
                    child: _buildQuickActionButton(action),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(QuickAction action) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (action.figmaIcon case final icon?)
                  FigmaCommuterIcon(icon, color: colors.iconDefault)
                else
                  Icon(action.icon, color: colors.iconDefault, size: 24),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(
                    fontSize: 11,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
