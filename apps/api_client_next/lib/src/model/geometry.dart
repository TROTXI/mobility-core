//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/geometry_stop_distances_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client_next/src/model/point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geometry.g.dart';

/// Geometry
///
/// Properties:
/// * [id] 
/// * [patternVersionId] 
/// * [points] 
/// * [stopDistances] 
/// * [source_] 
/// * [createdAt] 
@BuiltValue()
abstract class Geometry implements Built<Geometry, GeometryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'patternVersionId')
  String get patternVersionId;

  @BuiltValueField(wireName: r'points')
  BuiltList<Point> get points;

  @BuiltValueField(wireName: r'stopDistances')
  BuiltList<GeometryStopDistancesInner> get stopDistances;

  @BuiltValueField(wireName: r'source')
  GeometrySource_Enum get source_;
  // enum source_Enum {  observed,  configured,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  Geometry._();

  factory Geometry([void updates(GeometryBuilder b)]) = _$Geometry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeometryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Geometry> get serializer => _$GeometrySerializer();
}

class _$GeometrySerializer implements PrimitiveSerializer<Geometry> {
  @override
  final Iterable<Type> types = const [Geometry, _$Geometry];

  @override
  final String wireName = r'Geometry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Geometry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'patternVersionId';
    yield serializers.serialize(
      object.patternVersionId,
      specifiedType: const FullType(String),
    );
    yield r'points';
    yield serializers.serialize(
      object.points,
      specifiedType: const FullType(BuiltList, [FullType(Point)]),
    );
    yield r'stopDistances';
    yield serializers.serialize(
      object.stopDistances,
      specifiedType: const FullType(BuiltList, [FullType(GeometryStopDistancesInner)]),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(GeometrySource_Enum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Geometry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeometryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'patternVersionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.patternVersionId = valueDes;
          break;
        case r'points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Point)]),
          ) as BuiltList<Point>;
          result.points.replace(valueDes);
          break;
        case r'stopDistances':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(GeometryStopDistancesInner)]),
          ) as BuiltList<GeometryStopDistancesInner>;
          result.stopDistances.replace(valueDes);
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GeometrySource_Enum),
          ) as GeometrySource_Enum;
          result.source_ = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Geometry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeometryBuilder();
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

class GeometrySource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'observed')
  static const GeometrySource_Enum observed = _$geometrySourceEnum_observed;
  @BuiltValueEnumConst(wireName: r'configured')
  static const GeometrySource_Enum configured = _$geometrySourceEnum_configured;

  static Serializer<GeometrySource_Enum> get serializer => _$geometrySourceEnumSerializer;

  const GeometrySource_Enum._(String name): super(name);

  static BuiltSet<GeometrySource_Enum> get values => _$geometrySourceEnumValues;
  static GeometrySource_Enum valueOf(String name) => _$geometrySourceEnumValueOf(name);
}

