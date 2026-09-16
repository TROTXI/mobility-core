//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client_next/src/model/route.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_response.g.dart';

/// RouteResponse
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class RouteResponse implements Built<RouteResponse, RouteResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  Route get data;

  RouteResponse._();

  factory RouteResponse([void updates(RouteResponseBuilder b)]) = _$RouteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteResponse> get serializer => _$RouteResponseSerializer();
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
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
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

