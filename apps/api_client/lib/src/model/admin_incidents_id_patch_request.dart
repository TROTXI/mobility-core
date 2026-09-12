//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_incidents_id_patch_request.g.dart';

/// AdminIncidentsIdPatchRequest
///
/// Properties:
/// * [status] 
/// * [resolution] 
@BuiltValue()
abstract class AdminIncidentsIdPatchRequest implements Built<AdminIncidentsIdPatchRequest, AdminIncidentsIdPatchRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  AdminIncidentsIdPatchRequestStatusEnum get status;
  // enum statusEnum {  acknowledged,  resolved,  };

  @BuiltValueField(wireName: r'resolution')
  String? get resolution;

  AdminIncidentsIdPatchRequest._();

  factory AdminIncidentsIdPatchRequest([void updates(AdminIncidentsIdPatchRequestBuilder b)]) = _$AdminIncidentsIdPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminIncidentsIdPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminIncidentsIdPatchRequest> get serializer => _$AdminIncidentsIdPatchRequestSerializer();
}

class _$AdminIncidentsIdPatchRequestSerializer implements PrimitiveSerializer<AdminIncidentsIdPatchRequest> {
  @override
  final Iterable<Type> types = const [AdminIncidentsIdPatchRequest, _$AdminIncidentsIdPatchRequest];

  @override
  final String wireName = r'AdminIncidentsIdPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminIncidentsIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminIncidentsIdPatchRequestStatusEnum),
    );
    if (object.resolution != null) {
      yield r'resolution';
      yield serializers.serialize(
        object.resolution,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminIncidentsIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminIncidentsIdPatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminIncidentsIdPatchRequestStatusEnum),
          ) as AdminIncidentsIdPatchRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'resolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resolution = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminIncidentsIdPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminIncidentsIdPatchRequestBuilder();
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

class AdminIncidentsIdPatchRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'acknowledged')
  static const AdminIncidentsIdPatchRequestStatusEnum acknowledged = _$adminIncidentsIdPatchRequestStatusEnum_acknowledged;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const AdminIncidentsIdPatchRequestStatusEnum resolved = _$adminIncidentsIdPatchRequestStatusEnum_resolved;

  static Serializer<AdminIncidentsIdPatchRequestStatusEnum> get serializer => _$adminIncidentsIdPatchRequestStatusEnumSerializer;

  const AdminIncidentsIdPatchRequestStatusEnum._(String name): super(name);

  static BuiltSet<AdminIncidentsIdPatchRequestStatusEnum> get values => _$adminIncidentsIdPatchRequestStatusEnumValues;
  static AdminIncidentsIdPatchRequestStatusEnum valueOf(String name) => _$adminIncidentsIdPatchRequestStatusEnumValueOf(name);
}

