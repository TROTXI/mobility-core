//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payments_subscribe_post_request.g.dart';

/// PaymentsSubscribePostRequest
///
/// Properties:
/// * [plan] 
@BuiltValue()
abstract class PaymentsSubscribePostRequest implements Built<PaymentsSubscribePostRequest, PaymentsSubscribePostRequestBuilder> {
  @BuiltValueField(wireName: r'plan')
  PaymentsSubscribePostRequestPlanEnum get plan;
  // enum planEnum {  monthly,  annual,  };

  PaymentsSubscribePostRequest._();

  factory PaymentsSubscribePostRequest([void updates(PaymentsSubscribePostRequestBuilder b)]) = _$PaymentsSubscribePostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentsSubscribePostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentsSubscribePostRequest> get serializer => _$PaymentsSubscribePostRequestSerializer();
}

class _$PaymentsSubscribePostRequestSerializer implements PrimitiveSerializer<PaymentsSubscribePostRequest> {
  @override
  final Iterable<Type> types = const [PaymentsSubscribePostRequest, _$PaymentsSubscribePostRequest];

  @override
  final String wireName = r'PaymentsSubscribePostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentsSubscribePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(PaymentsSubscribePostRequestPlanEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentsSubscribePostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentsSubscribePostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentsSubscribePostRequestPlanEnum),
          ) as PaymentsSubscribePostRequestPlanEnum;
          result.plan = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentsSubscribePostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentsSubscribePostRequestBuilder();
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

class PaymentsSubscribePostRequestPlanEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'monthly')
  static const PaymentsSubscribePostRequestPlanEnum monthly = _$paymentsSubscribePostRequestPlanEnum_monthly;
  @BuiltValueEnumConst(wireName: r'annual')
  static const PaymentsSubscribePostRequestPlanEnum annual = _$paymentsSubscribePostRequestPlanEnum_annual;

  static Serializer<PaymentsSubscribePostRequestPlanEnum> get serializer => _$paymentsSubscribePostRequestPlanEnumSerializer;

  const PaymentsSubscribePostRequestPlanEnum._(String name): super(name);

  static BuiltSet<PaymentsSubscribePostRequestPlanEnum> get values => _$paymentsSubscribePostRequestPlanEnumValues;
  static PaymentsSubscribePostRequestPlanEnum valueOf(String name) => _$paymentsSubscribePostRequestPlanEnumValueOf(name);
}

