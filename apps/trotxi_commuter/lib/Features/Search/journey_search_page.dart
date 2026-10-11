import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/commute_selection.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
import '../Home/widgets/Tabs/route_preview_page.dart';
import '../Home/widgets/Tabs/standby_page.dart';
import 'journey_search.dart';

class JourneySearchPage extends StatefulWidget {
  const JourneySearchPage({
    super.key,
    required this.client,
    this.selectOnly = false,
    this.onAppSearch,
  });
  final CommuterApi client;
  final bool selectOnly;
  final VoidCallback? onAppSearch;

  @override
  State<JourneySearchPage> createState() => _JourneySearchPageState();
}

class _JourneySearchPageState extends State<JourneySearchPage> {
  final _from = TextEditingController(), _to = TextEditingController();
  final _fromFocus = FocusNode(), _toFocus = FocusNode();
  JourneyCatalog? _catalog;
  bool _loading = true;
  String? _error;
  DateTime _day = DateUtils.dateOnly(DateTime.now().toUtc());
  int _limit = 12;

  @override
  void initState() {
    super.initState();
    _fromFocus.addListener(_changed);
    _toFocus.addListener(_changed);
    _load();
  }

  void _changed() {
    if (mounted) setState(() => _limit = 12);
  }

  @override
  void dispose() {
    _fromFocus.removeListener(_changed);
    _toFocus.removeListener(_changed);
    _fromFocus.dispose();
    _toFocus.dispose();
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    final generation = widget.client.sessionGeneration;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final catalog = await JourneyCatalogStore.forClient(
        widget.client,
      ).load(widget.client, refresh: refresh);
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _catalog = catalog);
      }
    } catch (_) {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(
          () => _error =
              'We couldn’t load routes. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _chooseDay() async {
    final today = DateUtils.dateOnly(DateTime.now().toUtc());
    final picked = await showDatePicker(
      context: context,
      initialDate: _day.isBefore(today) ? today : _day,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _day = picked;
        _limit = 12;
      });
    }
  }

  void _select(JourneyMatch match) {
    FocusScope.of(context).unfocus();
    if (widget.selectOnly) {
      Navigator.of(context).pop(match);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            StandbyPage(client: widget.client, initialJourney: match),
      ),
    );
  }

  List<String> _suggestions(List<CommuteLegChoice> choices, bool from) {
    final query = from ? _from.text : _to.text;
    final names = <String>{};
    for (final choice in choices) {
      if (!operatesOn(choice, _day)) continue;
      if (from) {
        for (final pickup in choice.pickups) {
          if (_to.text.trim().isEmpty ||
              choice
                  .dropoffsAfter(pickup.id)
                  .any((s) => searchScore(s.name, _to.text) >= 0)) {
            names.add(pickup.name);
          }
        }
      } else {
        for (final pickup in choice.pickups) {
          if (_from.text.trim().isEmpty ||
              searchScore(pickup.name, _from.text) >= 0) {
            names.addAll(choice.dropoffsAfter(pickup.id).map((s) => s.name));
          }
        }
      }
    }
    final sorted = names.where((name) => searchScore(name, query) >= 0).toList()
      ..sort((a, b) {
        final score = searchScore(b, query).compareTo(searchScore(a, query));
        return score == 0 ? a.compareTo(b) : score;
      });
    return sorted.take(6).toList();
  }

  Widget _field({required bool from}) => TextField(
    key: ValueKey(from ? 'journey-from' : 'journey-to'),
    controller: from ? _from : _to,
    focusNode: from ? _fromFocus : _toFocus,
    textCapitalization: TextCapitalization.words,
    textInputAction: from ? TextInputAction.next : TextInputAction.search,
    onChanged: (_) => _changed(),
    onSubmitted: (_) =>
        from ? _toFocus.requestFocus() : FocusScope.of(context).unfocus(),
    decoration: InputDecoration(
      labelText: from ? 'From' : 'To',
      hintText: from ? 'Your pickup stop' : 'Where are you going?',
      prefixIcon: Icon(
        from ? Icons.trip_origin_rounded : Icons.location_on_outlined,
      ),
      suffixIcon: (from ? _from : _to).text.isEmpty
          ? null
          : IconButton(
              tooltip: from ? 'Clear pickup' : 'Clear destination',
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                (from ? _from : _to).clear();
                _changed();
              },
            ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final choices = _catalog?.choices ?? <CommuteLegChoice>[];
    final hasQuery = _from.text.trim().isNotEmpty && _to.text.trim().isNotEmpty;
    final matches = findJourneys(
      choices,
      from: _from.text,
      to: _to.text,
      day: _day,
    );
    final editing = _fromFocus.hasFocus || _toFocus.hasFocus;
    final suggestions = editing
        ? _suggestions(choices, _fromFocus.hasFocus)
        : <String>[];
    final routes = <String, CommuteLegChoice>{};
    for (final choice in choices) {
      if (operatesOn(choice, _day)) {
        routes.putIfAbsent(
          '${choice.route.id}:${choice.pattern.direction.name}',
          () => choice,
        );
      }
    }
    final browse = routes.values.toList()
      ..sort((a, b) => a.route.name.compareTo(b.route.name));
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(title: const Text('Find your commute')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const AppPageHeading(
                  title: 'A better way there.',
                  subtitle: 'Find a route between your pickup and destination.',
                ),
                const SizedBox(height: 24),
                AppSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field(from: true),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: 'Swap pickup and destination',
                          icon: const Icon(Icons.swap_vert_rounded),
                          onPressed: () {
                            final value = _from.text;
                            _from.text = _to.text;
                            _to.text = value;
                            _changed();
                          },
                        ),
                      ),
                      _field(from: false),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _chooseDay,
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                        ),
                        label: Text(DateFormat('EEE, d MMM').format(_day)),
                      ),
                    ],
                  ),
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AppSurface(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final name in suggestions)
                          Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(name),
                              onTap: () {
                                if (_fromFocus.hasFocus) {
                                  _from.text = name;
                                  _toFocus.requestFocus();
                                } else {
                                  _to.text = name;
                                  FocusScope.of(context).unfocus();
                                }
                                _changed();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  _message('Routes unavailable', _error!, retry: true)
                else ...[
                  if ((_catalog?.failedRoutes ?? 0) > 0) ...[
                    _message(
                      'Some routes couldn’t load',
                      'These results may be incomplete. Try again to check all routes.',
                      retry: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (hasQuery) ...[
                    Text(
                      'Your route options',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scheduled departures, not seat availability.',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (matches.isEmpty)
                      _message(
                        (_catalog?.failedRoutes ?? 0) > 0
                            ? 'No matches in loaded routes'
                            : 'No direct route found',
                        'Try a suggested stop, swap your journey or choose another travel date.',
                      ),
                    for (final match in matches.take(_limit)) ...[
                      _result(match),
                      const SizedBox(height: 16),
                    ],
                    if (matches.length > _limit)
                      TextButton(
                        onPressed: () => setState(() => _limit += 12),
                        child: const Text('Show more departures'),
                      ),
                  ] else ...[
                    Text(
                      'Explore our routes',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a route to start, or search by stop above.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (browse.isEmpty && (_catalog?.failedRoutes ?? 0) == 0)
                      _message(
                        'No departures on this date',
                        'Choose another date to see scheduled routes.',
                      ),
                    for (final choice in browse)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppSurface(
                          padding: EdgeInsets.zero,
                          child: Material(
                            type: MaterialType.transparency,
                            borderRadius: BorderRadius.circular(20),
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const Icon(Icons.route_outlined),
                              title: Text(choice.route.name),
                              subtitle: Text(
                                '${choice.version.stops.first.name} → ${choice.version.stops.last.name}',
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                _from.text = choice.version.stops.first.name;
                                _to.text = choice.version.stops.last.name;
                                FocusScope.of(context).unfocus();
                                _changed();
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
                if (!widget.selectOnly) ...[
                  const SizedBox(height: 24),
                  AppSettingsGroup(
                    children: [
                      AppSettingsRow(
                        icon: Icons.hourglass_empty_rounded,
                        title: 'My waitlist & offers',
                        subtitle: 'Check requests you’ve already made',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StandbyPage(client: widget.client),
                          ),
                        ),
                      ),
                      if (widget.onAppSearch != null)
                        AppSettingsRow(
                          icon: Icons.manage_search_rounded,
                          title: 'Search the app',
                          subtitle: 'Trips, payments and settings',
                          onTap: widget.onAppSearch,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _message(String title, String message, {bool retry = false}) =>
      AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.title),
            const SizedBox(height: 8),
            Text(message, style: AppTypography.bodySmall),
            if (retry)
              TextButton.icon(
                onPressed: () => _load(refresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
          ],
        ),
      );

  Widget _result(JourneyMatch match) {
    final choice = match.choice;
    final weekdays = choice.schedule.weekdays
        .map(
          (day) =>
              const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1],
        )
        .join(' · ');
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${match.pickup.name} → ${match.dropoff.name}',
            style: AppTypography.title,
          ),
          const SizedBox(height: 8),
          Text(choice.route.name, style: AppTypography.bodySmall),
          const SizedBox(height: 16),
          Text(
            '${choice.schedule.localDeparture} · Route departure',
            style: AppTypography.label,
          ),
          const SizedBox(height: 4),
          Text(weekdays, style: AppTypography.caption),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RouteChoicePreviewPage(
                  client: widget.client,
                  version: choice.version,
                  routeName: choice.route.name,
                  departureLabel:
                      '${choice.schedule.localDeparture} · ${DateFormat('d MMM').format(_day)}',
                ),
              ),
            ),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Preview route & stops'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => _select(match),
            child: Text(
              widget.selectOnly ? 'Choose this journey' : 'Plan this commute',
            ),
          ),
        ],
      ),
    );
  }
}
