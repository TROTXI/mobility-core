// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MeGet200ResponseRoleEnum _$meGet200ResponseRoleEnum_commuter =
    const MeGet200ResponseRoleEnum._('commuter');
const MeGet200ResponseRoleEnum _$meGet200ResponseRoleEnum_driver =
    const MeGet200ResponseRoleEnum._('driver');
const MeGet200ResponseRoleEnum _$meGet200ResponseRoleEnum_admin =
    const MeGet200ResponseRoleEnum._('admin');

MeGet200ResponseRoleEnum _$meGet200ResponseRoleEnumValueOf(String name) {
  switch (name) {
    case 'commuter':
      return _$meGet200ResponseRoleEnum_commuter;
    case 'driver':
      return _$meGet200ResponseRoleEnum_driver;
    case 'admin':
      return _$meGet200ResponseRoleEnum_admin;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MeGet200ResponseRoleEnum> _$meGet200ResponseRoleEnumValues =
    BuiltSet<MeGet200ResponseRoleEnum>(const <MeGet200ResponseRoleEnum>[
  _$meGet200ResponseRoleEnum_commuter,
  _$meGet200ResponseRoleEnum_driver,
  _$meGet200ResponseRoleEnum_admin,
]);

Serializer<MeGet200ResponseRoleEnum> _$meGet200ResponseRoleEnumSerializer =
    _$MeGet200ResponseRoleEnumSerializer();

class _$MeGet200ResponseRoleEnumSerializer
    implements PrimitiveSerializer<MeGet200ResponseRoleEnum> {
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
  final Iterable<Type> types = const <Type>[MeGet200ResponseRoleEnum];
  @override
  final String wireName = 'MeGet200ResponseRoleEnum';

  @override
  Object serialize(Serializers serializers, MeGet200ResponseRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MeGet200ResponseRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MeGet200ResponseRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MeGet200Response extends MeGet200Response {
  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? phone;
  @override
  final String? avatarUrl;
  @override
  final MeGet200ResponseRoleEnum role;
  @override
  final DateTime createdAt;

  factory _$MeGet200Response(
          [void Function(MeGet200ResponseBuilder)? updates]) =>
      (MeGet200ResponseBuilder()..update(updates))._build();

  _$MeGet200Response._(
      {required this.id,
      required this.displayName,
      this.phone,
      this.avatarUrl,
      required this.role,
      required this.createdAt})
      : super._();
  @override
  MeGet200Response rebuild(void Function(MeGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeGet200ResponseBuilder toBuilder() =>
      MeGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeGet200Response &&
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
    return (newBuiltValueToStringHelper(r'MeGet200Response')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('phone', phone)
          ..add('avatarUrl', avatarUrl)
          ..add('role', role)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MeGet200ResponseBuilder
    implements Builder<MeGet200Response, MeGet200ResponseBuilder> {
  _$MeGet200Response? _$v;

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

  MeGet200ResponseRoleEnum? _role;
  MeGet200ResponseRoleEnum? get role => _$this._role;
  set role(MeGet200ResponseRoleEnum? role) => _$this._role = role;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  MeGet200ResponseBuilder() {
    MeGet200Response._defaults(this);
  }

  MeGet200ResponseBuilder get _$this {
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
  void replace(MeGet200Response other) {
    _$v = other as _$MeGet200Response;
  }

  @override
  void update(void Function(MeGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeGet200Response build() => _build();

  _$MeGet200Response _build() {
    final _$result = _$v ??
        _$MeGet200Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'MeGet200Response', 'id'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'MeGet200Response', 'displayName'),
          phone: phone,
          avatarUrl: avatarUrl,
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'MeGet200Response', 'role'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'MeGet200Response', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
