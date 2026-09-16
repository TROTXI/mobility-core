// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GoogleSignIn extends GoogleSignIn {
  @override
  final String idToken;

  factory _$GoogleSignIn([void Function(GoogleSignInBuilder)? updates]) =>
      (GoogleSignInBuilder()..update(updates))._build();

  _$GoogleSignIn._({required this.idToken}) : super._();
  @override
  GoogleSignIn rebuild(void Function(GoogleSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoogleSignInBuilder toBuilder() => GoogleSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GoogleSignIn && idToken == other.idToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GoogleSignIn')
          ..add('idToken', idToken))
        .toString();
  }
}

class GoogleSignInBuilder
    implements Builder<GoogleSignIn, GoogleSignInBuilder> {
  _$GoogleSignIn? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  GoogleSignInBuilder() {
    GoogleSignIn._defaults(this);
  }

  GoogleSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GoogleSignIn other) {
    _$v = other as _$GoogleSignIn;
  }

  @override
  void update(void Function(GoogleSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GoogleSignIn build() => _build();

  _$GoogleSignIn _build() {
    final _$result = _$v ??
        _$GoogleSignIn._(
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'GoogleSignIn', 'idToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
