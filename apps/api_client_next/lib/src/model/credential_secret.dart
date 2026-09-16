//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credential_secret.g.dart';

/// CredentialSecret
///
/// Properties:
/// * [code] 
/// * [pin] 
@BuiltValue()
abstract class CredentialSecret implements Built<CredentialSecret, CredentialSecretBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'pin')
  String get pin;

  CredentialSecret._();

  factory CredentialSecret([void updates(CredentialSecretBuilder b)]) = _$CredentialSecret;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CredentialSecretBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CredentialSecret> get serializer => _$CredentialSecretSerializer();
}

class _$CredentialSecretSerializer implements PrimitiveSerializer<CredentialSecret> {
  @override
  final Iterable<Type> types = const [CredentialSecret, _$CredentialSecret];

  @override
  final String wireName = r'CredentialSecret';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CredentialSecret object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'pin';
    yield serializers.serialize(
      object.pin,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CredentialSecret object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CredentialSecretBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'pin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CredentialSecret deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CredentialSecretBuilder();
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

