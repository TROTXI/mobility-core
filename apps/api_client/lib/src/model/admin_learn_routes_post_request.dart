//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_learn_routes_post_request.g.dart';

/// AdminLearnRoutesPostRequest
///
/// Properties:
/// * [routeId] 
@BuiltValue()
abstract class AdminLearnRoutesPostRequest implements Built<AdminLearnRoutesPostRequest, AdminLearnRoutesPostRequestBuilder> {
  @BuiltValueField(wireName: r'routeId')
  String? get routeId;

  AdminLearnRoutesPostRequest._();

  factory AdminLearnRoutesPostRequest([void updates(AdminLearnRoutesPostRequestBuilder b)]) = _$AdminLearnRoutesPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLearnRoutesPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLearnRoutesPostRequest> get serializer => _$AdminLearnRoutesPostRequestSerializer();
}

class _$AdminLearnRoutesPostRequestSerializer implements PrimitiveSerializer<AdminLearnRoutesPostRequest> {
  @override
  final Iterable<Type> types = const [AdminLearnRoutesPostRequest, _$AdminLearnRoutesPostRequest];

  @override
  final String wireName = r'AdminLearnRoutesPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLearnRoutesPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.routeId != null) {
      yield r'routeId';
      yield serializers.serialize(
        object.routeId,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLearnRoutesPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLearnRoutesPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminLearnRoutesPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLearnRoutesPostRequestBuilder();
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

