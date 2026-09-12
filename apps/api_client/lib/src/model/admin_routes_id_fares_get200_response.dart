//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/admin_routes_id_fares_get200_response_fares_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_routes_id_fares_get200_response.g.dart';

/// AdminRoutesIdFaresGet200Response
///
/// Properties:
/// * [fares] 
@BuiltValue()
abstract class AdminRoutesIdFaresGet200Response implements Built<AdminRoutesIdFaresGet200Response, AdminRoutesIdFaresGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'fares')
  BuiltList<AdminRoutesIdFaresGet200ResponseFaresInner> get fares;

  AdminRoutesIdFaresGet200Response._();

  factory AdminRoutesIdFaresGet200Response([void updates(AdminRoutesIdFaresGet200ResponseBuilder b)]) = _$AdminRoutesIdFaresGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRoutesIdFaresGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRoutesIdFaresGet200Response> get serializer => _$AdminRoutesIdFaresGet200ResponseSerializer();
}

class _$AdminRoutesIdFaresGet200ResponseSerializer implements PrimitiveSerializer<AdminRoutesIdFaresGet200Response> {
  @override
  final Iterable<Type> types = const [AdminRoutesIdFaresGet200Response, _$AdminRoutesIdFaresGet200Response];

  @override
  final String wireName = r'AdminRoutesIdFaresGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRoutesIdFaresGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fares';
    yield serializers.serialize(
      object.fares,
      specifiedType: const FullType(BuiltList, [FullType(AdminRoutesIdFaresGet200ResponseFaresInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminRoutesIdFaresGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRoutesIdFaresGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fares':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminRoutesIdFaresGet200ResponseFaresInner)]),
          ) as BuiltList<AdminRoutesIdFaresGet200ResponseFaresInner>;
          result.fares.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminRoutesIdFaresGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRoutesIdFaresGet200ResponseBuilder();
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

