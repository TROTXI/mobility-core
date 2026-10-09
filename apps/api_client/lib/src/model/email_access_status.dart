//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'email_access_status.g.dart';

/// EmailAccessStatus
///
/// Properties:
/// * [email]
/// * [passwordEnabled]
@BuiltValue()
abstract class EmailAccessStatus
    implements Built<EmailAccessStatus, EmailAccessStatusBuilder> {
  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'passwordEnabled')
  bool get passwordEnabled;

  EmailAccessStatus._();

  factory EmailAccessStatus([void updates(EmailAccessStatusBuilder b)]) =
      _$EmailAccessStatus;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmailAccessStatusBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmailAccessStatus> get serializer =>
      _$EmailAccessStatusSerializer();
}

class _$EmailAccessStatusSerializer
    implements PrimitiveSerializer<EmailAccessStatus> {
  @override
  final Iterable<Type> types = const [EmailAccessStatus, _$EmailAccessStatus];

  @override
  final String wireName = r'EmailAccessStatus';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmailAccessStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield object.email == null
        ? null
        : serializers.serialize(
            object.email,
            specifiedType: const FullType.nullable(String),
          );
    yield r'passwordEnabled';
    yield serializers.serialize(
      object.passwordEnabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EmailAccessStatus object, {
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
    required EmailAccessStatusBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'passwordEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.passwordEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EmailAccessStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmailAccessStatusBuilder();
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
