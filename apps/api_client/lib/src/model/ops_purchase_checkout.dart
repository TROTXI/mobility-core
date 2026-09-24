//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase_checkout.g.dart';

/// OpsPurchaseCheckout
///
/// Properties:
/// * [url] 
/// * [expiresAt] 
@BuiltValue()
abstract class OpsPurchaseCheckout implements Built<OpsPurchaseCheckout, OpsPurchaseCheckoutBuilder> {
  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  OpsPurchaseCheckout._();

  factory OpsPurchaseCheckout([void updates(OpsPurchaseCheckoutBuilder b)]) = _$OpsPurchaseCheckout;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchaseCheckoutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsPurchaseCheckout> get serializer => _$OpsPurchaseCheckoutSerializer();
}

class _$OpsPurchaseCheckoutSerializer implements PrimitiveSerializer<OpsPurchaseCheckout> {
  @override
  final Iterable<Type> types = const [OpsPurchaseCheckout, _$OpsPurchaseCheckout];

  @override
  final String wireName = r'OpsPurchaseCheckout';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchaseCheckout object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield object.expiresAt == null ? null : serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType.nullable(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsPurchaseCheckout object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsPurchaseCheckoutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OpsPurchaseCheckout deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchaseCheckoutBuilder();
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

