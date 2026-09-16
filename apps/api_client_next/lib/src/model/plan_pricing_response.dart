//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/plan_pricing.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plan_pricing_response.g.dart';

/// PlanPricingResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PlanPricingResponse implements Built<PlanPricingResponse, PlanPricingResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PlanPricing get data;

  PlanPricingResponse._();

  factory PlanPricingResponse([void updates(PlanPricingResponseBuilder b)]) = _$PlanPricingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlanPricingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlanPricingResponse> get serializer => _$PlanPricingResponseSerializer();
}

class _$PlanPricingResponseSerializer implements PrimitiveSerializer<PlanPricingResponse> {
  @override
  final Iterable<Type> types = const [PlanPricingResponse, _$PlanPricingResponse];

  @override
  final String wireName = r'PlanPricingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlanPricingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PlanPricing),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlanPricingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlanPricingResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PlanPricing),
          ) as PlanPricing;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlanPricingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlanPricingResponseBuilder();
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

