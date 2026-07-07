// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_refresh_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthRefreshPost200Response extends AuthRefreshPost200Response {
  @override
  final String accessToken;
  @override
  final String refreshToken;

  factory _$AuthRefreshPost200Response(
          [void Function(AuthRefreshPost200ResponseBuilder)? updates]) =>
      (AuthRefreshPost200ResponseBuilder()..update(updates))._build();

  _$AuthRefreshPost200Response._(
      {required this.accessToken, required this.refreshToken})
      : super._();
  @override
  AuthRefreshPost200Response rebuild(
          void Function(AuthRefreshPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthRefreshPost200ResponseBuilder toBuilder() =>
      AuthRefreshPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRefreshPost200Response &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthRefreshPost200Response')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class AuthRefreshPost200ResponseBuilder
    implements
        Builder<AuthRefreshPost200Response, AuthRefreshPost200ResponseBuilder> {
  _$AuthRefreshPost200Response? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  AuthRefreshPost200ResponseBuilder() {
    AuthRefreshPost200Response._defaults(this);
  }

  AuthRefreshPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthRefreshPost200Response other) {
    _$v = other as _$AuthRefreshPost200Response;
  }

  @override
  void update(void Function(AuthRefreshPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRefreshPost200Response build() => _build();

  _$AuthRefreshPost200Response _build() {
    final _$result = _$v ??
        _$AuthRefreshPost200Response._(
          accessToken: BuiltValueNullFieldError.checkNotNull(
              accessToken, r'AuthRefreshPost200Response', 'accessToken'),
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'AuthRefreshPost200Response', 'refreshToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
