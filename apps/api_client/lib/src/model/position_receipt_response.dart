//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/position_receipt.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'position_receipt_response.g.dart';

/// PositionReceiptResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class PositionReceiptResponse implements Built<PositionReceiptResponse, PositionReceiptResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PositionReceipt get data;

  PositionReceiptResponse._();

  factory PositionReceiptResponse([void updates(PositionReceiptResponseBuilder b)]) = _$PositionReceiptResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PositionReceiptResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PositionReceiptResponse> get serializer => _$PositionReceiptResponseSerializer();
}

class _$PositionReceiptResponseSerializer implements PrimitiveSerializer<PositionReceiptResponse> {
  @override
  final Iterable<Type> types = const [PositionReceiptResponse, _$PositionReceiptResponse];

  @override
  final String wireName = r'PositionReceiptResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PositionReceiptResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PositionReceipt),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PositionReceiptResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PositionReceiptResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PositionReceipt),
          ) as PositionReceipt;
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
  PositionReceiptResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PositionReceiptResponseBuilder();
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

