import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'trip_tracking_page.dart';

class RoutesTab extends StatefulWidget {
  const RoutesTab({super.key, required this.client});
  final CommuterApi client;

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
      final trips = await widget.client.trips(from: date, to: date);
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('Departures', style: Theme.of(context).textTheme.headlineSmall),
      const Text(
        'Service dates and departure times are Ghana time. A listed trip does not confirm your seat or grant live tracking access.',
      ),
      Row(
        children: [
          TextButton(
            onPressed: _busy ? null : _chooseDate,
            child: Text(DateFormat('EEE, d MMM yyyy').format(_day)),
          ),
          IconButton(
            tooltip: 'Refresh departures',
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      if (_busy) const LinearProgressIndicator(),
      if (_error != null) Text(_error!),
      if (!_busy && _error == null && _trips.isEmpty)
        const Text('No departures on this service date.'),
      for (final trip in _trips)
        Card(
          child: ListTile(
            title: Text(_names[trip.routeId] ?? 'Route name unavailable'),
            subtitle: Text(
              '${trip.direction == wire.TripDirectionEnum.outbound ? 'Outbound' : 'Return'} · ${trip.status.name}\n'
              'Service ${trip.serviceDate} · Departs ${DateFormat('d MMM HH:mm').format(trip.scheduledAt.toUtc())}\n'
              '${trip.vehicleLabel ?? 'Vehicle not assigned'}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    TripTrackingPage(client: widget.client, tripId: trip.id),
              ),
            ),
          ),
        ),
    ],
  );
}
