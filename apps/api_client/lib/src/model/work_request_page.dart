//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/work_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'work_request_page.g.dart';

/// WorkRequestPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class WorkRequestPage implements Built<WorkRequestPage, WorkRequestPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<WorkRequest> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  WorkRequestPage._();

  factory WorkRequestPage([void updates(WorkRequestPageBuilder b)]) = _$WorkRequestPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkRequestPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkRequestPage> get serializer => _$WorkRequestPageSerializer();
}

class _$WorkRequestPageSerializer implements PrimitiveSerializer<WorkRequestPage> {
  @override
  final Iterable<Type> types = const [WorkRequestPage, _$WorkRequestPage];

  @override
  final String wireName = r'WorkRequestPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(WorkRequest)]),
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
    WorkRequestPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkRequestPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(WorkRequest)]),
          ) as BuiltList<WorkRequest>;
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
  WorkRequestPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkRequestPageBuilder();
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

