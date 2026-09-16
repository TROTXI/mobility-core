//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/schedule.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'schedule_page.g.dart';

/// SchedulePage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class SchedulePage implements Built<SchedulePage, SchedulePageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Schedule> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  SchedulePage._();

  factory SchedulePage([void updates(SchedulePageBuilder b)]) = _$SchedulePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SchedulePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SchedulePage> get serializer => _$SchedulePageSerializer();
}

class _$SchedulePageSerializer implements PrimitiveSerializer<SchedulePage> {
  @override
  final Iterable<Type> types = const [SchedulePage, _$SchedulePage];

  @override
  final String wireName = r'SchedulePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SchedulePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Schedule)]),
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
    SchedulePage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SchedulePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Schedule)]),
          ) as BuiltList<Schedule>;
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
  SchedulePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SchedulePageBuilder();
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

