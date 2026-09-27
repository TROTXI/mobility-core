//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_decision_one_of1.g.dart';

/// CommuteDecisionOneOf1
///
/// Properties:
/// * [action] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecisionOneOf1 implements Built<CommuteDecisionOneOf1, CommuteDecisionOneOf1Builder> {
  @BuiltValueField(wireName: r'action')
  CommuteDecisionOneOf1ActionEnum get action;
  // enum actionEnum {  waitlist,  };

  @BuiltValueField(wireName: r'note')
  String get note;

  CommuteDecisionOneOf1._();

  factory CommuteDecisionOneOf1([void updates(CommuteDecisionOneOf1Builder b)]) = _$CommuteDecisionOneOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionOneOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecisionOneOf1> get serializer => _$CommuteDecisionOneOf1Serializer();
}

class _$CommuteDecisionOneOf1Serializer implements PrimitiveSerializer<CommuteDecisionOneOf1> {
  @override
  final Iterable<Type> types = const [CommuteDecisionOneOf1, _$CommuteDecisionOneOf1];

  @override
  final String wireName = r'CommuteDecisionOneOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecisionOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CommuteDecisionOneOf1ActionEnum),
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
    CommuteDecisionOneOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteDecisionOneOf1Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteDecisionOneOf1ActionEnum),
          ) as CommuteDecisionOneOf1ActionEnum;
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
  CommuteDecisionOneOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionOneOf1Builder();
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

class CommuteDecisionOneOf1ActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'waitlist')
  static const CommuteDecisionOneOf1ActionEnum waitlist = _$commuteDecisionOneOf1ActionEnum_waitlist;

  static Serializer<CommuteDecisionOneOf1ActionEnum> get serializer => _$commuteDecisionOneOf1ActionEnumSerializer;

  const CommuteDecisionOneOf1ActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionOneOf1ActionEnum> get values => _$commuteDecisionOneOf1ActionEnumValues;
  static CommuteDecisionOneOf1ActionEnum valueOf(String name) => _$commuteDecisionOneOf1ActionEnumValueOf(name);
}

