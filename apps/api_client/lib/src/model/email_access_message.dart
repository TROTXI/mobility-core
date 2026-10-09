//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'email_access_message.g.dart';

/// EmailAccessMessage
///
/// Properties:
/// * [message]
@BuiltValue()
abstract class EmailAccessMessage
    implements Built<EmailAccessMessage, EmailAccessMessageBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  EmailAccessMessage._();

  factory EmailAccessMessage([void updates(EmailAccessMessageBuilder b)]) =
      _$EmailAccessMessage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmailAccessMessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmailAccessMessage> get serializer =>
      _$EmailAccessMessageSerializer();
}

class _$EmailAccessMessageSerializer
    implements PrimitiveSerializer<EmailAccessMessage> {
  @override
  final Iterable<Type> types = const [EmailAccessMessage, _$EmailAccessMessage];

  @override
  final String wireName = r'EmailAccessMessage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmailAccessMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EmailAccessMessage object, {
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
    required EmailAccessMessageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EmailAccessMessage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmailAccessMessageBuilder();
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
