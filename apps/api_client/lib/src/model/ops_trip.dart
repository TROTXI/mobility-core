//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/stop_occurrence.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_trip.g.dart';

/// OpsTrip
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
/// * [startedAt] 
/// * [completedAt] 
/// * [currentStopOccurrenceId] 
/// * [stops] 
/// * [version] 
/// * [editToken] 
/// * [scheduleId] 
/// * [assignedDriverId] 
/// * [vehicleId] 
@BuiltValue()
abstract class OpsTrip implements Built<OpsTrip, OpsTripBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'departureId')
  String get departureId;

  @BuiltValueField(wireName: r'serviceDate')
  Date get serviceDate;

  @BuiltValueField(wireName: r'runNumber')
  OpsTripRunNumberEnum get runNumber;
  // enum runNumberEnum {  1,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'patternId')
  String get patternId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'direction')
  OpsTripDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'status')
  OpsTripStatusEnum get status;
  // enum statusEnum {  scheduled,  active,  completed,  cancelled,  };

  @BuiltValueField(wireName: r'vehicleLabel')
  String? get vehicleLabel;

  @BuiltValueField(wireName: r'startedAt')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'completedAt')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'currentStopOccurrenceId')
  String? get currentStopOccurrenceId;

  @BuiltValueField(wireName: r'stops')
  BuiltList<StopOccurrence> get stops;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'editToken')
  String get editToken;

  @BuiltValueField(wireName: r'scheduleId')
  String get scheduleId;

  @BuiltValueField(wireName: r'assignedDriverId')
  String? get assignedDriverId;

  @BuiltValueField(wireName: r'vehicleId')
  String? get vehicleId;

  OpsTrip._();

  factory OpsTrip([void updates(OpsTripBuilder b)]) = _$OpsTrip;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsTripBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsTrip> get serializer => _$OpsTripSerializer();
}

class _$OpsTripSerializer implements PrimitiveSerializer<OpsTrip> {
  @override
  final Iterable<Type> types = const [OpsTrip, _$OpsTrip];

  @override
  final String wireName = r'OpsTrip';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsTrip object, {
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
      specifiedType: const FullType(OpsTripRunNumberEnum),
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
      specifiedType: const FullType(OpsTripDirectionEnum),
    );
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(OpsTripStatusEnum),
    );
    yield r'vehicleLabel';
    yield object.vehicleLabel == null ? null : serializers.serialize(
      object.vehicleLabel,
      specifiedType: const FullType.nullable(String),
    );
    yield r'startedAt';
    yield object.startedAt == null ? null : serializers.serialize(
      object.startedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'completedAt';
    yield object.completedAt == null ? null : serializers.serialize(
      object.completedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'currentStopOccurrenceId';
    yield object.currentStopOccurrenceId == null ? null : serializers.serialize(
      object.currentStopOccurrenceId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'stops';
    yield serializers.serialize(
      object.stops,
      specifiedType: const FullType(BuiltList, [FullType(StopOccurrence)]),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'editToken';
    yield serializers.serialize(
      object.editToken,
      specifiedType: const FullType(String),
    );
    yield r'scheduleId';
    yield serializers.serialize(
      object.scheduleId,
      specifiedType: const FullType(String),
    );
    yield r'assignedDriverId';
    yield object.assignedDriverId == null ? null : serializers.serialize(
      object.assignedDriverId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'vehicleId';
    yield object.vehicleId == null ? null : serializers.serialize(
      object.vehicleId,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsTrip object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsTripBuilder result,
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
            specifiedType: const FullType(OpsTripRunNumberEnum),
          ) as OpsTripRunNumberEnum;
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
            specifiedType: const FullType(OpsTripDirectionEnum),
          ) as OpsTripDirectionEnum;
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
            specifiedType: const FullType(OpsTripStatusEnum),
          ) as OpsTripStatusEnum;
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
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'completedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'currentStopOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currentStopOccurrenceId = valueDes;
          break;
        case r'stops':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StopOccurrence)]),
          ) as BuiltList<StopOccurrence>;
          result.stops.replace(valueDes);
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'editToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.editToken = valueDes;
          break;
        case r'scheduleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scheduleId = valueDes;
          break;
        case r'assignedDriverId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assignedDriverId = valueDes;
          break;
        case r'vehicleId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.vehicleId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsTrip deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsTripBuilder();
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

class OpsTripRunNumberEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const OpsTripRunNumberEnum number1 = _$opsTripRunNumberEnum_number1;

  static Serializer<OpsTripRunNumberEnum> get serializer => _$opsTripRunNumberEnumSerializer;

  const OpsTripRunNumberEnum._(String name): super(name);

  static BuiltSet<OpsTripRunNumberEnum> get values => _$opsTripRunNumberEnumValues;
  static OpsTripRunNumberEnum valueOf(String name) => _$opsTripRunNumberEnumValueOf(name);
}

class OpsTripDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const OpsTripDirectionEnum outbound = _$opsTripDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const OpsTripDirectionEnum return_ = _$opsTripDirectionEnum_return_;

  static Serializer<OpsTripDirectionEnum> get serializer => _$opsTripDirectionEnumSerializer;

  const OpsTripDirectionEnum._(String name): super(name);

  static BuiltSet<OpsTripDirectionEnum> get values => _$opsTripDirectionEnumValues;
  static OpsTripDirectionEnum valueOf(String name) => _$opsTripDirectionEnumValueOf(name);
}

class OpsTripStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const OpsTripStatusEnum scheduled = _$opsTripStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const OpsTripStatusEnum active = _$opsTripStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const OpsTripStatusEnum completed = _$opsTripStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const OpsTripStatusEnum cancelled = _$opsTripStatusEnum_cancelled;

  static Serializer<OpsTripStatusEnum> get serializer => _$opsTripStatusEnumSerializer;

  const OpsTripStatusEnum._(String name): super(name);

  static BuiltSet<OpsTripStatusEnum> get values => _$opsTripStatusEnumValues;
  static OpsTripStatusEnum valueOf(String name) => _$opsTripStatusEnumValueOf(name);
}

