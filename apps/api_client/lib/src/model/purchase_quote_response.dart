//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/purchase_quote.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'purchase_quote_response.g.dart';

/// PurchaseQuoteResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class PurchaseQuoteResponse implements Built<PurchaseQuoteResponse, PurchaseQuoteResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class PurchaseQuoteResponse
    implements Built<PurchaseQuoteResponse, PurchaseQuoteResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  PurchaseQuote get data;

  PurchaseQuoteResponse._();

<<<<<<< HEAD
  factory PurchaseQuoteResponse([void updates(PurchaseQuoteResponseBuilder b)]) = _$PurchaseQuoteResponse;
=======
  factory PurchaseQuoteResponse(
      [void updates(PurchaseQuoteResponseBuilder b)]) = _$PurchaseQuoteResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PurchaseQuoteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<PurchaseQuoteResponse> get serializer => _$PurchaseQuoteResponseSerializer();
}

class _$PurchaseQuoteResponseSerializer implements PrimitiveSerializer<PurchaseQuoteResponse> {
  @override
  final Iterable<Type> types = const [PurchaseQuoteResponse, _$PurchaseQuoteResponse];
=======
  static Serializer<PurchaseQuoteResponse> get serializer =>
      _$PurchaseQuoteResponseSerializer();
}

class _$PurchaseQuoteResponseSerializer
    implements PrimitiveSerializer<PurchaseQuoteResponse> {
  @override
  final Iterable<Type> types = const [
    PurchaseQuoteResponse,
    _$PurchaseQuoteResponse
  ];
>>>>>>> origin/main

  @override
  final String wireName = r'PurchaseQuoteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PurchaseQuoteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PurchaseQuote),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PurchaseQuoteResponse object, {
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
    required PurchaseQuoteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PurchaseQuote),
          ) as PurchaseQuote;
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
  PurchaseQuoteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PurchaseQuoteResponseBuilder();
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
