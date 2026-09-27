//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/route.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_response.g.dart';

/// RouteResponse
///
/// Properties:
<<<<<<< HEAD
/// * [data] 
@BuiltValue()
abstract class RouteResponse implements Built<RouteResponse, RouteResponseBuilder> {
=======
/// * [data]
@BuiltValue()
abstract class RouteResponse
    implements Built<RouteResponse, RouteResponseBuilder> {
>>>>>>> origin/main
  @BuiltValueField(wireName: r'data')
  Route get data;

  RouteResponse._();

<<<<<<< HEAD
  factory RouteResponse([void updates(RouteResponseBuilder b)]) = _$RouteResponse;
=======
  factory RouteResponse([void updates(RouteResponseBuilder b)]) =
      _$RouteResponse;
>>>>>>> origin/main

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
<<<<<<< HEAD
  static Serializer<RouteResponse> get serializer => _$RouteResponseSerializer();
=======
  static Serializer<RouteResponse> get serializer =>
      _$RouteResponseSerializer();
>>>>>>> origin/main
}

class _$RouteResponseSerializer implements PrimitiveSerializer<RouteResponse> {
  @override
  final Iterable<Type> types = const [RouteResponse, _$RouteResponse];

  @override
  final String wireName = r'RouteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(Route),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
<<<<<<< HEAD
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
=======
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
>>>>>>> origin/main
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Route),
          ) as Route;
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
  RouteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteResponseBuilder();
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
<<<<<<< HEAD

=======
>>>>>>> origin/main
