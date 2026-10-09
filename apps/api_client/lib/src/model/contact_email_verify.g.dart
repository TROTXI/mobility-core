// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_email_verify.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ContactEmailVerify extends ContactEmailVerify {
  @override
  final String token;

  factory _$ContactEmailVerify(
          [void Function(ContactEmailVerifyBuilder)? updates]) =>
      (ContactEmailVerifyBuilder()..update(updates))._build();

  _$ContactEmailVerify._({required this.token}) : super._();
  @override
  ContactEmailVerify rebuild(
          void Function(ContactEmailVerifyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContactEmailVerifyBuilder toBuilder() =>
      ContactEmailVerifyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ContactEmailVerify && token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ContactEmailVerify')
          ..add('token', token))
        .toString();
  }
}

class ContactEmailVerifyBuilder
    implements Builder<ContactEmailVerify, ContactEmailVerifyBuilder> {
  _$ContactEmailVerify? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  ContactEmailVerifyBuilder() {
    ContactEmailVerify._defaults(this);
  }

  ContactEmailVerifyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ContactEmailVerify other) {
    _$v = other as _$ContactEmailVerify;
  }

  @override
  void update(void Function(ContactEmailVerifyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ContactEmailVerify build() => _build();

  _$ContactEmailVerify _build() {
    final _$result = _$v ??
        _$ContactEmailVerify._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'ContactEmailVerify', 'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
