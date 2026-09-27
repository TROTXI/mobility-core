//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'webhook_ack.g.dart';

/// WebhookAck
///
/// Properties:
/// * [received] 
@BuiltValue()
abstract class WebhookAck implements Built<WebhookAck, WebhookAckBuilder> {
  @BuiltValueField(wireName: r'received')
  bool get received;

  WebhookAck._();

  factory WebhookAck([void updates(WebhookAckBuilder b)]) = _$WebhookAck;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WebhookAckBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WebhookAck> get serializer => _$WebhookAckSerializer();
}

class _$WebhookAckSerializer implements PrimitiveSerializer<WebhookAck> {
  @override
  final Iterable<Type> types = const [WebhookAck, _$WebhookAck];

  @override
  final String wireName = r'WebhookAck';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WebhookAck object, {
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
    WebhookAck object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WebhookAckBuilder result,
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
  WebhookAck deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WebhookAckBuilder();
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

