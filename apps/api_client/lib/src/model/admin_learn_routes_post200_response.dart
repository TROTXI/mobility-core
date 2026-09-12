//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/admin_learn_routes_post200_response_routes_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_learn_routes_post200_response.g.dart';

/// AdminLearnRoutesPost200Response
///
/// Properties:
/// * [routes] 
@BuiltValue()
abstract class AdminLearnRoutesPost200Response implements Built<AdminLearnRoutesPost200Response, AdminLearnRoutesPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'routes')
  BuiltList<AdminLearnRoutesPost200ResponseRoutesInner> get routes;

  AdminLearnRoutesPost200Response._();

  factory AdminLearnRoutesPost200Response([void updates(AdminLearnRoutesPost200ResponseBuilder b)]) = _$AdminLearnRoutesPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLearnRoutesPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLearnRoutesPost200Response> get serializer => _$AdminLearnRoutesPost200ResponseSerializer();
}

class _$AdminLearnRoutesPost200ResponseSerializer implements PrimitiveSerializer<AdminLearnRoutesPost200Response> {
  @override
  final Iterable<Type> types = const [AdminLearnRoutesPost200Response, _$AdminLearnRoutesPost200Response];

  @override
  final String wireName = r'AdminLearnRoutesPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLearnRoutesPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routes';
    yield serializers.serialize(
      object.routes,
      specifiedType: const FullType(BuiltList, [FullType(AdminLearnRoutesPost200ResponseRoutesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLearnRoutesPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLearnRoutesPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminLearnRoutesPost200ResponseRoutesInner)]),
          ) as BuiltList<AdminLearnRoutesPost200ResponseRoutesInner>;
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
  AdminLearnRoutesPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLearnRoutesPost200ResponseBuilder();
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

