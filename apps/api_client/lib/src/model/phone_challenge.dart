//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'phone_challenge.g.dart';

/// PhoneChallenge
///
/// Properties:
/// * [challengeId]
/// * [expiresAt]
/// * [resendAfterSeconds]
@BuiltValue()
abstract class PhoneChallenge
    implements Built<PhoneChallenge, PhoneChallengeBuilder> {
  @BuiltValueField(wireName: r'challengeId')
  String get challengeId;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'resendAfterSeconds')
  int get resendAfterSeconds;

  PhoneChallenge._();

  factory PhoneChallenge([void updates(PhoneChallengeBuilder b)]) =
      _$PhoneChallenge;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PhoneChallengeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PhoneChallenge> get serializer =>
      _$PhoneChallengeSerializer();
}

class _$PhoneChallengeSerializer
    implements PrimitiveSerializer<PhoneChallenge> {
  @override
  final Iterable<Type> types = const [PhoneChallenge, _$PhoneChallenge];

  @override
  final String wireName = r'PhoneChallenge';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PhoneChallenge object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'challengeId';
    yield serializers.serialize(
      object.challengeId,
      specifiedType: const FullType(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'resendAfterSeconds';
    yield serializers.serialize(
      object.resendAfterSeconds,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PhoneChallenge object, {
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
    required PhoneChallengeBuilder result,
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
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'resendAfterSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.resendAfterSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PhoneChallenge deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PhoneChallengeBuilder();
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
