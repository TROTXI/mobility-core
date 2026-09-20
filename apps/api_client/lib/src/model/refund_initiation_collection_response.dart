//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/refund_initiation_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refund_initiation_collection_response.g.dart';

/// RefundInitiationCollectionResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class RefundInitiationCollectionResponse implements Built<RefundInitiationCollectionResponse, RefundInitiationCollectionResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RefundInitiationCollection get data;

  RefundInitiationCollectionResponse._();

  factory RefundInitiationCollectionResponse([void updates(RefundInitiationCollectionResponseBuilder b)]) = _$RefundInitiationCollectionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefundInitiationCollectionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefundInitiationCollectionResponse> get serializer => _$RefundInitiationCollectionResponseSerializer();
}

class _$RefundInitiationCollectionResponseSerializer implements PrimitiveSerializer<RefundInitiationCollectionResponse> {
  @override
  final Iterable<Type> types = const [RefundInitiationCollectionResponse, _$RefundInitiationCollectionResponse];

  @override
  final String wireName = r'RefundInitiationCollectionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefundInitiationCollectionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RefundInitiationCollection),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RefundInitiationCollectionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RefundInitiationCollectionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RefundInitiationCollection),
          ) as RefundInitiationCollection;
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
  RefundInitiationCollectionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefundInitiationCollectionResponseBuilder();
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

