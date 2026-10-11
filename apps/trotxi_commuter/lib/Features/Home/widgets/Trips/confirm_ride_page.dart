import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
import 'ride_journey_cards.dart';

/// Figma 2444:694. Reviewing is read-only. A seat is requested only after the
/// explicit confirm action, for the reservation's date and direction.
class ConfirmRidePage extends StatefulWidget {
  const ConfirmRidePage({
    super.key,
    required this.client,
    required this.reservationId,
  });
  final CommuterApi client;
  final String reservationId;
  @override
  State<ConfirmRidePage> createState() => _ConfirmRidePageState();
}

class _ConfirmRidePageState extends State<ConfirmRidePage> {
  wire.ReservationDetail? _detail;
  String? _error;
  bool _loading = true, _saving = false;
  late final int _generation = widget.client.sessionGeneration;
  bool get _current =>
      mounted && _generation == widget.client.sessionGeneration;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await widget.client.reservationDetail(
        widget.reservationId,
      );
      if (!_current) return;
      if (detail.reservation.id != widget.reservationId) {
        throw const ApiException(
          502,
          'This reservation could not be verified.',
        );
      }
      setState(() => _detail = detail);
    } catch (e) {
      if (_current) {
        setState(
          () => _error = e is TrotxiException
              ? e.message
              : 'Could not load your ride. Please retry.',
        );
      }
    } finally {
      if (_current) setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    final detail = _detail;
    if (_saving || detail == null || !_current || !_canConfirm(detail)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await widget.client.decideReservation(
        wire.ReservationDecision(
          (b) => b
            ..travelDate = detail.reservation.travelDate
            ..direction =
                detail.reservation.direction ==
                    wire.ReservationDirectionEnum.outbound
                ? wire.ReservationDecisionDirectionEnum.outbound
                : wire.ReservationDecisionDirectionEnum.return_
            ..decision = wire.ReservationDecisionDecisionEnum.confirm,
        ),
      );
      if (!mounted || !_current) return;
      // The server may return unseated. Never claim confirmation optimistically.
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(result.reservation);
      if (result.reservation.status == wire.ReservationStatusEnum.unseated) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No seat is available for this ride.')),
        );
      }
    } catch (e) {
      if (_current) {
        setState(
          () => _error = e is TrotxiException
              ? e.message
              : 'Could not confirm this ride. Please retry.',
        );
      }
    } finally {
      if (_current) setState(() => _saving = false);
    }
  }

  bool _canConfirm(wire.ReservationDetail detail) =>
      detail.reservation.status == wire.ReservationStatusEnum.pending &&
      detail.trip?.status != wire.ReservationDetailTripStatusEnum.cancelled &&
      detail.trip?.status != wire.ReservationDetailTripStatusEnum.completed;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final detail = _detail;
    final day = detail?.reservation.travelDate.toDateTime();
    final tomorrow = wire.Date.now(
      utc: true,
    ).toDateTime().add(const Duration(days: 1));
    final title = day == tomorrow
        ? "Confirm tomorrow's ride"
        : 'Confirm your ride';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Text(
                  'Review your commute details before reserving your seat.',
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (!_loading && detail != null) ...[
                  AppSurface(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat('EEE, d MMM').format(day!)} · ${detail.reservation.direction == wire.ReservationDirectionEnum.outbound ? 'Outbound' : 'Return'}',
                          style: AppTypography.caption.copyWith(
                            color: c.actionSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          rideJourneyName(detail),
                          style: AppTypography.title.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          detail.trip == null
                              ? 'Departure time will appear once assigned.'
                              : 'Departs ${DateFormat('h:mm a').format(detail.trip!.scheduledAt.toUtc())}',
                          style: AppTypography.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(
                    'Pickup point',
                    detail.pickupStop?.name ?? 'Not yet assigned',
                  ),
                  const SizedBox(height: 16),
                  _field(
                    'Drop-off',
                    detail.dropoffStop?.name ?? 'Not yet assigned',
                  ),
                  const SizedBox(height: 16),
                  _field('Route', detail.route?.name ?? 'Your agreed commute'),
                  const SizedBox(height: 16),
                  AppSurface(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your commute plan',
                          style: AppTypography.label.copyWith(
                            color: c.actionSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Seat availability and your plan are checked when you confirm.',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_canConfirm(detail))
                    FilledButton(
                      onPressed: _saving ? null : _confirm,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(_saving ? 'Confirming…' : 'Confirm ride'),
                    )
                  else
                    _field(
                      'Reservation updated',
                      detail.reservation.status ==
                              wire.ReservationStatusEnum.reserved
                          ? 'Your seat is already confirmed.'
                          : 'This ride is no longer awaiting confirmation.',
                    ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: AppTypography.bodySmall.copyWith(color: c.error),
                  ),
                  if (detail == null)
                    TextButton(
                      onPressed: _load,
                      child: const Text('Try again'),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String value) => AppSurface(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Text(value, style: AppTypography.label.copyWith(fontSize: 13)),
      ],
    ),
  );
}
