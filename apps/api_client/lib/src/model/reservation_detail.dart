//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/reservation_detail_pickup_stop.dart';
import 'package:trotxi_api_client/src/model/reservation.dart';
import 'package:trotxi_api_client/src/model/reservation_detail_route.dart';
import 'package:trotxi_api_client/src/model/reservation_detail_trip.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_detail.g.dart';

/// ReservationDetail
///
/// Properties:
/// * [reservation]
/// * [route]
/// * [trip]
/// * [pickupStop]
/// * [dropoffStop]
@BuiltValue()
abstract class ReservationDetail
    implements Built<ReservationDetail, ReservationDetailBuilder> {
  @BuiltValueField(wireName: r'reservation')
  Reservation get reservation;

  @BuiltValueField(wireName: r'route')
  ReservationDetailRoute? get route;

  @BuiltValueField(wireName: r'trip')
  ReservationDetailTrip? get trip;

  @BuiltValueField(wireName: r'pickupStop')
  ReservationDetailPickupStop? get pickupStop;

  @BuiltValueField(wireName: r'dropoffStop')
  ReservationDetailPickupStop? get dropoffStop;

  ReservationDetail._();

  factory ReservationDetail([void updates(ReservationDetailBuilder b)]) =
      _$ReservationDetail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDetailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDetail> get serializer =>
      _$ReservationDetailSerializer();
}

class _$ReservationDetailSerializer
    implements PrimitiveSerializer<ReservationDetail> {
  @override
  final Iterable<Type> types = const [ReservationDetail, _$ReservationDetail];

  @override
  final String wireName = r'ReservationDetail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reservation';
    yield serializers.serialize(
      object.reservation,
      specifiedType: const FullType(Reservation),
    );
    yield r'route';
    yield object.route == null
        ? null
        : serializers.serialize(
            object.route,
            specifiedType: const FullType.nullable(ReservationDetailRoute),
          );
    yield r'trip';
    yield object.trip == null
        ? null
        : serializers.serialize(
            object.trip,
            specifiedType: const FullType.nullable(ReservationDetailTrip),
          );
    yield r'pickupStop';
    yield object.pickupStop == null
        ? null
        : serializers.serialize(
            object.pickupStop,
            specifiedType: const FullType.nullable(ReservationDetailPickupStop),
          );
    yield r'dropoffStop';
    yield object.dropoffStop == null
        ? null
        : serializers.serialize(
            object.dropoffStop,
            specifiedType: const FullType.nullable(ReservationDetailPickupStop),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDetail object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationDetailBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reservation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Reservation),
          ) as Reservation;
          result.reservation.replace(valueDes);
          break;
        case r'route':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReservationDetailRoute),
          ) as ReservationDetailRoute?;
          if (valueDes == null) continue;
          result.route.replace(valueDes);
          break;
        case r'trip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReservationDetailTrip),
          ) as ReservationDetailTrip?;
          if (valueDes == null) continue;
          result.trip.replace(valueDes);
          break;
        case r'pickupStop':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReservationDetailPickupStop),
          ) as ReservationDetailPickupStop?;
          if (valueDes == null) continue;
          result.pickupStop.replace(valueDes);
          break;
        case r'dropoffStop':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ReservationDetailPickupStop),
          ) as ReservationDetailPickupStop?;
          if (valueDes == null) continue;
          result.dropoffStop.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDetail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDetailBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
