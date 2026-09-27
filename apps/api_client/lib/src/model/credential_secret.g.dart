// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_secret.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CredentialSecret extends CredentialSecret {
  @override
  final String code;
  @override
  final String pin;
<<<<<<< HEAD
=======
  @override
  final DateTime temporaryPinExpiresAt;
  @override
  final CredentialSecretEmail? email;
  @override
  final CredentialSecretSms? sms;
>>>>>>> origin/main

  factory _$CredentialSecret(
          [void Function(CredentialSecretBuilder)? updates]) =>
      (CredentialSecretBuilder()..update(updates))._build();

<<<<<<< HEAD
  _$CredentialSecret._({required this.code, required this.pin}) : super._();
=======
  _$CredentialSecret._(
      {required this.code,
      required this.pin,
      required this.temporaryPinExpiresAt,
      this.email,
      this.sms})
      : super._();
>>>>>>> origin/main
  @override
  CredentialSecret rebuild(void Function(CredentialSecretBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CredentialSecretBuilder toBuilder() =>
      CredentialSecretBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
<<<<<<< HEAD
    return other is CredentialSecret && code == other.code && pin == other.pin;
=======
    return other is CredentialSecret &&
        code == other.code &&
        pin == other.pin &&
        temporaryPinExpiresAt == other.temporaryPinExpiresAt &&
        email == other.email &&
        sms == other.sms;
>>>>>>> origin/main
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
<<<<<<< HEAD
=======
    _$hash = $jc(_$hash, temporaryPinExpiresAt.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, sms.hashCode);
>>>>>>> origin/main
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CredentialSecret')
          ..add('code', code)
<<<<<<< HEAD
          ..add('pin', pin))
=======
          ..add('pin', pin)
          ..add('temporaryPinExpiresAt', temporaryPinExpiresAt)
          ..add('email', email)
          ..add('sms', sms))
>>>>>>> origin/main
        .toString();
  }
}

class CredentialSecretBuilder
    implements Builder<CredentialSecret, CredentialSecretBuilder> {
  _$CredentialSecret? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

<<<<<<< HEAD
=======
  DateTime? _temporaryPinExpiresAt;
  DateTime? get temporaryPinExpiresAt => _$this._temporaryPinExpiresAt;
  set temporaryPinExpiresAt(DateTime? temporaryPinExpiresAt) =>
      _$this._temporaryPinExpiresAt = temporaryPinExpiresAt;

  CredentialSecretEmailBuilder? _email;
  CredentialSecretEmailBuilder get email =>
      _$this._email ??= CredentialSecretEmailBuilder();
  set email(CredentialSecretEmailBuilder? email) => _$this._email = email;

  CredentialSecretSmsBuilder? _sms;
  CredentialSecretSmsBuilder get sms =>
      _$this._sms ??= CredentialSecretSmsBuilder();
  set sms(CredentialSecretSmsBuilder? sms) => _$this._sms = sms;

>>>>>>> origin/main
  CredentialSecretBuilder() {
    CredentialSecret._defaults(this);
  }

  CredentialSecretBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _pin = $v.pin;
<<<<<<< HEAD
=======
      _temporaryPinExpiresAt = $v.temporaryPinExpiresAt;
      _email = $v.email?.toBuilder();
      _sms = $v.sms?.toBuilder();
>>>>>>> origin/main
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CredentialSecret other) {
    _$v = other as _$CredentialSecret;
  }

  @override
  void update(void Function(CredentialSecretBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CredentialSecret build() => _build();

  _$CredentialSecret _build() {
<<<<<<< HEAD
    final _$result = _$v ??
        _$CredentialSecret._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'CredentialSecret', 'code'),
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'CredentialSecret', 'pin'),
        );
=======
    _$CredentialSecret _$result;
    try {
      _$result = _$v ??
          _$CredentialSecret._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'CredentialSecret', 'code'),
            pin: BuiltValueNullFieldError.checkNotNull(
                pin, r'CredentialSecret', 'pin'),
            temporaryPinExpiresAt: BuiltValueNullFieldError.checkNotNull(
                temporaryPinExpiresAt,
                r'CredentialSecret',
                'temporaryPinExpiresAt'),
            email: _email?.build(),
            sms: _sms?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'email';
        _email?.build();
        _$failedField = 'sms';
        _sms?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CredentialSecret', _$failedField, e.toString());
      }
      rethrow;
    }
>>>>>>> origin/main
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
