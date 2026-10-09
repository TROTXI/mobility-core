// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_registration.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneRegistration extends PhoneRegistration {
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? otherNames;
  @override
  final String email;
  @override
  final String password;

  factory _$PhoneRegistration(
          [void Function(PhoneRegistrationBuilder)? updates]) =>
      (PhoneRegistrationBuilder()..update(updates))._build();

  _$PhoneRegistration._(
      {required this.firstName,
      required this.lastName,
      this.otherNames,
      required this.email,
      required this.password})
      : super._();
  @override
  PhoneRegistration rebuild(void Function(PhoneRegistrationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneRegistrationBuilder toBuilder() =>
      PhoneRegistrationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneRegistration &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        otherNames == other.otherNames &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, otherNames.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhoneRegistration')
          ..add('firstName', firstName)
          ..add('lastName', lastName)
          ..add('otherNames', otherNames)
          ..add('email', email)
          ..add('password', password))
        .toString();
  }
}

class PhoneRegistrationBuilder
    implements Builder<PhoneRegistration, PhoneRegistrationBuilder> {
  _$PhoneRegistration? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _otherNames;
  String? get otherNames => _$this._otherNames;
  set otherNames(String? otherNames) => _$this._otherNames = otherNames;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  PhoneRegistrationBuilder() {
    PhoneRegistration._defaults(this);
  }

  PhoneRegistrationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _otherNames = $v.otherNames;
      _email = $v.email;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneRegistration other) {
    _$v = other as _$PhoneRegistration;
  }

  @override
  void update(void Function(PhoneRegistrationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneRegistration build() => _build();

  _$PhoneRegistration _build() {
    final _$result = _$v ??
        _$PhoneRegistration._(
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'PhoneRegistration', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'PhoneRegistration', 'lastName'),
          otherNames: otherNames,
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'PhoneRegistration', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'PhoneRegistration', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
