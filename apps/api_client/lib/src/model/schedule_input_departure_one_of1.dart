//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'schedule_input_departure_one_of1.g.dart';

/// ScheduleInputDepartureOneOf1
///
/// Properties:
/// * [kind] 
/// * [departureId] 
@BuiltValue()
abstract class ScheduleInputDepartureOneOf1 implements Built<ScheduleInputDepartureOneOf1, ScheduleInputDepartureOneOf1Builder> {
  @BuiltValueField(wireName: r'kind')
  ScheduleInputDepartureOneOf1KindEnum get kind;
  // enum kindEnum {  existing,  };

  @BuiltValueField(wireName: r'departureId')
  String get departureId;

  ScheduleInputDepartureOneOf1._();

  factory ScheduleInputDepartureOneOf1([void updates(ScheduleInputDepartureOneOf1Builder b)]) = _$ScheduleInputDepartureOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScheduleInputDepartureOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScheduleInputDepartureOneOf1> get serializer => _$ScheduleInputDepartureOneOf1Serializer();
}

class _$ScheduleInputDepartureOneOf1Serializer implements PrimitiveSerializer<ScheduleInputDepartureOneOf1> {
  @override
  final Iterable<Type> types = const [ScheduleInputDepartureOneOf1, _$ScheduleInputDepartureOneOf1];

  @override
  final String wireName = r'ScheduleInputDepartureOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScheduleInputDepartureOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ScheduleInputDepartureOneOf1KindEnum),
    );
    yield r'departureId';
    yield serializers.serialize(
      object.departureId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScheduleInputDepartureOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScheduleInputDepartureOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ScheduleInputDepartureOneOf1KindEnum),
          ) as ScheduleInputDepartureOneOf1KindEnum;
          result.kind = valueDes;
          break;
        case r'departureId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.departureId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScheduleInputDepartureOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScheduleInputDepartureOneOf1Builder();
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

class ScheduleInputDepartureOneOf1KindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'existing')
  static const ScheduleInputDepartureOneOf1KindEnum existing = _$scheduleInputDepartureOneOf1KindEnum_existing;

  static Serializer<ScheduleInputDepartureOneOf1KindEnum> get serializer => _$scheduleInputDepartureOneOf1KindEnumSerializer;

  const ScheduleInputDepartureOneOf1KindEnum._(String name): super(name);

  static BuiltSet<ScheduleInputDepartureOneOf1KindEnum> get values => _$scheduleInputDepartureOneOf1KindEnumValues;
  static ScheduleInputDepartureOneOf1KindEnum valueOf(String name) => _$scheduleInputDepartureOneOf1KindEnumValueOf(name);
}

