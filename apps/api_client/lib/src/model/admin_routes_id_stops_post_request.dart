//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_routes_id_stops_post_request.g.dart';

/// AdminRoutesIdStopsPostRequest
///
/// Properties:
/// * [stopId] 
/// * [seq] 
@BuiltValue()
abstract class AdminRoutesIdStopsPostRequest implements Built<AdminRoutesIdStopsPostRequest, AdminRoutesIdStopsPostRequestBuilder> {
  @BuiltValueField(wireName: r'stopId')
  String get stopId;

  @BuiltValueField(wireName: r'seq')
  int get seq;

  AdminRoutesIdStopsPostRequest._();

  factory AdminRoutesIdStopsPostRequest([void updates(AdminRoutesIdStopsPostRequestBuilder b)]) = _$AdminRoutesIdStopsPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRoutesIdStopsPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRoutesIdStopsPostRequest> get serializer => _$AdminRoutesIdStopsPostRequestSerializer();
}

class _$AdminRoutesIdStopsPostRequestSerializer implements PrimitiveSerializer<AdminRoutesIdStopsPostRequest> {
  @override
  final Iterable<Type> types = const [AdminRoutesIdStopsPostRequest, _$AdminRoutesIdStopsPostRequest];

  @override
  final String wireName = r'AdminRoutesIdStopsPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRoutesIdStopsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stopId';
    yield serializers.serialize(
      object.stopId,
      specifiedType: const FullType(String),
    );
    yield r'seq';
    yield serializers.serialize(
      object.seq,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminRoutesIdStopsPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRoutesIdStopsPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stopId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stopId = valueDes;
          break;
        case r'seq':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.seq = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminRoutesIdStopsPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRoutesIdStopsPostRequestBuilder();
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

