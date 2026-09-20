//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/refund_initiation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'refund_initiation_response.g.dart';

/// RefundInitiationResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class RefundInitiationResponse implements Built<RefundInitiationResponse, RefundInitiationResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RefundInitiation get data;

  RefundInitiationResponse._();

  factory RefundInitiationResponse([void updates(RefundInitiationResponseBuilder b)]) = _$RefundInitiationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RefundInitiationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RefundInitiationResponse> get serializer => _$RefundInitiationResponseSerializer();
}

class _$RefundInitiationResponseSerializer implements PrimitiveSerializer<RefundInitiationResponse> {
  @override
  final Iterable<Type> types = const [RefundInitiationResponse, _$RefundInitiationResponse];

  @override
  final String wireName = r'RefundInitiationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RefundInitiationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RefundInitiation),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RefundInitiationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RefundInitiationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RefundInitiation),
          ) as RefundInitiation;
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
  RefundInitiationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RefundInitiationResponseBuilder();
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

