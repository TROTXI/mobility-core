//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_users_id_role_patch200_response.g.dart';

/// AdminUsersIdRolePatch200Response
///
/// Properties:
/// * [id] 
/// * [displayName] 
/// * [phone] 
/// * [role] 
/// * [createdAt] 
@BuiltValue()
abstract class AdminUsersIdRolePatch200Response implements Built<AdminUsersIdRolePatch200Response, AdminUsersIdRolePatch200ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'role')
  AdminUsersIdRolePatch200ResponseRoleEnum get role;
  // enum roleEnum {  commuter,  driver,  admin,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  AdminUsersIdRolePatch200Response._();

  factory AdminUsersIdRolePatch200Response([void updates(AdminUsersIdRolePatch200ResponseBuilder b)]) = _$AdminUsersIdRolePatch200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminUsersIdRolePatch200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminUsersIdRolePatch200Response> get serializer => _$AdminUsersIdRolePatch200ResponseSerializer();
}

class _$AdminUsersIdRolePatch200ResponseSerializer implements PrimitiveSerializer<AdminUsersIdRolePatch200Response> {
  @override
  final Iterable<Type> types = const [AdminUsersIdRolePatch200Response, _$AdminUsersIdRolePatch200Response];

  @override
  final String wireName = r'AdminUsersIdRolePatch200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminUsersIdRolePatch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'displayName';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield object.phone == null ? null : serializers.serialize(
      object.phone,
      specifiedType: const FullType.nullable(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(AdminUsersIdRolePatch200ResponseRoleEnum),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminUsersIdRolePatch200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminUsersIdRolePatch200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminUsersIdRolePatch200ResponseRoleEnum),
          ) as AdminUsersIdRolePatch200ResponseRoleEnum;
          result.role = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminUsersIdRolePatch200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminUsersIdRolePatch200ResponseBuilder();
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

class AdminUsersIdRolePatch200ResponseRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const AdminUsersIdRolePatch200ResponseRoleEnum commuter = _$adminUsersIdRolePatch200ResponseRoleEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const AdminUsersIdRolePatch200ResponseRoleEnum driver = _$adminUsersIdRolePatch200ResponseRoleEnum_driver;
  @BuiltValueEnumConst(wireName: r'admin')
  static const AdminUsersIdRolePatch200ResponseRoleEnum admin = _$adminUsersIdRolePatch200ResponseRoleEnum_admin;

  static Serializer<AdminUsersIdRolePatch200ResponseRoleEnum> get serializer => _$adminUsersIdRolePatch200ResponseRoleEnumSerializer;

  const AdminUsersIdRolePatch200ResponseRoleEnum._(String name): super(name);

  static BuiltSet<AdminUsersIdRolePatch200ResponseRoleEnum> get values => _$adminUsersIdRolePatch200ResponseRoleEnumValues;
  static AdminUsersIdRolePatch200ResponseRoleEnum valueOf(String name) => _$adminUsersIdRolePatch200ResponseRoleEnumValueOf(name);
}

