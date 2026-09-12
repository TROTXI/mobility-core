//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/routes_id_geometry_get200_response_points_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'routes_id_geometry_get200_response.g.dart';

/// RoutesIdGeometryGet200Response
///
/// Properties:
/// * [routeId] 
/// * [points] 
/// * [source_] 
/// * [runCount] 
@BuiltValue()
abstract class RoutesIdGeometryGet200Response implements Built<RoutesIdGeometryGet200Response, RoutesIdGeometryGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String get routeId;

  @BuiltValueField(wireName: r'points')
  BuiltList<RoutesIdGeometryGet200ResponsePointsInner> get points;

  @BuiltValueField(wireName: r'source')
  RoutesIdGeometryGet200ResponseSource_Enum get source_;
  // enum source_Enum {  traces,  matched,  manual,  stops,  };

  @BuiltValueField(wireName: r'runCount')
  int get runCount;

  RoutesIdGeometryGet200Response._();

  factory RoutesIdGeometryGet200Response([void updates(RoutesIdGeometryGet200ResponseBuilder b)]) = _$RoutesIdGeometryGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RoutesIdGeometryGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RoutesIdGeometryGet200Response> get serializer => _$RoutesIdGeometryGet200ResponseSerializer();
}

class _$RoutesIdGeometryGet200ResponseSerializer implements PrimitiveSerializer<RoutesIdGeometryGet200Response> {
  @override
  final Iterable<Type> types = const [RoutesIdGeometryGet200Response, _$RoutesIdGeometryGet200Response];

  @override
  final String wireName = r'RoutesIdGeometryGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RoutesIdGeometryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routeId';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'points';
    yield serializers.serialize(
      object.points,
      specifiedType: const FullType(BuiltList, [FullType(RoutesIdGeometryGet200ResponsePointsInner)]),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(RoutesIdGeometryGet200ResponseSource_Enum),
    );
    yield r'runCount';
    yield serializers.serialize(
      object.runCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RoutesIdGeometryGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RoutesIdGeometryGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RoutesIdGeometryGet200ResponsePointsInner)]),
          ) as BuiltList<RoutesIdGeometryGet200ResponsePointsInner>;
          result.points.replace(valueDes);
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RoutesIdGeometryGet200ResponseSource_Enum),
          ) as RoutesIdGeometryGet200ResponseSource_Enum;
          result.source_ = valueDes;
          break;
        case r'runCount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.runCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RoutesIdGeometryGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RoutesIdGeometryGet200ResponseBuilder();
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

class RoutesIdGeometryGet200ResponseSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'traces')
  static const RoutesIdGeometryGet200ResponseSource_Enum traces = _$routesIdGeometryGet200ResponseSourceEnum_traces;
  @BuiltValueEnumConst(wireName: r'matched')
  static const RoutesIdGeometryGet200ResponseSource_Enum matched = _$routesIdGeometryGet200ResponseSourceEnum_matched;
  @BuiltValueEnumConst(wireName: r'manual')
  static const RoutesIdGeometryGet200ResponseSource_Enum manual = _$routesIdGeometryGet200ResponseSourceEnum_manual;
  @BuiltValueEnumConst(wireName: r'stops')
  static const RoutesIdGeometryGet200ResponseSource_Enum stops = _$routesIdGeometryGet200ResponseSourceEnum_stops;

  static Serializer<RoutesIdGeometryGet200ResponseSource_Enum> get serializer => _$routesIdGeometryGet200ResponseSourceEnumSerializer;

  const RoutesIdGeometryGet200ResponseSource_Enum._(String name): super(name);

  static BuiltSet<RoutesIdGeometryGet200ResponseSource_Enum> get values => _$routesIdGeometryGet200ResponseSourceEnumValues;
  static RoutesIdGeometryGet200ResponseSource_Enum valueOf(String name) => _$routesIdGeometryGet200ResponseSourceEnumValueOf(name);
}

