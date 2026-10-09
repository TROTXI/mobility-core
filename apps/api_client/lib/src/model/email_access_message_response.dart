//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/email_access_message.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'email_access_message_response.g.dart';

/// EmailAccessMessageResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class EmailAccessMessageResponse
    implements
        Built<EmailAccessMessageResponse, EmailAccessMessageResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  EmailAccessMessage get data;

  EmailAccessMessageResponse._();

  factory EmailAccessMessageResponse(
          [void updates(EmailAccessMessageResponseBuilder b)]) =
      _$EmailAccessMessageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmailAccessMessageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmailAccessMessageResponse> get serializer =>
      _$EmailAccessMessageResponseSerializer();
}

class _$EmailAccessMessageResponseSerializer
    implements PrimitiveSerializer<EmailAccessMessageResponse> {
  @override
  final Iterable<Type> types = const [
    EmailAccessMessageResponse,
    _$EmailAccessMessageResponse
  ];

  @override
  final String wireName = r'EmailAccessMessageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmailAccessMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(EmailAccessMessage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EmailAccessMessageResponse object, {
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
    required EmailAccessMessageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EmailAccessMessage),
          ) as EmailAccessMessage;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EmailAccessMessageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmailAccessMessageResponseBuilder();
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
