//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_drivers_id_credentials_patch_request.g.dart';

/// AdminDriversIdCredentialsPatchRequest
///
/// Properties:
/// * [status] 
/// * [unlock] 
@BuiltValue()
abstract class AdminDriversIdCredentialsPatchRequest implements Built<AdminDriversIdCredentialsPatchRequest, AdminDriversIdCredentialsPatchRequestBuilder> {
  @BuiltValueField(wireName: r'status')
  AdminDriversIdCredentialsPatchRequestStatusEnum? get status;
  // enum statusEnum {  active,  suspended,  };

  @BuiltValueField(wireName: r'unlock')
  bool? get unlock;

  AdminDriversIdCredentialsPatchRequest._();

  factory AdminDriversIdCredentialsPatchRequest([void updates(AdminDriversIdCredentialsPatchRequestBuilder b)]) = _$AdminDriversIdCredentialsPatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminDriversIdCredentialsPatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminDriversIdCredentialsPatchRequest> get serializer => _$AdminDriversIdCredentialsPatchRequestSerializer();
}

class _$AdminDriversIdCredentialsPatchRequestSerializer implements PrimitiveSerializer<AdminDriversIdCredentialsPatchRequest> {
  @override
  final Iterable<Type> types = const [AdminDriversIdCredentialsPatchRequest, _$AdminDriversIdCredentialsPatchRequest];

  @override
  final String wireName = r'AdminDriversIdCredentialsPatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminDriversIdCredentialsPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(AdminDriversIdCredentialsPatchRequestStatusEnum),
      );
    }
    if (object.unlock != null) {
      yield r'unlock';
      yield serializers.serialize(
        object.unlock,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminDriversIdCredentialsPatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminDriversIdCredentialsPatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminDriversIdCredentialsPatchRequestStatusEnum),
          ) as AdminDriversIdCredentialsPatchRequestStatusEnum;
          result.status = valueDes;
          break;
        case r'unlock':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.unlock = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminDriversIdCredentialsPatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminDriversIdCredentialsPatchRequestBuilder();
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

class AdminDriversIdCredentialsPatchRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const AdminDriversIdCredentialsPatchRequestStatusEnum active = _$adminDriversIdCredentialsPatchRequestStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'suspended')
  static const AdminDriversIdCredentialsPatchRequestStatusEnum suspended = _$adminDriversIdCredentialsPatchRequestStatusEnum_suspended;

  static Serializer<AdminDriversIdCredentialsPatchRequestStatusEnum> get serializer => _$adminDriversIdCredentialsPatchRequestStatusEnumSerializer;

  const AdminDriversIdCredentialsPatchRequestStatusEnum._(String name): super(name);

  static BuiltSet<AdminDriversIdCredentialsPatchRequestStatusEnum> get values => _$adminDriversIdCredentialsPatchRequestStatusEnumValues;
  static AdminDriversIdCredentialsPatchRequestStatusEnum valueOf(String name) => _$adminDriversIdCredentialsPatchRequestStatusEnumValueOf(name);
}

