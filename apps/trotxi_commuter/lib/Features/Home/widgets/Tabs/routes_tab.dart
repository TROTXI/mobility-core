import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'route_preview_page.dart';
import 'reservation_trips_tab.dart';
import 'standby_page.dart';

/// Standalone departures screen. RoutesTab is also embedded in other pages,
/// so direct navigation must provide its own Material and back affordance.
class RoutesPage extends StatelessWidget {
  const RoutesPage({super.key, required this.client, this.routeId});

  final CommuterApi client;
  final String? routeId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Departures')),
    body: RoutesTab(client: client, routeId: routeId),
  );
}

class RoutesTab extends StatefulWidget {
  const RoutesTab({super.key, required this.client, this.routeId});
  final CommuterApi client;

  /// Limits departures to one route; null lists every route.
  final String? routeId;

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab> {
  late DateTime _day;
  List<wire.Trip> _trips = [];
  Map<String, String> _names = {};
  String? _error;
  bool _busy = true;
  int _load = 0;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc(); // Accra, not the device time zone.
    _day = DateTime.utc(now.year, now.month, now.day);
    _refresh();
  }

  @override
  void dispose() {
    _load++;
    super.dispose();
  }

  Future<void> _refresh() async {
    final attempt = ++_load, generation = widget.client.sessionGeneration;
    final date = wire.Date(_day.year, _day.month, _day.day);
    setState(() {
      _busy = true;
      _error = null;
      _trips = [];
    });
    try {
      final trips = await widget.client.trips(
        from: date,
        to: date,
        routeId: widget.routeId,
      );
      Map<String, String> names = {};
      try {
        names = {for (final r in await widget.client.routes()) r.id: r.name};
      } on TrotxiException catch (e) {
        if (e is UnauthorizedException || e is UpgradeRequiredException) {
          rethrow;
        }
      }
      widget.client.ensureSession(generation);
      if (!mounted || attempt != _load) return;
      setState(() {
        _trips = [...trips]
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        _names = names;
      });
    } catch (e) {
      if (mounted && attempt == _load) {
        setState(
          () => _error = e is TrotxiException
              ? e.message
              : 'Could not load departures. Please retry.',
        );
      }
    } finally {
      if (mounted && attempt == _load) setState(() => _busy = false);
    }
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || date == null) return;
    setState(() => _day = DateTime.utc(date.year, date.month, date.day));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: colors.actionPrimaryDefault,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Available trips',
                      style: AppTypography.heading2.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReservationTripsTab(client: widget.client),
                      ),
                    ),
                    child: const Text('My trips'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Explore routes and departure times before choosing your commute.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: colors.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: colors.borderSubtle),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _busy ? null : _chooseDate,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: colors.actionPrimaryDefault,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SERVICE DATE',
                                style: AppTypography.caption.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              Text(
                                DateFormat('EEE, d MMM yyyy').format(_day),
                                style: AppTypography.buttonAction.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colors.iconSubtle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_busy)
                LinearProgressIndicator(color: colors.actionPrimaryDefault),
              if (_error != null)
                _messageCard(
                  context,
                  icon: Icons.wifi_off_rounded,
                  title: 'Could not load departures',
                  message: _error!,
                  action: 'Try again',
                  onAction: _refresh,
                ),
              if (!_busy && _error == null && _trips.isEmpty)
                _messageCard(
                  context,
                  icon: Icons.event_busy_rounded,
                  title: 'No departures on this day',
                  message:
                      'Choose another date or join the waitlist for a future commute.',
                ),
              if (!_busy && _error == null && _trips.isNotEmpty) ...[
                Text(
                  '${_trips.length} ${_trips.length == 1 ? 'departure' : 'departures'}',
                  style: AppTypography.label.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final trip in _trips) _tripCard(context, trip),
              ],
              const SizedBox(height: 16),
              Text(
                'A seat is only yours after your ride is confirmed. Browsing a route does not reserve one.',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StandbyPage(client: widget.client),
                  ),
                ),
                icon: const Icon(Icons.hourglass_bottom_rounded),
                label: const Text('Join route standby'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripCard(BuildContext context, wire.Trip trip) {
    final colors = context.appColors;
    final time = DateFormat('HH:mm').format(trip.scheduledAt.toUtc());
    final departure = DateFormat(
      'd MMM, HH:mm',
    ).format(trip.scheduledAt.toUtc());
    final serviceDay = DateFormat(
      'd MMM',
    ).format(trip.serviceDate.toDateTime(utc: true));
    final direction = trip.direction == wire.TripDirectionEnum.outbound
        ? 'Outbound'
        : 'Return';
    final status = switch (trip.status) {
      wire.TripStatusEnum.scheduled => 'Scheduled',
      wire.TripStatusEnum.active => 'In progress',
      wire.TripStatusEnum.completed => 'Completed',
      wire.TripStatusEnum.cancelled => 'Cancelled',
      _ => 'Status unavailable',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RoutePreviewPage(
                client: widget.client,
                trip: trip,
                routeName: _names[trip.routeId] ?? 'Route preview',
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.actionPrimaryDefault.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    time,
                    style: AppTypography.label.copyWith(
                      color: colors.actionPrimaryDefault,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _names[trip.routeId] ?? 'Route name unavailable',
                        style: AppTypography.buttonAction.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$direction · $status',
                        style: AppTypography.bodySmall.copyWith(
                          color: trip.status == wire.TripStatusEnum.cancelled
                              ? colors.error
                              : colors.textSecondary,
                        ),
                      ),
                      Text(
                        'Vehicle: ${trip.vehicleLabel ?? 'To be assigned'}',
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Service day $serviceDay · Departs $departure',
                        style: AppTypography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.iconSubtle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _messageCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? action,
    VoidCallback? onAction,
  }) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.backgroundSubtle,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.actionPrimaryDefault),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.buttonAction.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(action)),
          ],
        ],
      ),
    );
  }
}
