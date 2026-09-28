//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'passkey_status.g.dart';

/// PasskeyStatus
///
/// Properties:
/// * [registered]
/// * [passkeyCount]
/// * [registrationPending]
/// * [verified]
@BuiltValue()
abstract class PasskeyStatus
    implements Built<PasskeyStatus, PasskeyStatusBuilder> {
  @BuiltValueField(wireName: r'registered')
  bool get registered;

  @BuiltValueField(wireName: r'passkeyCount')
  int get passkeyCount;

  @BuiltValueField(wireName: r'registrationPending')
  bool get registrationPending;

  @BuiltValueField(wireName: r'verified')
  bool get verified;

  PasskeyStatus._();

  factory PasskeyStatus([void updates(PasskeyStatusBuilder b)]) =
      _$PasskeyStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasskeyStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasskeyStatus> get serializer =>
      _$PasskeyStatusSerializer();
}

class _$PasskeyStatusSerializer implements PrimitiveSerializer<PasskeyStatus> {
  @override
  final Iterable<Type> types = const [PasskeyStatus, _$PasskeyStatus];

  @override
  final String wireName = r'PasskeyStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasskeyStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'registered';
    yield serializers.serialize(
      object.registered,
      specifiedType: const FullType(bool),
    );
    yield r'passkeyCount';
    yield serializers.serialize(
      object.passkeyCount,
      specifiedType: const FullType(int),
    );
    yield r'registrationPending';
    yield serializers.serialize(
      object.registrationPending,
      specifiedType: const FullType(bool),
    );
    yield r'verified';
    yield serializers.serialize(
      object.verified,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PasskeyStatus object, {
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
    required PasskeyStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'registered':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.registered = valueDes;
          break;
        case r'passkeyCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.passkeyCount = valueDes;
          break;
        case r'registrationPending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.registrationPending = valueDes;
          break;
        case r'verified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.verified = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PasskeyStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasskeyStatusBuilder();
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
