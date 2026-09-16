//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'schedule.g.dart';

/// Schedule
///
/// Properties:
/// * [id] 
/// * [departureId] 
/// * [patternVersionId] 
/// * [serviceWindow] 
/// * [localDeparture] 
/// * [timeZone] 
/// * [weekdays] 
/// * [effectiveFrom] 
/// * [effectiveTo] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [version] 
@BuiltValue()
abstract class Schedule implements Built<Schedule, ScheduleBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'departureId')
  String get departureId;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'serviceWindow')
  ScheduleServiceWindowEnum get serviceWindow;
  // enum serviceWindowEnum {  morning,  evening,  };

  @BuiltValueField(wireName: r'localDeparture')
  String get localDeparture;

  @BuiltValueField(wireName: r'timeZone')
  ScheduleTimeZoneEnum get timeZone;
  // enum timeZoneEnum {  Africa/Accra,  };

  @BuiltValueField(wireName: r'weekdays')
  BuiltList<int> get weekdays;

  @BuiltValueField(wireName: r'effectiveFrom')
  Date get effectiveFrom;

  @BuiltValueField(wireName: r'effectiveTo')
  Date? get effectiveTo;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  Schedule._();

  factory Schedule([void updates(ScheduleBuilder b)]) = _$Schedule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScheduleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Schedule> get serializer => _$ScheduleSerializer();
}

class _$ScheduleSerializer implements PrimitiveSerializer<Schedule> {
  @override
  final Iterable<Type> types = const [Schedule, _$Schedule];

  @override
  final String wireName = r'Schedule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Schedule object, {
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
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'serviceWindow';
    yield serializers.serialize(
      object.serviceWindow,
      specifiedType: const FullType(ScheduleServiceWindowEnum),
    );
    yield r'localDeparture';
    yield serializers.serialize(
      object.localDeparture,
      specifiedType: const FullType(String),
    );
    yield r'timeZone';
    yield serializers.serialize(
      object.timeZone,
      specifiedType: const FullType(ScheduleTimeZoneEnum),
    );
    yield r'weekdays';
    yield serializers.serialize(
      object.weekdays,
      specifiedType: const FullType(BuiltList, [FullType(int)]),
    );
    yield r'effectiveFrom';
    yield serializers.serialize(
      object.effectiveFrom,
      specifiedType: const FullType(Date),
    );
    yield r'effectiveTo';
    yield object.effectiveTo == null ? null : serializers.serialize(
      object.effectiveTo,
      specifiedType: const FullType.nullable(Date),
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
    Schedule object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScheduleBuilder result,
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
        case r'patternVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternVersionId = valueDes;
          break;
        case r'serviceWindow':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ScheduleServiceWindowEnum),
          ) as ScheduleServiceWindowEnum;
          result.serviceWindow = valueDes;
          break;
        case r'localDeparture':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.localDeparture = valueDes;
          break;
        case r'timeZone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ScheduleTimeZoneEnum),
          ) as ScheduleTimeZoneEnum;
          result.timeZone = valueDes;
          break;
        case r'weekdays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(int)]),
          ) as BuiltList<int>;
          result.weekdays.replace(valueDes);
          break;
        case r'effectiveFrom':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.effectiveFrom = valueDes;
          break;
        case r'effectiveTo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.effectiveTo = valueDes;
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
  Schedule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScheduleBuilder();
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

class ScheduleServiceWindowEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'morning')
  static const ScheduleServiceWindowEnum morning = _$scheduleServiceWindowEnum_morning;
  @BuiltValueEnumConst(wireName: r'evening')
  static const ScheduleServiceWindowEnum evening = _$scheduleServiceWindowEnum_evening;

  static Serializer<ScheduleServiceWindowEnum> get serializer => _$scheduleServiceWindowEnumSerializer;

  const ScheduleServiceWindowEnum._(String name): super(name);

  static BuiltSet<ScheduleServiceWindowEnum> get values => _$scheduleServiceWindowEnumValues;
  static ScheduleServiceWindowEnum valueOf(String name) => _$scheduleServiceWindowEnumValueOf(name);
}

class ScheduleTimeZoneEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Africa/Accra')
  static const ScheduleTimeZoneEnum africaSlashAccra = _$scheduleTimeZoneEnum_africaSlashAccra;

  static Serializer<ScheduleTimeZoneEnum> get serializer => _$scheduleTimeZoneEnumSerializer;

  const ScheduleTimeZoneEnum._(String name): super(name);

  static BuiltSet<ScheduleTimeZoneEnum> get values => _$scheduleTimeZoneEnumValues;
  static ScheduleTimeZoneEnum valueOf(String name) => _$scheduleTimeZoneEnumValueOf(name);
}

