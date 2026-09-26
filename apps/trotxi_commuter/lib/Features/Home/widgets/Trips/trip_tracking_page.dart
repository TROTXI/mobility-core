import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/client_metadata.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Live position and ETA for one trip, from `GET /v1/trips/{id}/live`
/// (`LiveEligibleApi.getLiveTrip`). There's no maps SDK in this app, so this
/// renders the state/ETA/vehicle facts the API actually gives us rather than
/// a fabricated map.
class TripTrackingPage extends StatefulWidget {
  const TripTrackingPage({
    super.key,
    required this.client,
    required this.tripId,
    this.pickupName,
  });

  final TrotxiApiClient client;
  final String tripId;
  final String? pickupName;

  @override
  State<TripTrackingPage> createState() => _TripTrackingPageState();
}

class _TripTrackingPageState extends State<TripTrackingPage> {
  static const _pollInterval = Duration(seconds: 8);

  LiveTrip? _liveTrip;
  bool _loading = true;
  Object? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final response = await widget.client.getLiveEligibleApi().getLiveTrip(
        id: widget.tripId,
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
      );
      final liveTrip = response.data?.data;
      if (!mounted) return;
      setState(() {
        _liveTrip = liveTrip;
        _loading = false;
      });
      _scheduleNextPoll(liveTrip?.state);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error fetching live trip ${widget.tripId}: $e');
    }
  }

  /// Keeps polling while the trip could still move; stops once it's
  /// resolved so the page doesn't keep hitting the API after boarding.
  void _scheduleNextPoll(LiveTripStateEnum? state) {
    _pollTimer?.cancel();
    if (state == LiveTripStateEnum.ended) return;
    _pollTimer = Timer(_pollInterval, () => _fetch(silent: true));
  }

  StopEta? get _pickupEta {
    final liveTrip = _liveTrip;
    final pickupOccurrenceId = liveTrip?.riderPickupOccurrenceId;
    if (liveTrip == null || pickupOccurrenceId == null) return null;
    for (final eta in liveTrip.etas) {
      if (eta.stopOccurrenceId == pickupOccurrenceId) return eta;
    }
    return null;
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
              onRefresh: () => _fetch(),
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
    final header = _buildTopBar(context);

    if (_loading && _liveTrip == null) {
      return [
        header,
        const SizedBox(height: 60),
        Center(child: CircularProgressIndicator(color: colors.actionPrimaryDefault)),
      ];
    }

    final liveTrip = _liveTrip;
    if (_error != null && liveTrip == null) {
      return [header, const SizedBox(height: 24), _buildErrorCard(context)];
    }
    if (liveTrip == null) {
      return [header, const SizedBox(height: 24), _buildErrorCard(context)];
    }

    return [
      header,
      const SizedBox(height: 20),
      _buildStateCard(context, liveTrip),
    ];
  }

  Widget _buildTopBar(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 18),
        ),
        Expanded(
          child: Text(
            'Live trip map',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final colors = context.appColors;
    final error = _error;
    final message = error is TrotxiException
        ? error.message
        : "Couldn't load live tracking for this trip";
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
          TextButton(onPressed: () => _fetch(), child: const Text('Try again')),
        ],
      ),
    );
  }

  (String, String) _stateCopy(LiveTripStateEnum state) => switch (state) {
    LiveTripStateEnum.notStarted => (
      'Not started',
      "Your driver hasn't started this trip yet.",
    ),
    LiveTripStateEnum.awaitingFix => (
      'Connecting',
      'Waiting for a GPS fix from the vehicle.',
    ),
    LiveTripStateEnum.live => ('LIVE', 'Van is on the way.'),
    LiveTripStateEnum.stale => (
      'Signal delayed',
      "The vehicle's last known position is a little old.",
    ),
    LiveTripStateEnum.ended => ('Ended', 'This trip has ended.'),
    _ => ('Unknown', ''),
  };

  Widget _buildStateCard(BuildContext context, LiveTrip liveTrip) {
    final colors = context.appColors;
    final (badge, subtitle) = _stateCopy(liveTrip.state);
    final isLive = liveTrip.state == LiveTripStateEnum.live;
    final color = isLive
        ? colors.success
        : liveTrip.state == LiveTripStateEnum.stale
        ? colors.warning
        : colors.textSecondary;
    final eta = _pickupEta;
    final position = liveTrip.position;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.pickupName != null)
                Text(
                  widget.pickupName!,
                  style: AppTypography.caption.copyWith(color: colors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (eta != null) ...[
            Text(
              '${(eta.durationSeconds / 60).round()} min away',
              style: AppTypography.heading3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
          ],
          Text(subtitle, style: AppTypography.bodySmall.copyWith(color: colors.textSecondary)),
          if (position != null) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.borderSubtle),
            const SizedBox(height: 16),
            Text(
              'Last updated ${_formatAge(position.ageSeconds)}',
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAge(int ageSeconds) {
    if (ageSeconds < 60) return '${ageSeconds}s ago';
    return '${(ageSeconds / 60).round()} min ago';
  }
}
