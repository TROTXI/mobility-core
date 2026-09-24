// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RoleEditRoleEnum _$roleEditRoleEnum_commuter =
    const RoleEditRoleEnum._('commuter');
const RoleEditRoleEnum _$roleEditRoleEnum_driver =
    const RoleEditRoleEnum._('driver');
const RoleEditRoleEnum _$roleEditRoleEnum_admin =
    const RoleEditRoleEnum._('admin');

RoleEditRoleEnum _$roleEditRoleEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$roleEditRoleEnum_commuter;
    case 'driver':
      return _$roleEditRoleEnum_driver;
    case 'admin':
      return _$roleEditRoleEnum_admin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RoleEditRoleEnum> _$roleEditRoleEnumValues =
    BuiltSet<RoleEditRoleEnum>(const <RoleEditRoleEnum>[
  _$roleEditRoleEnum_commuter,
  _$roleEditRoleEnum_driver,
  _$roleEditRoleEnum_admin,
]);

Serializer<RoleEditRoleEnum> _$roleEditRoleEnumSerializer =
    _$RoleEditRoleEnumSerializer();

class _$RoleEditRoleEnumSerializer
    implements PrimitiveSerializer<RoleEditRoleEnum> {
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
  final Iterable<Type> types = const <Type>[RoleEditRoleEnum];
  @override
  final String wireName = 'RoleEditRoleEnum';

  @override
  Object serialize(Serializers serializers, RoleEditRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RoleEditRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RoleEditRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RoleEdit extends RoleEdit {
  @override
  final RoleEditRoleEnum role;
  @override
  final String reason;

  factory _$RoleEdit([void Function(RoleEditBuilder)? updates]) =>
      (RoleEditBuilder()..update(updates))._build();

  _$RoleEdit._({required this.role, required this.reason}) : super._();
  @override
  RoleEdit rebuild(void Function(RoleEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoleEditBuilder toBuilder() => RoleEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoleEdit && role == other.role && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RoleEdit')
          ..add('role', role)
          ..add('reason', reason))
        .toString();
  }
}

class RoleEditBuilder implements Builder<RoleEdit, RoleEditBuilder> {
  _$RoleEdit? _$v;

  RoleEditRoleEnum? _role;
  RoleEditRoleEnum? get role => _$this._role;
  set role(RoleEditRoleEnum? role) => _$this._role = role;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RoleEditBuilder() {
    RoleEdit._defaults(this);
  }

  RoleEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _role = $v.role;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoleEdit other) {
    _$v = other as _$RoleEdit;
  }

  @override
  void update(void Function(RoleEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RoleEdit build() => _build();

  _$RoleEdit _build() {
    final _$result = _$v ??
        _$RoleEdit._(
          role:
              BuiltValueNullFieldError.checkNotNull(role, r'RoleEdit', 'role'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'RoleEdit', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
