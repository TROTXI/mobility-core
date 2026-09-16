//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plan_pricing.g.dart';

/// PlanPricing
///
/// Properties:
/// * [plan] 
/// * [ridesPerPeriod] 
/// * [priceMultiplierBp] 
/// * [takeRateBp] 
/// * [creditPerRide] 
/// * [version] 
@BuiltValue()
abstract class PlanPricing implements Built<PlanPricing, PlanPricingBuilder> {
  @BuiltValueField(wireName: r'plan')
  PlanPricingPlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'ridesPerPeriod')
  int get ridesPerPeriod;

  @BuiltValueField(wireName: r'priceMultiplierBp')
  int get priceMultiplierBp;

  @BuiltValueField(wireName: r'takeRateBp')
  int get takeRateBp;

  @BuiltValueField(wireName: r'creditPerRide')
  Money get creditPerRide;

  @BuiltValueField(wireName: r'version')
  int get version;

  PlanPricing._();

  factory PlanPricing([void updates(PlanPricingBuilder b)]) = _$PlanPricing;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlanPricingBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlanPricing> get serializer => _$PlanPricingSerializer();
}

class _$PlanPricingSerializer implements PrimitiveSerializer<PlanPricing> {
  @override
  final Iterable<Type> types = const [PlanPricing, _$PlanPricing];

  @override
  final String wireName = r'PlanPricing';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlanPricing object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(PlanPricingPlanEnum),
    );
    yield r'ridesPerPeriod';
    yield serializers.serialize(
      object.ridesPerPeriod,
      specifiedType: const FullType(int),
    );
    yield r'priceMultiplierBp';
    yield serializers.serialize(
      object.priceMultiplierBp,
      specifiedType: const FullType(int),
    );
    yield r'takeRateBp';
    yield serializers.serialize(
      object.takeRateBp,
      specifiedType: const FullType(int),
    );
    yield r'creditPerRide';
    yield serializers.serialize(
      object.creditPerRide,
      specifiedType: const FullType(Money),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlanPricing object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlanPricingBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlanPricingPlanEnum),
          ) as PlanPricingPlanEnum;
          result.plan = valueDes;
          break;
        case r'ridesPerPeriod':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ridesPerPeriod = valueDes;
          break;
        case r'priceMultiplierBp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceMultiplierBp = valueDes;
          break;
        case r'takeRateBp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.takeRateBp = valueDes;
          break;
        case r'creditPerRide':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.creditPerRide.replace(valueDes);
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlanPricing deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlanPricingBuilder();
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

class PlanPricingPlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const PlanPricingPlanEnum monthly = _$planPricingPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const PlanPricingPlanEnum annual = _$planPricingPlanEnum_annual;

  static Serializer<PlanPricingPlanEnum> get serializer => _$planPricingPlanEnumSerializer;

  const PlanPricingPlanEnum._(String name): super(name);

  static BuiltSet<PlanPricingPlanEnum> get values => _$planPricingPlanEnumValues;
  static PlanPricingPlanEnum valueOf(String name) => _$planPricingPlanEnumValueOf(name);
}

