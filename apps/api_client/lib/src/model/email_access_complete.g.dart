// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_access_complete.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmailAccessComplete extends EmailAccessComplete {
  @override
  final String token;
  @override
  final String password;

  factory _$EmailAccessComplete(
          [void Function(EmailAccessCompleteBuilder)? updates]) =>
      (EmailAccessCompleteBuilder()..update(updates))._build();

  _$EmailAccessComplete._({required this.token, required this.password})
      : super._();
  @override
  EmailAccessComplete rebuild(
          void Function(EmailAccessCompleteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmailAccessCompleteBuilder toBuilder() =>
      EmailAccessCompleteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmailAccessComplete &&
        token == other.token &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmailAccessComplete')
          ..add('token', token)
          ..add('password', password))
        .toString();
  }
}

class EmailAccessCompleteBuilder
    implements Builder<EmailAccessComplete, EmailAccessCompleteBuilder> {
  _$EmailAccessComplete? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  EmailAccessCompleteBuilder() {
    EmailAccessComplete._defaults(this);
  }

  EmailAccessCompleteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmailAccessComplete other) {
    _$v = other as _$EmailAccessComplete;
  }

  @override
  void update(void Function(EmailAccessCompleteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmailAccessComplete build() => _build();

  _$EmailAccessComplete _build() {
    final _$result = _$v ??
        _$EmailAccessComplete._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'EmailAccessComplete', 'token'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'EmailAccessComplete', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
