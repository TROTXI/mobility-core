//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/notification_read_count.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_read_count_response.g.dart';

/// NotificationReadCountResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class NotificationReadCountResponse
    implements
        Built<NotificationReadCountResponse,
            NotificationReadCountResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  NotificationReadCount get data;

  NotificationReadCountResponse._();

  factory NotificationReadCountResponse(
          [void updates(NotificationReadCountResponseBuilder b)]) =
      _$NotificationReadCountResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationReadCountResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationReadCountResponse> get serializer =>
      _$NotificationReadCountResponseSerializer();
}

class _$NotificationReadCountResponseSerializer
    implements PrimitiveSerializer<NotificationReadCountResponse> {
  @override
  final Iterable<Type> types = const [
    NotificationReadCountResponse,
    _$NotificationReadCountResponse
  ];

  @override
  final String wireName = r'NotificationReadCountResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationReadCountResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(NotificationReadCount),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationReadCountResponse object, {
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
    required NotificationReadCountResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationReadCount),
          ) as NotificationReadCount;
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
  NotificationReadCountResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationReadCountResponseBuilder();
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
