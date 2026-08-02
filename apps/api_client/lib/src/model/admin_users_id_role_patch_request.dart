//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_users_id_role_patch_request.g.dart';

/// AdminUsersIdRolePatchRequest
///
/// Properties:
/// * [role] 
@BuiltValue()
abstract class AdminUsersIdRolePatchRequest implements Built<AdminUsersIdRolePatchRequest, AdminUsersIdRolePatchRequestBuilder> {
  @BuiltValueField(wireName: r'role')
  AdminUsersIdRolePatchRequestRoleEnum get role;
  // enum roleEnum {  commuter,  driver,  admin,  };

  AdminUsersIdRolePatchRequest._();

  factory AdminUsersIdRolePatchRequest([void updates(AdminUsersIdRolePatchRequestBuilder b)]) = _$AdminUsersIdRolePatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUsersIdRolePatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUsersIdRolePatchRequest> get serializer => _$AdminUsersIdRolePatchRequestSerializer();
}

class _$AdminUsersIdRolePatchRequestSerializer implements PrimitiveSerializer<AdminUsersIdRolePatchRequest> {
  @override
  final Iterable<Type> types = const [AdminUsersIdRolePatchRequest, _$AdminUsersIdRolePatchRequest];

  @override
  final String wireName = r'AdminUsersIdRolePatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUsersIdRolePatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(AdminUsersIdRolePatchRequestRoleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUsersIdRolePatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUsersIdRolePatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUsersIdRolePatchRequestRoleEnum),
          ) as AdminUsersIdRolePatchRequestRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUsersIdRolePatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUsersIdRolePatchRequestBuilder();
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

class AdminUsersIdRolePatchRequestRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const AdminUsersIdRolePatchRequestRoleEnum commuter = _$adminUsersIdRolePatchRequestRoleEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const AdminUsersIdRolePatchRequestRoleEnum driver = _$adminUsersIdRolePatchRequestRoleEnum_driver;
  @BuiltValueEnumConst(wireName: r'admin')
  static const AdminUsersIdRolePatchRequestRoleEnum admin = _$adminUsersIdRolePatchRequestRoleEnum_admin;

  static Serializer<AdminUsersIdRolePatchRequestRoleEnum> get serializer => _$adminUsersIdRolePatchRequestRoleEnumSerializer;

  const AdminUsersIdRolePatchRequestRoleEnum._(String name): super(name);

  static BuiltSet<AdminUsersIdRolePatchRequestRoleEnum> get values => _$adminUsersIdRolePatchRequestRoleEnumValues;
  static AdminUsersIdRolePatchRequestRoleEnum valueOf(String name) => _$adminUsersIdRolePatchRequestRoleEnumValueOf(name);
}

