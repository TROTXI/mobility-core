//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_detail_pickup_stop.g.dart';

/// Published stop-occurrence snapshot; null until a trip is assigned.
///
/// Properties:
/// * [occurrenceId]
/// * [name]
/// * [location]
/// * [ordinal]
@BuiltValue()
abstract class ReservationDetailPickupStop
    implements
        Built<ReservationDetailPickupStop, ReservationDetailPickupStopBuilder> {
  @BuiltValueField(wireName: r'occurrenceId')
  String get occurrenceId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'location')
  Point get location;

  @BuiltValueField(wireName: r'ordinal')
  int get ordinal;

  ReservationDetailPickupStop._();

  factory ReservationDetailPickupStop(
          [void updates(ReservationDetailPickupStopBuilder b)]) =
      _$ReservationDetailPickupStop;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDetailPickupStopBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDetailPickupStop> get serializer =>
      _$ReservationDetailPickupStopSerializer();
}

class _$ReservationDetailPickupStopSerializer
    implements PrimitiveSerializer<ReservationDetailPickupStop> {
  @override
  final Iterable<Type> types = const [
    ReservationDetailPickupStop,
    _$ReservationDetailPickupStop
  ];

  @override
  final String wireName = r'ReservationDetailPickupStop';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDetailPickupStop object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'occurrenceId';
    yield serializers.serialize(
      object.occurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(Point),
    );
    yield r'ordinal';
    yield serializers.serialize(
      object.ordinal,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDetailPickupStop object, {
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
    required ReservationDetailPickupStopBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'occurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.occurrenceId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Point),
          ) as Point;
          result.location.replace(valueDes);
          break;
        case r'ordinal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ordinal = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDetailPickupStop deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDetailPickupStopBuilder();
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
