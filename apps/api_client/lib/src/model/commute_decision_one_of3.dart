//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_decision_one_of3.g.dart';

/// CommuteDecisionOneOf3
///
/// Properties:
/// * [action] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecisionOneOf3 implements Built<CommuteDecisionOneOf3, CommuteDecisionOneOf3Builder> {
  @BuiltValueField(wireName: r'action')
  CommuteDecisionOneOf3ActionEnum get action;
  // enum actionEnum {  resume,  };

  @BuiltValueField(wireName: r'note')
  String get note;

  CommuteDecisionOneOf3._();

  factory CommuteDecisionOneOf3([void updates(CommuteDecisionOneOf3Builder b)]) = _$CommuteDecisionOneOf3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionOneOf3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecisionOneOf3> get serializer => _$CommuteDecisionOneOf3Serializer();
}

class _$CommuteDecisionOneOf3Serializer implements PrimitiveSerializer<CommuteDecisionOneOf3> {
  @override
  final Iterable<Type> types = const [CommuteDecisionOneOf3, _$CommuteDecisionOneOf3];

  @override
  final String wireName = r'CommuteDecisionOneOf3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecisionOneOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CommuteDecisionOneOf3ActionEnum),
    );
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteDecisionOneOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteDecisionOneOf3Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteDecisionOneOf3ActionEnum),
          ) as CommuteDecisionOneOf3ActionEnum;
          result.action = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommuteDecisionOneOf3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionOneOf3Builder();
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

class CommuteDecisionOneOf3ActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'resume')
  static const CommuteDecisionOneOf3ActionEnum resume = _$commuteDecisionOneOf3ActionEnum_resume;

  static Serializer<CommuteDecisionOneOf3ActionEnum> get serializer => _$commuteDecisionOneOf3ActionEnumSerializer;

  const CommuteDecisionOneOf3ActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionOneOf3ActionEnum> get values => _$commuteDecisionOneOf3ActionEnumValues;
  static CommuteDecisionOneOf3ActionEnum valueOf(String name) => _$commuteDecisionOneOf3ActionEnumValueOf(name);
}

