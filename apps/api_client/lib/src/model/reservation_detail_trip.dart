//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation_detail_trip.g.dart';

/// ReservationDetailTrip
///
/// Properties:
/// * [id]
/// * [scheduledAt] - Operational scheduled departure, not a pickup-stop ETA.
/// * [status]
/// * [vehicleLabel]
/// * [vehiclePlate]
@BuiltValue()
abstract class ReservationDetailTrip
    implements Built<ReservationDetailTrip, ReservationDetailTripBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Operational scheduled departure, not a pickup-stop ETA.
  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'status')
  ReservationDetailTripStatusEnum get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'vehicleLabel')
  String? get vehicleLabel;

  @BuiltValueField(wireName: r'vehiclePlate')
  String? get vehiclePlate;

  ReservationDetailTrip._();

  factory ReservationDetailTrip(
      [void updates(ReservationDetailTripBuilder b)]) = _$ReservationDetailTrip;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationDetailTripBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReservationDetailTrip> get serializer =>
      _$ReservationDetailTripSerializer();
}

class _$ReservationDetailTripSerializer
    implements PrimitiveSerializer<ReservationDetailTrip> {
  @override
  final Iterable<Type> types = const [
    ReservationDetailTrip,
    _$ReservationDetailTrip
  ];

  @override
  final String wireName = r'ReservationDetailTrip';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReservationDetailTrip object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReservationDetailTripStatusEnum),
    );
    yield r'vehicleLabel';
    yield object.vehicleLabel == null
        ? null
        : serializers.serialize(
            object.vehicleLabel,
            specifiedType: const FullType.nullable(String),
          );
    yield r'vehiclePlate';
    yield object.vehiclePlate == null
        ? null
        : serializers.serialize(
            object.vehiclePlate,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReservationDetailTrip object, {
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
    required ReservationDetailTripBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDetailTripStatusEnum),
          ) as ReservationDetailTripStatusEnum;
          result.status = valueDes;
          break;
        case r'vehicleLabel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleLabel = valueDes;
          break;
        case r'vehiclePlate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehiclePlate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReservationDetailTrip deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationDetailTripBuilder();
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

class ReservationDetailTripStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'scheduled')
  static const ReservationDetailTripStatusEnum scheduled =
      _$reservationDetailTripStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const ReservationDetailTripStatusEnum active =
      _$reservationDetailTripStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const ReservationDetailTripStatusEnum completed =
      _$reservationDetailTripStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const ReservationDetailTripStatusEnum cancelled =
      _$reservationDetailTripStatusEnum_cancelled;

  static Serializer<ReservationDetailTripStatusEnum> get serializer =>
      _$reservationDetailTripStatusEnumSerializer;

  const ReservationDetailTripStatusEnum._(String name) : super(name);

  static BuiltSet<ReservationDetailTripStatusEnum> get values =>
      _$reservationDetailTripStatusEnumValues;
  static ReservationDetailTripStatusEnum valueOf(String name) =>
      _$reservationDetailTripStatusEnumValueOf(name);
}
