//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/route.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_page.g.dart';

/// RoutePage
///
/// Properties:
/// * [data] 
/// * [page] 
@BuiltValue()
abstract class RoutePage implements Built<RoutePage, RoutePageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<Route> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  RoutePage._();

  factory RoutePage([void updates(RoutePageBuilder b)]) = _$RoutePage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RoutePageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RoutePage> get serializer => _$RoutePageSerializer();
}

class _$RoutePageSerializer implements PrimitiveSerializer<RoutePage> {
  @override
  final Iterable<Type> types = const [RoutePage, _$RoutePage];

  @override
  final String wireName = r'RoutePage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RoutePage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(Route)]),
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
    RoutePage object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RoutePageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Route)]),
          ) as BuiltList<Route>;
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
  RoutePage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RoutePageBuilder();
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

