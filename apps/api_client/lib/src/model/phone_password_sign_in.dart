//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_password_sign_in.g.dart';

/// PhonePasswordSignIn
///
/// Properties:
/// * [phone]
/// * [password]
@BuiltValue()
abstract class PhonePasswordSignIn
    implements Built<PhonePasswordSignIn, PhonePasswordSignInBuilder> {
  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'password')
  String get password;

  PhonePasswordSignIn._();

  factory PhonePasswordSignIn([void updates(PhonePasswordSignInBuilder b)]) =
      _$PhonePasswordSignIn;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhonePasswordSignInBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhonePasswordSignIn> get serializer =>
      _$PhonePasswordSignInSerializer();
}

class _$PhonePasswordSignInSerializer
    implements PrimitiveSerializer<PhonePasswordSignIn> {
  @override
  final Iterable<Type> types = const [
    PhonePasswordSignIn,
    _$PhonePasswordSignIn
  ];

  @override
  final String wireName = r'PhonePasswordSignIn';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhonePasswordSignIn object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'phone';
    yield serializers.serialize(
      object.phone,
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
    PhonePasswordSignIn object, {
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
    required PhonePasswordSignInBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
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
  PhonePasswordSignIn deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhonePasswordSignInBuilder();
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
