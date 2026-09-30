//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_preferences.g.dart';

/// NotificationPreferences
///
/// Properties:
/// * [dailyAskTime]
/// * [optionalUpdatesEnabled]
/// * [updatedAt]
/// * [version]
@BuiltValue()
abstract class NotificationPreferences
    implements Built<NotificationPreferences, NotificationPreferencesBuilder> {
  @BuiltValueField(wireName: r'dailyAskTime')
  String get dailyAskTime;

  @BuiltValueField(wireName: r'optionalUpdatesEnabled')
  bool get optionalUpdatesEnabled;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'version')
  int get version;

  NotificationPreferences._();

  factory NotificationPreferences(
          [void updates(NotificationPreferencesBuilder b)]) =
      _$NotificationPreferences;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPreferencesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPreferences> get serializer =>
      _$NotificationPreferencesSerializer();
}

class _$NotificationPreferencesSerializer
    implements PrimitiveSerializer<NotificationPreferences> {
  @override
  final Iterable<Type> types = const [
    NotificationPreferences,
    _$NotificationPreferences
  ];

  @override
  final String wireName = r'NotificationPreferences';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPreferences object, {
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
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPreferences object, {
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
    required NotificationPreferencesBuilder result,
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
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationPreferences deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPreferencesBuilder();
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
