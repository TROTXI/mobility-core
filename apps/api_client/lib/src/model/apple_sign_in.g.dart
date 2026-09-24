// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppleSignIn extends AppleSignIn {
  @override
  final String idToken;
  @override
  final String? nonce;
  @override
  final String? authorizationCode;
  @override
  final String? displayName;

  factory _$AppleSignIn([void Function(AppleSignInBuilder)? updates]) =>
      (AppleSignInBuilder()..update(updates))._build();

  _$AppleSignIn._(
      {required this.idToken,
      this.nonce,
      this.authorizationCode,
      this.displayName})
      : super._();
  @override
  AppleSignIn rebuild(void Function(AppleSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppleSignInBuilder toBuilder() => AppleSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppleSignIn &&
        idToken == other.idToken &&
        nonce == other.nonce &&
        authorizationCode == other.authorizationCode &&
        displayName == other.displayName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jc(_$hash, nonce.hashCode);
    _$hash = $jc(_$hash, authorizationCode.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppleSignIn')
          ..add('idToken', idToken)
          ..add('nonce', nonce)
          ..add('authorizationCode', authorizationCode)
          ..add('displayName', displayName))
        .toString();
  }
}

class AppleSignInBuilder implements Builder<AppleSignIn, AppleSignInBuilder> {
  _$AppleSignIn? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  String? _nonce;
  String? get nonce => _$this._nonce;
  set nonce(String? nonce) => _$this._nonce = nonce;

  String? _authorizationCode;
  String? get authorizationCode => _$this._authorizationCode;
  set authorizationCode(String? authorizationCode) =>
      _$this._authorizationCode = authorizationCode;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  AppleSignInBuilder() {
    AppleSignIn._defaults(this);
  }

  AppleSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _nonce = $v.nonce;
      _authorizationCode = $v.authorizationCode;
      _displayName = $v.displayName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppleSignIn other) {
    _$v = other as _$AppleSignIn;
  }

  @override
  void update(void Function(AppleSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppleSignIn build() => _build();

  _$AppleSignIn _build() {
    final _$result = _$v ??
        _$AppleSignIn._(
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'AppleSignIn', 'idToken'),
          nonce: nonce,
          authorizationCode: authorizationCode,
          displayName: displayName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
