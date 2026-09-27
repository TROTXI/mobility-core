//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_decision_one_of4.g.dart';

/// CommuteDecisionOneOf4
///
/// Properties:
/// * [action] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecisionOneOf4 implements Built<CommuteDecisionOneOf4, CommuteDecisionOneOf4Builder> {
  @BuiltValueField(wireName: r'action')
  CommuteDecisionOneOf4ActionEnum get action;
  // enum actionEnum {  apply,  };

  @BuiltValueField(wireName: r'note')
  String get note;

  CommuteDecisionOneOf4._();

  factory CommuteDecisionOneOf4([void updates(CommuteDecisionOneOf4Builder b)]) = _$CommuteDecisionOneOf4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionOneOf4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecisionOneOf4> get serializer => _$CommuteDecisionOneOf4Serializer();
}

class _$CommuteDecisionOneOf4Serializer implements PrimitiveSerializer<CommuteDecisionOneOf4> {
  @override
  final Iterable<Type> types = const [CommuteDecisionOneOf4, _$CommuteDecisionOneOf4];

  @override
  final String wireName = r'CommuteDecisionOneOf4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecisionOneOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CommuteDecisionOneOf4ActionEnum),
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
    CommuteDecisionOneOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteDecisionOneOf4Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteDecisionOneOf4ActionEnum),
          ) as CommuteDecisionOneOf4ActionEnum;
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
  CommuteDecisionOneOf4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionOneOf4Builder();
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

class CommuteDecisionOneOf4ActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'apply')
  static const CommuteDecisionOneOf4ActionEnum apply = _$commuteDecisionOneOf4ActionEnum_apply;

  static Serializer<CommuteDecisionOneOf4ActionEnum> get serializer => _$commuteDecisionOneOf4ActionEnumSerializer;

  const CommuteDecisionOneOf4ActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionOneOf4ActionEnum> get values => _$commuteDecisionOneOf4ActionEnumValues;
  static CommuteDecisionOneOf4ActionEnum valueOf(String name) => _$commuteDecisionOneOf4ActionEnumValueOf(name);
}

