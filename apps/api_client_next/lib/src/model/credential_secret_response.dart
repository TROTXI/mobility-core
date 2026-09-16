//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/credential_secret.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credential_secret_response.g.dart';

/// CredentialSecretResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class CredentialSecretResponse implements Built<CredentialSecretResponse, CredentialSecretResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  CredentialSecret get data;

  CredentialSecretResponse._();

  factory CredentialSecretResponse([void updates(CredentialSecretResponseBuilder b)]) = _$CredentialSecretResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CredentialSecretResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CredentialSecretResponse> get serializer => _$CredentialSecretResponseSerializer();
}

class _$CredentialSecretResponseSerializer implements PrimitiveSerializer<CredentialSecretResponse> {
  @override
  final Iterable<Type> types = const [CredentialSecretResponse, _$CredentialSecretResponse];

  @override
  final String wireName = r'CredentialSecretResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CredentialSecretResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(CredentialSecret),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CredentialSecretResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CredentialSecretResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CredentialSecret),
          ) as CredentialSecret;
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
  CredentialSecretResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CredentialSecretResponseBuilder();
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

