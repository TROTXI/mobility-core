//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/commute_request_page_page.dart';
import 'package:trotxi_api_client/src/model/standby_application.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/standby_application_page_route_demand_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standby_application_page.g.dart';

/// StandbyApplicationPage
///
/// Properties:
/// * [data]
/// * [page]
/// * [routeDemand]
@BuiltValue()
abstract class StandbyApplicationPage
    implements Built<StandbyApplicationPage, StandbyApplicationPageBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<StandbyApplication> get data;

  @BuiltValueField(wireName: r'page')
  CommuteRequestPagePage get page;

  @BuiltValueField(wireName: r'routeDemand')
  BuiltList<StandbyApplicationPageRouteDemandInner>? get routeDemand;

  StandbyApplicationPage._();

  factory StandbyApplicationPage(
          [void updates(StandbyApplicationPageBuilder b)]) =
      _$StandbyApplicationPage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandbyApplicationPageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandbyApplicationPage> get serializer =>
      _$StandbyApplicationPageSerializer();
}

class _$StandbyApplicationPageSerializer
    implements PrimitiveSerializer<StandbyApplicationPage> {
  @override
  final Iterable<Type> types = const [
    StandbyApplicationPage,
    _$StandbyApplicationPage
  ];

  @override
  final String wireName = r'StandbyApplicationPage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandbyApplicationPage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(StandbyApplication)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(CommuteRequestPagePage),
    );
    if (object.routeDemand != null) {
      yield r'routeDemand';
      yield serializers.serialize(
        object.routeDemand,
        specifiedType: const FullType(
            BuiltList, [FullType(StandbyApplicationPageRouteDemandInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StandbyApplicationPage object, {
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
    required StandbyApplicationPageBuilder result,
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
                const FullType(BuiltList, [FullType(StandbyApplication)]),
          ) as BuiltList<StandbyApplication>;
          result.data.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CommuteRequestPagePage),
          ) as CommuteRequestPagePage;
          result.page.replace(valueDes);
          break;
        case r'routeDemand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(StandbyApplicationPageRouteDemandInner)]),
          ) as BuiltList<StandbyApplicationPageRouteDemandInner>;
          result.routeDemand.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandbyApplicationPage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandbyApplicationPageBuilder();
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
