import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/pass_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_status.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_tracking_page.dart';
import 'package:trotxi_commuter/core/config/client_metadata.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

String _formatWeekdayDay(DateTime date) =>
    DateFormat('EEE · d MMM').format(date).toUpperCase();

String _formatWeekdayDayShort(DateTime date) =>
    DateFormat('EEE, d MMM').format(date);

String _formatTime(DateTime date) => DateFormat('h:mm a').format(date.toLocal());

/// Trip details for a single reservation, driven by
/// `GET /v1/me/reservations/{id}` (see `ReservationDetail` in trotxi_client).
///
/// The dark hero-card layout is used for outcomes the rider still cares
/// about experiencing (awaiting confirmation, confirmed, completed); outcomes
/// where the ride didn't happen as booked (missed, declined, cancelled,
/// unseated) get a plainer summary card plus a short explanation instead.
class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({
    super.key,
    required this.client,
    required this.reservationId,
  });

  final TrotxiApiClient client;
  final String reservationId;

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  ReservationDetail? _detail;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await widget.client.getReservationDetail(
        id: widget.reservationId,
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error loading reservation ${widget.reservationId}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: RefreshIndicator(
              onRefresh: _load,
              color: colors.actionPrimaryDefault,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: _buildBody(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final colors = context.appColors;
    final detail = _detail;

    if (_loading && detail == null) {
      return [
        _buildTopBar(context, null),
        const SizedBox(height: 60),
        Center(
          child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
        ),
      ];
    }

    if (detail == null) {
      return [_buildTopBar(context, null), const SizedBox(height: 24), _buildErrorCard(context)];
    }

    final outcome = tripOutcomeOf(detail.reservation.status);
    final isHappyPath = switch (outcome) {
      TripOutcome.pending || TripOutcome.confirmed || TripOutcome.completed =>
        true,
      _ => false,
    };

    return [
      _buildTopBar(context, outcome),
      const SizedBox(height: 4),
      Text(
        '${_formatWeekdayDayShort(detail.reservation.travelDate.toDateTime())} · '
        '${directionLabel(detail.reservation.direction)}',
        style: AppTypography.caption.copyWith(color: colors.textSecondary),
      ),
      const SizedBox(height: 16),
      isHappyPath
          ? _buildHeroCard(context, detail)
          : _buildSummaryCard(context, detail, outcome),
      if (!isHappyPath) ...[
        const SizedBox(height: 16),
        _buildExplanationCard(context, outcome),
      ],
      if (detail.trip?.vehicleLabel != null ||
          detail.trip?.vehiclePlate != null) ...[
        const SizedBox(height: 20),
        _buildSectionTitle(context, 'Vehicle & boarding'),
        const SizedBox(height: 12),
        _buildVehicleCard(context, detail.trip!),
      ],
      ..._buildActions(context, detail, outcome),
      const SizedBox(height: 20),
      Center(
        child: Text(
          'Trip ID  ${detail.reservation.id}',
          style: AppTypography.caption.copyWith(color: colors.textTertiary),
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------

  Widget _buildTopBar(BuildContext context, TripOutcome? outcome) {
    final colors = context.appColors;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 18),
        ),
        Expanded(
          child: Text(
            'Trip details',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
        ),
        if (outcome != null) _buildStatusPill(context, outcome),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildStatusPill(BuildContext context, TripOutcome outcome) {
    final color = tripOutcomeColor(context, outcome);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        tripOutcomeLabel(outcome).toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final colors = context.appColors;
    final error = _error;
    final message = error is TrotxiException
        ? error.message
        : "Couldn't load this trip";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTypography.label.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Try again')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Happy-path hero (pending / confirmed / completed)
  // ---------------------------------------------------------------------

  Widget _buildHeroCard(BuildContext context, ReservationDetail detail) {
    final colors = context.appColors;
    final pickup = detail.pickupStop;
    final dropoff = detail.dropoffStop;
    final title = pickup != null && dropoff != null
        ? '${pickup.name} → ${dropoff.name}'
        : detail.route?.name ?? 'Trip';
    final scheduledAt = detail.trip?.scheduledAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _formatWeekdayDay(detail.reservation.travelDate.toDateTime()),
                  style: AppTypography.label.copyWith(
                    color: colors.actionPrimaryDefault,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              if (scheduledAt != null)
                Text(
                  _formatTime(scheduledAt),
                  style: AppTypography.label.copyWith(color: colors.onSurfaceStrong),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.title.copyWith(
              color: colors.onSurfaceStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            directionLabel(detail.reservation.direction),
            style: AppTypography.caption.copyWith(
              color: colors.onSurfaceStrong.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 18),
          _buildTimelineRow(
            context,
            filled: true,
            label: 'Pickup · ${pickup?.name ?? 'Not yet assigned'}',
          ),
          const SizedBox(height: 6),
          _buildTimelineRow(
            context,
            filled: false,
            label: 'Drop-off · ${dropoff?.name ?? 'Not yet assigned'}',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    BuildContext context, {
    required bool filled,
    required String label,
  }) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? colors.actionPrimaryDefault : Colors.transparent,
            border: Border.all(color: colors.onSurfaceStrong, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: colors.onSurfaceStrong),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Plain summary (missed / declined / operator-cancelled / unseated)
  // ---------------------------------------------------------------------

  Widget _buildSummaryCard(
    BuildContext context,
    ReservationDetail detail,
    TripOutcome outcome,
  ) {
    final colors = context.appColors;
    final pickup = detail.pickupStop;
    final dropoff = detail.dropoffStop;
    final title = pickup != null && dropoff != null
        ? '${pickup.name} → ${dropoff.name}'
        : detail.route?.name ?? 'Trip';
    final scheduledAt = detail.trip?.scheduledAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.label.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            context,
            'Scheduled departure',
            scheduledAt != null ? _formatTime(scheduledAt) : '—',
          ),
          const Divider(height: 24),
          _buildSummaryRow(context, 'Pickup', pickup?.name ?? '—'),
          const Divider(height: 24),
          _buildSummaryRow(
            context,
            'Trip status',
            tripOutcomeLabel(outcome),
            valueColor: tripOutcomeColor(context, outcome),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: colors.textSecondary)),
        Text(
          value,
          style: AppTypography.label.copyWith(color: valueColor ?? colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildExplanationCard(BuildContext context, TripOutcome outcome) {
    final colors = context.appColors;
    final color = tripOutcomeColor(context, outcome);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why this trip is marked ${tripOutcomeLabel(outcome).toLowerCase()}',
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            tripOutcomeExplanation(outcome),
            style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Vehicle & boarding
  // ---------------------------------------------------------------------

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.appColors;
    return Text(title, style: AppTypography.buttonAction.copyWith(color: colors.textPrimary));
  }

  Widget _buildVehicleCard(BuildContext context, ReservationDetailTrip trip) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.actionPrimaryDefault.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.directions_bus_filled_rounded,
              color: colors.actionPrimaryDefault,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.vehicleLabel ?? 'Assigned vehicle',
                  style: AppTypography.label.copyWith(color: colors.textPrimary),
                ),
                if (trip.vehiclePlate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    trip.vehiclePlate!,
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

  List<Widget> _buildActions(
    BuildContext context,
    ReservationDetail detail,
    TripOutcome outcome,
  ) {
    if (outcome != TripOutcome.confirmed) return const [];

    final trip = detail.trip;
    final buttons = <Widget>[];

    if (trip != null) {
      buttons.add(
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TripTrackingPage(
                  client: widget.client,
                  tripId: trip.id,
                  pickupName: detail.pickupStop?.name,
                ),
              ),
            ),
            child: const Text('Track trip'),
          ),
        ),
      );
    }

    buttons.add(
      Expanded(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PassTab(reservationId: detail.reservation.id),
            ),
          ),
          child: const Text('Boarding pass'),
        ),
      ),
    );

    return [
      const SizedBox(height: 20),
      Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i != 0) const SizedBox(width: 12),
            buttons[i],
          ],
        ],
      ),
    ];
  }
}
