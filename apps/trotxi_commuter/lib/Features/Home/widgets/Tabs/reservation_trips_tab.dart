import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_status.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

enum _TripsSegment { upcoming, history }

String _formatWeekdayDay(DateTime date) =>
    DateFormat('EEE · d MMM').format(date).toUpperCase();

String _formatMonthAbbrev(DateTime date) =>
    DateFormat('MMM').format(date).toUpperCase();

/// The rider's own upcoming and last 30 days of trips. Each row is deliberately light — the list
/// endpoint only carries identifiers — and opens [TripDetailsPage], which
/// calls `GET /v1/me/reservations/{id}` for the route name, schedule and
/// stop names the list omits.
class ReservationTripsTab extends StatefulWidget {
  const ReservationTripsTab({super.key, required this.client});
  final CommuterApi client;

  @override
  State<ReservationTripsTab> createState() => _ReservationTripsTabState();
}

class _ReservationTripsTabState extends State<ReservationTripsTab> {
  _TripsSegment _segment = _TripsSegment.upcoming;

  bool _loading = true;
  Object? _error;
  List<Reservation> _upcoming = const [];
  List<Reservation> _history = const [];

  int _loadRevision = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _loadRevision++;
    super.dispose();
  }

  Future<void> _load() async {
    final revision = ++_loadRevision;
    final generation = widget.client.sessionGeneration;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now().toUtc();
      final today = Date(now.year, now.month, now.day);
      final rangeEnd = now.add(const Duration(days: 30)).toDate();
      final rangeStart = now.subtract(const Duration(days: 30)).toDate();

      final upcomingRows = await widget.client.reservations(
        from: today,
        to: rangeEnd,
      );
      final historyRows = await widget.client.reservations(
        from: rangeStart,
        to: today,
      );
      widget.client.ensureSession(generation);

      final upcoming =
          upcomingRows
              .where(
                (r) =>
                    r.status == ReservationStatusEnum.pending ||
                    r.status == ReservationStatusEnum.reserved,
              )
              .toList()
            ..sort((a, b) {
              final byDate = a.travelDate.compareTo(b.travelDate);
              if (byDate != 0) return byDate;
              return a.direction.name.compareTo(b.direction.name);
            });
      final history =
          historyRows
              .where(
                (r) =>
                    r.travelDate.compareTo(today) < 0 ||
                    (r.status != ReservationStatusEnum.pending &&
                        r.status != ReservationStatusEnum.reserved),
              )
              .toList()
            ..sort((a, b) => b.travelDate.compareTo(a.travelDate));

      if (!mounted || revision != _loadRevision) return;
      setState(() {
        _upcoming = upcoming;
        _history = history;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || revision != _loadRevision) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error loading reservations: $e');
    }
  }

  void _openDetails(Reservation reservation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripDetailsPage(
          client: widget.client,
          reservationId: reservation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final layout = ResponsiveLayoutInfo.of(context);

    final maxContentWidth = layout.select(
      phone: 520.0,
      tabletPortrait: 680.0,
      tabletLandscape: 960.0,
    );
    final horizontalPadding = layout.select(
      phone: 16.0,
      tabletPortrait: 24.0,
      tabletLandscape: 32.0,
    );

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: RefreshIndicator(
              onRefresh: _load,
              color: colors.actionPrimaryDefault,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  32,
                ),
                children: _buildBody(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final header = _buildHeader(context);
    final segmentedTabs = _buildSegmentedTabs(context);

    if (_loading) {
      return [
        header,
        const SizedBox(height: 20),
        segmentedTabs,
        const SizedBox(height: 24),
        _buildLoadingCard(context),
      ];
    }

    if (_error != null) {
      return [
        header,
        const SizedBox(height: 20),
        segmentedTabs,
        const SizedBox(height: 24),
        _buildErrorCard(context),
      ];
    }

    return [
      header,
      const SizedBox(height: 20),
      segmentedTabs,
      const SizedBox(height: 24),
      ..._segment == _TripsSegment.upcoming
          ? _buildUpcomingSection(context)
          : _buildHistorySection(context),
    ];
  }

  // ---------------------------------------------------------------------
  // Header + segmented tabs
  // ---------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trips',
          style: AppTypography.heading2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Your scheduled and completed commutes.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabs(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              context,
              _TripsSegment.upcoming,
              'Upcoming',
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              context,
              _TripsSegment.history,
              'History',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context,
    _TripsSegment segment,
    String label,
  ) {
    final colors = context.appColors;
    final selected = _segment == segment;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () => setState(() => _segment = segment),
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: selected
                  ? colors.actionPrimaryDefault
                  : colors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final colors = context.appColors;
    final error = _error;
    final message = error is TrotxiException
        ? error.message
        : "Couldn't load your trips";
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
          Text(
            message,
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Try again')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Upcoming
  // ---------------------------------------------------------------------

  List<Widget> _buildUpcomingSection(BuildContext context) {
    if (_upcoming.isEmpty) {
      return [
        _buildEmptyCard(
          context,
          icon: Icons.event_available_outlined,
          title: 'No upcoming trips',
          message:
              'Your confirmed rides for the next 30 days will appear here. Browse routes from Home to plan a commute.',
        ),
      ];
    }

    final next = _upcoming.first;
    final rest = _upcoming.skip(1).toList();

    return [
      _buildSectionTitle(context, 'Next trip'),
      const SizedBox(height: 12),
      _buildHeroCard(context, next),
      if (rest.isNotEmpty) ...[
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Upcoming'),
        const SizedBox(height: 12),
        _buildTripList(context, rest),
      ],
    ];
  }

  Widget _buildHeroCard(BuildContext context, Reservation reservation) {
    final colors = context.appColors;
    final outcome = tripOutcomeOf(reservation.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openDetails(reservation),
        child: Container(
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
                      _formatWeekdayDay(reservation.travelDate.toDateTime()),
                      style: AppTypography.label.copyWith(
                        color: colors.actionPrimaryDefault,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  _buildOutcomeBadge(context, outcome, onDark: true),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                directionLabel(reservation.direction),
                style: AppTypography.title.copyWith(
                  color: colors.onSurfaceStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View pickup, drop-off and vehicle details',
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceStrong.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------

  List<Widget> _buildHistorySection(BuildContext context) {
    if (_history.isEmpty) {
      return [
        _buildEmptyCard(
          context,
          icon: Icons.history_rounded,
          title: 'No recent trips',
          message:
              'Completed and cancelled trips from the last 30 days will appear here.',
        ),
      ];
    }
    return [
      _buildSectionTitle(context, 'Recent'),
      const SizedBox(height: 12),
      _buildTripList(context, _history),
    ];
  }

  // ---------------------------------------------------------------------
  // Shared list rendering
  // ---------------------------------------------------------------------

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: AppTypography.buttonAction.copyWith(color: colors.textPrimary),
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: colors.actionPrimaryDefault),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(BuildContext context, List<Reservation> reservations) {
    return Column(
      children: [
        for (int i = 0; i < reservations.length; i++) ...[
          _buildTripListTile(context, reservations[i]),
          if (i != reservations.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildTripListTile(BuildContext context, Reservation reservation) {
    final colors = context.appColors;
    final outcome = tripOutcomeOf(reservation.status);
    final date = reservation.travelDate.toDateTime();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _openDetails(reservation),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.borderSubtle),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              _buildDateBadge(context, date, outcome),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      directionLabel(reservation.direction),
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatWeekdayDay(date),
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tripOutcomeLabel(outcome),
                      style: AppTypography.caption.copyWith(
                        color: tripOutcomeColor(context, outcome),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBadge(
    BuildContext context,
    DateTime date,
    TripOutcome outcome,
  ) {
    final colors = context.appColors;
    final color = tripOutcomeColor(context, outcome);
    return Container(
      width: 52,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatMonthAbbrev(date),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            date.day.toString().padLeft(2, '0'),
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeBadge(
    BuildContext context,
    TripOutcome outcome, {
    bool onDark = false,
  }) {
    final colors = context.appColors;
    final color = tripOutcomeColor(context, outcome);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: onDark
            ? color.withValues(alpha: 0.22)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tripOutcomeLabel(outcome).toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: onDark ? colors.onSurfaceStrong : color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
