//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'role_edit.g.dart';

/// RoleEdit
///
/// Properties:
/// * [role] 
/// * [reason] 
@BuiltValue()
abstract class RoleEdit implements Built<RoleEdit, RoleEditBuilder> {
  @BuiltValueField(wireName: r'role')
  RoleEditRoleEnum get role;
  // enum roleEnum {  commuter,  driver,  admin,  };

  @BuiltValueField(wireName: r'reason')
  String get reason;

  RoleEdit._();

  factory RoleEdit([void updates(RoleEditBuilder b)]) = _$RoleEdit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RoleEditBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RoleEdit> get serializer => _$RoleEditSerializer();
}

class _$RoleEditSerializer implements PrimitiveSerializer<RoleEdit> {
  @override
  final Iterable<Type> types = const [RoleEdit, _$RoleEdit];

  @override
  final String wireName = r'RoleEdit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RoleEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(RoleEditRoleEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RoleEdit object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RoleEditBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RoleEditRoleEnum),
          ) as RoleEditRoleEnum;
          result.role = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RoleEdit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RoleEditBuilder();
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

class RoleEditRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const RoleEditRoleEnum commuter = _$roleEditRoleEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const RoleEditRoleEnum driver = _$roleEditRoleEnum_driver;
  @BuiltValueEnumConst(wireName: r'admin')
  static const RoleEditRoleEnum admin = _$roleEditRoleEnum_admin;

  static Serializer<RoleEditRoleEnum> get serializer => _$roleEditRoleEnumSerializer;

  const RoleEditRoleEnum._(String name): super(name);

  static BuiltSet<RoleEditRoleEnum> get values => _$roleEditRoleEnumValues;
  static RoleEditRoleEnum valueOf(String name) => _$roleEditRoleEnumValueOf(name);
}

