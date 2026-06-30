// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_google_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthGooglePostRequest extends AuthGooglePostRequest {
  @override
  final String idToken;

  factory _$AuthGooglePostRequest(
          [void Function(AuthGooglePostRequestBuilder)? updates]) =>
      (AuthGooglePostRequestBuilder()..update(updates))._build();

  _$AuthGooglePostRequest._({required this.idToken}) : super._();
  @override
  AuthGooglePostRequest rebuild(
          void Function(AuthGooglePostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthGooglePostRequestBuilder toBuilder() =>
      AuthGooglePostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthGooglePostRequest && idToken == other.idToken;
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
    return (newBuiltValueToStringHelper(r'AuthGooglePostRequest')
          ..add('idToken', idToken))
        .toString();
  }
}

class AuthGooglePostRequestBuilder
    implements Builder<AuthGooglePostRequest, AuthGooglePostRequestBuilder> {
  _$AuthGooglePostRequest? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  AuthGooglePostRequestBuilder() {
    AuthGooglePostRequest._defaults(this);
  }

  AuthGooglePostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthGooglePostRequest other) {
    _$v = other as _$AuthGooglePostRequest;
  }

  @override
  void update(void Function(AuthGooglePostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthGooglePostRequest build() => _build();

  _$AuthGooglePostRequest _build() {
    final _$result = _$v ??
        _$AuthGooglePostRequest._(
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'AuthGooglePostRequest', 'idToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
