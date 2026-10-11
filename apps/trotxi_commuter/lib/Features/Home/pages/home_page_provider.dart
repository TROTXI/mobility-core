import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_client/trotxi_client.dart' as wire;
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
  const RidePending({this.reservationId});
  final String? reservationId;
}

class RideReserved extends RideLifecycleState {
  final String? tripId;
  final String? reservationId;
  final EtaPhase etaPhase;
  const RideReserved({
    required this.tripId,
    required this.etaPhase,
    this.reservationId,
  });
}

class RideBoarded extends RideLifecycleState {
  final String tripId;
  final String? reservationId;
  const RideBoarded({required this.tripId, this.reservationId});
}

class RideCompleted extends RideLifecycleState {
  const RideCompleted({required this.reservationId});
  final String reservationId;
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
      return RidePending(reservationId: r.id);
    }
    if (r.status == wire.ReservationStatusEnum.reserved) {
      return RideReserved(
        tripId: r.tripId,
        reservationId: r.id,
        etaPhase: const EtaPhase(isEstimated: true),
      );
    }
    if (r.status == wire.ReservationStatusEnum.boarded) {
      if (r.tripStatus == wire.ReservationTripStatusEnum.completed) {
        return RideCompleted(reservationId: r.id);
      }
      if (r.tripStatus == wire.ReservationTripStatusEnum.cancelled) {
        return const RideOperatorCancelled();
      }
      return RideBoarded(tripId: r.tripId!, reservationId: r.id);
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

// Optional hero details must never delay the authoritative reservation state.
// Watching the lifecycle also discards late results after a refresh or a
// direction change. The root ProviderScope is replaced on session changes.
final homeReservationDetailProvider =
    FutureProvider.autoDispose<wire.ReservationDetail?>((ref) async {
      final client = ref.watch(trotxiClientProvider);
      final lifecycle = await ref.watch(rideLifecycleProvider.future);
      final reservationId = switch (lifecycle) {
        RideReserved(:final reservationId) => reservationId,
        RidePending(:final reservationId) => reservationId,
        RideBoarded(:final reservationId) => reservationId,
        RideCompleted(:final reservationId) => reservationId,
        _ => null,
      };
      if (reservationId == null) return null;
      return ref.watch(homeDetailProvider((client, reservationId)).future);
    });

// The hero and upcoming card can refer to the same reservation. Share that
// request rather than fetching it twice; session scope is part of the key.
final homeDetailProvider = FutureProvider.autoDispose
    .family<wire.ReservationDetail, (CommuterApi, String)>((ref, key) async {
      final (client, id) = key;
      final generation = client.sessionGeneration;
      final detail = await client.reservationDetail(id);
      client.ensureSession(generation);
      return detail;
    });
