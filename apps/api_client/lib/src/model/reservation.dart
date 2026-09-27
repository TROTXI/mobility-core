//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reservation.g.dart';

/// Reservation
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [travelDate] 
/// * [direction] 
/// * [status] 
/// * [pickupOccurrenceId] 
/// * [dropoffOccurrenceId] 
/// * [source_] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class Reservation implements Built<Reservation, ReservationBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'tripId')
  String? get tripId;

  @BuiltValueField(wireName: r'travelDate')
  Date get travelDate;

  @BuiltValueField(wireName: r'direction')
  ReservationDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'status')
  ReservationStatusEnum get status;
  // enum statusEnum {  pending,  reserved,  declined,  unseated,  boarded,  no_show,  operator_cancelled,  };

  @BuiltValueField(wireName: r'pickupOccurrenceId')
  String? get pickupOccurrenceId;

  @BuiltValueField(wireName: r'dropoffOccurrenceId')
  String? get dropoffOccurrenceId;

  @BuiltValueField(wireName: r'source')
  ReservationSource_Enum get source_;
  // enum source_Enum {  confirmation,  default,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  Reservation._();

  factory Reservation([void updates(ReservationBuilder b)]) = _$Reservation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReservationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Reservation> get serializer => _$ReservationSerializer();
}

class _$ReservationSerializer implements PrimitiveSerializer<Reservation> {
  @override
  final Iterable<Type> types = const [Reservation, _$Reservation];

  @override
  final String wireName = r'Reservation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Reservation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'tripId';
    yield object.tripId == null ? null : serializers.serialize(
      object.tripId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'travelDate';
    yield serializers.serialize(
      object.travelDate,
      specifiedType: const FullType(Date),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(ReservationDirectionEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ReservationStatusEnum),
    );
    yield r'pickupOccurrenceId';
    yield object.pickupOccurrenceId == null ? null : serializers.serialize(
      object.pickupOccurrenceId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'dropoffOccurrenceId';
    yield object.dropoffOccurrenceId == null ? null : serializers.serialize(
      object.dropoffOccurrenceId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(ReservationSource_Enum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Reservation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReservationBuilder result,
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
        case r'tripId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tripId = valueDes;
          break;
        case r'travelDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.travelDate = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationDirectionEnum),
          ) as ReservationDirectionEnum;
          result.direction = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationStatusEnum),
          ) as ReservationStatusEnum;
          result.status = valueDes;
          break;
        case r'pickupOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pickupOccurrenceId = valueDes;
          break;
        case r'dropoffOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.dropoffOccurrenceId = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReservationSource_Enum),
          ) as ReservationSource_Enum;
          result.source_ = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Reservation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReservationBuilder();
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

class ReservationDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const ReservationDirectionEnum outbound = _$reservationDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const ReservationDirectionEnum return_ = _$reservationDirectionEnum_return_;

  static Serializer<ReservationDirectionEnum> get serializer => _$reservationDirectionEnumSerializer;

  const ReservationDirectionEnum._(String name): super(name);

  static BuiltSet<ReservationDirectionEnum> get values => _$reservationDirectionEnumValues;
  static ReservationDirectionEnum valueOf(String name) => _$reservationDirectionEnumValueOf(name);
}

class ReservationStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const ReservationStatusEnum pending = _$reservationStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'reserved')
  static const ReservationStatusEnum reserved = _$reservationStatusEnum_reserved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const ReservationStatusEnum declined = _$reservationStatusEnum_declined;
  @BuiltValueEnumConst(wireName: r'unseated')
  static const ReservationStatusEnum unseated = _$reservationStatusEnum_unseated;
  @BuiltValueEnumConst(wireName: r'boarded')
  static const ReservationStatusEnum boarded = _$reservationStatusEnum_boarded;
  @BuiltValueEnumConst(wireName: r'no_show')
  static const ReservationStatusEnum noShow = _$reservationStatusEnum_noShow;
  @BuiltValueEnumConst(wireName: r'operator_cancelled')
  static const ReservationStatusEnum operatorCancelled = _$reservationStatusEnum_operatorCancelled;

  static Serializer<ReservationStatusEnum> get serializer => _$reservationStatusEnumSerializer;

  const ReservationStatusEnum._(String name): super(name);

  static BuiltSet<ReservationStatusEnum> get values => _$reservationStatusEnumValues;
  static ReservationStatusEnum valueOf(String name) => _$reservationStatusEnumValueOf(name);
}

class ReservationSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'confirmation')
  static const ReservationSource_Enum confirmation = _$reservationSourceEnum_confirmation;
  @BuiltValueEnumConst(wireName: r'default')
  static const ReservationSource_Enum default_ = _$reservationSourceEnum_default_;

  static Serializer<ReservationSource_Enum> get serializer => _$reservationSourceEnumSerializer;

  const ReservationSource_Enum._(String name): super(name);

  static BuiltSet<ReservationSource_Enum> get values => _$reservationSourceEnumValues;
  static ReservationSource_Enum valueOf(String name) => _$reservationSourceEnumValueOf(name);
}

