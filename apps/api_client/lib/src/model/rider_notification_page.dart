//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:trotxi_api_client/src/model/rider_notification.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rider_notification_page.g.dart';

/// RiderNotificationPage
///
/// Properties:
/// * [data]
/// * [page]
@BuiltValue()
abstract class RiderNotificationPage
    implements Built<RiderNotificationPage, RiderNotificationPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<RiderNotification> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  RiderNotificationPage._();

  factory RiderNotificationPage(
      [void updates(RiderNotificationPageBuilder b)]) = _$RiderNotificationPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RiderNotificationPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RiderNotificationPage> get serializer =>
      _$RiderNotificationPageSerializer();
}

class _$RiderNotificationPageSerializer
    implements PrimitiveSerializer<RiderNotificationPage> {
  @override
  final Iterable<Type> types = const [
    RiderNotificationPage,
    _$RiderNotificationPage
  ];

  @override
  final String wireName = r'RiderNotificationPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RiderNotificationPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(RiderNotification)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(CommuteRequestPagePage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RiderNotificationPage object, {
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
    required RiderNotificationPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(RiderNotification)]),
          ) as BuiltList<RiderNotification>;
          result.data.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteRequestPagePage),
          ) as CommuteRequestPagePage;
          result.page.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RiderNotificationPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RiderNotificationPageBuilder();
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
