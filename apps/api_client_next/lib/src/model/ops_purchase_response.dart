//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/ops_purchase.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ops_purchase_response.g.dart';

/// OpsPurchaseResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OpsPurchaseResponse implements Built<OpsPurchaseResponse, OpsPurchaseResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OpsPurchase get data;

  OpsPurchaseResponse._();

  factory OpsPurchaseResponse([void updates(OpsPurchaseResponseBuilder b)]) = _$OpsPurchaseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OpsPurchaseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OpsPurchaseResponse> get serializer => _$OpsPurchaseResponseSerializer();
}

class _$OpsPurchaseResponseSerializer implements PrimitiveSerializer<OpsPurchaseResponse> {
  @override
  final Iterable<Type> types = const [OpsPurchaseResponse, _$OpsPurchaseResponse];

  @override
  final String wireName = r'OpsPurchaseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OpsPurchaseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OpsPurchase),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OpsPurchaseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OpsPurchaseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OpsPurchase),
          ) as OpsPurchase;
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
  OpsPurchaseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OpsPurchaseResponseBuilder();
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

