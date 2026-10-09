// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmailSignIn extends EmailSignIn {
  @override
  final String email;
  @override
  final String password;

  factory _$EmailSignIn([void Function(EmailSignInBuilder)? updates]) =>
      (EmailSignInBuilder()..update(updates))._build();

  _$EmailSignIn._({required this.email, required this.password}) : super._();
  @override
  EmailSignIn rebuild(void Function(EmailSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmailSignInBuilder toBuilder() => EmailSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmailSignIn &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmailSignIn')
          ..add('email', email)
          ..add('password', password))
        .toString();
  }
}

class EmailSignInBuilder implements Builder<EmailSignIn, EmailSignInBuilder> {
  _$EmailSignIn? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  EmailSignInBuilder() {
    EmailSignIn._defaults(this);
  }

  EmailSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmailSignIn other) {
    _$v = other as _$EmailSignIn;
  }

  @override
  void update(void Function(EmailSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmailSignIn build() => _build();

  _$EmailSignIn _build() {
    final _$result = _$v ??
        _$EmailSignIn._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'EmailSignIn', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'EmailSignIn', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
