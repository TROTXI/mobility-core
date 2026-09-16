//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/payment_review.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_review_response.g.dart';

/// PaymentReviewResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PaymentReviewResponse implements Built<PaymentReviewResponse, PaymentReviewResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PaymentReview get data;

  PaymentReviewResponse._();

  factory PaymentReviewResponse([void updates(PaymentReviewResponseBuilder b)]) = _$PaymentReviewResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentReviewResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentReviewResponse> get serializer => _$PaymentReviewResponseSerializer();
}

class _$PaymentReviewResponseSerializer implements PrimitiveSerializer<PaymentReviewResponse> {
  @override
  final Iterable<Type> types = const [PaymentReviewResponse, _$PaymentReviewResponse];

  @override
  final String wireName = r'PaymentReviewResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentReviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PaymentReview),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentReviewResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentReviewResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentReview),
          ) as PaymentReview;
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
  PaymentReviewResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentReviewResponseBuilder();
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

