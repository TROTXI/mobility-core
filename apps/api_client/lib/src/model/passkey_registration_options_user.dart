//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_registration_options_user.g.dart';

/// PasskeyRegistrationOptionsUser
///
/// Properties:
/// * [id]
/// * [name]
/// * [displayName]
@BuiltValue()
abstract class PasskeyRegistrationOptionsUser
    implements
        Built<PasskeyRegistrationOptionsUser,
            PasskeyRegistrationOptionsUserBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  PasskeyRegistrationOptionsUser._();

  factory PasskeyRegistrationOptionsUser(
          [void updates(PasskeyRegistrationOptionsUserBuilder b)]) =
      _$PasskeyRegistrationOptionsUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyRegistrationOptionsUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyRegistrationOptionsUser> get serializer =>
      _$PasskeyRegistrationOptionsUserSerializer();
}

class _$PasskeyRegistrationOptionsUserSerializer
    implements PrimitiveSerializer<PasskeyRegistrationOptionsUser> {
  @override
  final Iterable<Type> types = const [
    PasskeyRegistrationOptionsUser,
    _$PasskeyRegistrationOptionsUser
  ];

  @override
  final String wireName = r'PasskeyRegistrationOptionsUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyRegistrationOptionsUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyRegistrationOptionsUser object, {
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
    required PasskeyRegistrationOptionsUserBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyRegistrationOptionsUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyRegistrationOptionsUserBuilder();
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
