//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'receive_paystack_webhook_request.g.dart';

/// ReceivePaystackWebhookRequest
///
/// Properties:
/// * [event] 
/// * [data] 
@BuiltValue()
abstract class ReceivePaystackWebhookRequest implements Built<ReceivePaystackWebhookRequest, ReceivePaystackWebhookRequestBuilder> {
  @BuiltValueField(wireName: r'event')
  String get event;

  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?> get data;

  ReceivePaystackWebhookRequest._();

  factory ReceivePaystackWebhookRequest([void updates(ReceivePaystackWebhookRequestBuilder b)]) = _$ReceivePaystackWebhookRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReceivePaystackWebhookRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ReceivePaystackWebhookRequest> get serializer => _$ReceivePaystackWebhookRequestSerializer();
}

class _$ReceivePaystackWebhookRequestSerializer implements PrimitiveSerializer<ReceivePaystackWebhookRequest> {
  @override
  final Iterable<Type> types = const [ReceivePaystackWebhookRequest, _$ReceivePaystackWebhookRequest];

  @override
  final String wireName = r'ReceivePaystackWebhookRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ReceivePaystackWebhookRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'event';
    yield serializers.serialize(
      object.event,
      specifiedType: const FullType(String),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReceivePaystackWebhookRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ReceivePaystackWebhookRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'event':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.event = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
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
  ReceivePaystackWebhookRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ReceivePaystackWebhookRequestBuilder();
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

