// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_password_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhonePasswordSignIn extends PhonePasswordSignIn {
  @override
  final String phone;
  @override
  final String password;

  factory _$PhonePasswordSignIn(
          [void Function(PhonePasswordSignInBuilder)? updates]) =>
      (PhonePasswordSignInBuilder()..update(updates))._build();

  _$PhonePasswordSignIn._({required this.phone, required this.password})
      : super._();
  @override
  PhonePasswordSignIn rebuild(
          void Function(PhonePasswordSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhonePasswordSignInBuilder toBuilder() =>
      PhonePasswordSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhonePasswordSignIn &&
        phone == other.phone &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhonePasswordSignIn')
          ..add('phone', phone)
          ..add('password', password))
        .toString();
  }
}

class PhonePasswordSignInBuilder
    implements Builder<PhonePasswordSignIn, PhonePasswordSignInBuilder> {
  _$PhonePasswordSignIn? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  PhonePasswordSignInBuilder() {
    PhonePasswordSignIn._defaults(this);
  }

  PhonePasswordSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhonePasswordSignIn other) {
    _$v = other as _$PhonePasswordSignIn;
  }

  @override
  void update(void Function(PhonePasswordSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhonePasswordSignIn build() => _build();

  _$PhonePasswordSignIn _build() {
    final _$result = _$v ??
        _$PhonePasswordSignIn._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'PhonePasswordSignIn', 'phone'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'PhonePasswordSignIn', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
