//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credential_secret_email.g.dart';

/// CredentialSecretEmail
///
/// Properties:
/// * [id]
/// * [to]
/// * [state]
@BuiltValue()
abstract class CredentialSecretEmail
    implements Built<CredentialSecretEmail, CredentialSecretEmailBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'to')
  String get to;

  @BuiltValueField(wireName: r'state')
  CredentialSecretEmailStateEnum get state;
  // enum stateEnum {  queued,  };

  CredentialSecretEmail._();

  factory CredentialSecretEmail(
      [void updates(CredentialSecretEmailBuilder b)]) = _$CredentialSecretEmail;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CredentialSecretEmailBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CredentialSecretEmail> get serializer =>
      _$CredentialSecretEmailSerializer();
}

class _$CredentialSecretEmailSerializer
    implements PrimitiveSerializer<CredentialSecretEmail> {
  @override
  final Iterable<Type> types = const [
    CredentialSecretEmail,
    _$CredentialSecretEmail
  ];

  @override
  final String wireName = r'CredentialSecretEmail';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CredentialSecretEmail object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'to';
    yield serializers.serialize(
      object.to,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(CredentialSecretEmailStateEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CredentialSecretEmail object, {
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
    required CredentialSecretEmailBuilder result,
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
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.to = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CredentialSecretEmailStateEnum),
          ) as CredentialSecretEmailStateEnum;
          result.state = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CredentialSecretEmail deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CredentialSecretEmailBuilder();
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

class CredentialSecretEmailStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'queued')
  static const CredentialSecretEmailStateEnum queued =
      _$credentialSecretEmailStateEnum_queued;

  static Serializer<CredentialSecretEmailStateEnum> get serializer =>
      _$credentialSecretEmailStateEnumSerializer;

  const CredentialSecretEmailStateEnum._(String name) : super(name);

  static BuiltSet<CredentialSecretEmailStateEnum> get values =>
      _$credentialSecretEmailStateEnumValues;
  static CredentialSecretEmailStateEnum valueOf(String name) =>
      _$credentialSecretEmailStateEnumValueOf(name);
}
