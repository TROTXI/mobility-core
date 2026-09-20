// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_self.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverSelf extends DriverSelf {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? phone;
  @override
  final String? licenseNumber;
  @override
  final DriverSelfCredential? credential;

  factory _$DriverSelf([void Function(DriverSelfBuilder)? updates]) =>
      (DriverSelfBuilder()..update(updates))._build();

  _$DriverSelf._(
      {required this.id,
      required this.name,
      this.phone,
      this.licenseNumber,
      this.credential})
      : super._();
  @override
  DriverSelf rebuild(void Function(DriverSelfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverSelfBuilder toBuilder() => DriverSelfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverSelf &&
        id == other.id &&
        name == other.name &&
        phone == other.phone &&
        licenseNumber == other.licenseNumber &&
        credential == other.credential;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, licenseNumber.hashCode);
    _$hash = $jc(_$hash, credential.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverSelf')
          ..add('id', id)
          ..add('name', name)
          ..add('phone', phone)
          ..add('licenseNumber', licenseNumber)
          ..add('credential', credential))
        .toString();
  }
}

class DriverSelfBuilder implements Builder<DriverSelf, DriverSelfBuilder> {
  _$DriverSelf? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  DriverSelfCredentialBuilder? _credential;
  DriverSelfCredentialBuilder get credential =>
      _$this._credential ??= DriverSelfCredentialBuilder();
  set credential(DriverSelfCredentialBuilder? credential) =>
      _$this._credential = credential;

  DriverSelfBuilder() {
    DriverSelf._defaults(this);
  }

  DriverSelfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _phone = $v.phone;
      _licenseNumber = $v.licenseNumber;
      _credential = $v.credential?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverSelf other) {
    _$v = other as _$DriverSelf;
  }

  @override
  void update(void Function(DriverSelfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverSelf build() => _build();

  _$DriverSelf _build() {
    _$DriverSelf _$result;
    try {
      _$result = _$v ??
          _$DriverSelf._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'DriverSelf', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'DriverSelf', 'name'),
            phone: phone,
            licenseNumber: licenseNumber,
            credential: _credential?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'credential';
        _credential?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverSelf', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
