//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_authentication_response_response.g.dart';

/// PasskeyAuthenticationResponseResponse
///
/// Properties:
/// * [clientDataJSON] 
/// * [authenticatorData] 
/// * [signature] 
/// * [userHandle] 
@BuiltValue()
abstract class PasskeyAuthenticationResponseResponse implements Built<PasskeyAuthenticationResponseResponse, PasskeyAuthenticationResponseResponseBuilder> {
  @BuiltValueField(wireName: r'clientDataJSON')
  String get clientDataJSON;

  @BuiltValueField(wireName: r'authenticatorData')
  String get authenticatorData;

  @BuiltValueField(wireName: r'signature')
  String get signature;

  @BuiltValueField(wireName: r'userHandle')
  String? get userHandle;

  PasskeyAuthenticationResponseResponse._();

  factory PasskeyAuthenticationResponseResponse([void updates(PasskeyAuthenticationResponseResponseBuilder b)]) = _$PasskeyAuthenticationResponseResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyAuthenticationResponseResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyAuthenticationResponseResponse> get serializer => _$PasskeyAuthenticationResponseResponseSerializer();
}

class _$PasskeyAuthenticationResponseResponseSerializer implements PrimitiveSerializer<PasskeyAuthenticationResponseResponse> {
  @override
  final Iterable<Type> types = const [PasskeyAuthenticationResponseResponse, _$PasskeyAuthenticationResponseResponse];

  @override
  final String wireName = r'PasskeyAuthenticationResponseResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyAuthenticationResponseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'clientDataJSON';
    yield serializers.serialize(
      object.clientDataJSON,
      specifiedType: const FullType(String),
    );
    yield r'authenticatorData';
    yield serializers.serialize(
      object.authenticatorData,
      specifiedType: const FullType(String),
    );
    yield r'signature';
    yield serializers.serialize(
      object.signature,
      specifiedType: const FullType(String),
    );
    if (object.userHandle != null) {
      yield r'userHandle';
      yield serializers.serialize(
        object.userHandle,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyAuthenticationResponseResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PasskeyAuthenticationResponseResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'clientDataJSON':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientDataJSON = valueDes;
          break;
        case r'authenticatorData':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authenticatorData = valueDes;
          break;
        case r'signature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.signature = valueDes;
          break;
        case r'userHandle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userHandle = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyAuthenticationResponseResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyAuthenticationResponseResponseBuilder();
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

