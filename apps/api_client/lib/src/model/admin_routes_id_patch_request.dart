//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_routes_id_patch_request.g.dart';

/// AdminRoutesIdPatchRequest
///
/// Properties:
/// * [name] 
/// * [description] 
@BuiltValue()
abstract class AdminRoutesIdPatchRequest implements Built<AdminRoutesIdPatchRequest, AdminRoutesIdPatchRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  AdminRoutesIdPatchRequest._();

  factory AdminRoutesIdPatchRequest([void updates(AdminRoutesIdPatchRequestBuilder b)]) = _$AdminRoutesIdPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminRoutesIdPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminRoutesIdPatchRequest> get serializer => _$AdminRoutesIdPatchRequestSerializer();
}

class _$AdminRoutesIdPatchRequestSerializer implements PrimitiveSerializer<AdminRoutesIdPatchRequest> {
  @override
  final Iterable<Type> types = const [AdminRoutesIdPatchRequest, _$AdminRoutesIdPatchRequest];

  @override
  final String wireName = r'AdminRoutesIdPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminRoutesIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminRoutesIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminRoutesIdPatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminRoutesIdPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminRoutesIdPatchRequestBuilder();
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

