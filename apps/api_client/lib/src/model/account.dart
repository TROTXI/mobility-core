//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'account.g.dart';

/// Account
///
/// Properties:
/// * [id] 
/// * [displayName] 
/// * [email] 
/// * [phone] 
/// * [avatarUrl] 
/// * [role] 
/// * [createdAt] 
@BuiltValue()
abstract class Account implements Built<Account, AccountBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'displayName')
  String get displayName;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'avatarUrl')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'role')
  AccountRoleEnum get role;
  // enum roleEnum {  commuter,  driver,  admin,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  Account._();

  factory Account([void updates(AccountBuilder b)]) = _$Account;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AccountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Account> get serializer => _$AccountSerializer();
}

class _$AccountSerializer implements PrimitiveSerializer<Account> {
  @override
  final Iterable<Type> types = const [Account, _$Account];

  @override
  final String wireName = r'Account';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Account object, {
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
    yield r'email';
    yield object.email == null ? null : serializers.serialize(
      object.email,
      specifiedType: const FullType.nullable(String),
    );
    yield r'phone';
    yield object.phone == null ? null : serializers.serialize(
      object.phone,
      specifiedType: const FullType.nullable(String),
    );
    yield r'avatarUrl';
    yield object.avatarUrl == null ? null : serializers.serialize(
      object.avatarUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(AccountRoleEnum),
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
    Account object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AccountBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'avatarUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AccountRoleEnum),
          ) as AccountRoleEnum;
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
  Account deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AccountBuilder();
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

class AccountRoleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'commuter')
  static const AccountRoleEnum commuter = _$accountRoleEnum_commuter;
  @BuiltValueEnumConst(wireName: r'driver')
  static const AccountRoleEnum driver = _$accountRoleEnum_driver;
  @BuiltValueEnumConst(wireName: r'admin')
  static const AccountRoleEnum admin = _$accountRoleEnum_admin;

  static Serializer<AccountRoleEnum> get serializer => _$accountRoleEnumSerializer;

  const AccountRoleEnum._(String name): super(name);

  static BuiltSet<AccountRoleEnum> get values => _$accountRoleEnumValues;
  static AccountRoleEnum valueOf(String name) => _$accountRoleEnumValueOf(name);
}

