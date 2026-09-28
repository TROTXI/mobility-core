//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/passkey_authentication_response_response.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_authentication_response.g.dart';

/// PasskeyAuthenticationResponse
///
/// Properties:
/// * [id]
/// * [rawId]
/// * [authenticatorAttachment]
/// * [clientExtensionResults]
/// * [type]
/// * [response]
@BuiltValue()
abstract class PasskeyAuthenticationResponse
    implements
        Built<PasskeyAuthenticationResponse,
            PasskeyAuthenticationResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'rawId')
  String get rawId;

  @BuiltValueField(wireName: r'authenticatorAttachment')
  PasskeyAuthenticationResponseAuthenticatorAttachmentEnum?
      get authenticatorAttachment;
  // enum authenticatorAttachmentEnum {  cross-platform,  platform,  };

  @BuiltValueField(wireName: r'clientExtensionResults')
  BuiltMap<String, JsonObject?> get clientExtensionResults;

  @BuiltValueField(wireName: r'type')
  PasskeyAuthenticationResponseTypeEnum get type;
  // enum typeEnum {  public-key,  };

  @BuiltValueField(wireName: r'response')
  PasskeyAuthenticationResponseResponse get response;

  PasskeyAuthenticationResponse._();

  factory PasskeyAuthenticationResponse(
          [void updates(PasskeyAuthenticationResponseBuilder b)]) =
      _$PasskeyAuthenticationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyAuthenticationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyAuthenticationResponse> get serializer =>
      _$PasskeyAuthenticationResponseSerializer();
}

class _$PasskeyAuthenticationResponseSerializer
    implements PrimitiveSerializer<PasskeyAuthenticationResponse> {
  @override
  final Iterable<Type> types = const [
    PasskeyAuthenticationResponse,
    _$PasskeyAuthenticationResponse
  ];

  @override
  final String wireName = r'PasskeyAuthenticationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyAuthenticationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'rawId';
    yield serializers.serialize(
      object.rawId,
      specifiedType: const FullType(String),
    );
    if (object.authenticatorAttachment != null) {
      yield r'authenticatorAttachment';
      yield serializers.serialize(
        object.authenticatorAttachment,
        specifiedType: const FullType.nullable(
            PasskeyAuthenticationResponseAuthenticatorAttachmentEnum),
      );
    }
    yield r'clientExtensionResults';
    yield serializers.serialize(
      object.clientExtensionResults,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(PasskeyAuthenticationResponseTypeEnum),
    );
    yield r'response';
    yield serializers.serialize(
      object.response,
      specifiedType: const FullType(PasskeyAuthenticationResponseResponse),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyAuthenticationResponse object, {
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
    required PasskeyAuthenticationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'rawId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rawId = valueDes;
          break;
        case r'authenticatorAttachment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PasskeyAuthenticationResponseAuthenticatorAttachmentEnum),
          ) as PasskeyAuthenticationResponseAuthenticatorAttachmentEnum?;
          if (valueDes == null) continue;
          result.authenticatorAttachment = valueDes;
          break;
        case r'clientExtensionResults':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.clientExtensionResults.replace(valueDes);
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PasskeyAuthenticationResponseTypeEnum),
          ) as PasskeyAuthenticationResponseTypeEnum;
          result.type = valueDes;
          break;
        case r'response':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PasskeyAuthenticationResponseResponse),
          ) as PasskeyAuthenticationResponseResponse;
          result.response.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyAuthenticationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyAuthenticationResponseBuilder();
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

class PasskeyAuthenticationResponseAuthenticatorAttachmentEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cross-platform')
  static const PasskeyAuthenticationResponseAuthenticatorAttachmentEnum
      crossPlatform =
      _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_crossPlatform;
  @BuiltValueEnumConst(wireName: r'platform')
  static const PasskeyAuthenticationResponseAuthenticatorAttachmentEnum
      platform =
      _$passkeyAuthenticationResponseAuthenticatorAttachmentEnum_platform;

  static Serializer<PasskeyAuthenticationResponseAuthenticatorAttachmentEnum>
      get serializer =>
          _$passkeyAuthenticationResponseAuthenticatorAttachmentEnumSerializer;

  const PasskeyAuthenticationResponseAuthenticatorAttachmentEnum._(String name)
      : super(name);

  static BuiltSet<PasskeyAuthenticationResponseAuthenticatorAttachmentEnum>
      get values =>
          _$passkeyAuthenticationResponseAuthenticatorAttachmentEnumValues;
  static PasskeyAuthenticationResponseAuthenticatorAttachmentEnum valueOf(
          String name) =>
      _$passkeyAuthenticationResponseAuthenticatorAttachmentEnumValueOf(name);
}

class PasskeyAuthenticationResponseTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'public-key')
  static const PasskeyAuthenticationResponseTypeEnum publicKey =
      _$passkeyAuthenticationResponseTypeEnum_publicKey;

  static Serializer<PasskeyAuthenticationResponseTypeEnum> get serializer =>
      _$passkeyAuthenticationResponseTypeEnumSerializer;

  const PasskeyAuthenticationResponseTypeEnum._(String name) : super(name);

  static BuiltSet<PasskeyAuthenticationResponseTypeEnum> get values =>
      _$passkeyAuthenticationResponseTypeEnumValues;
  static PasskeyAuthenticationResponseTypeEnum valueOf(String name) =>
      _$passkeyAuthenticationResponseTypeEnumValueOf(name);
}
