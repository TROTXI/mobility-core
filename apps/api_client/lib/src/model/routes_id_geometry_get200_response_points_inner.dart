//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'routes_id_geometry_get200_response_points_inner.g.dart';

/// RoutesIdGeometryGet200ResponsePointsInner
///
/// Properties:
/// * [latitude] 
/// * [longitude] 
@BuiltValue()
abstract class RoutesIdGeometryGet200ResponsePointsInner implements Built<RoutesIdGeometryGet200ResponsePointsInner, RoutesIdGeometryGet200ResponsePointsInnerBuilder> {
  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  RoutesIdGeometryGet200ResponsePointsInner._();

  factory RoutesIdGeometryGet200ResponsePointsInner([void updates(RoutesIdGeometryGet200ResponsePointsInnerBuilder b)]) = _$RoutesIdGeometryGet200ResponsePointsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RoutesIdGeometryGet200ResponsePointsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RoutesIdGeometryGet200ResponsePointsInner> get serializer => _$RoutesIdGeometryGet200ResponsePointsInnerSerializer();
}

class _$RoutesIdGeometryGet200ResponsePointsInnerSerializer implements PrimitiveSerializer<RoutesIdGeometryGet200ResponsePointsInner> {
  @override
  final Iterable<Type> types = const [RoutesIdGeometryGet200ResponsePointsInner, _$RoutesIdGeometryGet200ResponsePointsInner];

  @override
  final String wireName = r'RoutesIdGeometryGet200ResponsePointsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RoutesIdGeometryGet200ResponsePointsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RoutesIdGeometryGet200ResponsePointsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RoutesIdGeometryGet200ResponsePointsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RoutesIdGeometryGet200ResponsePointsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RoutesIdGeometryGet200ResponsePointsInnerBuilder();
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


