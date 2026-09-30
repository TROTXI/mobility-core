//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_preferences_input.g.dart';

/// NotificationPreferencesInput
///
/// Properties:
/// * [dailyAskTime]
/// * [optionalUpdatesEnabled]
@BuiltValue()
abstract class NotificationPreferencesInput
    implements
        Built<NotificationPreferencesInput,
            NotificationPreferencesInputBuilder> {
  @BuiltValueField(wireName: r'dailyAskTime')
  String get dailyAskTime;

  @BuiltValueField(wireName: r'optionalUpdatesEnabled')
  bool get optionalUpdatesEnabled;

  NotificationPreferencesInput._();

  factory NotificationPreferencesInput(
          [void updates(NotificationPreferencesInputBuilder b)]) =
      _$NotificationPreferencesInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPreferencesInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPreferencesInput> get serializer =>
      _$NotificationPreferencesInputSerializer();
}

class _$NotificationPreferencesInputSerializer
    implements PrimitiveSerializer<NotificationPreferencesInput> {
  @override
  final Iterable<Type> types = const [
    NotificationPreferencesInput,
    _$NotificationPreferencesInput
  ];

  @override
  final String wireName = r'NotificationPreferencesInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPreferencesInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'dailyAskTime';
    yield serializers.serialize(
      object.dailyAskTime,
      specifiedType: const FullType(String),
    );
    yield r'optionalUpdatesEnabled';
    yield serializers.serialize(
      object.optionalUpdatesEnabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPreferencesInput object, {
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
    required NotificationPreferencesInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dailyAskTime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dailyAskTime = valueDes;
          break;
        case r'optionalUpdatesEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.optionalUpdatesEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationPreferencesInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPreferencesInputBuilder();
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
