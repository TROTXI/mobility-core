import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/commuter_trip_tracking.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_map/trotxi_map.dart';
import 'trip_map_canvas.dart';

typedef TripMapBuilder =
    Widget Function(CommuterTripSnapshot snapshot, TrotxiMapStyle style);
Widget buildTripMap(CommuterTripSnapshot snapshot, TrotxiMapStyle style) =>
    TripMapCanvas(snapshot: snapshot, style: style);

@visibleForTesting
Duration? tripTrackingPollDelay(
  wire.LiveTripStateEnum state,
  Duration liveInterval,
) => switch (state) {
  wire.LiveTripStateEnum.notStarted || wire.LiveTripStateEnum.ended => null,
  wire.LiveTripStateEnum.awaitingFix ||
  wire.LiveTripStateEnum.stale => const Duration(seconds: 30),
  _ => liveInterval,
};

final _pollJitter = math.Random();

@visibleForTesting
Duration jitterTripTrackingDelay(
  Duration delay, {
  double? sample,
  bool notBefore = false,
}) {
  final boundedSample = (sample ?? _pollJitter.nextDouble()).clamp(0.0, 1.0);
  final factor = notBefore
      ? 1.0 + (boundedSample * 0.2)
      : 0.8 + (boundedSample * 0.4);
  return Duration(microseconds: (delay.inMicroseconds * factor).round());
}

typedef TripTrackingContentBuilder =
    Widget Function(
      CommuterTripSnapshot? snapshot,
      Widget? map,
      String? error,
      bool loading,
    );

class TripTrackingPage extends StatefulWidget {
  const TripTrackingPage({
    super.key,
    required this.client,
    required this.tripId,
    this.mapBuilder = buildTripMap,
    this.pollInterval = const Duration(seconds: 15),
    this.contentBuilder,
    this.isActive = true,
    this.onTripEnded,
  });
  final CommuterApi client;
  final String tripId;
  final TripMapBuilder mapBuilder;
  final TripTrackingContentBuilder? contentBuilder;
  final bool isActive;
  final VoidCallback? onTripEnded;

  /// Injectable scheduler interval for lifecycle tests; app callers use 15s.
  final Duration pollInterval;
  @override
  State<TripTrackingPage> createState() => _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage>
    with WidgetsBindingObserver {
  late CommuterTripTracking _tracking;
  CommuterTripSnapshot? _snapshot;
  String? _error;
  Timer? _poll, _age;
  bool _foreground = true,
      _inFlight = false,
      _loading = false,
      _resumePending = false;
  int _epoch = 0;
  Duration _delay = const Duration(seconds: 15);
  bool _routeCurrent = true;
  bool get _visible => _foreground && widget.isActive && _routeCurrent;
  @override
  void initState() {
    super.initState();
    _tracking = CommuterTripTracking(widget.client, widget.tripId);
    _delay = widget.pollInterval;
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    if (_visible) _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current == _routeCurrent) return;
    _routeCurrent = current;
    _stop();
    _snapshot = null;
    _error = null;
    if (_visible) {
      if (_inFlight) {
        _resumePending = true;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _visible) _refresh();
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant TripTrackingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final identityChanged =
        oldWidget.client != widget.client || oldWidget.tripId != widget.tripId;
    if (identityChanged || oldWidget.isActive != widget.isActive) {
      _stop();
      _snapshot = null;
      _error = null;
      if (identityChanged) {
        _tracking.dispose();
        _tracking = CommuterTripTracking(widget.client, widget.tripId);
      }
      if (_visible) {
        if (_inFlight) {
          _resumePending = true;
        } else {
          _refresh();
        }
      }
    }
  }

  @override
  void dispose() {
    _stop();
    _tracking.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _stop() {
    _epoch++;
    _resumePending = false;
    _tracking.invalidate();
    _poll?.cancel();
    _age?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _stop();
    setState(() {
      _snapshot = null;
      _error = null;
    });
    if (_visible) {
      if (_inFlight) {
        _resumePending = true;
      } else {
        _refresh();
      }
    }
  }

  Future<void> _refresh({bool userInitiated = false}) async {
    if (!_visible || _inFlight) return;
    _poll?.cancel();
    final epoch = _epoch;
    final showProgress = userInitiated || _snapshot == null;
    _inFlight = true;
    if (showProgress) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    var again = true;
    var retryNotBefore = false;
    try {
      final snapshot = await _tracking.load();
      if (!mounted || epoch != _epoch || !_visible) return;
      final nextPoll = tripTrackingPollDelay(
        snapshot.live.state,
        widget.pollInterval,
      );
      setState(() {
        _snapshot = snapshot;
        _error = null;
        if (nextPoll != null) _delay = nextPoll;
      });
      again = nextPoll != null;
      if (snapshot.live.state == wire.LiveTripStateEnum.ended) {
        widget.onTripEnded?.call();
      }
      _age?.cancel();
      if (snapshot.hasPosition) {
        _age = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted && _visible && _snapshot != null) setState(() {});
        });
      }
    } catch (e) {
      if (!mounted || epoch != _epoch || !_visible) return;
      _age?.cancel();
      setState(() {
        _snapshot = null;
        _error =
            e is ApiException && (e.statusCode == 404 || e.statusCode == 403)
            ? 'Live tracking is unavailable for this trip or your current access. Refresh after your access changes.'
            : e is TrotxiException
            ? e.message
            : 'Could not refresh live tracking. Please retry.';
      });
      if (e is RateLimitException) {
        retryNotBefore = true;
        _delay = e.retryAfter > widget.pollInterval
            ? e.retryAfter
            : widget.pollInterval;
      } else {
        final doubled = Duration(microseconds: _delay.inMicroseconds * 2);
        const ceiling = Duration(minutes: 2);
        _delay = doubled < widget.pollInterval
            ? widget.pollInterval
            : doubled > ceiling
            ? ceiling
            : doubled;
      }
      again =
          !(e is UnauthorizedException ||
              e is UpgradeRequiredException ||
              e is ApiException &&
                  (e.statusCode == 403 || e.statusCode == 404));
    } finally {
      _inFlight = false;
      if (mounted) {
        if (showProgress) setState(() => _loading = false);
        if (_visible && _resumePending) {
          _resumePending = false;
          unawaited(_refresh());
        } else if (_visible && epoch == _epoch && again) {
          _poll = Timer(
            jitterTripTrackingDelay(_delay, notBefore: retryNotBefore),
            _refresh,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final tiles = widget.client.configuration?.mapTiles;
    String? clean(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
    final style = TrotxiMapStyle(
      lightUrl: clean(tiles?.styleUrl),
      darkUrl: clean(tiles?.darkStyleUrl),
      attribution: clean(tiles?.attribution) ?? TrotxiMapStyle.none.attribution,
    );
    final colors = context.appColors;
    if (widget.contentBuilder case final builder?) {
      return builder(
        snapshot,
        snapshot == null ? null : widget.mapBuilder(snapshot, style),
        _error,
        _loading,
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Track your bus')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              children: [
                AppPageHeading(
                  title: snapshot?.routeName ?? 'Your bus, on the way.',
                  subtitle:
                      'Only the bus location is shown. This app does not collect your location.',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _inFlight || !_foreground
                        ? null
                        : () => _refresh(userInitiated: true),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Check latest location'),
                  ),
                ),
                if (_loading) const LinearProgressIndicator(),
                if (!_foreground)
                  const AppSurface(
                    child: Text('Tracking paused while the app is not active.'),
                  ),
                if (_error != null)
                  AppSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          color: colors.warning,
                        ),
                        const SizedBox(height: 12),
                        Text(_error!, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                if (snapshot != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: widget.mapBuilder(snapshot, style),
                  ),
                  const SizedBox(height: 20),
                  AppSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppStatusBadge(
                          label: switch (snapshot.live.state) {
                            wire.LiveTripStateEnum.notStarted =>
                              'Trip has not started.',
                            wire.LiveTripStateEnum.awaitingFix =>
                              'Waiting for the driver’s first location update.',
                            wire.LiveTripStateEnum.ended =>
                              'Trip ended. No live bus location is shown.',
                            _ =>
                              snapshot.hasPosition
                                  ? '${snapshot.fresh ? 'Live bus' : 'Last known bus position'} · ${snapshot.age!.inSeconds}s old'
                                  : 'Bus location unavailable.',
                          },
                          color: snapshot.fresh
                              ? colors.success
                              : colors.warning,
                        ),
                        const SizedBox(height: 16),
                        if (snapshot.pickupEta != null) ...[
                          Text(
                            '~${(snapshot.pickupEta!.durationSeconds / 60).ceil()} min',
                            style: AppTypography.heading1.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Estimated arrival at your pickup',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ] else
                          Text(
                            'No current pickup prediction. This does not mean the bus has arrived.',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        if (snapshot.age != null &&
                            snapshot.age! > const Duration(seconds: 120)) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Position is too old for an arrival prediction.',
                            style: AppTypography.caption.copyWith(
                              color: colors.warning,
                            ),
                          ),
                        ],
                        if (snapshot.mapWarning != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            snapshot.mapWarning!,
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        AppDetailRow(
                          label:
                              snapshot.trip.direction ==
                                  wire.TripDirectionEnum.outbound
                              ? 'Outbound departure'
                              : 'Return departure',
                          value: DateFormat(
                            'EEE, d MMM · h:mm a',
                          ).format(snapshot.trip.scheduledAt.toUtc()),
                        ),
                        AppDetailRow(
                          label: 'Your bus',
                          value:
                              snapshot.trip.vehicleLabel ??
                              'Vehicle not assigned',
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.etas.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Along your route',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppSettingsGroup(
                      children: [
                        for (final eta in snapshot.etas)
                          ListTile(
                            title: Text(
                              snapshot.stopName(eta.stopOccurrenceId),
                            ),
                            subtitle: Text(
                              '~${(eta.durationSeconds / 60).ceil()} min · Estimated arrival',
                            ),
                            leading: Icon(
                              eta.stopOccurrenceId ==
                                      snapshot.live.riderPickupOccurrenceId
                                  ? Icons.place_outlined
                                  : Icons.circle_outlined,
                              color: colors.actionSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
