//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'review_decision.g.dart';

/// ReviewDecision
///
/// Properties:
/// * [decision] 
/// * [reason] 
@BuiltValue()
abstract class ReviewDecision implements Built<ReviewDecision, ReviewDecisionBuilder> {
  @BuiltValueField(wireName: r'decision')
  ReviewDecisionDecisionEnum get decision;
  // enum decisionEnum {  resolved,  waived,  };

  @BuiltValueField(wireName: r'reason')
  String get reason;

  ReviewDecision._();

  factory ReviewDecision([void updates(ReviewDecisionBuilder b)]) = _$ReviewDecision;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReviewDecisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReviewDecision> get serializer => _$ReviewDecisionSerializer();
}

class _$ReviewDecisionSerializer implements PrimitiveSerializer<ReviewDecision> {
  @override
  final Iterable<Type> types = const [ReviewDecision, _$ReviewDecision];

  @override
  final String wireName = r'ReviewDecision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReviewDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'decision';
    yield serializers.serialize(
      object.decision,
      specifiedType: const FullType(ReviewDecisionDecisionEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReviewDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReviewDecisionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'decision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ReviewDecisionDecisionEnum),
          ) as ReviewDecisionDecisionEnum;
          result.decision = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ReviewDecision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReviewDecisionBuilder();
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

class ReviewDecisionDecisionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'resolved')
  static const ReviewDecisionDecisionEnum resolved = _$reviewDecisionDecisionEnum_resolved;
  @BuiltValueEnumConst(wireName: r'waived')
  static const ReviewDecisionDecisionEnum waived = _$reviewDecisionDecisionEnum_waived;

  static Serializer<ReviewDecisionDecisionEnum> get serializer => _$reviewDecisionDecisionEnumSerializer;

  const ReviewDecisionDecisionEnum._(String name): super(name);

  static BuiltSet<ReviewDecisionDecisionEnum> get values => _$reviewDecisionDecisionEnumValues;
  static ReviewDecisionDecisionEnum valueOf(String name) => _$reviewDecisionDecisionEnumValueOf(name);
}

