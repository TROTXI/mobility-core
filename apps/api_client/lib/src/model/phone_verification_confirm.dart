//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_verification_confirm.g.dart';

/// PhoneVerificationConfirm
///
/// Properties:
/// * [challengeId]
/// * [code]
@BuiltValue()
abstract class PhoneVerificationConfirm
    implements
        Built<PhoneVerificationConfirm, PhoneVerificationConfirmBuilder> {
  @BuiltValueField(wireName: r'challengeId')
  String get challengeId;

  @BuiltValueField(wireName: r'code')
  String get code;

  PhoneVerificationConfirm._();

  factory PhoneVerificationConfirm(
          [void updates(PhoneVerificationConfirmBuilder b)]) =
      _$PhoneVerificationConfirm;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneVerificationConfirmBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneVerificationConfirm> get serializer =>
      _$PhoneVerificationConfirmSerializer();
}

class _$PhoneVerificationConfirmSerializer
    implements PrimitiveSerializer<PhoneVerificationConfirm> {
  @override
  final Iterable<Type> types = const [
    PhoneVerificationConfirm,
    _$PhoneVerificationConfirm
  ];

  @override
  final String wireName = r'PhoneVerificationConfirm';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneVerificationConfirm object, {
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
    PhoneVerificationConfirm object, {
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
    required PhoneVerificationConfirmBuilder result,
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
  PhoneVerificationConfirm deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneVerificationConfirmBuilder();
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
