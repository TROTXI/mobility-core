// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverEdit extends DriverEdit {
  @override
  final String? name;
  @override
  final String? phone;
  @override
  final String? licenseNumber;
  @override
  final String? userId;
  @override
  final bool? archived;

  factory _$DriverEdit([void Function(DriverEditBuilder)? updates]) =>
      (DriverEditBuilder()..update(updates))._build();

  _$DriverEdit._(
      {this.name, this.phone, this.licenseNumber, this.userId, this.archived})
      : super._();
  @override
  DriverEdit rebuild(void Function(DriverEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverEditBuilder toBuilder() => DriverEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverEdit &&
        name == other.name &&
        phone == other.phone &&
        licenseNumber == other.licenseNumber &&
        userId == other.userId &&
        archived == other.archived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, licenseNumber.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverEdit')
          ..add('name', name)
          ..add('phone', phone)
          ..add('licenseNumber', licenseNumber)
          ..add('userId', userId)
          ..add('archived', archived))
        .toString();
  }
}

class DriverEditBuilder implements Builder<DriverEdit, DriverEditBuilder> {
  _$DriverEdit? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

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

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  DriverEditBuilder() {
    DriverEdit._defaults(this);
  }

  DriverEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _phone = $v.phone;
      _licenseNumber = $v.licenseNumber;
      _userId = $v.userId;
      _archived = $v.archived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverEdit other) {
    _$v = other as _$DriverEdit;
  }

  @override
  void update(void Function(DriverEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverEdit build() => _build();

  _$DriverEdit _build() {
    final _$result = _$v ??
        _$DriverEdit._(
          name: name,
          phone: phone,
          licenseNumber: licenseNumber,
          userId: userId,
          archived: archived,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
