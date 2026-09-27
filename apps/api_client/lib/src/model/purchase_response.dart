//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/purchase.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_response.g.dart';

/// PurchaseResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PurchaseResponse implements Built<PurchaseResponse, PurchaseResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Purchase get data;

  PurchaseResponse._();

  factory PurchaseResponse([void updates(PurchaseResponseBuilder b)]) = _$PurchaseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PurchaseResponse> get serializer => _$PurchaseResponseSerializer();
}

class _$PurchaseResponseSerializer implements PrimitiveSerializer<PurchaseResponse> {
  @override
  final Iterable<Type> types = const [PurchaseResponse, _$PurchaseResponse];

  @override
  final String wireName = r'PurchaseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Purchase),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PurchaseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Purchase),
          ) as Purchase;
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
  PurchaseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseResponseBuilder();
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

