//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'schedule_input_departure_one_of.g.dart';

/// ScheduleInputDepartureOneOf
///
/// Properties:
/// * [kind] 
@BuiltValue()
abstract class ScheduleInputDepartureOneOf implements Built<ScheduleInputDepartureOneOf, ScheduleInputDepartureOneOfBuilder> {
  @BuiltValueField(wireName: r'kind')
  ScheduleInputDepartureOneOfKindEnum get kind;
  // enum kindEnum {  new,  };

  ScheduleInputDepartureOneOf._();

  factory ScheduleInputDepartureOneOf([void updates(ScheduleInputDepartureOneOfBuilder b)]) = _$ScheduleInputDepartureOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ScheduleInputDepartureOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ScheduleInputDepartureOneOf> get serializer => _$ScheduleInputDepartureOneOfSerializer();
}

class _$ScheduleInputDepartureOneOfSerializer implements PrimitiveSerializer<ScheduleInputDepartureOneOf> {
  @override
  final Iterable<Type> types = const [ScheduleInputDepartureOneOf, _$ScheduleInputDepartureOneOf];

  @override
  final String wireName = r'ScheduleInputDepartureOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ScheduleInputDepartureOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(ScheduleInputDepartureOneOfKindEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ScheduleInputDepartureOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ScheduleInputDepartureOneOfBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ScheduleInputDepartureOneOfKindEnum),
          ) as ScheduleInputDepartureOneOfKindEnum;
          result.kind = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ScheduleInputDepartureOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ScheduleInputDepartureOneOfBuilder();
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

class ScheduleInputDepartureOneOfKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'new')
  static const ScheduleInputDepartureOneOfKindEnum new_ = _$scheduleInputDepartureOneOfKindEnum_new_;

  static Serializer<ScheduleInputDepartureOneOfKindEnum> get serializer => _$scheduleInputDepartureOneOfKindEnumSerializer;

  const ScheduleInputDepartureOneOfKindEnum._(String name): super(name);

  static BuiltSet<ScheduleInputDepartureOneOfKindEnum> get values => _$scheduleInputDepartureOneOfKindEnumValues;
  static ScheduleInputDepartureOneOfKindEnum valueOf(String name) => _$scheduleInputDepartureOneOfKindEnumValueOf(name);
}

