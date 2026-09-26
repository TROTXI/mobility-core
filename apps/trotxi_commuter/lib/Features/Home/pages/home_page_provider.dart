import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/main.dart';

typedef ReservationDto = Reservation;

// =============================================================================
// Client metadata (X-Trotxi-* headers)
// =============================================================================

final clientMetadataProvider = Provider<TrotxiClientMetadata>((ref) {
  return TrotxiClientMetadata.forCurrentPlatform(client: 'commuter', build: 1);
});

final membershipProvider = FutureProvider.autoDispose<Membership>((ref) async {
  final api = ref.watch(trotxiClientProvider).getRiderOwnApi();
  final meta = ref.watch(clientMetadataProvider);
  final response = await api.getMembership(
    xTrotxiClient: meta.client,
    xTrotxiBuild: meta.build,
    xTrotxiPlatform: meta.platform,
  );
  final membership = response.data?.data; // MembershipResponse -> Membership
  if (membership == null) throw StateError('Empty membership response');
  return membership;
});

// =============================================================================
// Status mapping
// =============================================================================

enum ReservationStatus {
  pending,
  reserved,
  boarded,
  declined,
  unseated,
  noShow,
  operatorCancelled,
}

// ReservationStatusEnum is a built_value EnumClass, not a Dart enum,
// so switches on it can't be exhaustive. Use an if-chain.
ReservationStatus _mapStatus(ReservationStatusEnum status) {
  if (status == ReservationStatusEnum.pending) return ReservationStatus.pending;
  if (status == ReservationStatusEnum.reserved) {
    return ReservationStatus.reserved;
  }
  if (status == ReservationStatusEnum.boarded) return ReservationStatus.boarded;
  if (status == ReservationStatusEnum.declined) {
    return ReservationStatus.declined;
  }
  if (status == ReservationStatusEnum.unseated) {
    return ReservationStatus.unseated;
  }
  if (status == ReservationStatusEnum.noShow) return ReservationStatus.noShow;
  if (status == ReservationStatusEnum.operatorCancelled) {
    return ReservationStatus.operatorCancelled;
  }
  throw StateError('Unhandled reservation status from API: $status');
}

// =============================================================================
// Lifecycle state
// =============================================================================

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
  final String reservationId;
  final String? tripId;
  final EtaPhase etaPhase;
  const RideReserved({
    required this.reservationId,
    required this.tripId,
    required this.etaPhase,
  });
}

class RideBoarded extends RideLifecycleState {
  final String reservationId;
  final String? tripId; // nullable: the API types it as String?
  const RideBoarded({required this.reservationId, required this.tripId});
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
  final RiderOwnApi _api;
  final TrotxiClientMetadata _meta;

  DioReservationRepository(this._api, this._meta);

  @override
  Future<ReservationDto?> fetchTodayReservation() async {
    // Africa/Accra is UTC+0 with no DST, so UTC is the Accra day.
    final now = DateTime.now().toUtc();
    final today = Date(now.year, now.month, now.day);

    final response = await _api.listReservations(
      xTrotxiClient: _meta.client,
      xTrotxiBuild: _meta.build,
      xTrotxiPlatform: _meta.platform,
      fromDate: today,
      toDate: today,
    );

    final items = response.data?.data;
    if (items == null || items.isEmpty) return null;

    // Assumption: outbound = morning leg, return = evening leg.
    final wanted = now.hour < 12
        ? ReservationDirectionEnum.outbound
        : ReservationDirectionEnum.return_;

    for (final r in items) {
      if (r.direction == wanted) return r;
    }
    return items.first; // fall back to any reservation for today
  }
}

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final client = ref.watch(trotxiClientProvider);
  final meta = ref.watch(clientMetadataProvider);
  return DioReservationRepository(client.getRiderOwnApi(), meta);
});

// =============================================================================
// Notifier
// =============================================================================

class RideLifecycleNotifier extends AsyncNotifier<RideLifecycleState?> {
  @override
  Future<RideLifecycleState?> build() => _load();

  Future<RideLifecycleState?> _load() async {
    final reservation = await ref
        .read(reservationRepositoryProvider)
        .fetchTodayReservation();

    if (reservation == null) return null;

    return switch (_mapStatus(reservation.status)) {
      ReservationStatus.pending => const RidePending(),
      ReservationStatus.reserved => RideReserved(
        reservationId: reservation.id,
        tripId: reservation.tripId,
        etaPhase: const EtaPhase(isEstimated: true), // no live position yet
      ),
      ReservationStatus.boarded => RideBoarded(
        reservationId: reservation.id,
        tripId: reservation.tripId,
      ),
      ReservationStatus.declined => const RideDeclined(),
      ReservationStatus.unseated => const RideUnseated(),
      ReservationStatus.noShow => const RideNoShow(),
      ReservationStatus.operatorCancelled => const RideOperatorCancelled(),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final rideLifecycleProvider =
    AsyncNotifierProvider<RideLifecycleNotifier, RideLifecycleState?>(
      RideLifecycleNotifier.new,
    );
