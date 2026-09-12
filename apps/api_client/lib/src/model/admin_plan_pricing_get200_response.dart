//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/admin_plan_pricing_get200_response_plans_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_plan_pricing_get200_response.g.dart';

/// AdminPlanPricingGet200Response
///
/// Properties:
/// * [plans] 
@BuiltValue()
abstract class AdminPlanPricingGet200Response implements Built<AdminPlanPricingGet200Response, AdminPlanPricingGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'plans')
  BuiltList<AdminPlanPricingGet200ResponsePlansInner> get plans;

  AdminPlanPricingGet200Response._();

  factory AdminPlanPricingGet200Response([void updates(AdminPlanPricingGet200ResponseBuilder b)]) = _$AdminPlanPricingGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminPlanPricingGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminPlanPricingGet200Response> get serializer => _$AdminPlanPricingGet200ResponseSerializer();
}

class _$AdminPlanPricingGet200ResponseSerializer implements PrimitiveSerializer<AdminPlanPricingGet200Response> {
  @override
  final Iterable<Type> types = const [AdminPlanPricingGet200Response, _$AdminPlanPricingGet200Response];

  @override
  final String wireName = r'AdminPlanPricingGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminPlanPricingGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plans';
    yield serializers.serialize(
      object.plans,
      specifiedType: const FullType(BuiltList, [FullType(AdminPlanPricingGet200ResponsePlansInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminPlanPricingGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminPlanPricingGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plans':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminPlanPricingGet200ResponsePlansInner)]),
          ) as BuiltList<AdminPlanPricingGet200ResponsePlansInner>;
          result.plans.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminPlanPricingGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminPlanPricingGet200ResponseBuilder();
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

