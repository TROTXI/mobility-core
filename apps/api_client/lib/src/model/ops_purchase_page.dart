//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/ops_purchase.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase_page.g.dart';

/// OpsPurchasePage
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class OpsPurchasePage implements Built<OpsPurchasePage, OpsPurchasePageBuilder> {
=======
/// * [data]
/// * [page]
@BuiltValue()
abstract class OpsPurchasePage
    implements Built<OpsPurchasePage, OpsPurchasePageBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  BuiltList<OpsPurchase> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  OpsPurchasePage._();

<<<<<<< HEAD
  factory OpsPurchasePage([void updates(OpsPurchasePageBuilder b)]) = _$OpsPurchasePage;
=======
  factory OpsPurchasePage([void updates(OpsPurchasePageBuilder b)]) =
      _$OpsPurchasePage;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchasePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<OpsPurchasePage> get serializer => _$OpsPurchasePageSerializer();
}

class _$OpsPurchasePageSerializer implements PrimitiveSerializer<OpsPurchasePage> {
=======
  static Serializer<OpsPurchasePage> get serializer =>
      _$OpsPurchasePageSerializer();
}

class _$OpsPurchasePageSerializer
    implements PrimitiveSerializer<OpsPurchasePage> {
>>>>>>> origin/main
  @override
  final Iterable<Type> types = const [OpsPurchasePage, _$OpsPurchasePage];

  @override
  final String wireName = r'OpsPurchasePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchasePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OpsPurchase)]),
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
    OpsPurchasePage object, {
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
    required OpsPurchasePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OpsPurchase)]),
          ) as BuiltList<OpsPurchase>;
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
  OpsPurchasePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchasePageBuilder();
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
