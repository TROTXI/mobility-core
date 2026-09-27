//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/geometry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'geometry_response.g.dart';

/// GeometryResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class GeometryResponse implements Built<GeometryResponse, GeometryResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Geometry get data;

  GeometryResponse._();

  factory GeometryResponse([void updates(GeometryResponseBuilder b)]) = _$GeometryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GeometryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GeometryResponse> get serializer => _$GeometryResponseSerializer();
}

class _$GeometryResponseSerializer implements PrimitiveSerializer<GeometryResponse> {
  @override
  final Iterable<Type> types = const [GeometryResponse, _$GeometryResponse];

  @override
  final String wireName = r'GeometryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GeometryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Geometry),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GeometryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GeometryResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Geometry),
          ) as Geometry;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GeometryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GeometryResponseBuilder();
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

