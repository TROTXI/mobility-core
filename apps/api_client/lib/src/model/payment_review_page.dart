//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/payment_review.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_review_page.g.dart';

/// PaymentReviewPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class PaymentReviewPage implements Built<PaymentReviewPage, PaymentReviewPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<PaymentReview> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  PaymentReviewPage._();

  factory PaymentReviewPage([void updates(PaymentReviewPageBuilder b)]) = _$PaymentReviewPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentReviewPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentReviewPage> get serializer => _$PaymentReviewPageSerializer();
}

class _$PaymentReviewPageSerializer implements PrimitiveSerializer<PaymentReviewPage> {
  @override
  final Iterable<Type> types = const [PaymentReviewPage, _$PaymentReviewPage];

  @override
  final String wireName = r'PaymentReviewPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentReviewPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PaymentReview)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(CommuteRequestPagePage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentReviewPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentReviewPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PaymentReview)]),
          ) as BuiltList<PaymentReview>;
          result.data.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteRequestPagePage),
          ) as CommuteRequestPagePage;
          result.page.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentReviewPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentReviewPageBuilder();
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

