//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/passkey_authentication_options.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_authentication_options_response.g.dart';

/// PasskeyAuthenticationOptionsResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class PasskeyAuthenticationOptionsResponse
    implements
        Built<PasskeyAuthenticationOptionsResponse,
            PasskeyAuthenticationOptionsResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  PasskeyAuthenticationOptions get data;

  PasskeyAuthenticationOptionsResponse._();

  factory PasskeyAuthenticationOptionsResponse(
          [void updates(PasskeyAuthenticationOptionsResponseBuilder b)]) =
      _$PasskeyAuthenticationOptionsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyAuthenticationOptionsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyAuthenticationOptionsResponse> get serializer =>
      _$PasskeyAuthenticationOptionsResponseSerializer();
}

class _$PasskeyAuthenticationOptionsResponseSerializer
    implements PrimitiveSerializer<PasskeyAuthenticationOptionsResponse> {
  @override
  final Iterable<Type> types = const [
    PasskeyAuthenticationOptionsResponse,
    _$PasskeyAuthenticationOptionsResponse
  ];

  @override
  final String wireName = r'PasskeyAuthenticationOptionsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyAuthenticationOptionsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(PasskeyAuthenticationOptions),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyAuthenticationOptionsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PasskeyAuthenticationOptionsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PasskeyAuthenticationOptions),
          ) as PasskeyAuthenticationOptions;
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
  PasskeyAuthenticationOptionsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyAuthenticationOptionsResponseBuilder();
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
