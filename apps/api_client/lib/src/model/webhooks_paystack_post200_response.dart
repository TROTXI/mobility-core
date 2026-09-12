//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'webhooks_paystack_post200_response.g.dart';

/// WebhooksPaystackPost200Response
///
/// Properties:
/// * [received] 
@BuiltValue()
abstract class WebhooksPaystackPost200Response implements Built<WebhooksPaystackPost200Response, WebhooksPaystackPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'received')
  bool get received;

  WebhooksPaystackPost200Response._();

  factory WebhooksPaystackPost200Response([void updates(WebhooksPaystackPost200ResponseBuilder b)]) = _$WebhooksPaystackPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WebhooksPaystackPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WebhooksPaystackPost200Response> get serializer => _$WebhooksPaystackPost200ResponseSerializer();
}

class _$WebhooksPaystackPost200ResponseSerializer implements PrimitiveSerializer<WebhooksPaystackPost200Response> {
  @override
  final Iterable<Type> types = const [WebhooksPaystackPost200Response, _$WebhooksPaystackPost200Response];

  @override
  final String wireName = r'WebhooksPaystackPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WebhooksPaystackPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'received';
    yield serializers.serialize(
      object.received,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WebhooksPaystackPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WebhooksPaystackPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.received = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WebhooksPaystackPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WebhooksPaystackPost200ResponseBuilder();
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

