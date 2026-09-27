//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geometry_stop_distances_inner.g.dart';

/// GeometryStopDistancesInner
///
/// Properties:
/// * [stopOccurrenceId] 
/// * [distanceMeters] 
@BuiltValue()
abstract class GeometryStopDistancesInner implements Built<GeometryStopDistancesInner, GeometryStopDistancesInnerBuilder> {
  @BuiltValueField(wireName: r'stopOccurrenceId')
  String get stopOccurrenceId;

  @BuiltValueField(wireName: r'distanceMeters')
  num get distanceMeters;

  GeometryStopDistancesInner._();

  factory GeometryStopDistancesInner([void updates(GeometryStopDistancesInnerBuilder b)]) = _$GeometryStopDistancesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeometryStopDistancesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeometryStopDistancesInner> get serializer => _$GeometryStopDistancesInnerSerializer();
}

class _$GeometryStopDistancesInnerSerializer implements PrimitiveSerializer<GeometryStopDistancesInner> {
  @override
  final Iterable<Type> types = const [GeometryStopDistancesInner, _$GeometryStopDistancesInner];

  @override
  final String wireName = r'GeometryStopDistancesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeometryStopDistancesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stopOccurrenceId';
    yield serializers.serialize(
      object.stopOccurrenceId,
      specifiedType: const FullType(String),
    );
    yield r'distanceMeters';
    yield serializers.serialize(
      object.distanceMeters,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeometryStopDistancesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeometryStopDistancesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stopOccurrenceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stopOccurrenceId = valueDes;
          break;
        case r'distanceMeters':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceMeters = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GeometryStopDistancesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeometryStopDistancesInnerBuilder();
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

