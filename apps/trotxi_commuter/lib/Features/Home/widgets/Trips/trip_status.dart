import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

/// Rider-facing outcome of a reservation, collapsed from the wire enum's
/// seven values into what the Trips UI actually distinguishes on.
enum TripOutcome {
  pending,
  confirmed,
  completed,
  missed,
  declined,
  operatorCancelled,
  unseated,
}

// ReservationStatusEnum is a built_value EnumClass, not a Dart enum, so a
// switch on it can't be exhaustive — same reasoning as
// home_page_provider.dart's `_mapStatus`.
TripOutcome tripOutcomeOf(ReservationStatusEnum status) {
  if (status == ReservationStatusEnum.pending) return TripOutcome.pending;
  if (status == ReservationStatusEnum.reserved) return TripOutcome.confirmed;
  if (status == ReservationStatusEnum.boarded) return TripOutcome.completed;
  if (status == ReservationStatusEnum.declined) return TripOutcome.declined;
  if (status == ReservationStatusEnum.unseated) return TripOutcome.unseated;
  if (status == ReservationStatusEnum.noShow) return TripOutcome.missed;
  if (status == ReservationStatusEnum.operatorCancelled) {
    return TripOutcome.operatorCancelled;
  }
  throw StateError('Unhandled reservation status from API: $status');
}

String tripOutcomeLabel(TripOutcome outcome) => switch (outcome) {
  TripOutcome.pending => 'Awaiting confirmation',
  TripOutcome.confirmed => 'Confirmed',
  TripOutcome.completed => 'Completed',
  TripOutcome.missed => 'Missed',
  TripOutcome.declined => 'Cancelled',
  TripOutcome.operatorCancelled => 'Cancelled by operator',
  TripOutcome.unseated => 'Unseated',
};

Color tripOutcomeColor(BuildContext context, TripOutcome outcome) {
  final colors = context.appColors;
  return switch (outcome) {
    TripOutcome.pending => colors.warning,
    TripOutcome.confirmed => colors.success,
    TripOutcome.completed => colors.success,
    TripOutcome.missed => colors.error,
    TripOutcome.declined => colors.warning,
    TripOutcome.operatorCancelled => colors.error,
    TripOutcome.unseated => colors.warning,
  };
}

/// Outcomes the rider didn't get the ride they booked, so the detail page
/// owes them a short explanation rather than just a status word.
bool tripOutcomeNeedsExplanation(TripOutcome outcome) => switch (outcome) {
  TripOutcome.missed ||
  TripOutcome.declined ||
  TripOutcome.operatorCancelled ||
  TripOutcome.unseated => true,
  TripOutcome.pending || TripOutcome.confirmed || TripOutcome.completed =>
    false,
};

String tripOutcomeExplanation(TripOutcome outcome) => switch (outcome) {
  TripOutcome.missed =>
    "Boarding wasn't recorded for this trip before it ended, so it's "
        'marked as missed.',
  TripOutcome.declined => "Your reservation request wasn't approved for "
      'this trip.',
  TripOutcome.operatorCancelled =>
    'This trip was cancelled by the operator.',
  TripOutcome.unseated =>
    "Your seat wasn't confirmed in time and was released.",
  TripOutcome.pending || TripOutcome.confirmed || TripOutcome.completed => '',
};

/// outbound = morning leg, return = evening leg — same assumption
/// `DioReservationRepository.fetchTodayReservation` makes in
/// home_page_provider.dart.
String directionLabel(ReservationDirectionEnum direction) =>
    direction == ReservationDirectionEnum.outbound
        ? 'Morning commute'
        : 'Evening commute';
