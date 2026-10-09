//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/email_access_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'email_access_status_response.g.dart';

/// EmailAccessStatusResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class EmailAccessStatusResponse
    implements
        Built<EmailAccessStatusResponse, EmailAccessStatusResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  EmailAccessStatus get data;

  EmailAccessStatusResponse._();

  factory EmailAccessStatusResponse(
          [void updates(EmailAccessStatusResponseBuilder b)]) =
      _$EmailAccessStatusResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EmailAccessStatusResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EmailAccessStatusResponse> get serializer =>
      _$EmailAccessStatusResponseSerializer();
}

class _$EmailAccessStatusResponseSerializer
    implements PrimitiveSerializer<EmailAccessStatusResponse> {
  @override
  final Iterable<Type> types = const [
    EmailAccessStatusResponse,
    _$EmailAccessStatusResponse
  ];

  @override
  final String wireName = r'EmailAccessStatusResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EmailAccessStatusResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(EmailAccessStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    EmailAccessStatusResponse object, {
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
    required EmailAccessStatusResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(EmailAccessStatus),
          ) as EmailAccessStatus;
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
  EmailAccessStatusResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EmailAccessStatusResponseBuilder();
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
