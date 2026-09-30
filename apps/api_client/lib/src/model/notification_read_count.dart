//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_read_count.g.dart';

/// NotificationReadCount
///
/// Properties:
/// * [readCount]
@BuiltValue()
abstract class NotificationReadCount
    implements Built<NotificationReadCount, NotificationReadCountBuilder> {
  @BuiltValueField(wireName: r'readCount')
  int get readCount;

  NotificationReadCount._();

  factory NotificationReadCount(
      [void updates(NotificationReadCountBuilder b)]) = _$NotificationReadCount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationReadCountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationReadCount> get serializer =>
      _$NotificationReadCountSerializer();
}

class _$NotificationReadCountSerializer
    implements PrimitiveSerializer<NotificationReadCount> {
  @override
  final Iterable<Type> types = const [
    NotificationReadCount,
    _$NotificationReadCount
  ];

  @override
  final String wireName = r'NotificationReadCount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationReadCount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'readCount';
    yield serializers.serialize(
      object.readCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationReadCount object, {
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
    required NotificationReadCountBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'readCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.readCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationReadCount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationReadCountBuilder();
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
