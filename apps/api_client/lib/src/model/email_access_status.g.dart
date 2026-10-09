// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_access_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EmailAccessStatus extends EmailAccessStatus {
  @override
  final String? email;
  @override
  final bool passwordEnabled;
  @override
  final bool emailVerified;

  factory _$EmailAccessStatus(
          [void Function(EmailAccessStatusBuilder)? updates]) =>
      (EmailAccessStatusBuilder()..update(updates))._build();

  _$EmailAccessStatus._(
      {this.email, required this.passwordEnabled, required this.emailVerified})
      : super._();
  @override
  EmailAccessStatus rebuild(void Function(EmailAccessStatusBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EmailAccessStatusBuilder toBuilder() =>
      EmailAccessStatusBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EmailAccessStatus &&
        email == other.email &&
        passwordEnabled == other.passwordEnabled &&
        emailVerified == other.emailVerified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, passwordEnabled.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EmailAccessStatus')
          ..add('email', email)
          ..add('passwordEnabled', passwordEnabled)
          ..add('emailVerified', emailVerified))
        .toString();
  }
}

class EmailAccessStatusBuilder
    implements Builder<EmailAccessStatus, EmailAccessStatusBuilder> {
  _$EmailAccessStatus? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  bool? _passwordEnabled;
  bool? get passwordEnabled => _$this._passwordEnabled;
  set passwordEnabled(bool? passwordEnabled) =>
      _$this._passwordEnabled = passwordEnabled;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  EmailAccessStatusBuilder() {
    EmailAccessStatus._defaults(this);
  }

  EmailAccessStatusBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _passwordEnabled = $v.passwordEnabled;
      _emailVerified = $v.emailVerified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EmailAccessStatus other) {
    _$v = other as _$EmailAccessStatus;
  }

  @override
  void update(void Function(EmailAccessStatusBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EmailAccessStatus build() => _build();

  _$EmailAccessStatus _build() {
    final _$result = _$v ??
        _$EmailAccessStatus._(
          email: email,
          passwordEnabled: BuiltValueNullFieldError.checkNotNull(
              passwordEnabled, r'EmailAccessStatus', 'passwordEnabled'),
          emailVerified: BuiltValueNullFieldError.checkNotNull(
              emailVerified, r'EmailAccessStatus', 'emailVerified'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
