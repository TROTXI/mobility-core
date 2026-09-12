//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_driver_requests_id_patch_request.g.dart';

/// AdminDriverRequestsIdPatchRequest
///
/// Properties:
/// * [status] 
/// * [decisionNote] 
@BuiltValue()
abstract class AdminDriverRequestsIdPatchRequest implements Built<AdminDriverRequestsIdPatchRequest, AdminDriverRequestsIdPatchRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  AdminDriverRequestsIdPatchRequestStatusEnum get status;
  // enum statusEnum {  approved,  declined,  };

  @BuiltValueField(wireName: r'decisionNote')
  String? get decisionNote;

  AdminDriverRequestsIdPatchRequest._();

  factory AdminDriverRequestsIdPatchRequest([void updates(AdminDriverRequestsIdPatchRequestBuilder b)]) = _$AdminDriverRequestsIdPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDriverRequestsIdPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDriverRequestsIdPatchRequest> get serializer => _$AdminDriverRequestsIdPatchRequestSerializer();
}

class _$AdminDriverRequestsIdPatchRequestSerializer implements PrimitiveSerializer<AdminDriverRequestsIdPatchRequest> {
  @override
  final Iterable<Type> types = const [AdminDriverRequestsIdPatchRequest, _$AdminDriverRequestsIdPatchRequest];

  @override
  final String wireName = r'AdminDriverRequestsIdPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDriverRequestsIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdminDriverRequestsIdPatchRequestStatusEnum),
    );
    if (object.decisionNote != null) {
      yield r'decisionNote';
      yield serializers.serialize(
        object.decisionNote,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDriverRequestsIdPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDriverRequestsIdPatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDriverRequestsIdPatchRequestStatusEnum),
          ) as AdminDriverRequestsIdPatchRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'decisionNote':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.decisionNote = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDriverRequestsIdPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDriverRequestsIdPatchRequestBuilder();
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

class AdminDriverRequestsIdPatchRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'approved')
  static const AdminDriverRequestsIdPatchRequestStatusEnum approved = _$adminDriverRequestsIdPatchRequestStatusEnum_approved;
  @BuiltValueEnumConst(wireName: r'declined')
  static const AdminDriverRequestsIdPatchRequestStatusEnum declined = _$adminDriverRequestsIdPatchRequestStatusEnum_declined;

  static Serializer<AdminDriverRequestsIdPatchRequestStatusEnum> get serializer => _$adminDriverRequestsIdPatchRequestStatusEnumSerializer;

  const AdminDriverRequestsIdPatchRequestStatusEnum._(String name): super(name);

  static BuiltSet<AdminDriverRequestsIdPatchRequestStatusEnum> get values => _$adminDriverRequestsIdPatchRequestStatusEnumValues;
  static AdminDriverRequestsIdPatchRequestStatusEnum valueOf(String name) => _$adminDriverRequestsIdPatchRequestStatusEnumValueOf(name);
}

