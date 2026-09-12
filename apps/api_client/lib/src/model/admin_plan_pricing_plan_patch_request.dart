//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_plan_pricing_plan_patch_request.g.dart';

/// AdminPlanPricingPlanPatchRequest
///
/// Properties:
/// * [ridesPerPeriod] 
/// * [priceMultiplierBp] 
/// * [takeRateBp] 
/// * [creditPesewasPerRide] 
@BuiltValue()
abstract class AdminPlanPricingPlanPatchRequest implements Built<AdminPlanPricingPlanPatchRequest, AdminPlanPricingPlanPatchRequestBuilder> {
  @BuiltValueField(wireName: r'ridesPerPeriod')
  int? get ridesPerPeriod;

  @BuiltValueField(wireName: r'priceMultiplierBp')
  int? get priceMultiplierBp;

  @BuiltValueField(wireName: r'takeRateBp')
  int? get takeRateBp;

  @BuiltValueField(wireName: r'creditPesewasPerRide')
  int? get creditPesewasPerRide;

  AdminPlanPricingPlanPatchRequest._();

  factory AdminPlanPricingPlanPatchRequest([void updates(AdminPlanPricingPlanPatchRequestBuilder b)]) = _$AdminPlanPricingPlanPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminPlanPricingPlanPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminPlanPricingPlanPatchRequest> get serializer => _$AdminPlanPricingPlanPatchRequestSerializer();
}

class _$AdminPlanPricingPlanPatchRequestSerializer implements PrimitiveSerializer<AdminPlanPricingPlanPatchRequest> {
  @override
  final Iterable<Type> types = const [AdminPlanPricingPlanPatchRequest, _$AdminPlanPricingPlanPatchRequest];

  @override
  final String wireName = r'AdminPlanPricingPlanPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminPlanPricingPlanPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ridesPerPeriod != null) {
      yield r'ridesPerPeriod';
      yield serializers.serialize(
        object.ridesPerPeriod,
        specifiedType: const FullType(int),
      );
    }
    if (object.priceMultiplierBp != null) {
      yield r'priceMultiplierBp';
      yield serializers.serialize(
        object.priceMultiplierBp,
        specifiedType: const FullType(int),
      );
    }
    if (object.takeRateBp != null) {
      yield r'takeRateBp';
      yield serializers.serialize(
        object.takeRateBp,
        specifiedType: const FullType(int),
      );
    }
    if (object.creditPesewasPerRide != null) {
      yield r'creditPesewasPerRide';
      yield serializers.serialize(
        object.creditPesewasPerRide,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminPlanPricingPlanPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminPlanPricingPlanPatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  AdminPlanPricingPlanPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminPlanPricingPlanPatchRequestBuilder();
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

