//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'credential_secret_sms.g.dart';

/// CredentialSecretSms
///
/// Properties:
/// * [id]
/// * [to]
/// * [state]
@BuiltValue()
abstract class CredentialSecretSms
    implements Built<CredentialSecretSms, CredentialSecretSmsBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'to')
  String get to;

  @BuiltValueField(wireName: r'state')
  CredentialSecretSmsStateEnum get state;
  // enum stateEnum {  queued,  };

  CredentialSecretSms._();

  factory CredentialSecretSms([void updates(CredentialSecretSmsBuilder b)]) =
      _$CredentialSecretSms;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CredentialSecretSmsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CredentialSecretSms> get serializer =>
      _$CredentialSecretSmsSerializer();
}

class _$CredentialSecretSmsSerializer
    implements PrimitiveSerializer<CredentialSecretSms> {
  @override
  final Iterable<Type> types = const [
    CredentialSecretSms,
    _$CredentialSecretSms
  ];

  @override
  final String wireName = r'CredentialSecretSms';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CredentialSecretSms object, {
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
      specifiedType: const FullType(CredentialSecretSmsStateEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CredentialSecretSms object, {
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
    required CredentialSecretSmsBuilder result,
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
            specifiedType: const FullType(CredentialSecretSmsStateEnum),
          ) as CredentialSecretSmsStateEnum;
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
  CredentialSecretSms deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CredentialSecretSmsBuilder();
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

class CredentialSecretSmsStateEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'queued')
  static const CredentialSecretSmsStateEnum queued =
      _$credentialSecretSmsStateEnum_queued;

  static Serializer<CredentialSecretSmsStateEnum> get serializer =>
      _$credentialSecretSmsStateEnumSerializer;

  const CredentialSecretSmsStateEnum._(String name) : super(name);

  static BuiltSet<CredentialSecretSmsStateEnum> get values =>
      _$credentialSecretSmsStateEnumValues;
  static CredentialSecretSmsStateEnum valueOf(String name) =>
      _$credentialSecretSmsStateEnumValueOf(name);
}
