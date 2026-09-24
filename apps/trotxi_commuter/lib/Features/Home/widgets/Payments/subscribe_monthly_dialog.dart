import 'package:flutter/material.dart';
// The API's Route model clashes with Flutter's navigator Route, so it's
// pulled in under a prefix.
import 'package:trotxi_client/trotxi_client.dart' hide Route;
import 'package:trotxi_client/trotxi_client.dart' as api show Route;
import 'package:trotxi_commuter/core/config/client_metadata.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/utils/money_format.dart';

/// Route + commute picker for a monthly `POST /v1/me/purchases`.
///
/// A purchase pins the rider to one outbound and one return leg: a
/// departure (schedule) in each direction, plus pickup and dropoff stops
/// on that departure's pattern version.
///
/// Shown via [showSubscribeMonthlyDialog]. Returns the created [Purchase],
/// or `null` if the rider cancelled. While the purchase still has cash to
/// collect, `checkout.url` is the Paystack page to open; when credit
/// covered everything, `checkout` is null.
Future<Purchase?> showSubscribeMonthlyDialog(
  BuildContext context, {
  required TrotxiApiClient client,
  Money? availableCredit,
  MembershipCommute? currentCommute,
}) {
  return showDialog<Purchase>(
    context: context,
    builder: (context) => _SubscribeMonthlyDialog(
      client: client,
      availableCredit: availableCredit,
      currentCommute: currentCommute,
    ),
  );
}

/// The rider's picks for one direction.
class _LegSelection {
  Schedule? departure;
  StopOccurrence? pickup;
  StopOccurrence? dropoff;

  bool get isComplete =>
      departure != null && pickup != null && dropoff != null;
}

class _SubscribeMonthlyDialog extends StatefulWidget {
  const _SubscribeMonthlyDialog({
    required this.client,
    this.availableCredit,
    this.currentCommute,
  });

  final TrotxiApiClient client;

  /// Credit the rider can put toward this purchase. A toggle to apply it
  /// is offered when it's non-zero.
  final Money? availableCredit;

  /// The rider's existing commute, if any, used to pre-fill a renewal.
  final MembershipCommute? currentCommute;

  @override
  State<_SubscribeMonthlyDialog> createState() =>
      _SubscribeMonthlyDialogState();
}

class _SubscribeMonthlyDialogState extends State<_SubscribeMonthlyDialog> {
  static const _directions = [
    CommuteLegDirectionEnum.outbound,
    CommuteLegDirectionEnum.return_,
  ];

  static const _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  bool _loadingRoutes = true;
  Object? _routesError;
  List<api.Route> _routes = const [];

  api.Route? _selectedRoute;
  bool _loadingCatalog = false;
  Object? _catalogError;

  /// Departures on [_selectedRoute] per direction, earliest first.
  Map<CommuteLegDirectionEnum, List<Schedule>> _departures = const {};

  /// Stops on each pattern version, keyed by version id, in ride order.
  Map<String, List<StopOccurrence>> _stopsByVersion = const {};

  final Map<CommuteLegDirectionEnum, _LegSelection> _legs = {
    for (final direction in _directions) direction: _LegSelection(),
  };

  late bool _useCredit = _hasCredit;

  /// Reused when the same selection is retried, so a retry can't create a
  /// second purchase. Cleared whenever the selection changes.
  String? _idempotencyKey;

  bool _submitting = false;
  String? _submitError;

  bool get _hasCredit => (widget.availableCredit?.amountMinor ?? 0) > 0;

  PublicApi get _publicApi => widget.client.getPublicApi();

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    setState(() {
      _loadingRoutes = true;
      _routesError = null;
    });
    try {
      final routes = <api.Route>[];
      String? cursor;
      do {
        final response = await _publicApi.listRoutes(
          xTrotxiClient: commuterMetadata.client,
          xTrotxiBuild: commuterMetadata.build,
          xTrotxiPlatform: commuterMetadata.platform,
          cursor: cursor,
        );
        routes.addAll(response.data?.data ?? const <api.Route>[]);
        cursor = response.data?.page.nextCursor;
      } while (cursor != null);
      if (!mounted) return;

      final active = routes.where((r) => !r.archived).toList();
      // Renewing: start from the route the rider already commutes on.
      final current = widget.currentCommute;
      final currentRoute = active
          .where((r) => r.id == current?.routeId)
          .firstOrNull;
      setState(() {
        _routes = active;
        _selectedRoute = currentRoute;
        _loadingRoutes = false;
      });
      if (currentRoute != null) {
        await _loadCatalog(currentRoute, prefill: current);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _routesError = e;
        _loadingRoutes = false;
      });
    }
  }

  Future<void> _onRouteChanged(String? routeId) async {
    final route = _routes.where((r) => r.id == routeId).firstOrNull;
    _select(() {
      _selectedRoute = route;
      _departures = const {};
      _stopsByVersion = const {};
      for (final direction in _directions) {
        _legs[direction] = _LegSelection();
      }
    });
    if (route != null) await _loadCatalog(route);
  }

  /// Loads the departures and stops the rider can pick from on [route].
  Future<void> _loadCatalog(
    api.Route route, {
    MembershipCommute? prefill,
  }) async {
    setState(() {
      _loadingCatalog = true;
      _catalogError = null;
    });
    try {
      final schedules = <Schedule>[];
      String? cursor;
      do {
        final response = await _publicApi.listRouteSchedules(
          id: route.id,
          xTrotxiClient: commuterMetadata.client,
          xTrotxiBuild: commuterMetadata.build,
          xTrotxiPlatform: commuterMetadata.platform,
          cursor: cursor,
        );
        schedules.addAll(response.data?.data ?? const <Schedule>[]);
        cursor = response.data?.page.nextCursor;
      } while (cursor != null);

      // Direction lives on the pattern, not the schedule.
      final patterns = await Future.wait(
        route.patternIds.map(
          (id) => _publicApi.getPattern(
            id: id,
            xTrotxiClient: commuterMetadata.client,
            xTrotxiBuild: commuterMetadata.build,
            xTrotxiPlatform: commuterMetadata.platform,
          ),
        ),
      );
      final directionByPattern = {
        for (final response in patterns)
          if (response.data?.data case final pattern?)
            pattern.id: pattern.direction == PatternDirectionEnum.outbound
                ? CommuteLegDirectionEnum.outbound
                : CommuteLegDirectionEnum.return_,
      };

      final today = Date.now(utc: true);
      final bookable =
          schedules
              .where(
                (s) =>
                    directionByPattern.containsKey(s.patternId) &&
                    (s.effectiveTo == null ||
                        s.effectiveTo!.compareTo(today) >= 0),
              )
              .toList()
            ..sort((a, b) => a.localDeparture.compareTo(b.localDeparture));

      // One fetch per distinct pattern version the departures run on.
      final patternByVersion = {
        for (final s in bookable) s.patternVersionId: s.patternId,
      };
      final versions = await Future.wait(
        patternByVersion.entries.map(
          (entry) => _publicApi.getPatternVersion(
            id: entry.value,
            versionId: entry.key,
            xTrotxiClient: commuterMetadata.client,
            xTrotxiBuild: commuterMetadata.build,
            xTrotxiPlatform: commuterMetadata.platform,
          ),
        ),
      );
      final stopsByVersion = {
        for (final response in versions)
          if (response.data?.data case final version?)
            version.id: (version.stops.toList()
              ..sort((a, b) => a.ordinal.compareTo(b.ordinal))),
      };

      // The rider may have picked another route while this was loading.
      if (!mounted || _selectedRoute?.id != route.id) return;
      setState(() {
        _departures = {
          for (final direction in _directions)
            direction: bookable
                .where((s) => directionByPattern[s.patternId] == direction)
                .toList(),
        };
        _stopsByVersion = stopsByVersion;
        for (final direction in _directions) {
          _legs[direction] = _initialLeg(direction, prefill);
        }
        _loadingCatalog = false;
      });
    } catch (e) {
      if (!mounted || _selectedRoute?.id != route.id) return;
      setState(() {
        _catalogError = e;
        _loadingCatalog = false;
      });
    }
  }

  /// Pre-fills [direction] from [prefill] where its departure and stops
  /// are still offered; otherwise picks the departure if there's only one.
  _LegSelection _initialLeg(
    CommuteLegDirectionEnum direction,
    MembershipCommute? prefill,
  ) {
    final departures = _departures[direction] ?? const <Schedule>[];
    final previous = prefill?.legs
        .where((l) => l.direction.name == direction.name)
        .firstOrNull;

    final leg = _LegSelection()
      ..departure =
          departures.where((s) => s.id == previous?.scheduleId).firstOrNull ??
          (departures.length == 1 ? departures.single : null);
    if (previous != null && leg.departure?.id == previous.scheduleId) {
      final stops = _stopsFor(leg.departure);
      leg.pickup = stops
          .where((s) => s.id == previous.pickupOccurrenceId)
          .firstOrNull;
      leg.dropoff = stops
          .where((s) => s.id == previous.dropoffOccurrenceId)
          .firstOrNull;
    }
    return leg;
  }

  List<StopOccurrence> _stopsFor(Schedule? departure) => departure == null
      ? const []
      : _stopsByVersion[departure.patternVersionId] ?? const [];

  /// Applies a selection change, dropping the error and idempotency key
  /// that belonged to the previous selection.
  void _select(VoidCallback change) {
    setState(() {
      change();
      _idempotencyKey = null;
      _submitError = null;
    });
  }

  void _onDepartureChanged(
    CommuteLegDirectionEnum direction,
    String? scheduleId,
  ) {
    _select(() {
      final leg = _legs[direction]!;
      leg.departure = _departures[direction]
          ?.where((s) => s.id == scheduleId)
          .firstOrNull;
      // Stops belong to a pattern version, so keep earlier picks only if
      // this departure runs on the same one.
      final stops = _stopsFor(leg.departure);
      if (!stops.contains(leg.pickup)) leg.pickup = null;
      if (!stops.contains(leg.dropoff)) leg.dropoff = null;
    });
  }

  void _onPickupChanged(CommuteLegDirectionEnum direction, String? stopId) {
    _select(() {
      final leg = _legs[direction]!;
      final stop = _stopsFor(
        leg.departure,
      ).where((s) => s.id == stopId).firstOrNull;
      leg.pickup = stop;
      // A dropoff at or before the new pickup no longer makes sense.
      if (stop != null &&
          leg.dropoff != null &&
          leg.dropoff!.ordinal <= stop.ordinal) {
        leg.dropoff = null;
      }
    });
  }

  void _onDropoffChanged(CommuteLegDirectionEnum direction, String? stopId) {
    _select(() {
      final leg = _legs[direction]!;
      leg.dropoff = _stopsFor(
        leg.departure,
      ).where((s) => s.id == stopId).firstOrNull;
    });
  }

  bool get _canSubmit =>
      !_submitting &&
      !_loadingCatalog &&
      _selectedRoute != null &&
      _legs.values.every((leg) => leg.isComplete);

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final route = _selectedRoute!;
    final idempotencyKey = _idempotencyKey ??= newIdempotencyKey();
    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final input = PurchaseInput(
        (b) => b
          ..plan = PurchaseInputPlanEnum.monthly
          ..routeId = route.id
          ..useCredit = _hasCredit && _useCredit
          ..legs.addAll(_directions.map(_legInput)),
      );
      final response = await widget.client.getRiderOwnApi().createPurchase(
        idempotencyKey: idempotencyKey,
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
        purchaseInput: input,
      );
      final purchase = response.data?.data;
      if (!mounted) return;
      if (purchase == null) {
        setState(() {
          _submitError = 'Could not start checkout. Please try again.';
          _submitting = false;
        });
        return;
      }
      Navigator.of(context).pop(purchase);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = 'Could not start checkout. Please try again.';
        _submitting = false;
      });
    }
  }

  CommuteLeg _legInput(CommuteLegDirectionEnum direction) {
    final leg = _legs[direction]!;
    return CommuteLeg(
      (b) => b
        ..direction = direction
        ..scheduleId = leg.departure!.id
        ..patternVersionId = leg.departure!.patternVersionId
        ..pickupOccurrenceId = leg.pickup!.id
        ..dropoffOccurrenceId = leg.dropoff!.id,
    );
  }

  /// ISO weekdays (1 = Monday) as a short label, e.g. `Weekdays`.
  static String _weekdaysLabel(Iterable<int> weekdays) {
    final days = weekdays.toSet();
    if (days.length == 7) return 'Daily';
    if (days.length == 5 && days.containsAll(const [1, 2, 3, 4, 5])) {
      return 'Weekdays';
    }
    if (days.length == 2 && days.containsAll(const [6, 7])) return 'Weekends';
    return (days.toList()..sort()).map((d) => _weekdayNames[d - 1]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AlertDialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Subscribe to monthly',
        style: AppTypography.title.copyWith(color: colors.textPrimary),
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(child: _buildContent(context)),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTypography.buttonAction.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.actionPrimaryDefault,
            disabledBackgroundColor: colors.actionPrimaryDisabled,
          ),
          child: _submitting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.actionOnPrimary,
                  ),
                )
              : Text(
                  'Continue',
                  style: AppTypography.buttonAction.copyWith(
                    color: colors.actionOnPrimary,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.appColors;

    if (_loadingRoutes) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_routesError != null) {
      return _buildRetry(
        context,
        message: "Couldn't load routes",
        onRetry: _fetchRoutes,
      );
    }

    if (_routes.isEmpty) {
      return Text(
        'No routes are open for subscriptions yet.',
        style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
      );
    }

    final route = _selectedRoute;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick your route, then the departure and stops you ride each way.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        _buildDropdown<String>(
          context,
          label: 'Route',
          value: route?.id,
          items: _routes
              .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
              .toList(),
          onChanged: _submitting ? null : _onRouteChanged,
        ),
        if (route != null)
          if (_loadingCatalog)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_catalogError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildRetry(
                context,
                message: "Couldn't load departures for this route.",
                onRetry: () => _loadCatalog(route),
              ),
            )
          else
            for (final direction in _directions)
              _buildLegSection(context, route, direction),
        if (_hasCredit) ...[
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _useCredit,
            onChanged: _submitting
                ? null
                : (value) => _select(() => _useCredit = value),
            title: Text(
              'Use ${widget.availableCredit!.formatted} credit',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Applied before you pay the rest.',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
        if (_submitError != null) ...[
          const SizedBox(height: 12),
          Text(
            _submitError!,
            style: AppTypography.caption.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildLegSection(
    BuildContext context,
    api.Route route,
    CommuteLegDirectionEnum direction,
  ) {
    final colors = context.appColors;
    final departures = _departures[direction] ?? const <Schedule>[];
    final leg = _legs[direction]!;
    final stops = _stopsFor(leg.departure);
    final pickup = leg.pickup;
    final enabled = !_submitting;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            direction == CommuteLegDirectionEnum.outbound
                ? 'Outbound trip'
                : 'Return trip',
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          if (departures.isEmpty)
            Text(
              'No departures are scheduled this way yet.',
              style: AppTypography.caption.copyWith(color: colors.error),
            )
          else ...[
            // Keyed by what should force each field to forget a stale
            // selection and redisplay — DropdownButtonFormField's
            // initialValue only seeds the field once, so a programmatic
            // reset (a new route, a departure on another pattern version,
            // a pickup that invalidates the dropoff) needs a fresh field,
            // not just a fresh value.
            _buildDropdown<String>(
              context,
              fieldKey: ValueKey('departure-${route.id}-${direction.name}'),
              label: 'Departure',
              value: leg.departure?.id,
              items: departures
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        '${s.localDeparture} · ${_weekdaysLabel(s.weekdays)}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: enabled
                  ? (id) => _onDepartureChanged(direction, id)
                  : null,
            ),
            const SizedBox(height: 12),
            _buildDropdown<String>(
              context,
              fieldKey: ValueKey(
                'pickup-${direction.name}-${leg.departure?.id}',
              ),
              label: 'Pickup stop',
              value: pickup?.id,
              // Nobody boards at the last stop.
              items: stops
                  .take(stops.isEmpty ? 0 : stops.length - 1)
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: enabled && leg.departure != null
                  ? (id) => _onPickupChanged(direction, id)
                  : null,
            ),
            const SizedBox(height: 12),
            _buildDropdown<String>(
              context,
              fieldKey: ValueKey(
                'dropoff-${direction.name}-${leg.departure?.id}-${pickup?.id}',
              ),
              label: 'Dropoff stop',
              value: leg.dropoff?.id,
              items: stops
                  .where((s) => pickup == null || s.ordinal > pickup.ordinal)
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: enabled && pickup != null
                  ? (id) => _onDropoffChanged(direction, id)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRetry(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context, {
    Key? fieldKey,
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    final colors = context.appColors;
    return DropdownButtonFormField<T>(
      key: fieldKey,
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption.copyWith(color: colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
      ),
    );
  }
}
