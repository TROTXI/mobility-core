import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/Features/Home/models/home_ride_lifecycle_state.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_details_sheet.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_labels.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/commuter_preference.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_notification.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_security.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/routes_tab.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_details_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Trips/trip_status.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/utils/money_format.dart';

/// One tappable search result. [keywords] are extra words that should find the
/// entry without being shown (e.g. "money" finds Wallet).
class SearchEntry {
  const SearchEntry({
    required this.group,
    required this.title,
    required this.icon,
    required this.onSelected,
    this.subtitle,
    this.keywords = '',
  });

  final String group;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String keywords;
  final VoidCallback onSelected;

  String get _haystack => '$title ${subtitle ?? ''} $keywords'.toLowerCase();
}

/// Every whitespace-separated word of [query] must appear somewhere in an
/// entry. An empty query matches everything.
List<SearchEntry> searchEntries(List<SearchEntry> entries, String query) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return entries;
  return entries
      .where((e) => words.every((w) => e._haystack.contains(w)))
      .toList();
}

/// Opens the floating search bar. Picking a result closes it first, then runs
/// the result's action against [context], so navigation never targets the
/// dismissed dialog.
Future<void> showCommuterSearch(
  BuildContext context, {
  required CommuterApi client,
  required ValueChanged<CommuterDestination> onDestination,
}) async {
  final picked = await showGeneralDialog<VoidCallback>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close search',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (dialogContext, _, _) => _SearchPanel(
      client: client,
      onDestination: onDestination,
      navigatorContext: context,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, -0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
  if (picked != null && context.mounted) picked();
}

class _SearchPanel extends StatefulWidget {
  const _SearchPanel({
    required this.client,
    required this.onDestination,
    required this.navigatorContext,
  });

  final CommuterApi client;
  final ValueChanged<CommuterDestination> onDestination;
  final BuildContext navigatorContext;

  @override
  State<_SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<_SearchPanel> {
  final _controller = TextEditingController();
  List<wire.Reservation> _reservations = const [];
  List<wire.Route> _routes = const [];
  List<wire.Purchase> _purchases = const [];
  int _pendingLoads = 3;

  bool get _loading => _pendingLoads > 0;

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _loadRoutes();
    _loadPurchases();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Runs one of the optional lookups. Trips, routes and payments are a bonus:
  /// if one can't load, the screen results and the other lookups still work.
  Future<void> _load(Future<void> Function() fetch) async {
    try {
      await fetch();
    } catch (_) {
      // Leave that group of results empty.
    } finally {
      if (mounted) setState(() => _pendingLoads--);
    }
  }

  Future<void> _loadTrips() => _load(() async {
    final now = DateTime.now().toUtc();
    final rows = await widget.client.reservations(
      from: now.subtract(const Duration(days: 30)).toDate(),
      to: now.add(const Duration(days: 30)).toDate(),
    );
    if (!mounted) return;
    setState(
      () => _reservations = [...rows]
        ..sort((a, b) => b.travelDate.compareTo(a.travelDate)),
    );
  });

  Future<void> _loadRoutes() => _load(() async {
    final rows = await widget.client.routes();
    if (!mounted) return;
    setState(
      () => _routes = [...rows.where((r) => !r.archived)]
        ..sort((a, b) => a.name.compareTo(b.name)),
    );
  });

  Future<void> _loadPurchases() => _load(() async {
    final rows = await widget.client.purchases();
    if (!mounted) return;
    setState(
      () => _purchases = [...rows]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  });

  /// Closes the panel, then lets [showCommuterSearch] run [action].
  void _select(VoidCallback action) => Navigator.of(context).pop(action);

  List<SearchEntry> _entries() {
    final navigator = widget.navigatorContext;
    void push(Widget Function(BuildContext) builder) => Navigator.of(
      navigator,
    ).push(MaterialPageRoute<void>(builder: builder));
    SearchEntry tab(
      CommuterDestination d,
      String title,
      IconData icon,
      String keywords,
    ) => SearchEntry(
      group: 'Go to',
      title: title,
      icon: icon,
      keywords: keywords,
      onSelected: () => widget.onDestination(d),
    );

    void pushScaffold(String title, Widget body) => push(
      (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: body,
      ),
    );

    final screens = <SearchEntry>[
      tab(
        CommuterDestination.home,
        'Home',
        Icons.home_outlined,
        'today ride reservation eta boarding pass',
      ),
      tab(
        CommuterDestination.trips,
        'Trips',
        Icons.directions_bus_outlined,
        'upcoming history rides commutes reservations',
      ),
      tab(
        CommuterDestination.wallet,
        'Wallet',
        Icons.account_balance_wallet_outlined,
        'money payments membership subscription plan subscribe renew credit rides purchases',
      ),
      tab(
        CommuterDestination.profile,
        'Profile',
        Icons.person_outline_rounded,
        'account name photo picture appearance theme dark light personal information sign out delete',
      ),
      SearchEntry(
        group: 'Go to',
        title: 'Commute preferences',
        subtitle: 'Your current commute and route change requests',
        icon: Icons.alt_route_rounded,
        keywords: 'route change request new route pickup destination operations',
        onSelected: () =>
            push((_) => CommutePreferencesPage(client: widget.client)),
      ),
      SearchEntry(
        group: 'Go to',
        title: 'Routes & schedule',
        subtitle: 'Departures and times for a service date',
        icon: Icons.schedule_rounded,
        keywords:
            'route routes schedule timetable departures departure times '
            'service date bus live track tracking',
        onSelected: () => pushScaffold(
          'Departures',
          RoutesTab(client: widget.client),
        ),
      ),
      SearchEntry(
        group: 'Go to',
        title: 'Notifications',
        icon: Icons.notifications_none_rounded,
        keywords: 'alerts push reminders',
        onSelected: () => push((_) => const ProfileNotificationsPage()),
      ),
      SearchEntry(
        group: 'Go to',
        title: 'Security',
        icon: Icons.lock_outline_rounded,
        keywords: 'privacy sessions devices passkey sign in password',
        onSelected: () =>
            push((_) => ProfileSecurityPage(client: widget.client)),
      ),
    ];

    final dayFormat = DateFormat('EEE, d MMM yyyy');
    final longFormat = DateFormat('EEEE d MMMM yyyy');
    final trips = <SearchEntry>[
      for (final r in _reservations)
        SearchEntry(
          group: 'Your trips',
          title:
              '${directionLabel(r.direction)} · '
              '${dayFormat.format(r.travelDate.toDateTime())}',
          subtitle: tripOutcomeLabel(tripOutcomeOf(r.status)),
          icon: Icons.directions_bus_outlined,
          keywords:
              'trip ride reservation ${r.direction.name} '
              '${r.travelDate} ${longFormat.format(r.travelDate.toDateTime())}',
          onSelected: () => push(
            (_) => TripDetailsPage(client: widget.client, reservationId: r.id),
          ),
        ),
    ];
    final routes = <SearchEntry>[
      for (final r in _routes)
        SearchEntry(
          group: 'Routes',
          title: r.name,
          subtitle: r.description,
          icon: Icons.alt_route_rounded,
          keywords: 'route schedule departures timetable',
          onSelected: () => pushScaffold(
            r.name,
            RoutesTab(client: widget.client, routeId: r.id),
          ),
        ),
    ];

    final payments = <SearchEntry>[
      for (final p in _purchases)
        SearchEntry(
          group: 'Payments',
          title:
              '${purchasePlanLabel(p.plan)} · '
              '${dayFormat.format(p.createdAt.toUtc())}',
          subtitle: '${purchaseStateLabel(p.state)} · ${p.price.formatted}',
          icon: Icons.receipt_long_outlined,
          keywords:
              'payment purchase receipt wallet subscription membership '
              '${p.state.name} ${longFormat.format(p.createdAt.toUtc())}',
          onSelected: () => showPurchaseDetailsSheet(
            navigator,
            client: widget.client,
            purchaseId: p.id,
          ),
        ),
    ];
    return [...screens, ...routes, ...trips, ...payments];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final media = MediaQuery.of(context);
    final query = _controller.text.trim();
    final all = _entries();
    // With no query, offer shortcuts to screens rather than a long trip list.
    final results = query.isEmpty
        ? all.where((e) => e.group == 'Go to').toList()
        : searchEntries(all, query);
    // Keep the whole panel above the keyboard.
    final listMaxHeight =
        (media.size.height -
                media.viewInsets.bottom -
                media.padding.top -
                140)
            .clamp(120.0, 420.0);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Material(
              color: colors.surfaceElevated,
              elevation: 8,
              shadowColor: Colors.black45,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) {
                              if (results.isNotEmpty) {
                                _select(results.first.onSelected);
                              }
                            },
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search trips, wallet, settings…',
                              hintStyle: AppTypography.bodySmall.copyWith(
                                color: colors.textTertiary,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                        if (query.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear',
                            onPressed: () =>
                                setState(() => _controller.clear()),
                            icon: const Icon(Icons.close_rounded),
                          )
                        else
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: colors.borderSubtle),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: listMaxHeight),
                    child: results.isEmpty
                        ? _buildEmpty(context, query)
                        : _buildResults(context, results, query.isEmpty),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String query) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        _loading
            ? 'Searching…'
            : 'No results for “$query”. Try a screen, route, date or payment.',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    List<SearchEntry> results,
    bool shortcuts,
  ) {
    final colors = context.appColors;
    final children = <Widget>[];
    String? group;
    for (final entry in results) {
      if (entry.group != group) {
        group = entry.group;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              shortcuts ? 'Shortcuts' : entry.group,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
      children.add(
        ListTile(
          dense: true,
          leading: Icon(entry.icon, color: colors.actionPrimaryDefault),
          title: Text(
            entry.title,
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          subtitle: entry.subtitle == null
              ? null
              : Text(
                  entry.subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: colors.textTertiary,
          ),
          onTap: () => _select(entry.onSelected),
        ),
      );
    }
    if (_loading && !shortcuts) {
      children.add(const LinearProgressIndicator(minHeight: 2));
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      children: children,
    );
  }
}
