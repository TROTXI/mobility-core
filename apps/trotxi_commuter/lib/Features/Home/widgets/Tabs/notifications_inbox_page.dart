import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/wallet_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/standby_page.dart';
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
        final known = _items.map((item) => item.id).toSet();
        _items.addAll(page.data.where((item) => known.add(item.id)));
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
    } else if (notification.target.type ==
        RiderNotificationTargetTypeEnum.standby) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StandbyPage(
            client: widget.client,
            applicationId: notification.target.id,
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

  bool _startsDay(int index) {
    if (index == 0) return true;
    final current = _items[index].createdAt.toLocal();
    final previous = _items[index - 1].createdAt.toLocal();
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  String _dayLabel(DateTime value) {
    final date = value.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final difference = today.difference(day).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return DateFormat('EEE, d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: colors.backgroundDefault,
        actions: [
          IconButton(
            onPressed: _loading ? null : _markAll,
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: _InboxFilter(
                  unreadOnly: _unreadOnly,
                  onChanged: (value) {
                    if (value == _unreadOnly) return;
                    setState(() => _unreadOnly = value);
                    _load();
                  },
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
                          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 38,
                              color: colors.actionSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _unreadOnly
                                  ? 'All caught up'
                                  : 'Nothing here yet',
                              textAlign: TextAlign.center,
                              style: AppTypography.title.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _unreadOnly
                                  ? 'New ride updates will appear here.'
                                  : 'We will show your offers, ride updates and payment notices here.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          itemCount: _items.length + (_cursor != null ? 1 : 0),
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_startsDay(index)) ...[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? 0 : 12,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      _dayLabel(item.createdAt),
                                      style: AppTypography.label.copyWith(
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                                _InboxItem(
                                  item: item,
                                  copy: copy,
                                  onTap: () => _open(item),
                                ),
                              ],
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

class _InboxFilter extends StatelessWidget {
  const _InboxFilter({required this.unreadOnly, required this.onChanged});

  final bool unreadOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final entry in const [(false, 'All'), (true, 'Unread')])
            Expanded(
              child: Semantics(
                selected: unreadOnly == entry.$1,
                button: true,
                child: InkWell(
                  onTap: () => onChanged(entry.$1),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: unreadOnly == entry.$1
                          ? colors.backgroundDefault
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.$2,
                      style: AppTypography.label.copyWith(
                        color: unreadOnly == entry.$1
                            ? colors.actionSecondary
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InboxItem extends StatelessWidget {
  const _InboxItem({
    required this.item,
    required this.copy,
    required this.onTap,
  });

  final RiderNotification item;
  final (String, String, IconData) copy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final unread = item.readAt == null;
    return Material(
      color: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.actionPrimaryDefault.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(copy.$3, size: 21, color: colors.actionSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.$1,
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      copy.$2,
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat('h:mm a').format(item.createdAt.toLocal()),
                      style: AppTypography.caption.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: colors.actionSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
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
      RiderNotificationKindEnum.standbyOffered => (
        'A place is available',
        'Review your standby offer before it expires.',
        Icons.hourglass_bottom,
      ),
      _ => ('Trip update', 'Open for details.', Icons.notifications_outlined),
    };
