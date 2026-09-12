//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_plan_pricing_get200_response_plans_inner.g.dart';

/// AdminPlanPricingGet200ResponsePlansInner
///
/// Properties:
/// * [plan] 
/// * [ridesPerPeriod] 
/// * [priceMultiplierBp] 
/// * [takeRateBp] 
/// * [creditPesewasPerRide] 
@BuiltValue()
abstract class AdminPlanPricingGet200ResponsePlansInner implements Built<AdminPlanPricingGet200ResponsePlansInner, AdminPlanPricingGet200ResponsePlansInnerBuilder> {
  @BuiltValueField(wireName: r'plan')
  AdminPlanPricingGet200ResponsePlansInnerPlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  @BuiltValueField(wireName: r'ridesPerPeriod')
  int get ridesPerPeriod;

  @BuiltValueField(wireName: r'priceMultiplierBp')
  int get priceMultiplierBp;

  @BuiltValueField(wireName: r'takeRateBp')
  int get takeRateBp;

  @BuiltValueField(wireName: r'creditPesewasPerRide')
  int get creditPesewasPerRide;

  AdminPlanPricingGet200ResponsePlansInner._();

  factory AdminPlanPricingGet200ResponsePlansInner([void updates(AdminPlanPricingGet200ResponsePlansInnerBuilder b)]) = _$AdminPlanPricingGet200ResponsePlansInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminPlanPricingGet200ResponsePlansInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminPlanPricingGet200ResponsePlansInner> get serializer => _$AdminPlanPricingGet200ResponsePlansInnerSerializer();
}

class _$AdminPlanPricingGet200ResponsePlansInnerSerializer implements PrimitiveSerializer<AdminPlanPricingGet200ResponsePlansInner> {
  @override
  final Iterable<Type> types = const [AdminPlanPricingGet200ResponsePlansInner, _$AdminPlanPricingGet200ResponsePlansInner];

  @override
  final String wireName = r'AdminPlanPricingGet200ResponsePlansInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminPlanPricingGet200ResponsePlansInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(AdminPlanPricingGet200ResponsePlansInnerPlanEnum),
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
    yield r'creditPesewasPerRide';
    yield serializers.serialize(
      object.creditPesewasPerRide,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminPlanPricingGet200ResponsePlansInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminPlanPricingGet200ResponsePlansInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminPlanPricingGet200ResponsePlansInnerPlanEnum),
          ) as AdminPlanPricingGet200ResponsePlansInnerPlanEnum;
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
        case r'creditPesewasPerRide':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.creditPesewasPerRide = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminPlanPricingGet200ResponsePlansInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminPlanPricingGet200ResponsePlansInnerBuilder();
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

class AdminPlanPricingGet200ResponsePlansInnerPlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const AdminPlanPricingGet200ResponsePlansInnerPlanEnum monthly = _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const AdminPlanPricingGet200ResponsePlansInnerPlanEnum annual = _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_annual;

  static Serializer<AdminPlanPricingGet200ResponsePlansInnerPlanEnum> get serializer => _$adminPlanPricingGet200ResponsePlansInnerPlanEnumSerializer;

  const AdminPlanPricingGet200ResponsePlansInnerPlanEnum._(String name): super(name);

  static BuiltSet<AdminPlanPricingGet200ResponsePlansInnerPlanEnum> get values => _$adminPlanPricingGet200ResponsePlansInnerPlanEnumValues;
  static AdminPlanPricingGet200ResponsePlansInnerPlanEnum valueOf(String name) => _$adminPlanPricingGet200ResponsePlansInnerPlanEnumValueOf(name);
}

