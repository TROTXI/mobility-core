//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_registration.g.dart';

/// PhoneRegistration
///
/// Properties:
/// * [firstName]
/// * [lastName]
/// * [otherNames]
/// * [email]
/// * [password]
@BuiltValue()
abstract class PhoneRegistration
    implements Built<PhoneRegistration, PhoneRegistrationBuilder> {
  @BuiltValueField(wireName: r'firstName')
  String get firstName;

  @BuiltValueField(wireName: r'lastName')
  String get lastName;

  @BuiltValueField(wireName: r'otherNames')
  String? get otherNames;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'password')
  String get password;

  PhoneRegistration._();

  factory PhoneRegistration([void updates(PhoneRegistrationBuilder b)]) =
      _$PhoneRegistration;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneRegistrationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneRegistration> get serializer =>
      _$PhoneRegistrationSerializer();
}

class _$PhoneRegistrationSerializer
    implements PrimitiveSerializer<PhoneRegistration> {
  @override
  final Iterable<Type> types = const [PhoneRegistration, _$PhoneRegistration];

  @override
  final String wireName = r'PhoneRegistration';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneRegistration object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'firstName';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'lastName';
    yield serializers.serialize(
      object.lastName,
      specifiedType: const FullType(String),
    );
    if (object.otherNames != null) {
      yield r'otherNames';
      yield serializers.serialize(
        object.otherNames,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneRegistration object, {
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
    required PhoneRegistrationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'firstName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.firstName = valueDes;
          break;
        case r'lastName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastName = valueDes;
          break;
        case r'otherNames':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.otherNames = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhoneRegistration deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneRegistrationBuilder();
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
