//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_decision_one_of6.g.dart';

/// CommuteDecisionOneOf6
///
/// Properties:
/// * [action] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecisionOneOf6 implements Built<CommuteDecisionOneOf6, CommuteDecisionOneOf6Builder> {
  @BuiltValueField(wireName: r'action')
  CommuteDecisionOneOf6ActionEnum get action;
  // enum actionEnum {  reject,  };

  @BuiltValueField(wireName: r'note')
  String get note;

  CommuteDecisionOneOf6._();

  factory CommuteDecisionOneOf6([void updates(CommuteDecisionOneOf6Builder b)]) = _$CommuteDecisionOneOf6;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionOneOf6Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecisionOneOf6> get serializer => _$CommuteDecisionOneOf6Serializer();
}

class _$CommuteDecisionOneOf6Serializer implements PrimitiveSerializer<CommuteDecisionOneOf6> {
  @override
  final Iterable<Type> types = const [CommuteDecisionOneOf6, _$CommuteDecisionOneOf6];

  @override
  final String wireName = r'CommuteDecisionOneOf6';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecisionOneOf6 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CommuteDecisionOneOf6ActionEnum),
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
    CommuteDecisionOneOf6 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteDecisionOneOf6Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteDecisionOneOf6ActionEnum),
          ) as CommuteDecisionOneOf6ActionEnum;
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
  CommuteDecisionOneOf6 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionOneOf6Builder();
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

class CommuteDecisionOneOf6ActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'reject')
  static const CommuteDecisionOneOf6ActionEnum reject = _$commuteDecisionOneOf6ActionEnum_reject;

  static Serializer<CommuteDecisionOneOf6ActionEnum> get serializer => _$commuteDecisionOneOf6ActionEnumSerializer;

  const CommuteDecisionOneOf6ActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionOneOf6ActionEnum> get values => _$commuteDecisionOneOf6ActionEnumValues;
  static CommuteDecisionOneOf6ActionEnum valueOf(String name) => _$commuteDecisionOneOf6ActionEnumValueOf(name);
}

