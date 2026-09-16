//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/schedule_input_departure.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'schedule_input.g.dart';

/// ScheduleInput
///
/// Properties:
/// * [departure] 
/// * [patternVersionId] 
/// * [serviceWindow] 
/// * [localDeparture] 
/// * [timeZone] 
/// * [weekdays] 
/// * [effectiveFrom] 
/// * [effectiveTo] 
@BuiltValue()
abstract class ScheduleInput implements Built<ScheduleInput, ScheduleInputBuilder> {
  @BuiltValueField(wireName: r'departure')
  ScheduleInputDeparture get departure;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'serviceWindow')
  ScheduleInputServiceWindowEnum get serviceWindow;
  // enum serviceWindowEnum {  morning,  evening,  };

  @BuiltValueField(wireName: r'localDeparture')
  String get localDeparture;

  @BuiltValueField(wireName: r'timeZone')
  ScheduleInputTimeZoneEnum get timeZone;
  // enum timeZoneEnum {  Africa/Accra,  };

  @BuiltValueField(wireName: r'weekdays')
  BuiltList<int> get weekdays;

  @BuiltValueField(wireName: r'effectiveFrom')
  Date get effectiveFrom;

  @BuiltValueField(wireName: r'effectiveTo')
  Date? get effectiveTo;

  ScheduleInput._();

  factory ScheduleInput([void updates(ScheduleInputBuilder b)]) = _$ScheduleInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScheduleInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScheduleInput> get serializer => _$ScheduleInputSerializer();
}

class _$ScheduleInputSerializer implements PrimitiveSerializer<ScheduleInput> {
  @override
  final Iterable<Type> types = const [ScheduleInput, _$ScheduleInput];

  @override
  final String wireName = r'ScheduleInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScheduleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'departure';
    yield serializers.serialize(
      object.departure,
      specifiedType: const FullType(ScheduleInputDeparture),
    );
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'serviceWindow';
    yield serializers.serialize(
      object.serviceWindow,
      specifiedType: const FullType(ScheduleInputServiceWindowEnum),
    );
    yield r'localDeparture';
    yield serializers.serialize(
      object.localDeparture,
      specifiedType: const FullType(String),
    );
    yield r'timeZone';
    yield serializers.serialize(
      object.timeZone,
      specifiedType: const FullType(ScheduleInputTimeZoneEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ScheduleInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScheduleInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'departure':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ScheduleInputDeparture),
          ) as ScheduleInputDeparture;
          result.departure.replace(valueDes);
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
            specifiedType: const FullType(ScheduleInputServiceWindowEnum),
          ) as ScheduleInputServiceWindowEnum;
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
            specifiedType: const FullType(ScheduleInputTimeZoneEnum),
          ) as ScheduleInputTimeZoneEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScheduleInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScheduleInputBuilder();
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

class ScheduleInputServiceWindowEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'morning')
  static const ScheduleInputServiceWindowEnum morning = _$scheduleInputServiceWindowEnum_morning;
  @BuiltValueEnumConst(wireName: r'evening')
  static const ScheduleInputServiceWindowEnum evening = _$scheduleInputServiceWindowEnum_evening;

  static Serializer<ScheduleInputServiceWindowEnum> get serializer => _$scheduleInputServiceWindowEnumSerializer;

  const ScheduleInputServiceWindowEnum._(String name): super(name);

  static BuiltSet<ScheduleInputServiceWindowEnum> get values => _$scheduleInputServiceWindowEnumValues;
  static ScheduleInputServiceWindowEnum valueOf(String name) => _$scheduleInputServiceWindowEnumValueOf(name);
}

class ScheduleInputTimeZoneEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'Africa/Accra')
  static const ScheduleInputTimeZoneEnum africaSlashAccra = _$scheduleInputTimeZoneEnum_africaSlashAccra;

  static Serializer<ScheduleInputTimeZoneEnum> get serializer => _$scheduleInputTimeZoneEnumSerializer;

  const ScheduleInputTimeZoneEnum._(String name): super(name);

  static BuiltSet<ScheduleInputTimeZoneEnum> get values => _$scheduleInputTimeZoneEnumValues;
  static ScheduleInputTimeZoneEnum valueOf(String name) => _$scheduleInputTimeZoneEnumValueOf(name);
}

