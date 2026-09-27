//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_sign_in_verify.g.dart';

/// PhoneSignInVerify
///
/// Properties:
/// * [challengeId]
/// * [code]
@BuiltValue()
abstract class PhoneSignInVerify
    implements Built<PhoneSignInVerify, PhoneSignInVerifyBuilder> {
  @BuiltValueField(wireName: r'challengeId')
  String get challengeId;

  @BuiltValueField(wireName: r'code')
  String get code;

  PhoneSignInVerify._();

  factory PhoneSignInVerify([void updates(PhoneSignInVerifyBuilder b)]) =
      _$PhoneSignInVerify;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneSignInVerifyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneSignInVerify> get serializer =>
      _$PhoneSignInVerifySerializer();
}

class _$PhoneSignInVerifySerializer
    implements PrimitiveSerializer<PhoneSignInVerify> {
  @override
  final Iterable<Type> types = const [PhoneSignInVerify, _$PhoneSignInVerify];

  @override
  final String wireName = r'PhoneSignInVerify';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneSignInVerify object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'challengeId';
    yield serializers.serialize(
      object.challengeId,
      specifiedType: const FullType(String),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneSignInVerify object, {
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
    required PhoneSignInVerifyBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'challengeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.challengeId = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhoneSignInVerify deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneSignInVerifyBuilder();
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
