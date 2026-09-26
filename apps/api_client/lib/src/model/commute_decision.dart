//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_decision_one_of1.dart';
import 'package:trotxi_api_client/src/model/commute_decision_one_of4.dart';
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:trotxi_api_client/src/model/commute_decision_one_of.dart';
import 'package:trotxi_api_client/src/model/commute_decision_one_of3.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/commute_decision_one_of6.dart';
import 'package:trotxi_api_client/src/model/commute_decision_one_of2.dart';
import 'package:trotxi_api_client/src/model/commute_decision_one_of5.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/one_of.dart';

part 'commute_decision.g.dart';

/// CommuteDecision
///
/// Properties:
/// * [action] 
/// * [slotId] 
/// * [effectiveDate] 
/// * [note] 
@BuiltValue()
abstract class CommuteDecision implements Built<CommuteDecision, CommuteDecisionBuilder> {
  /// One Of [CommuteDecisionOneOf], [CommuteDecisionOneOf1], [CommuteDecisionOneOf2], [CommuteDecisionOneOf3], [CommuteDecisionOneOf4], [CommuteDecisionOneOf5], [CommuteDecisionOneOf6]
  OneOf get oneOf;

  CommuteDecision._();

  factory CommuteDecision([void updates(CommuteDecisionBuilder b)]) = _$CommuteDecision;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommuteDecisionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommuteDecision> get serializer => _$CommuteDecisionSerializer();
}

class _$CommuteDecisionSerializer implements PrimitiveSerializer<CommuteDecision> {
  @override
  final Iterable<Type> types = const [CommuteDecision, _$CommuteDecision];

  @override
  final String wireName = r'CommuteDecision';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommuteDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    CommuteDecision object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final oneOf = object.oneOf;
    return serializers.serialize(oneOf.value, specifiedType: FullType(oneOf.valueType))!;
  }

  @override
  CommuteDecision deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommuteDecisionBuilder();
    Object? oneOfDataSrc;
    final targetType = const FullType(OneOf, [FullType(CommuteDecisionOneOf), FullType(CommuteDecisionOneOf1), FullType(CommuteDecisionOneOf2), FullType(CommuteDecisionOneOf3), FullType(CommuteDecisionOneOf4), FullType(CommuteDecisionOneOf5), FullType(CommuteDecisionOneOf6), ]);
    oneOfDataSrc = serialized;
    result.oneOf = serializers.deserialize(oneOfDataSrc, specifiedType: targetType) as OneOf;
    return result.build();
  }
}

class CommuteDecisionActionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'reject')
  static const CommuteDecisionActionEnum reject = _$commuteDecisionActionEnum_reject;

  static Serializer<CommuteDecisionActionEnum> get serializer => _$commuteDecisionActionEnumSerializer;

  const CommuteDecisionActionEnum._(String name): super(name);

  static BuiltSet<CommuteDecisionActionEnum> get values => _$commuteDecisionActionEnumValues;
  static CommuteDecisionActionEnum valueOf(String name) => _$commuteDecisionActionEnumValueOf(name);
}

