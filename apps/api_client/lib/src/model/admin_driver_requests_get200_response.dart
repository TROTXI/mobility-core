//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/admin_driver_requests_get200_response_requests_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_driver_requests_get200_response.g.dart';

/// AdminDriverRequestsGet200Response
///
/// Properties:
/// * [requests] 
@BuiltValue()
abstract class AdminDriverRequestsGet200Response implements Built<AdminDriverRequestsGet200Response, AdminDriverRequestsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'requests')
  BuiltList<AdminDriverRequestsGet200ResponseRequestsInner> get requests;

  AdminDriverRequestsGet200Response._();

  factory AdminDriverRequestsGet200Response([void updates(AdminDriverRequestsGet200ResponseBuilder b)]) = _$AdminDriverRequestsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDriverRequestsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDriverRequestsGet200Response> get serializer => _$AdminDriverRequestsGet200ResponseSerializer();
}

class _$AdminDriverRequestsGet200ResponseSerializer implements PrimitiveSerializer<AdminDriverRequestsGet200Response> {
  @override
  final Iterable<Type> types = const [AdminDriverRequestsGet200Response, _$AdminDriverRequestsGet200Response];

  @override
  final String wireName = r'AdminDriverRequestsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDriverRequestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'requests';
    yield serializers.serialize(
      object.requests,
      specifiedType: const FullType(BuiltList, [FullType(AdminDriverRequestsGet200ResponseRequestsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDriverRequestsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDriverRequestsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'requests':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminDriverRequestsGet200ResponseRequestsInner)]),
          ) as BuiltList<AdminDriverRequestsGet200ResponseRequestsInner>;
          result.requests.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDriverRequestsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDriverRequestsGet200ResponseBuilder();
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

