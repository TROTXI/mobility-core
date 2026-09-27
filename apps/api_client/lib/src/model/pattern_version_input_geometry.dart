//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/point.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pattern_version_input_geometry.g.dart';

/// PatternVersionInputGeometry
///
/// Properties:
/// * [points] 
/// * [stopDistancesMeters] 
@BuiltValue()
abstract class PatternVersionInputGeometry implements Built<PatternVersionInputGeometry, PatternVersionInputGeometryBuilder> {
  @BuiltValueField(wireName: r'points')
  BuiltList<Point> get points;

  @BuiltValueField(wireName: r'stopDistancesMeters')
  BuiltList<num> get stopDistancesMeters;

  PatternVersionInputGeometry._();

  factory PatternVersionInputGeometry([void updates(PatternVersionInputGeometryBuilder b)]) = _$PatternVersionInputGeometry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatternVersionInputGeometryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatternVersionInputGeometry> get serializer => _$PatternVersionInputGeometrySerializer();
}

class _$PatternVersionInputGeometrySerializer implements PrimitiveSerializer<PatternVersionInputGeometry> {
  @override
  final Iterable<Type> types = const [PatternVersionInputGeometry, _$PatternVersionInputGeometry];

  @override
  final String wireName = r'PatternVersionInputGeometry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatternVersionInputGeometry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'points';
    yield serializers.serialize(
      object.points,
      specifiedType: const FullType(BuiltList, [FullType(Point)]),
    );
    yield r'stopDistancesMeters';
    yield serializers.serialize(
      object.stopDistancesMeters,
      specifiedType: const FullType(BuiltList, [FullType(num)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatternVersionInputGeometry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatternVersionInputGeometryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Point)]),
          ) as BuiltList<Point>;
          result.points.replace(valueDes);
          break;
        case r'stopDistancesMeters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(num)]),
          ) as BuiltList<num>;
          result.stopDistancesMeters.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatternVersionInputGeometry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatternVersionInputGeometryBuilder();
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

