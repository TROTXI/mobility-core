// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_users_id_role_patch200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUsersIdRolePatch200ResponseRoleEnum
    _$adminUsersIdRolePatch200ResponseRoleEnum_commuter =
    const AdminUsersIdRolePatch200ResponseRoleEnum._('commuter');
const AdminUsersIdRolePatch200ResponseRoleEnum
    _$adminUsersIdRolePatch200ResponseRoleEnum_driver =
    const AdminUsersIdRolePatch200ResponseRoleEnum._('driver');
const AdminUsersIdRolePatch200ResponseRoleEnum
    _$adminUsersIdRolePatch200ResponseRoleEnum_admin =
    const AdminUsersIdRolePatch200ResponseRoleEnum._('admin');

AdminUsersIdRolePatch200ResponseRoleEnum
    _$adminUsersIdRolePatch200ResponseRoleEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$adminUsersIdRolePatch200ResponseRoleEnum_commuter;
    case 'driver':
      return _$adminUsersIdRolePatch200ResponseRoleEnum_driver;
    case 'admin':
      return _$adminUsersIdRolePatch200ResponseRoleEnum_admin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUsersIdRolePatch200ResponseRoleEnum>
    _$adminUsersIdRolePatch200ResponseRoleEnumValues = BuiltSet<
        AdminUsersIdRolePatch200ResponseRoleEnum>(const <AdminUsersIdRolePatch200ResponseRoleEnum>[
  _$adminUsersIdRolePatch200ResponseRoleEnum_commuter,
  _$adminUsersIdRolePatch200ResponseRoleEnum_driver,
  _$adminUsersIdRolePatch200ResponseRoleEnum_admin,
]);

Serializer<AdminUsersIdRolePatch200ResponseRoleEnum>
    _$adminUsersIdRolePatch200ResponseRoleEnumSerializer =
    _$AdminUsersIdRolePatch200ResponseRoleEnumSerializer();

class _$AdminUsersIdRolePatch200ResponseRoleEnumSerializer
    implements PrimitiveSerializer<AdminUsersIdRolePatch200ResponseRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'commuter': 'commuter',
    'driver': 'driver',
    'admin': 'admin',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'commuter': 'commuter',
    'driver': 'driver',
    'admin': 'admin',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminUsersIdRolePatch200ResponseRoleEnum
  ];
  @override
  final String wireName = 'AdminUsersIdRolePatch200ResponseRoleEnum';

  @override
  Object serialize(Serializers serializers,
          AdminUsersIdRolePatch200ResponseRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUsersIdRolePatch200ResponseRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUsersIdRolePatch200ResponseRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUsersIdRolePatch200Response
    extends AdminUsersIdRolePatch200Response {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? phone;
  @override
  final AdminUsersIdRolePatch200ResponseRoleEnum role;
  @override
  final DateTime createdAt;

  factory _$AdminUsersIdRolePatch200Response(
          [void Function(AdminUsersIdRolePatch200ResponseBuilder)? updates]) =>
      (AdminUsersIdRolePatch200ResponseBuilder()..update(updates))._build();

  _$AdminUsersIdRolePatch200Response._(
      {required this.id,
      required this.displayName,
      this.phone,
      required this.role,
      required this.createdAt})
      : super._();
  @override
  AdminUsersIdRolePatch200Response rebuild(
          void Function(AdminUsersIdRolePatch200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminUsersIdRolePatch200ResponseBuilder toBuilder() =>
      AdminUsersIdRolePatch200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUsersIdRolePatch200Response &&
        id == other.id &&
        displayName == other.displayName &&
        phone == other.phone &&
        role == other.role &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUsersIdRolePatch200Response')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('phone', phone)
          ..add('role', role)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminUsersIdRolePatch200ResponseBuilder
    implements
        Builder<AdminUsersIdRolePatch200Response,
            AdminUsersIdRolePatch200ResponseBuilder> {
  _$AdminUsersIdRolePatch200Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  AdminUsersIdRolePatch200ResponseRoleEnum? _role;
  AdminUsersIdRolePatch200ResponseRoleEnum? get role => _$this._role;
  set role(AdminUsersIdRolePatch200ResponseRoleEnum? role) =>
      _$this._role = role;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminUsersIdRolePatch200ResponseBuilder() {
    AdminUsersIdRolePatch200Response._defaults(this);
  }

  AdminUsersIdRolePatch200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _phone = $v.phone;
      _role = $v.role;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUsersIdRolePatch200Response other) {
    _$v = other as _$AdminUsersIdRolePatch200Response;
  }

  @override
  void update(void Function(AdminUsersIdRolePatch200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUsersIdRolePatch200Response build() => _build();

  _$AdminUsersIdRolePatch200Response _build() {
    final _$result = _$v ??
        _$AdminUsersIdRolePatch200Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminUsersIdRolePatch200Response', 'id'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'AdminUsersIdRolePatch200Response', 'displayName'),
          phone: phone,
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'AdminUsersIdRolePatch200Response', 'role'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminUsersIdRolePatch200Response', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
