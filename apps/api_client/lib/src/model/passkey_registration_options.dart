//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/passkey_registration_options_authenticator_selection.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/passkey_authentication_options_allow_credentials_inner.dart';
import 'package:trotxi_api_client/src/model/passkey_registration_options_user.dart';
import 'package:trotxi_api_client/src/model/passkey_registration_options_rp.dart';
import 'package:trotxi_api_client/src/model/passkey_registration_options_pub_key_cred_params_inner.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_options.g.dart';

/// PasskeyRegistrationOptions
///
/// Properties:
/// * [rp]
/// * [user]
/// * [challenge]
/// * [pubKeyCredParams]
/// * [timeout]
/// * [excludeCredentials]
/// * [authenticatorSelection]
/// * [hints]
/// * [attestation]
/// * [attestationFormats]
/// * [extensions]
@BuiltValue()
abstract class PasskeyRegistrationOptions
    implements
        Built<PasskeyRegistrationOptions, PasskeyRegistrationOptionsBuilder> {
  @BuiltValueField(wireName: r'rp')
  PasskeyRegistrationOptionsRp get rp;

  @BuiltValueField(wireName: r'user')
  PasskeyRegistrationOptionsUser get user;

  @BuiltValueField(wireName: r'challenge')
  String get challenge;

  @BuiltValueField(wireName: r'pubKeyCredParams')
  BuiltList<PasskeyRegistrationOptionsPubKeyCredParamsInner>
      get pubKeyCredParams;

  @BuiltValueField(wireName: r'timeout')
  num? get timeout;

  @BuiltValueField(wireName: r'excludeCredentials')
  BuiltList<PasskeyAuthenticationOptionsAllowCredentialsInner>?
      get excludeCredentials;

  @BuiltValueField(wireName: r'authenticatorSelection')
  PasskeyRegistrationOptionsAuthenticatorSelection? get authenticatorSelection;

  @BuiltValueField(wireName: r'hints')
  BuiltList<String>? get hints;

  @BuiltValueField(wireName: r'attestation')
  PasskeyRegistrationOptionsAttestationEnum? get attestation;
  // enum attestationEnum {  direct,  enterprise,  indirect,  none,  };

  @BuiltValueField(wireName: r'attestationFormats')
  BuiltList<String>? get attestationFormats;

  @BuiltValueField(wireName: r'extensions')
  BuiltMap<String, JsonObject?>? get extensions;

  PasskeyRegistrationOptions._();

  factory PasskeyRegistrationOptions(
          [void updates(PasskeyRegistrationOptionsBuilder b)]) =
      _$PasskeyRegistrationOptions;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyRegistrationOptionsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationOptions> get serializer =>
      _$PasskeyRegistrationOptionsSerializer();
}

class _$PasskeyRegistrationOptionsSerializer
    implements PrimitiveSerializer<PasskeyRegistrationOptions> {
  @override
  final Iterable<Type> types = const [
    PasskeyRegistrationOptions,
    _$PasskeyRegistrationOptions
  ];

  @override
  final String wireName = r'PasskeyRegistrationOptions';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationOptions object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rp';
    yield serializers.serialize(
      object.rp,
      specifiedType: const FullType(PasskeyRegistrationOptionsRp),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(PasskeyRegistrationOptionsUser),
    );
    yield r'challenge';
    yield serializers.serialize(
      object.challenge,
      specifiedType: const FullType(String),
    );
    yield r'pubKeyCredParams';
    yield serializers.serialize(
      object.pubKeyCredParams,
      specifiedType: const FullType(BuiltList,
          [FullType(PasskeyRegistrationOptionsPubKeyCredParamsInner)]),
    );
    if (object.timeout != null) {
      yield r'timeout';
      yield serializers.serialize(
        object.timeout,
        specifiedType: const FullType(num),
      );
    }
    if (object.excludeCredentials != null) {
      yield r'excludeCredentials';
      yield serializers.serialize(
        object.excludeCredentials,
        specifiedType: const FullType(BuiltList,
            [FullType(PasskeyAuthenticationOptionsAllowCredentialsInner)]),
      );
    }
    if (object.authenticatorSelection != null) {
      yield r'authenticatorSelection';
      yield serializers.serialize(
        object.authenticatorSelection,
        specifiedType:
            const FullType(PasskeyRegistrationOptionsAuthenticatorSelection),
      );
    }
    if (object.hints != null) {
      yield r'hints';
      yield serializers.serialize(
        object.hints,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.attestation != null) {
      yield r'attestation';
      yield serializers.serialize(
        object.attestation,
        specifiedType:
            const FullType(PasskeyRegistrationOptionsAttestationEnum),
      );
    }
    if (object.attestationFormats != null) {
      yield r'attestationFormats';
      yield serializers.serialize(
        object.attestationFormats,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.extensions != null) {
      yield r'extensions';
      yield serializers.serialize(
        object.extensions,
        specifiedType: const FullType(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationOptions object, {
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
    required PasskeyRegistrationOptionsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PasskeyRegistrationOptionsRp),
          ) as PasskeyRegistrationOptionsRp;
          result.rp.replace(valueDes);
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PasskeyRegistrationOptionsUser),
          ) as PasskeyRegistrationOptionsUser;
          result.user.replace(valueDes);
          break;
        case r'challenge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.challenge = valueDes;
          break;
        case r'pubKeyCredParams':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(PasskeyRegistrationOptionsPubKeyCredParamsInner)]),
          ) as BuiltList<PasskeyRegistrationOptionsPubKeyCredParamsInner>;
          result.pubKeyCredParams.replace(valueDes);
          break;
        case r'timeout':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.timeout = valueDes;
          break;
        case r'excludeCredentials':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(PasskeyAuthenticationOptionsAllowCredentialsInner)]),
          ) as BuiltList<PasskeyAuthenticationOptionsAllowCredentialsInner>;
          result.excludeCredentials.replace(valueDes);
          break;
        case r'authenticatorSelection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PasskeyRegistrationOptionsAuthenticatorSelection),
          ) as PasskeyRegistrationOptionsAuthenticatorSelection;
          result.authenticatorSelection.replace(valueDes);
          break;
        case r'hints':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.hints.replace(valueDes);
          break;
        case r'attestation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PasskeyRegistrationOptionsAttestationEnum),
          ) as PasskeyRegistrationOptionsAttestationEnum;
          result.attestation = valueDes;
          break;
        case r'attestationFormats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.attestationFormats.replace(valueDes);
          break;
        case r'extensions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.extensions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyRegistrationOptions deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationOptionsBuilder();
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

class PasskeyRegistrationOptionsAttestationEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'direct')
  static const PasskeyRegistrationOptionsAttestationEnum direct =
      _$passkeyRegistrationOptionsAttestationEnum_direct;
  @BuiltValueEnumConst(wireName: r'enterprise')
  static const PasskeyRegistrationOptionsAttestationEnum enterprise =
      _$passkeyRegistrationOptionsAttestationEnum_enterprise;
  @BuiltValueEnumConst(wireName: r'indirect')
  static const PasskeyRegistrationOptionsAttestationEnum indirect =
      _$passkeyRegistrationOptionsAttestationEnum_indirect;
  @BuiltValueEnumConst(wireName: r'none')
  static const PasskeyRegistrationOptionsAttestationEnum none =
      _$passkeyRegistrationOptionsAttestationEnum_none;

  static Serializer<PasskeyRegistrationOptionsAttestationEnum> get serializer =>
      _$passkeyRegistrationOptionsAttestationEnumSerializer;

  const PasskeyRegistrationOptionsAttestationEnum._(String name) : super(name);

  static BuiltSet<PasskeyRegistrationOptionsAttestationEnum> get values =>
      _$passkeyRegistrationOptionsAttestationEnumValues;
  static PasskeyRegistrationOptionsAttestationEnum valueOf(String name) =>
      _$passkeyRegistrationOptionsAttestationEnumValueOf(name);
}
