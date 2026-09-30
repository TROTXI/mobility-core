//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/notification_preferences.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_preferences_response.g.dart';

/// NotificationPreferencesResponse
///
/// Properties:
/// * [data]
@BuiltValue()
abstract class NotificationPreferencesResponse
    implements
        Built<NotificationPreferencesResponse,
            NotificationPreferencesResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  NotificationPreferences get data;

  NotificationPreferencesResponse._();

  factory NotificationPreferencesResponse(
          [void updates(NotificationPreferencesResponseBuilder b)]) =
      _$NotificationPreferencesResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPreferencesResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPreferencesResponse> get serializer =>
      _$NotificationPreferencesResponseSerializer();
}

class _$NotificationPreferencesResponseSerializer
    implements PrimitiveSerializer<NotificationPreferencesResponse> {
  @override
  final Iterable<Type> types = const [
    NotificationPreferencesResponse,
    _$NotificationPreferencesResponse
  ];

  @override
  final String wireName = r'NotificationPreferencesResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPreferencesResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(NotificationPreferences),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationPreferencesResponse object, {
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
    required NotificationPreferencesResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationPreferences),
          ) as NotificationPreferences;
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
  NotificationPreferencesResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPreferencesResponseBuilder();
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
