// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_drivers_get200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDriversGet200ResponseInner
    extends AdminDriversGet200ResponseInner {
  @override
  final String id;
  @override
  final String fullName;
  @override
  final String? phone;
  @override
  final String? licenseNumber;
  @override
  final String? userId;
  @override
  final DateTime createdAt;

  factory _$AdminDriversGet200ResponseInner(
          [void Function(AdminDriversGet200ResponseInnerBuilder)? updates]) =>
      (AdminDriversGet200ResponseInnerBuilder()..update(updates))._build();

  _$AdminDriversGet200ResponseInner._(
      {required this.id,
      required this.fullName,
      this.phone,
      this.licenseNumber,
      this.userId,
      required this.createdAt})
      : super._();
  @override
  AdminDriversGet200ResponseInner rebuild(
          void Function(AdminDriversGet200ResponseInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriversGet200ResponseInnerBuilder toBuilder() =>
      AdminDriversGet200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriversGet200ResponseInner &&
        id == other.id &&
        fullName == other.fullName &&
        phone == other.phone &&
        licenseNumber == other.licenseNumber &&
        userId == other.userId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, licenseNumber.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDriversGet200ResponseInner')
          ..add('id', id)
          ..add('fullName', fullName)
          ..add('phone', phone)
          ..add('licenseNumber', licenseNumber)
          ..add('userId', userId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminDriversGet200ResponseInnerBuilder
    implements
        Builder<AdminDriversGet200ResponseInner,
            AdminDriversGet200ResponseInnerBuilder> {
  _$AdminDriversGet200ResponseInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _licenseNumber;
  String? get licenseNumber => _$this._licenseNumber;
  set licenseNumber(String? licenseNumber) =>
      _$this._licenseNumber = licenseNumber;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminDriversGet200ResponseInnerBuilder() {
    AdminDriversGet200ResponseInner._defaults(this);
  }

  AdminDriversGet200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _fullName = $v.fullName;
      _phone = $v.phone;
      _licenseNumber = $v.licenseNumber;
      _userId = $v.userId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriversGet200ResponseInner other) {
    _$v = other as _$AdminDriversGet200ResponseInner;
  }

  @override
  void update(void Function(AdminDriversGet200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriversGet200ResponseInner build() => _build();

  _$AdminDriversGet200ResponseInner _build() {
    final _$result = _$v ??
        _$AdminDriversGet200ResponseInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminDriversGet200ResponseInner', 'id'),
          fullName: BuiltValueNullFieldError.checkNotNull(
              fullName, r'AdminDriversGet200ResponseInner', 'fullName'),
          phone: phone,
          licenseNumber: licenseNumber,
          userId: userId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminDriversGet200ResponseInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
