//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/stop_occurrence.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_trip.g.dart';

/// DriverTrip
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
@BuiltValue()
abstract class DriverTrip implements Built<DriverTrip, DriverTripBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'departureId')
  String get departureId;

  @BuiltValueField(wireName: r'serviceDate')
  Date get serviceDate;

  @BuiltValueField(wireName: r'runNumber')
  DriverTripRunNumberEnum get runNumber;
  // enum runNumberEnum {  1,  };

  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'patternId')
  String get patternId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'direction')
  DriverTripDirectionEnum get direction;
  // enum directionEnum {  outbound,  return,  };

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime get scheduledAt;

  @BuiltValueField(wireName: r'status')
  DriverTripStatusEnum get status;
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

  DriverTrip._();

  factory DriverTrip([void updates(DriverTripBuilder b)]) = _$DriverTrip;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTripBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverTrip> get serializer => _$DriverTripSerializer();
}

class _$DriverTripSerializer implements PrimitiveSerializer<DriverTrip> {
  @override
  final Iterable<Type> types = const [DriverTrip, _$DriverTrip];

  @override
  final String wireName = r'DriverTrip';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverTrip object, {
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
      specifiedType: const FullType(DriverTripRunNumberEnum),
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
      specifiedType: const FullType(DriverTripDirectionEnum),
    );
    yield r'scheduledAt';
    yield serializers.serialize(
      object.scheduledAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(DriverTripStatusEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverTrip object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverTripBuilder result,
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
            specifiedType: const FullType(DriverTripRunNumberEnum),
          ) as DriverTripRunNumberEnum;
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
            specifiedType: const FullType(DriverTripDirectionEnum),
          ) as DriverTripDirectionEnum;
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
            specifiedType: const FullType(DriverTripStatusEnum),
          ) as DriverTripStatusEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverTrip deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverTripBuilder();
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

class DriverTripRunNumberEnum extends EnumClass {

  @BuiltValueEnumConst(wireNumber: 1)
  static const DriverTripRunNumberEnum number1 = _$driverTripRunNumberEnum_number1;

  static Serializer<DriverTripRunNumberEnum> get serializer => _$driverTripRunNumberEnumSerializer;

  const DriverTripRunNumberEnum._(String name): super(name);

  static BuiltSet<DriverTripRunNumberEnum> get values => _$driverTripRunNumberEnumValues;
  static DriverTripRunNumberEnum valueOf(String name) => _$driverTripRunNumberEnumValueOf(name);
}

class DriverTripDirectionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'outbound')
  static const DriverTripDirectionEnum outbound = _$driverTripDirectionEnum_outbound;
  @BuiltValueEnumConst(wireName: r'return')
  static const DriverTripDirectionEnum return_ = _$driverTripDirectionEnum_return_;

  static Serializer<DriverTripDirectionEnum> get serializer => _$driverTripDirectionEnumSerializer;

  const DriverTripDirectionEnum._(String name): super(name);

  static BuiltSet<DriverTripDirectionEnum> get values => _$driverTripDirectionEnumValues;
  static DriverTripDirectionEnum valueOf(String name) => _$driverTripDirectionEnumValueOf(name);
}

class DriverTripStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scheduled')
  static const DriverTripStatusEnum scheduled = _$driverTripStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'active')
  static const DriverTripStatusEnum active = _$driverTripStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'completed')
  static const DriverTripStatusEnum completed = _$driverTripStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const DriverTripStatusEnum cancelled = _$driverTripStatusEnum_cancelled;

  static Serializer<DriverTripStatusEnum> get serializer => _$driverTripStatusEnumSerializer;

  const DriverTripStatusEnum._(String name): super(name);

  static BuiltSet<DriverTripStatusEnum> get values => _$driverTripStatusEnumValues;
  static DriverTripStatusEnum valueOf(String name) => _$driverTripStatusEnumValueOf(name);
}

