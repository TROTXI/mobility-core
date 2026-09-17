//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/tokens.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tokens_response.g.dart';

/// TokensResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class TokensResponse implements Built<TokensResponse, TokensResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Tokens get data;

  TokensResponse._();

  factory TokensResponse([void updates(TokensResponseBuilder b)]) = _$TokensResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TokensResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TokensResponse> get serializer => _$TokensResponseSerializer();
}

class _$TokensResponseSerializer implements PrimitiveSerializer<TokensResponse> {
  @override
  final Iterable<Type> types = const [TokensResponse, _$TokensResponse];

  @override
  final String wireName = r'TokensResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TokensResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Tokens),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TokensResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TokensResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Tokens),
          ) as Tokens;
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
  TokensResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TokensResponseBuilder();
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

