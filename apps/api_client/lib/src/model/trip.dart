//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip.g.dart';

/// Trip
///
/// Properties:
/// * [id] 
/// * [departureId] 
/// * [serviceDate] 
/// * [runNumber] 
/// * [routeId] 
/// * [patternId] 
/// * [patternVersionId] 
/// * [direction] 
/// * [scheduledAt] 
/// * [status] 
/// * [vehicleLabel] 
@BuiltValue()
abstract class Trip implements Built<Trip, TripBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'departureId')
  String get departureId;

  @BuiltValueField(wireName: r'serviceDate')
  Date get serviceDate;

  @BuiltValueField(wireName: r'runNumber')
  TripRunNumberEnum get runNumber;
  // enum runNumberEnum {  1,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'patternId')
  String get patternId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'direction')
  TripDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'status')
  TripStatusEnum get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'vehicleLabel')
  String? get vehicleLabel;

  Trip._();

  factory Trip([void updates(TripBuilder b)]) = _$Trip;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Trip> get serializer => _$TripSerializer();
}

class _$TripSerializer implements PrimitiveSerializer<Trip> {
  @override
  final Iterable<Type> types = const [Trip, _$Trip];

  @override
  final String wireName = r'Trip';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Trip object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'departureId';
    yield serializers.serialize(
      object.departureId,
      specifiedType: const FullType(String),
    );
    yield r'serviceDate';
    yield serializers.serialize(
      object.serviceDate,
      specifiedType: const FullType(Date),
    );
    yield r'runNumber';
    yield serializers.serialize(
      object.runNumber,
      specifiedType: const FullType(TripRunNumberEnum),
    );
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'patternId';
    yield serializers.serialize(
      object.patternId,
      specifiedType: const FullType(String),
    );
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'direction';
    yield serializers.serialize(
      object.direction,
      specifiedType: const FullType(TripDirectionEnum),
    );
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(TripStatusEnum),
    );
    yield r'vehicleLabel';
    yield object.vehicleLabel == null ? null : serializers.serialize(
      object.vehicleLabel,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Trip object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripBuilder result,
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
        case r'departureId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.departureId = valueDes;
          break;
        case r'serviceDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.serviceDate = valueDes;
          break;
        case r'runNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripRunNumberEnum),
          ) as TripRunNumberEnum;
          result.runNumber = valueDes;
          break;
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'patternId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternId = valueDes;
          break;
        case r'patternVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternVersionId = valueDes;
          break;
        case r'direction':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripDirectionEnum),
          ) as TripDirectionEnum;
          result.direction = valueDes;
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
            specifiedType: const FullType(TripStatusEnum),
          ) as TripStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Trip deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripBuilder();
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

class TripRunNumberEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const TripRunNumberEnum number1 = _$tripRunNumberEnum_number1;

  static Serializer<TripRunNumberEnum> get serializer => _$tripRunNumberEnumSerializer;

  const TripRunNumberEnum._(String name): super(name);

  static BuiltSet<TripRunNumberEnum> get values => _$tripRunNumberEnumValues;
  static TripRunNumberEnum valueOf(String name) => _$tripRunNumberEnumValueOf(name);
}

class TripDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const TripDirectionEnum outbound = _$tripDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const TripDirectionEnum return_ = _$tripDirectionEnum_return_;

  static Serializer<TripDirectionEnum> get serializer => _$tripDirectionEnumSerializer;

  const TripDirectionEnum._(String name): super(name);

  static BuiltSet<TripDirectionEnum> get values => _$tripDirectionEnumValues;
  static TripDirectionEnum valueOf(String name) => _$tripDirectionEnumValueOf(name);
}

class TripStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const TripStatusEnum scheduled = _$tripStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const TripStatusEnum active = _$tripStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const TripStatusEnum completed = _$tripStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const TripStatusEnum cancelled = _$tripStatusEnum_cancelled;

  static Serializer<TripStatusEnum> get serializer => _$tripStatusEnumSerializer;

  const TripStatusEnum._(String name): super(name);

  static BuiltSet<TripStatusEnum> get values => _$tripStatusEnumValues;
  static TripStatusEnum valueOf(String name) => _$tripStatusEnumValueOf(name);
}

