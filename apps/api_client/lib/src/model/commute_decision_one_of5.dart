//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_decision_one_of5.g.dart';

/// CommuteDecisionOneOf5
///
/// Properties:
/// * [action] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecisionOneOf5 implements Built<CommuteDecisionOneOf5, CommuteDecisionOneOf5Builder> {
  @BuiltValueField(wireName: r'action')
  CommuteDecisionOneOf5ActionEnum get action;
  // enum actionEnum {  cancel,  };

  @BuiltValueField(wireName: r'note')
  String get note;

  CommuteDecisionOneOf5._();

  factory CommuteDecisionOneOf5([void updates(CommuteDecisionOneOf5Builder b)]) = _$CommuteDecisionOneOf5;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionOneOf5Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecisionOneOf5> get serializer => _$CommuteDecisionOneOf5Serializer();
}

class _$CommuteDecisionOneOf5Serializer implements PrimitiveSerializer<CommuteDecisionOneOf5> {
  @override
  final Iterable<Type> types = const [CommuteDecisionOneOf5, _$CommuteDecisionOneOf5];

  @override
  final String wireName = r'CommuteDecisionOneOf5';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecisionOneOf5 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CommuteDecisionOneOf5ActionEnum),
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
    CommuteDecisionOneOf5 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteDecisionOneOf5Builder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteDecisionOneOf5ActionEnum),
          ) as CommuteDecisionOneOf5ActionEnum;
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
  CommuteDecisionOneOf5 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionOneOf5Builder();
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

class CommuteDecisionOneOf5ActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'cancel')
  static const CommuteDecisionOneOf5ActionEnum cancel = _$commuteDecisionOneOf5ActionEnum_cancel;

  static Serializer<CommuteDecisionOneOf5ActionEnum> get serializer => _$commuteDecisionOneOf5ActionEnumSerializer;

  const CommuteDecisionOneOf5ActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionOneOf5ActionEnum> get values => _$commuteDecisionOneOf5ActionEnumValues;
  static CommuteDecisionOneOf5ActionEnum valueOf(String name) => _$commuteDecisionOneOf5ActionEnumValueOf(name);
}

