//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'contact_email_verify.g.dart';

/// ContactEmailVerify
///
/// Properties:
/// * [token]
@BuiltValue()
abstract class ContactEmailVerify
    implements Built<ContactEmailVerify, ContactEmailVerifyBuilder> {
  @BuiltValueField(wireName: r'token')
  String get token;

  ContactEmailVerify._();

  factory ContactEmailVerify([void updates(ContactEmailVerifyBuilder b)]) =
      _$ContactEmailVerify;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ContactEmailVerifyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ContactEmailVerify> get serializer =>
      _$ContactEmailVerifySerializer();
}

class _$ContactEmailVerifySerializer
    implements PrimitiveSerializer<ContactEmailVerify> {
  @override
  final Iterable<Type> types = const [ContactEmailVerify, _$ContactEmailVerify];

  @override
  final String wireName = r'ContactEmailVerify';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ContactEmailVerify object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ContactEmailVerify object, {
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
    required ContactEmailVerifyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ContactEmailVerify deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ContactEmailVerifyBuilder();
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
