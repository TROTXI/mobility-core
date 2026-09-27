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
<<<<<<< HEAD
/// * [event] 
/// * [data] 
@BuiltValue()
abstract class ReceivePaystackWebhookRequest implements Built<ReceivePaystackWebhookRequest, ReceivePaystackWebhookRequestBuilder> {
=======
/// * [event]
/// * [data]
@BuiltValue()
abstract class ReceivePaystackWebhookRequest
    implements
        Built<ReceivePaystackWebhookRequest,
            ReceivePaystackWebhookRequestBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'event')
  String get event;

  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?> get data;

  ReceivePaystackWebhookRequest._();

<<<<<<< HEAD
  factory ReceivePaystackWebhookRequest([void updates(ReceivePaystackWebhookRequestBuilder b)]) = _$ReceivePaystackWebhookRequest;
=======
  factory ReceivePaystackWebhookRequest(
          [void updates(ReceivePaystackWebhookRequestBuilder b)]) =
      _$ReceivePaystackWebhookRequest;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ReceivePaystackWebhookRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<ReceivePaystackWebhookRequest> get serializer => _$ReceivePaystackWebhookRequestSerializer();
}

class _$ReceivePaystackWebhookRequestSerializer implements PrimitiveSerializer<ReceivePaystackWebhookRequest> {
  @override
  final Iterable<Type> types = const [ReceivePaystackWebhookRequest, _$ReceivePaystackWebhookRequest];
=======
  static Serializer<ReceivePaystackWebhookRequest> get serializer =>
      _$ReceivePaystackWebhookRequestSerializer();
}

class _$ReceivePaystackWebhookRequestSerializer
    implements PrimitiveSerializer<ReceivePaystackWebhookRequest> {
  @override
  final Iterable<Type> types = const [
    ReceivePaystackWebhookRequest,
    _$ReceivePaystackWebhookRequest
  ];
>>>>>>> origin/main

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
<<<<<<< HEAD
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
=======
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
>>>>>>> origin/main
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ReceivePaystackWebhookRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
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
<<<<<<< HEAD
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
=======
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
>>>>>>> origin/main
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
