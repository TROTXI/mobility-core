import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/wallet_tab.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Server-owned history; push alerts are only hints to refresh this page.
class NotificationsInboxPage extends StatefulWidget {
  const NotificationsInboxPage({super.key, required this.client});
  final CommuterApi client;

  @override
  State<NotificationsInboxPage> createState() => _NotificationsInboxPageState();
}

class _NotificationsInboxPageState extends State<NotificationsInboxPage> {
  final List<RiderNotification> _items = [];
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  bool _unreadOnly = false;
  Object? _error;
  int _requestRevision = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loadingMore || _cursor == null)) return;
    final generation = widget.client.sessionGeneration;
    final revision = more ? _requestRevision : ++_requestRevision;
    final unreadOnly = _unreadOnly;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });
    try {
      final page = await widget.client.notificationPage(
        cursor: more ? _cursor : null,
        unreadOnly: unreadOnly,
      );
      if (!mounted ||
          generation != widget.client.sessionGeneration ||
          revision != _requestRevision) {
        return;
      }
      setState(() {
        if (!more) _items.clear();
        _items.addAll(page.data);
        _cursor = page.page.nextCursor;
      });
    } catch (error) {
      if (!mounted ||
          generation != widget.client.sessionGeneration ||
          revision != _requestRevision) {
        return;
      }
      setState(() => _error = error);
    } finally {
      if (mounted &&
          generation == widget.client.sessionGeneration &&
          revision == _requestRevision) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _markAll() async {
    try {
      await widget.client.markAllNotificationsRead();
      if (mounted) await _load();
    } catch (_) {
      if (mounted) _message('Could not mark notifications as read.');
    }
  }

  Future<void> _open(RiderNotification notification) async {
    try {
      if (notification.readAt == null) {
        final changed = await widget.client.markNotificationRead(
          notification.id,
        );
        if (!mounted) return;
        final index = _items.indexWhere((item) => item.id == notification.id);
        if (index >= 0) setState(() => _items[index] = changed);
      }
    } catch (_) {
      if (mounted) _message('Could not mark this notification as read.');
    }
    if (!mounted) return;
    if (notification.target.type ==
        RiderNotificationTargetTypeEnum.reservation) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TripDetailsPage(
            client: widget.client,
            reservationId: notification.target.id,
          ),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Wallet')),
            body: WalletTab(client: widget.client),
          ),
        ),
      );
    }
    if (mounted && _unreadOnly) await _load();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.backgroundDefault,
        actions: [
          TextButton(onPressed: _markAll, child: const Text('Mark all read')),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Unread only'),
                    selected: _unreadOnly,
                    onSelected: (value) {
                      setState(() => _unreadOnly = value);
                      _load();
                    },
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null && _items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                'Could not load notifications.',
                                style: AppTypography.body,
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        )
                      : _items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                _unreadOnly
                                    ? 'You’re all caught up.'
                                    : 'No notifications yet.',
                                style: AppTypography.body,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                          itemCount: _items.length + (_cursor != null ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _items.length) {
                              return Center(
                                child: TextButton(
                                  onPressed: _loadingMore
                                      ? null
                                      : () => _load(more: true),
                                  child: Text(
                                    _loadingMore ? 'Loading…' : 'Load more',
                                  ),
                                ),
                              );
                            }
                            final item = _items[index];
                            final copy = notificationCopy(item.kind);
                            return Card(
                              color: colors.surfaceElevated,
                              child: ListTile(
                                leading: Icon(
                                  copy.$3,
                                  color: colors.actionPrimaryDefault,
                                ),
                                title: Text(
                                  copy.$1,
                                  style: AppTypography.label.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: item.readAt == null
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  '${copy.$2}\n${DateFormat('d MMM · h:mm a').format(item.createdAt.toUtc())} GMT',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: item.readAt == null
                                    ? Icon(
                                        Icons.circle,
                                        size: 9,
                                        color: colors.actionPrimaryDefault,
                                      )
                                    : null,
                                onTap: () => _open(item),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// No provider content or mutable route label is embedded in a push payload.
/// The first-party target is opened after this safe, local copy is shown.
(String, String, IconData) notificationCopy(RiderNotificationKindEnum kind) =>
    switch (kind) {
      RiderNotificationKindEnum.seatAsk => (
        'Confirm your ride',
        'Tell us whether you’re travelling.',
        Icons.event_seat_outlined,
      ),
      RiderNotificationKindEnum.seatHeld => (
        'Ride confirmed',
        'Your seat is reserved.',
        Icons.check_circle_outline,
      ),
      RiderNotificationKindEnum.seatUnseated => (
        'Seat unavailable',
        'Open your trip for the latest status.',
        Icons.info_outline,
      ),
      RiderNotificationKindEnum.rideUsed => (
        'Ride used',
        'One ride was deducted when you boarded.',
        Icons.directions_bus_outlined,
      ),
      RiderNotificationKindEnum.creditConverted => (
        'Ride Credit added',
        'Unused rides were converted to your wallet.',
        Icons.account_balance_wallet_outlined,
      ),
      RiderNotificationKindEnum.tripChanged => (
        'Trip updated',
        'Your trip details have changed.',
        Icons.update_outlined,
      ),
      RiderNotificationKindEnum.tripCancelled => (
        'Trip cancelled',
        'Open your trip for the latest status.',
        Icons.event_busy_outlined,
      ),
      _ => ('Trip update', 'Open for details.', Icons.notifications_outlined),
    };
