// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AccountRoleEnum _$accountRoleEnum_commuter =
    const AccountRoleEnum._('commuter');
const AccountRoleEnum _$accountRoleEnum_driver =
    const AccountRoleEnum._('driver');
const AccountRoleEnum _$accountRoleEnum_admin =
    const AccountRoleEnum._('admin');

AccountRoleEnum _$accountRoleEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$accountRoleEnum_commuter;
    case 'driver':
      return _$accountRoleEnum_driver;
    case 'admin':
      return _$accountRoleEnum_admin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AccountRoleEnum> _$accountRoleEnumValues =
    BuiltSet<AccountRoleEnum>(const <AccountRoleEnum>[
  _$accountRoleEnum_commuter,
  _$accountRoleEnum_driver,
  _$accountRoleEnum_admin,
]);

Serializer<AccountRoleEnum> _$accountRoleEnumSerializer =
    _$AccountRoleEnumSerializer();

class _$AccountRoleEnumSerializer
    implements PrimitiveSerializer<AccountRoleEnum> {
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
  final Iterable<Type> types = const <Type>[AccountRoleEnum];
  @override
  final String wireName = 'AccountRoleEnum';

  @override
  Object serialize(Serializers serializers, AccountRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AccountRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AccountRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Account extends Account {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? phone;
  @override
  final String? avatarUrl;
  @override
  final AccountRoleEnum role;
  @override
  final DateTime createdAt;

  factory _$Account([void Function(AccountBuilder)? updates]) =>
      (AccountBuilder()..update(updates))._build();

  _$Account._(
      {required this.id,
      required this.displayName,
      this.phone,
      this.avatarUrl,
      required this.role,
      required this.createdAt})
      : super._();
  @override
  Account rebuild(void Function(AccountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AccountBuilder toBuilder() => AccountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Account &&
        id == other.id &&
        displayName == other.displayName &&
        phone == other.phone &&
        avatarUrl == other.avatarUrl &&
        role == other.role &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Account')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('phone', phone)
          ..add('avatarUrl', avatarUrl)
          ..add('role', role)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AccountBuilder implements Builder<Account, AccountBuilder> {
  _$Account? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  AccountRoleEnum? _role;
  AccountRoleEnum? get role => _$this._role;
  set role(AccountRoleEnum? role) => _$this._role = role;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AccountBuilder() {
    Account._defaults(this);
  }

  AccountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _phone = $v.phone;
      _avatarUrl = $v.avatarUrl;
      _role = $v.role;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Account other) {
    _$v = other as _$Account;
  }

  @override
  void update(void Function(AccountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Account build() => _build();

  _$Account _build() {
    final _$result = _$v ??
        _$Account._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Account', 'id'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'Account', 'displayName'),
          phone: phone,
          avatarUrl: avatarUrl,
          role: BuiltValueNullFieldError.checkNotNull(role, r'Account', 'role'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Account', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
