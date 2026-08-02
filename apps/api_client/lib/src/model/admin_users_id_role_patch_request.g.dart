// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_users_id_role_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUsersIdRolePatchRequestRoleEnum
    _$adminUsersIdRolePatchRequestRoleEnum_commuter =
    const AdminUsersIdRolePatchRequestRoleEnum._('commuter');
const AdminUsersIdRolePatchRequestRoleEnum
    _$adminUsersIdRolePatchRequestRoleEnum_driver =
    const AdminUsersIdRolePatchRequestRoleEnum._('driver');
const AdminUsersIdRolePatchRequestRoleEnum
    _$adminUsersIdRolePatchRequestRoleEnum_admin =
    const AdminUsersIdRolePatchRequestRoleEnum._('admin');

AdminUsersIdRolePatchRequestRoleEnum
    _$adminUsersIdRolePatchRequestRoleEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$adminUsersIdRolePatchRequestRoleEnum_commuter;
    case 'driver':
      return _$adminUsersIdRolePatchRequestRoleEnum_driver;
    case 'admin':
      return _$adminUsersIdRolePatchRequestRoleEnum_admin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUsersIdRolePatchRequestRoleEnum>
    _$adminUsersIdRolePatchRequestRoleEnumValues = BuiltSet<
        AdminUsersIdRolePatchRequestRoleEnum>(const <AdminUsersIdRolePatchRequestRoleEnum>[
  _$adminUsersIdRolePatchRequestRoleEnum_commuter,
  _$adminUsersIdRolePatchRequestRoleEnum_driver,
  _$adminUsersIdRolePatchRequestRoleEnum_admin,
]);

Serializer<AdminUsersIdRolePatchRequestRoleEnum>
    _$adminUsersIdRolePatchRequestRoleEnumSerializer =
    _$AdminUsersIdRolePatchRequestRoleEnumSerializer();

class _$AdminUsersIdRolePatchRequestRoleEnumSerializer
    implements PrimitiveSerializer<AdminUsersIdRolePatchRequestRoleEnum> {
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
    AdminUsersIdRolePatchRequestRoleEnum
  ];
  @override
  final String wireName = 'AdminUsersIdRolePatchRequestRoleEnum';

  @override
  Object serialize(
          Serializers serializers, AdminUsersIdRolePatchRequestRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUsersIdRolePatchRequestRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUsersIdRolePatchRequestRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUsersIdRolePatchRequest extends AdminUsersIdRolePatchRequest {
  @override
  final AdminUsersIdRolePatchRequestRoleEnum role;

  factory _$AdminUsersIdRolePatchRequest(
          [void Function(AdminUsersIdRolePatchRequestBuilder)? updates]) =>
      (AdminUsersIdRolePatchRequestBuilder()..update(updates))._build();

  _$AdminUsersIdRolePatchRequest._({required this.role}) : super._();
  @override
  AdminUsersIdRolePatchRequest rebuild(
          void Function(AdminUsersIdRolePatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminUsersIdRolePatchRequestBuilder toBuilder() =>
      AdminUsersIdRolePatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUsersIdRolePatchRequest && role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUsersIdRolePatchRequest')
          ..add('role', role))
        .toString();
  }
}

class AdminUsersIdRolePatchRequestBuilder
    implements
        Builder<AdminUsersIdRolePatchRequest,
            AdminUsersIdRolePatchRequestBuilder> {
  _$AdminUsersIdRolePatchRequest? _$v;

  AdminUsersIdRolePatchRequestRoleEnum? _role;
  AdminUsersIdRolePatchRequestRoleEnum? get role => _$this._role;
  set role(AdminUsersIdRolePatchRequestRoleEnum? role) => _$this._role = role;

  AdminUsersIdRolePatchRequestBuilder() {
    AdminUsersIdRolePatchRequest._defaults(this);
  }

  AdminUsersIdRolePatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUsersIdRolePatchRequest other) {
    _$v = other as _$AdminUsersIdRolePatchRequest;
  }

  @override
  void update(void Function(AdminUsersIdRolePatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUsersIdRolePatchRequest build() => _build();

  _$AdminUsersIdRolePatchRequest _build() {
    final _$result = _$v ??
        _$AdminUsersIdRolePatchRequest._(
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'AdminUsersIdRolePatchRequest', 'role'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
