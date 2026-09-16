import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/main.dart';

typedef ReservationDto = wire.Reservation;

enum CommuteDirection { outbound, returning }

class SelectedDirection extends Notifier<CommuteDirection> {
  @override
  CommuteDirection build() => CommuteDirection.outbound;
  void select(CommuteDirection direction) => state = direction;
}

final selectedDirectionProvider =
    NotifierProvider<SelectedDirection, CommuteDirection>(
      SelectedDirection.new,
    );

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

abstract class ReservationRepository {
  Future<ReservationDto?> fetchTodayReservation();
}

class DioReservationRepository implements ReservationRepository {
  DioReservationRepository(this.client, this.direction);
  final CommuterApi client;
  final CommuteDirection direction;
  @override
  Future<ReservationDto?> fetchTodayReservation() async {
    // Service calendars are Africa/Accra (UTC), regardless of phone timezone.
    final today = wire.Date.now(utc: true);
    final rows = await client.reservations(from: today, to: today);
    final matching = rows
        .where(
          (r) =>
              r.travelDate == today &&
              r.direction ==
                  (direction == CommuteDirection.outbound
                      ? wire.ReservationDirectionEnum.outbound
                      : wire.ReservationDirectionEnum.return_),
        )
        .toList();
    if (matching.length > 1) {
      throw const ApiException(
        502,
        'More than one reservation was returned for this direction.',
      );
    }
    return matching.isEmpty ? null : matching.single;
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => DioReservationRepository(
    ref.watch(trotxiClientProvider),
    ref.watch(selectedDirectionProvider),
  ),
);

class RideLifecycleNotifier extends AsyncNotifier<RideLifecycleState?> {
  @override
  FutureOr<RideLifecycleState?> build() async {
    final r = await ref
        .watch(reservationRepositoryProvider)
        .fetchTodayReservation();
    if (r == null) return null;
    if (r.status == wire.ReservationStatusEnum.boarded && r.tripId == null) {
      throw const ApiException(502, 'Boarded reservation has no departure.');
    }
    if (r.status == wire.ReservationStatusEnum.pending) {
      return const RidePending();
    }
    if (r.status == wire.ReservationStatusEnum.reserved) {
      return RideReserved(
        tripId: r.tripId,
        etaPhase: const EtaPhase(isEstimated: true),
      );
    }
    if (r.status == wire.ReservationStatusEnum.boarded) {
      return RideBoarded(tripId: r.tripId!);
    }
    if (r.status == wire.ReservationStatusEnum.declined) {
      return const RideDeclined();
    }
    if (r.status == wire.ReservationStatusEnum.unseated) {
      return const RideUnseated();
    }
    if (r.status == wire.ReservationStatusEnum.noShow) {
      return const RideNoShow();
    }
    if (r.status == wire.ReservationStatusEnum.operatorCancelled) {
      return const RideOperatorCancelled();
    }
    throw const ApiException(502, 'Unknown reservation state.');
  }
}

final rideLifecycleProvider =
    AsyncNotifierProvider<RideLifecycleNotifier, RideLifecycleState?>(
      RideLifecycleNotifier.new,
    );
