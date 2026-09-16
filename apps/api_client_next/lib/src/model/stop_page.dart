//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/stop.dart';
import 'package:trotxi_api_client_next/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stop_page.g.dart';

/// StopPage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class StopPage implements Built<StopPage, StopPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Stop> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  StopPage._();

  factory StopPage([void updates(StopPageBuilder b)]) = _$StopPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StopPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StopPage> get serializer => _$StopPageSerializer();
}

class _$StopPageSerializer implements PrimitiveSerializer<StopPage> {
  @override
  final Iterable<Type> types = const [StopPage, _$StopPage];

  @override
  final String wireName = r'StopPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StopPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Stop)]),
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
    StopPage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StopPageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Stop)]),
          ) as BuiltList<Stop>;
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
  StopPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StopPageBuilder();
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

