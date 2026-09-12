//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:trotxi_api_client/src/model/me_work_routes_get200_response_routes_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_work_routes_get200_response.g.dart';

/// MeWorkRoutesGet200Response
///
/// Properties:
/// * [routes] 
@BuiltValue()
abstract class MeWorkRoutesGet200Response implements Built<MeWorkRoutesGet200Response, MeWorkRoutesGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'routes')
  BuiltList<MeWorkRoutesGet200ResponseRoutesInner> get routes;

  MeWorkRoutesGet200Response._();

  factory MeWorkRoutesGet200Response([void updates(MeWorkRoutesGet200ResponseBuilder b)]) = _$MeWorkRoutesGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeWorkRoutesGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeWorkRoutesGet200Response> get serializer => _$MeWorkRoutesGet200ResponseSerializer();
}

class _$MeWorkRoutesGet200ResponseSerializer implements PrimitiveSerializer<MeWorkRoutesGet200Response> {
  @override
  final Iterable<Type> types = const [MeWorkRoutesGet200Response, _$MeWorkRoutesGet200Response];

  @override
  final String wireName = r'MeWorkRoutesGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeWorkRoutesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routes';
    yield serializers.serialize(
      object.routes,
      specifiedType: const FullType(BuiltList, [FullType(MeWorkRoutesGet200ResponseRoutesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MeWorkRoutesGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeWorkRoutesGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MeWorkRoutesGet200ResponseRoutesInner)]),
          ) as BuiltList<MeWorkRoutesGet200ResponseRoutesInner>;
          result.routes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeWorkRoutesGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeWorkRoutesGet200ResponseBuilder();
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

