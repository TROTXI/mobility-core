//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'work_decision.g.dart';

/// WorkDecision
///
/// Properties:
/// * [status] 
/// * [decisionNote] 
@BuiltValue()
abstract class WorkDecision implements Built<WorkDecision, WorkDecisionBuilder> {
  @BuiltValueField(wireName: r'status')
  WorkDecisionStatusEnum get status;
  // enum statusEnum {  approved,  declined,  };

  @BuiltValueField(wireName: r'decisionNote')
  String get decisionNote;

  WorkDecision._();

  factory WorkDecision([void updates(WorkDecisionBuilder b)]) = _$WorkDecision;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkDecisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkDecision> get serializer => _$WorkDecisionSerializer();
}

class _$WorkDecisionSerializer implements PrimitiveSerializer<WorkDecision> {
  @override
  final Iterable<Type> types = const [WorkDecision, _$WorkDecision];

  @override
  final String wireName = r'WorkDecision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(WorkDecisionStatusEnum),
    );
    yield r'decisionNote';
    yield serializers.serialize(
      object.decisionNote,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkDecisionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WorkDecisionStatusEnum),
          ) as WorkDecisionStatusEnum;
          result.status = valueDes;
          break;
        case r'decisionNote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.decisionNote = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkDecision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkDecisionBuilder();
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

class WorkDecisionStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'approved')
  static const WorkDecisionStatusEnum approved = _$workDecisionStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const WorkDecisionStatusEnum declined = _$workDecisionStatusEnum_declined;

  static Serializer<WorkDecisionStatusEnum> get serializer => _$workDecisionStatusEnumSerializer;

  const WorkDecisionStatusEnum._(String name): super(name);

  static BuiltSet<WorkDecisionStatusEnum> get values => _$workDecisionStatusEnumValues;
  static WorkDecisionStatusEnum valueOf(String name) => _$workDecisionStatusEnumValueOf(name);
}

