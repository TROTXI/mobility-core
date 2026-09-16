//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commute_decision_one_of.g.dart';

/// CommuteDecisionOneOf
///
/// Properties:
/// * [action] 
/// * [slotId] 
/// * [effectiveDate] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecisionOneOf implements Built<CommuteDecisionOneOf, CommuteDecisionOneOfBuilder> {
  @BuiltValueField(wireName: r'action')
  CommuteDecisionOneOfActionEnum get action;
  // enum actionEnum {  approve,  };

  @BuiltValueField(wireName: r'slotId')
  String get slotId;

  @BuiltValueField(wireName: r'effectiveDate')
  Date get effectiveDate;

  @BuiltValueField(wireName: r'note')
  String get note;

  CommuteDecisionOneOf._();

  factory CommuteDecisionOneOf([void updates(CommuteDecisionOneOfBuilder b)]) = _$CommuteDecisionOneOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionOneOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecisionOneOf> get serializer => _$CommuteDecisionOneOfSerializer();
}

class _$CommuteDecisionOneOfSerializer implements PrimitiveSerializer<CommuteDecisionOneOf> {
  @override
  final Iterable<Type> types = const [CommuteDecisionOneOf, _$CommuteDecisionOneOf];

  @override
  final String wireName = r'CommuteDecisionOneOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecisionOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CommuteDecisionOneOfActionEnum),
    );
    yield r'slotId';
    yield serializers.serialize(
      object.slotId,
      specifiedType: const FullType(String),
    );
    yield r'effectiveDate';
    yield serializers.serialize(
      object.effectiveDate,
      specifiedType: const FullType(Date),
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
    CommuteDecisionOneOf object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommuteDecisionOneOfBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteDecisionOneOfActionEnum),
          ) as CommuteDecisionOneOfActionEnum;
          result.action = valueDes;
          break;
        case r'slotId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.slotId = valueDes;
          break;
        case r'effectiveDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.effectiveDate = valueDes;
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
  CommuteDecisionOneOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionOneOfBuilder();
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

class CommuteDecisionOneOfActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'approve')
  static const CommuteDecisionOneOfActionEnum approve = _$commuteDecisionOneOfActionEnum_approve;

  static Serializer<CommuteDecisionOneOfActionEnum> get serializer => _$commuteDecisionOneOfActionEnumSerializer;

  const CommuteDecisionOneOfActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionOneOfActionEnum> get values => _$commuteDecisionOneOfActionEnumValues;
  static CommuteDecisionOneOfActionEnum valueOf(String name) => _$commuteDecisionOneOfActionEnumValueOf(name);
}

