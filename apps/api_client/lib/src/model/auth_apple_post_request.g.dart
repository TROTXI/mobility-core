// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_apple_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthApplePostRequest extends AuthApplePostRequest {
  @override
  final String idToken;
  @override
  final String? fullName;
  @override
  final String? nonce;
  @override
  final String? authorizationCode;

  factory _$AuthApplePostRequest(
          [void Function(AuthApplePostRequestBuilder)? updates]) =>
      (AuthApplePostRequestBuilder()..update(updates))._build();

  _$AuthApplePostRequest._(
      {required this.idToken,
      this.fullName,
      this.nonce,
      this.authorizationCode})
      : super._();
  @override
  AuthApplePostRequest rebuild(
          void Function(AuthApplePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthApplePostRequestBuilder toBuilder() =>
      AuthApplePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthApplePostRequest &&
        idToken == other.idToken &&
        fullName == other.fullName &&
        nonce == other.nonce &&
        authorizationCode == other.authorizationCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, nonce.hashCode);
    _$hash = $jc(_$hash, authorizationCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthApplePostRequest')
          ..add('idToken', idToken)
          ..add('fullName', fullName)
          ..add('nonce', nonce)
          ..add('authorizationCode', authorizationCode))
        .toString();
  }
}

class AuthApplePostRequestBuilder
    implements Builder<AuthApplePostRequest, AuthApplePostRequestBuilder> {
  _$AuthApplePostRequest? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _nonce;
  String? get nonce => _$this._nonce;
  set nonce(String? nonce) => _$this._nonce = nonce;

  String? _authorizationCode;
  String? get authorizationCode => _$this._authorizationCode;
  set authorizationCode(String? authorizationCode) =>
      _$this._authorizationCode = authorizationCode;

  AuthApplePostRequestBuilder() {
    AuthApplePostRequest._defaults(this);
  }

  AuthApplePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _fullName = $v.fullName;
      _nonce = $v.nonce;
      _authorizationCode = $v.authorizationCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthApplePostRequest other) {
    _$v = other as _$AuthApplePostRequest;
  }

  @override
  void update(void Function(AuthApplePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthApplePostRequest build() => _build();

  _$AuthApplePostRequest _build() {
    final _$result = _$v ??
        _$AuthApplePostRequest._(
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'AuthApplePostRequest', 'idToken'),
          fullName: fullName,
          nonce: nonce,
          authorizationCode: authorizationCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
