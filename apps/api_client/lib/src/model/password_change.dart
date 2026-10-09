//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'password_change.g.dart';

/// PasswordChange
///
/// Properties:
/// * [currentPassword]
/// * [password]
@BuiltValue()
abstract class PasswordChange
    implements Built<PasswordChange, PasswordChangeBuilder> {
  @BuiltValueField(wireName: r'currentPassword')
  String get currentPassword;

  @BuiltValueField(wireName: r'password')
  String get password;

  PasswordChange._();

  factory PasswordChange([void updates(PasswordChangeBuilder b)]) =
      _$PasswordChange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PasswordChangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PasswordChange> get serializer =>
      _$PasswordChangeSerializer();
}

class _$PasswordChangeSerializer
    implements PrimitiveSerializer<PasswordChange> {
  @override
  final Iterable<Type> types = const [PasswordChange, _$PasswordChange];

  @override
  final String wireName = r'PasswordChange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PasswordChange object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'currentPassword';
    yield serializers.serialize(
      object.currentPassword,
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
    PasswordChange object, {
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
    required PasswordChangeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'currentPassword':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currentPassword = valueDes;
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
  PasswordChange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PasswordChangeBuilder();
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
