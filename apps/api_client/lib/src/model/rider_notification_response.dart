//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/rider_notification.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rider_notification_response.g.dart';

/// RiderNotificationResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class RiderNotificationResponse
    implements
        Built<RiderNotificationResponse, RiderNotificationResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  RiderNotification get data;

  RiderNotificationResponse._();

  factory RiderNotificationResponse(
          [void updates(RiderNotificationResponseBuilder b)]) =
      _$RiderNotificationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RiderNotificationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RiderNotificationResponse> get serializer =>
      _$RiderNotificationResponseSerializer();
}

class _$RiderNotificationResponseSerializer
    implements PrimitiveSerializer<RiderNotificationResponse> {
  @override
  final Iterable<Type> types = const [
    RiderNotificationResponse,
    _$RiderNotificationResponse
  ];

  @override
  final String wireName = r'RiderNotificationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RiderNotificationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(RiderNotification),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RiderNotificationResponse object, {
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
    required RiderNotificationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RiderNotification),
          ) as RiderNotification;
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
  RiderNotificationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RiderNotificationResponseBuilder();
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
