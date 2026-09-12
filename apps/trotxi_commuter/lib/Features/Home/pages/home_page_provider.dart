import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/main.dart';

typedef ReservationDto = MeReservationsGet200ResponseReservationsInner;

enum ReservationStatus {
  pending,
  reserved,
  boarded,
  declined,
  unseated,
  noShow,
  released,
  operatorCancelled,
}

ReservationStatus _mapStatus(
  MeReservationsGet200ResponseReservationsInnerStatusEnum status,
) {
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum.pending) {
    return ReservationStatus.pending;
  }
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum.reserved) {
    return ReservationStatus.reserved;
  }
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum.declined) {
    return ReservationStatus.declined;
  }
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum.boarded) {
    return ReservationStatus.boarded;
  }
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum.noShow) {
    return ReservationStatus.noShow;
  }
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum.released) {
    return ReservationStatus.released;
  }
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum
          .operatorCancelled) {
    return ReservationStatus.operatorCancelled;
  }
  if (status ==
      MeReservationsGet200ResponseReservationsInnerStatusEnum.unseated) {
    return ReservationStatus.unseated;
  }
  throw StateError('Unhandled reservation status from API: $status');
}

class EtaPhase {
  final Duration? eta;
  final bool isEstimated;
  const EtaPhase({this.eta, required this.isEstimated});
}

sealed class RideLifecycleState {
  const RideLifecycleState();
}

class RidePending extends RideLifecycleState {
  const RidePending();
}

class RideReserved extends RideLifecycleState {
  final String? tripId;
  final EtaPhase etaPhase;
  const RideReserved({required this.tripId, required this.etaPhase});
}

class RideBoarded extends RideLifecycleState {
  final String tripId;
  const RideBoarded({required this.tripId});
}

class RideDeclined extends RideLifecycleState {
  const RideDeclined();
}

class RideUnseated extends RideLifecycleState {
  const RideUnseated();
}

class RideNoShow extends RideLifecycleState {
  const RideNoShow();
}

class RideReleased extends RideLifecycleState {
  const RideReleased();
}

class RideOperatorCancelled extends RideLifecycleState {
  const RideOperatorCancelled();
}

// =============================================================================
// Repository
// =============================================================================

abstract class ReservationRepository {
  Future<ReservationDto?> fetchTodayReservation();
}

class DioReservationRepository implements ReservationRepository {
  final ReservationsApi _api;

  DioReservationRepository(this._api);

  @override
  Future<ReservationDto?> fetchTodayReservation() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final response = await _api.meReservationsGet(from: today);
    final reservations = response.data?.reservations;

    if (reservations == null) return null;

    final wantedDirection = DateTime.now().hour < 12
        ? MeReservationsGet200ResponseReservationsInnerDirectionEnum.morning
        : MeReservationsGet200ResponseReservationsInnerDirectionEnum.evening;

    for (final r in reservations) {
      if (r.travelDate == today && r.direction == wantedDirection) {
        return r;
      }
    }
    return null;
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final client = ref.watch(trotxiClientProvider);
  return DioReservationRepository(client.getReservationsApi());
});

// =============================================================================
// Notifier
// =============================================================================

class RideLifecycleNotifier extends AsyncNotifier<RideLifecycleState?> {
  @override
  FutureOr<RideLifecycleState?> build() async {
    final reservation = await ref
        .read(reservationRepositoryProvider)
        .fetchTodayReservation();

    if (reservation == null) return null;

    final status = _mapStatus(reservation.status);

    return switch (status) {
      ReservationStatus.pending => const RidePending(),
      ReservationStatus.reserved => RideReserved(
        tripId: reservation.tripId,
        etaPhase: const EtaPhase(isEstimated: true), // no live position yet
      ),
      ReservationStatus.boarded => RideBoarded(tripId: reservation.tripId!),
      ReservationStatus.declined => const RideDeclined(),
      ReservationStatus.unseated => const RideUnseated(),
      ReservationStatus.noShow => const RideNoShow(),
      ReservationStatus.released => const RideReleased(),
      ReservationStatus.operatorCancelled => const RideOperatorCancelled(),
    };
  }
}

final rideLifecycleProvider =
    AsyncNotifierProvider<RideLifecycleNotifier, RideLifecycleState?>(
      RideLifecycleNotifier.new,
    );
