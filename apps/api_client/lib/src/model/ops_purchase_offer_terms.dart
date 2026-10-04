//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/money.dart';
import 'package:trotxi_api_client/src/model/subscription_offer_leg.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase_offer_terms.g.dart';

/// OpsPurchaseOfferTerms
///
/// Properties:
/// * [coverageStart]
/// * [coverageEnd]
/// * [price]
/// * [legs]
@BuiltValue()
abstract class OpsPurchaseOfferTerms
    implements Built<OpsPurchaseOfferTerms, OpsPurchaseOfferTermsBuilder> {
  @BuiltValueField(wireName: r'coverageStart')
  Date get coverageStart;

  @BuiltValueField(wireName: r'coverageEnd')
  Date get coverageEnd;

  @BuiltValueField(wireName: r'price')
  Money get price;

  @BuiltValueField(wireName: r'legs')
  BuiltList<SubscriptionOfferLeg> get legs;

  OpsPurchaseOfferTerms._();

  factory OpsPurchaseOfferTerms(
      [void updates(OpsPurchaseOfferTermsBuilder b)]) = _$OpsPurchaseOfferTerms;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchaseOfferTermsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsPurchaseOfferTerms> get serializer =>
      _$OpsPurchaseOfferTermsSerializer();
}

class _$OpsPurchaseOfferTermsSerializer
    implements PrimitiveSerializer<OpsPurchaseOfferTerms> {
  @override
  final Iterable<Type> types = const [
    OpsPurchaseOfferTerms,
    _$OpsPurchaseOfferTerms
  ];

  @override
  final String wireName = r'OpsPurchaseOfferTerms';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchaseOfferTerms object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'coverageStart';
    yield serializers.serialize(
      object.coverageStart,
      specifiedType: const FullType(Date),
    );
    yield r'coverageEnd';
    yield serializers.serialize(
      object.coverageEnd,
      specifiedType: const FullType(Date),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(Money),
    );
    yield r'legs';
    yield serializers.serialize(
      object.legs,
      specifiedType:
          const FullType(BuiltList, [FullType(SubscriptionOfferLeg)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsPurchaseOfferTerms object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsPurchaseOfferTermsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'coverageStart':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.coverageStart = valueDes;
          break;
        case r'coverageEnd':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.coverageEnd = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Money),
          ) as Money;
          result.price.replace(valueDes);
          break;
        case r'legs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(SubscriptionOfferLeg)]),
          ) as BuiltList<SubscriptionOfferLeg>;
          result.legs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsPurchaseOfferTerms deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchaseOfferTermsBuilder();
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
