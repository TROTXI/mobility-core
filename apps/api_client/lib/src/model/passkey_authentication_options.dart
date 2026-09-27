//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/passkey_authentication_options_allow_credentials_inner.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_authentication_options.g.dart';

/// PasskeyAuthenticationOptions
///
/// Properties:
/// * [challenge] 
/// * [timeout] 
/// * [rpId] 
/// * [allowCredentials] 
/// * [userVerification] 
/// * [hints] 
/// * [extensions] 
@BuiltValue()
abstract class PasskeyAuthenticationOptions implements Built<PasskeyAuthenticationOptions, PasskeyAuthenticationOptionsBuilder> {
  @BuiltValueField(wireName: r'challenge')
  String get challenge;

  @BuiltValueField(wireName: r'timeout')
  num? get timeout;

  @BuiltValueField(wireName: r'rpId')
  String? get rpId;

  @BuiltValueField(wireName: r'allowCredentials')
  BuiltList<PasskeyAuthenticationOptionsAllowCredentialsInner>? get allowCredentials;

  @BuiltValueField(wireName: r'userVerification')
  PasskeyAuthenticationOptionsUserVerificationEnum? get userVerification;
  // enum userVerificationEnum {  discouraged,  preferred,  required,  };

  @BuiltValueField(wireName: r'hints')
  BuiltList<String>? get hints;

  @BuiltValueField(wireName: r'extensions')
  BuiltMap<String, JsonObject?>? get extensions;

  PasskeyAuthenticationOptions._();

  factory PasskeyAuthenticationOptions([void updates(PasskeyAuthenticationOptionsBuilder b)]) = _$PasskeyAuthenticationOptions;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyAuthenticationOptionsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyAuthenticationOptions> get serializer => _$PasskeyAuthenticationOptionsSerializer();
}

class _$PasskeyAuthenticationOptionsSerializer implements PrimitiveSerializer<PasskeyAuthenticationOptions> {
  @override
  final Iterable<Type> types = const [PasskeyAuthenticationOptions, _$PasskeyAuthenticationOptions];

  @override
  final String wireName = r'PasskeyAuthenticationOptions';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyAuthenticationOptions object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'challenge';
    yield serializers.serialize(
      object.challenge,
      specifiedType: const FullType(String),
    );
    if (object.timeout != null) {
      yield r'timeout';
      yield serializers.serialize(
        object.timeout,
        specifiedType: const FullType(num),
      );
    }
    if (object.rpId != null) {
      yield r'rpId';
      yield serializers.serialize(
        object.rpId,
        specifiedType: const FullType(String),
      );
    }
    if (object.allowCredentials != null) {
      yield r'allowCredentials';
      yield serializers.serialize(
        object.allowCredentials,
        specifiedType: const FullType(BuiltList, [FullType(PasskeyAuthenticationOptionsAllowCredentialsInner)]),
      );
    }
    if (object.userVerification != null) {
      yield r'userVerification';
      yield serializers.serialize(
        object.userVerification,
        specifiedType: const FullType(PasskeyAuthenticationOptionsUserVerificationEnum),
      );
    }
    if (object.hints != null) {
      yield r'hints';
      yield serializers.serialize(
        object.hints,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.extensions != null) {
      yield r'extensions';
      yield serializers.serialize(
        object.extensions,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyAuthenticationOptions object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PasskeyAuthenticationOptionsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'challenge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.challenge = valueDes;
          break;
        case r'timeout':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.timeout = valueDes;
          break;
        case r'rpId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rpId = valueDes;
          break;
        case r'allowCredentials':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PasskeyAuthenticationOptionsAllowCredentialsInner)]),
          ) as BuiltList<PasskeyAuthenticationOptionsAllowCredentialsInner>;
          result.allowCredentials.replace(valueDes);
          break;
        case r'userVerification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PasskeyAuthenticationOptionsUserVerificationEnum),
          ) as PasskeyAuthenticationOptionsUserVerificationEnum;
          result.userVerification = valueDes;
          break;
        case r'hints':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.hints.replace(valueDes);
          break;
        case r'extensions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
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
  PasskeyAuthenticationOptions deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyAuthenticationOptionsBuilder();
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

class PasskeyAuthenticationOptionsUserVerificationEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'discouraged')
  static const PasskeyAuthenticationOptionsUserVerificationEnum discouraged = _$passkeyAuthenticationOptionsUserVerificationEnum_discouraged;
  @BuiltValueEnumConst(wireName: r'preferred')
  static const PasskeyAuthenticationOptionsUserVerificationEnum preferred = _$passkeyAuthenticationOptionsUserVerificationEnum_preferred;
  @BuiltValueEnumConst(wireName: r'required')
  static const PasskeyAuthenticationOptionsUserVerificationEnum required_ = _$passkeyAuthenticationOptionsUserVerificationEnum_required_;

  static Serializer<PasskeyAuthenticationOptionsUserVerificationEnum> get serializer => _$passkeyAuthenticationOptionsUserVerificationEnumSerializer;

  const PasskeyAuthenticationOptionsUserVerificationEnum._(String name): super(name);

  static BuiltSet<PasskeyAuthenticationOptionsUserVerificationEnum> get values => _$passkeyAuthenticationOptionsUserVerificationEnumValues;
  static PasskeyAuthenticationOptionsUserVerificationEnum valueOf(String name) => _$passkeyAuthenticationOptionsUserVerificationEnumValueOf(name);
}

