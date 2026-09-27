//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/plan_pricing.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plan_pricing_page.g.dart';

/// PlanPricingPage
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class PlanPricingPage implements Built<PlanPricingPage, PlanPricingPageBuilder> {
=======
/// * [data]
/// * [page]
@BuiltValue()
abstract class PlanPricingPage
    implements Built<PlanPricingPage, PlanPricingPageBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  BuiltList<PlanPricing> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  PlanPricingPage._();

<<<<<<< HEAD
  factory PlanPricingPage([void updates(PlanPricingPageBuilder b)]) = _$PlanPricingPage;
=======
  factory PlanPricingPage([void updates(PlanPricingPageBuilder b)]) =
      _$PlanPricingPage;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlanPricingPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<PlanPricingPage> get serializer => _$PlanPricingPageSerializer();
}

class _$PlanPricingPageSerializer implements PrimitiveSerializer<PlanPricingPage> {
=======
  static Serializer<PlanPricingPage> get serializer =>
      _$PlanPricingPageSerializer();
}

class _$PlanPricingPageSerializer
    implements PrimitiveSerializer<PlanPricingPage> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [PlanPricingPage, _$PlanPricingPage];

  @override
  final String wireName = r'PlanPricingPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlanPricingPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(PlanPricing)]),
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
    PlanPricingPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlanPricingPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PlanPricing)]),
          ) as BuiltList<PlanPricing>;
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
  PlanPricingPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlanPricingPageBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
