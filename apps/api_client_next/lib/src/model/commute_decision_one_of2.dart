//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_decision_one_of2.g.dart';

/// CommuteDecisionOneOf2
///
/// Properties:
/// * [action] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecisionOneOf2 implements Built<CommuteDecisionOneOf2, CommuteDecisionOneOf2Builder> {
  @BuiltValueField(wireName: r'action')
  CommuteDecisionOneOf2ActionEnum get action;
  // enum actionEnum {  pause,  };

  @BuiltValueField(wireName: r'note')
  String get note;

  CommuteDecisionOneOf2._();

  factory CommuteDecisionOneOf2([void updates(CommuteDecisionOneOf2Builder b)]) = _$CommuteDecisionOneOf2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionOneOf2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecisionOneOf2> get serializer => _$CommuteDecisionOneOf2Serializer();
}

class _$CommuteDecisionOneOf2Serializer implements PrimitiveSerializer<CommuteDecisionOneOf2> {
  @override
  final Iterable<Type> types = const [CommuteDecisionOneOf2, _$CommuteDecisionOneOf2];

  @override
  final String wireName = r'CommuteDecisionOneOf2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecisionOneOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CommuteDecisionOneOf2ActionEnum),
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
    CommuteDecisionOneOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteDecisionOneOf2Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteDecisionOneOf2ActionEnum),
          ) as CommuteDecisionOneOf2ActionEnum;
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
  CommuteDecisionOneOf2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionOneOf2Builder();
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

class CommuteDecisionOneOf2ActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pause')
  static const CommuteDecisionOneOf2ActionEnum pause = _$commuteDecisionOneOf2ActionEnum_pause;

  static Serializer<CommuteDecisionOneOf2ActionEnum> get serializer => _$commuteDecisionOneOf2ActionEnumSerializer;

  const CommuteDecisionOneOf2ActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionOneOf2ActionEnum> get values => _$commuteDecisionOneOf2ActionEnumValues;
  static CommuteDecisionOneOf2ActionEnum valueOf(String name) => _$commuteDecisionOneOf2ActionEnumValueOf(name);
}

