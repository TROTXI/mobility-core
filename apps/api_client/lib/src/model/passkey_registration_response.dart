//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/passkey_registration_response_response.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_response.g.dart';

/// PasskeyRegistrationResponse
///
/// Properties:
/// * [id]
/// * [rawId]
/// * [authenticatorAttachment]
/// * [clientExtensionResults]
/// * [type]
/// * [response]
@BuiltValue()
abstract class PasskeyRegistrationResponse
    implements
        Built<PasskeyRegistrationResponse, PasskeyRegistrationResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'rawId')
  String get rawId;

  @BuiltValueField(wireName: r'authenticatorAttachment')
  PasskeyRegistrationResponseAuthenticatorAttachmentEnum?
      get authenticatorAttachment;
  // enum authenticatorAttachmentEnum {  cross-platform,  platform,  };

  @BuiltValueField(wireName: r'clientExtensionResults')
  BuiltMap<String, JsonObject?> get clientExtensionResults;

  @BuiltValueField(wireName: r'type')
  PasskeyRegistrationResponseTypeEnum get type;
  // enum typeEnum {  public-key,  };

  @BuiltValueField(wireName: r'response')
  PasskeyRegistrationResponseResponse get response;

  PasskeyRegistrationResponse._();

  factory PasskeyRegistrationResponse(
          [void updates(PasskeyRegistrationResponseBuilder b)]) =
      _$PasskeyRegistrationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyRegistrationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationResponse> get serializer =>
      _$PasskeyRegistrationResponseSerializer();
}

class _$PasskeyRegistrationResponseSerializer
    implements PrimitiveSerializer<PasskeyRegistrationResponse> {
  @override
  final Iterable<Type> types = const [
    PasskeyRegistrationResponse,
    _$PasskeyRegistrationResponse
  ];

  @override
  final String wireName = r'PasskeyRegistrationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationResponse object, {
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
            PasskeyRegistrationResponseAuthenticatorAttachmentEnum),
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
      specifiedType: const FullType(PasskeyRegistrationResponseTypeEnum),
    );
    yield r'response';
    yield serializers.serialize(
      object.response,
      specifiedType: const FullType(PasskeyRegistrationResponseResponse),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationResponse object, {
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
    required PasskeyRegistrationResponseBuilder result,
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
                PasskeyRegistrationResponseAuthenticatorAttachmentEnum),
          ) as PasskeyRegistrationResponseAuthenticatorAttachmentEnum?;
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
            specifiedType: const FullType(PasskeyRegistrationResponseTypeEnum),
          ) as PasskeyRegistrationResponseTypeEnum;
          result.type = valueDes;
          break;
        case r'response':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PasskeyRegistrationResponseResponse),
          ) as PasskeyRegistrationResponseResponse;
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
  PasskeyRegistrationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationResponseBuilder();
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

class PasskeyRegistrationResponseAuthenticatorAttachmentEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cross-platform')
  static const PasskeyRegistrationResponseAuthenticatorAttachmentEnum
      crossPlatform =
      _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_crossPlatform;
  @BuiltValueEnumConst(wireName: r'platform')
  static const PasskeyRegistrationResponseAuthenticatorAttachmentEnum platform =
      _$passkeyRegistrationResponseAuthenticatorAttachmentEnum_platform;

  static Serializer<PasskeyRegistrationResponseAuthenticatorAttachmentEnum>
      get serializer =>
          _$passkeyRegistrationResponseAuthenticatorAttachmentEnumSerializer;

  const PasskeyRegistrationResponseAuthenticatorAttachmentEnum._(String name)
      : super(name);

  static BuiltSet<PasskeyRegistrationResponseAuthenticatorAttachmentEnum>
      get values =>
          _$passkeyRegistrationResponseAuthenticatorAttachmentEnumValues;
  static PasskeyRegistrationResponseAuthenticatorAttachmentEnum valueOf(
          String name) =>
      _$passkeyRegistrationResponseAuthenticatorAttachmentEnumValueOf(name);
}

class PasskeyRegistrationResponseTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'public-key')
  static const PasskeyRegistrationResponseTypeEnum publicKey =
      _$passkeyRegistrationResponseTypeEnum_publicKey;

  static Serializer<PasskeyRegistrationResponseTypeEnum> get serializer =>
      _$passkeyRegistrationResponseTypeEnumSerializer;

  const PasskeyRegistrationResponseTypeEnum._(String name) : super(name);

  static BuiltSet<PasskeyRegistrationResponseTypeEnum> get values =>
      _$passkeyRegistrationResponseTypeEnumValues;
  static PasskeyRegistrationResponseTypeEnum valueOf(String name) =>
      _$passkeyRegistrationResponseTypeEnumValueOf(name);
}
