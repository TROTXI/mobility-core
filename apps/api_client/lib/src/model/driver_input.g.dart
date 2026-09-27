// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverInput extends DriverInput {
  @override
  final String name;
  @override
  final String? phone;
  @override
<<<<<<< HEAD
=======
  final String? email;
  @override
>>>>>>> origin/main
  final String? licenseNumber;
  @override
  final String? userId;

  factory _$DriverInput([void Function(DriverInputBuilder)? updates]) =>
      (DriverInputBuilder()..update(updates))._build();

  _$DriverInput._(
<<<<<<< HEAD
      {required this.name, this.phone, this.licenseNumber, this.userId})
=======
      {required this.name,
      this.phone,
      this.email,
      this.licenseNumber,
      this.userId})
>>>>>>> origin/main
      : super._();
  @override
  DriverInput rebuild(void Function(DriverInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverInputBuilder toBuilder() => DriverInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverInput &&
        name == other.name &&
        phone == other.phone &&
<<<<<<< HEAD
=======
        email == other.email &&
>>>>>>> origin/main
        licenseNumber == other.licenseNumber &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
<<<<<<< HEAD
=======
    _$hash = $jc(_$hash, email.hashCode);
>>>>>>> origin/main
    _$hash = $jc(_$hash, licenseNumber.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverInput')
          ..add('name', name)
          ..add('phone', phone)
<<<<<<< HEAD
=======
          ..add('email', email)
>>>>>>> origin/main
          ..add('licenseNumber', licenseNumber)
          ..add('userId', userId))
        .toString();
  }
}

class DriverInputBuilder implements Builder<DriverInput, DriverInputBuilder> {
  _$DriverInput? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

<<<<<<< HEAD
=======
  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

>>>>>>> origin/main
  String? _licenseNumber;
  String? get licenseNumber => _$this._licenseNumber;
  set licenseNumber(String? licenseNumber) =>
      _$this._licenseNumber = licenseNumber;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  DriverInputBuilder() {
    DriverInput._defaults(this);
  }

  DriverInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _phone = $v.phone;
<<<<<<< HEAD
=======
      _email = $v.email;
>>>>>>> origin/main
      _licenseNumber = $v.licenseNumber;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverInput other) {
    _$v = other as _$DriverInput;
  }

  @override
  void update(void Function(DriverInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverInput build() => _build();

  _$DriverInput _build() {
    final _$result = _$v ??
        _$DriverInput._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'DriverInput', 'name'),
          phone: phone,
<<<<<<< HEAD
=======
          email: email,
>>>>>>> origin/main
          licenseNumber: licenseNumber,
          userId: userId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
