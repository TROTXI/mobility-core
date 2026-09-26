import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';

/// The trip's route corridor as it exists today; the reservation does not
/// snapshot route renames, so this can read differently than what the rider
/// saw when they booked.
class ReservationDetailRoute {
  const ReservationDetailRoute({required this.id, required this.name});

  final String id;
  final String name;
}

/// The trip assigned to a reservation. Null until dispatch assigns one.
class ReservationDetailTrip {
  const ReservationDetailTrip({
    required this.id,
    required this.scheduledAt,
    required this.status,
    this.vehicleLabel,
    this.vehiclePlate,
  });

  final String id;

  /// Operational scheduled departure, not a pickup-stop ETA.
  final DateTime scheduledAt;
  final TripStatusEnum status;
  final String? vehicleLabel;
  final String? vehiclePlate;
}

/// A published stop-occurrence snapshot. Null until a trip is assigned.
class ReservationDetailStop {
  const ReservationDetailStop({
    required this.occurrenceId,
    required this.name,
    required this.location,
    required this.ordinal,
  });

  final String occurrenceId;
  final String name;
  final Point location;
  final int ordinal;
}

/// `GET /v1/me/reservations/{id}` — rider detail for a single reservation,
/// carrying the route name, trip schedule/vehicle and pickup/dropoff stop
/// names that `RiderOwnApi.listReservations` omits.
///
/// Not part of the generated client: this endpoint was added to the API
/// after `api_client` was last regenerated, so there is no `Reservation` +
/// codegen model for it. `reservation` reuses the generated [Reservation]
/// serializer since that sub-object matches the generated schema exactly;
/// the rest is hand-parsed.
class ReservationDetail {
  const ReservationDetail({
    required this.reservation,
    this.route,
    this.trip,
    this.pickupStop,
    this.dropoffStop,
  });

  final Reservation reservation;
  final ReservationDetailRoute? route;
  final ReservationDetailTrip? trip;
  final ReservationDetailStop? pickupStop;
  final ReservationDetailStop? dropoffStop;

  static ReservationDetail fromJson(
    Map<String, dynamic> json,
    Serializers serializers,
  ) {
    final reservation = serializers.deserialize(
      json['reservation'],
      specifiedType: const FullType(Reservation),
    ) as Reservation;

    ReservationDetailStop? parseStop(Object? raw) {
      if (raw is! Map<String, dynamic>) return null;
      return ReservationDetailStop(
        occurrenceId: raw['occurrenceId'] as String,
        name: raw['name'] as String,
        location: serializers.deserialize(
          raw['location'],
          specifiedType: const FullType(Point),
        ) as Point,
        ordinal: raw['ordinal'] as int,
      );
    }

    final routeJson = json['route'];
    final tripJson = json['trip'];

    return ReservationDetail(
      reservation: reservation,
      route: routeJson is Map<String, dynamic>
          ? ReservationDetailRoute(
              id: routeJson['id'] as String,
              name: routeJson['name'] as String,
            )
          : null,
      trip: tripJson is Map<String, dynamic>
          ? ReservationDetailTrip(
              id: tripJson['id'] as String,
              scheduledAt: DateTime.parse(tripJson['scheduledAt'] as String),
              status: serializers.deserialize(
                tripJson['status'],
                specifiedType: const FullType(TripStatusEnum),
              ) as TripStatusEnum,
              vehicleLabel: tripJson['vehicleLabel'] as String?,
              vehiclePlate: tripJson['vehiclePlate'] as String?,
            )
          : null,
      pickupStop: parseStop(json['pickupStop']),
      dropoffStop: parseStop(json['dropoffStop']),
    );
  }
}

/// See [ReservationDetail] for why this is a hand-rolled call instead of a
/// generated API group method.
extension TrotxiApiClientReservationDetail on TrotxiApiClient {
  Future<ReservationDetail> getReservationDetail({
    required String id,
    required String xTrotxiClient,
    int xTrotxiBuild = 1,
    String? xTrotxiPlatform,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '/v1/me/reservations/$id',
      options: Options(
        headers: <String, dynamic>{
          'X-Trotxi-Client': xTrotxiClient,
          'X-Trotxi-Build': xTrotxiBuild,
          if (xTrotxiPlatform != null) 'X-Trotxi-Platform': xTrotxiPlatform,
        },
      ),
      cancelToken: cancelToken,
    );

    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('getReservationDetail($id) returned no data');
    }
    // `this` qualifies deliberately: the generated client also exports a
    // plugin-less top-level `serializers`, and an unqualified reference here
    // would bind to that one instead of the instance field with
    // StandardJsonPlugin, breaking every nested deserialize above.
    return ReservationDetail.fromJson(data, this.serializers);
  }
}
