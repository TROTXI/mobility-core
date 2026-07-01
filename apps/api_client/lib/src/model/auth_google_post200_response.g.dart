// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_google_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthGooglePost200Response extends AuthGooglePost200Response {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final MeGet200Response user;

  factory _$AuthGooglePost200Response(
          [void Function(AuthGooglePost200ResponseBuilder)? updates]) =>
      (AuthGooglePost200ResponseBuilder()..update(updates))._build();

  _$AuthGooglePost200Response._(
      {required this.accessToken,
      required this.refreshToken,
      required this.user})
      : super._();
  @override
  AuthGooglePost200Response rebuild(
          void Function(AuthGooglePost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthGooglePost200ResponseBuilder toBuilder() =>
      AuthGooglePost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthGooglePost200Response &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthGooglePost200Response')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('user', user))
        .toString();
  }
}

class AuthGooglePost200ResponseBuilder
    implements
        Builder<AuthGooglePost200Response, AuthGooglePost200ResponseBuilder> {
  _$AuthGooglePost200Response? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  MeGet200ResponseBuilder? _user;
  MeGet200ResponseBuilder get user =>
      _$this._user ??= MeGet200ResponseBuilder();
  set user(MeGet200ResponseBuilder? user) => _$this._user = user;

  AuthGooglePost200ResponseBuilder() {
    AuthGooglePost200Response._defaults(this);
  }

  AuthGooglePost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthGooglePost200Response other) {
    _$v = other as _$AuthGooglePost200Response;
  }

  @override
  void update(void Function(AuthGooglePost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthGooglePost200Response build() => _build();

  _$AuthGooglePost200Response _build() {
    _$AuthGooglePost200Response _$result;
    try {
      _$result = _$v ??
          _$AuthGooglePost200Response._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'AuthGooglePost200Response', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'AuthGooglePost200Response', 'refreshToken'),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthGooglePost200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
