//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/driver_tokens.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_tokens_response.g.dart';

/// DriverTokensResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class DriverTokensResponse implements Built<DriverTokensResponse, DriverTokensResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  DriverTokens get data;

  DriverTokensResponse._();

  factory DriverTokensResponse([void updates(DriverTokensResponseBuilder b)]) = _$DriverTokensResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverTokensResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverTokensResponse> get serializer => _$DriverTokensResponseSerializer();
}

class _$DriverTokensResponseSerializer implements PrimitiveSerializer<DriverTokensResponse> {
  @override
  final Iterable<Type> types = const [DriverTokensResponse, _$DriverTokensResponse];

  @override
  final String wireName = r'DriverTokensResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverTokensResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(DriverTokens),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverTokensResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverTokensResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DriverTokens),
          ) as DriverTokens;
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
  DriverTokensResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverTokensResponseBuilder();
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

