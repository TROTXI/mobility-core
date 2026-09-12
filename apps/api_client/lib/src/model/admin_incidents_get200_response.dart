//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:trotxi_api_client/src/model/admin_incidents_get200_response_incidents_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_incidents_get200_response.g.dart';

/// AdminIncidentsGet200Response
///
/// Properties:
/// * [incidents] 
@BuiltValue()
abstract class AdminIncidentsGet200Response implements Built<AdminIncidentsGet200Response, AdminIncidentsGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'incidents')
  BuiltList<AdminIncidentsGet200ResponseIncidentsInner> get incidents;

  AdminIncidentsGet200Response._();

  factory AdminIncidentsGet200Response([void updates(AdminIncidentsGet200ResponseBuilder b)]) = _$AdminIncidentsGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminIncidentsGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminIncidentsGet200Response> get serializer => _$AdminIncidentsGet200ResponseSerializer();
}

class _$AdminIncidentsGet200ResponseSerializer implements PrimitiveSerializer<AdminIncidentsGet200Response> {
  @override
  final Iterable<Type> types = const [AdminIncidentsGet200Response, _$AdminIncidentsGet200Response];

  @override
  final String wireName = r'AdminIncidentsGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminIncidentsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'incidents';
    yield serializers.serialize(
      object.incidents,
      specifiedType: const FullType(BuiltList, [FullType(AdminIncidentsGet200ResponseIncidentsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminIncidentsGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminIncidentsGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'incidents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdminIncidentsGet200ResponseIncidentsInner)]),
          ) as BuiltList<AdminIncidentsGet200ResponseIncidentsInner>;
          result.incidents.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminIncidentsGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminIncidentsGet200ResponseBuilder();
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

