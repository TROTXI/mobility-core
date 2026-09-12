// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_driver_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthDriverPost200Response extends AuthDriverPost200Response {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final MeGet200Response user;
  @override
  final AuthDriverPost200ResponseDriver driver;
  @override
  final bool mustChangePin;

  factory _$AuthDriverPost200Response(
          [void Function(AuthDriverPost200ResponseBuilder)? updates]) =>
      (AuthDriverPost200ResponseBuilder()..update(updates))._build();

  _$AuthDriverPost200Response._(
      {required this.accessToken,
      required this.refreshToken,
      required this.user,
      required this.driver,
      required this.mustChangePin})
      : super._();
  @override
  AuthDriverPost200Response rebuild(
          void Function(AuthDriverPost200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthDriverPost200ResponseBuilder toBuilder() =>
      AuthDriverPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthDriverPost200Response &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        user == other.user &&
        driver == other.driver &&
        mustChangePin == other.mustChangePin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, driver.hashCode);
    _$hash = $jc(_$hash, mustChangePin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthDriverPost200Response')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('user', user)
          ..add('driver', driver)
          ..add('mustChangePin', mustChangePin))
        .toString();
  }
}

class AuthDriverPost200ResponseBuilder
    implements
        Builder<AuthDriverPost200Response, AuthDriverPost200ResponseBuilder> {
  _$AuthDriverPost200Response? _$v;

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

  AuthDriverPost200ResponseDriverBuilder? _driver;
  AuthDriverPost200ResponseDriverBuilder get driver =>
      _$this._driver ??= AuthDriverPost200ResponseDriverBuilder();
  set driver(AuthDriverPost200ResponseDriverBuilder? driver) =>
      _$this._driver = driver;

  bool? _mustChangePin;
  bool? get mustChangePin => _$this._mustChangePin;
  set mustChangePin(bool? mustChangePin) =>
      _$this._mustChangePin = mustChangePin;

  AuthDriverPost200ResponseBuilder() {
    AuthDriverPost200Response._defaults(this);
  }

  AuthDriverPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _user = $v.user.toBuilder();
      _driver = $v.driver.toBuilder();
      _mustChangePin = $v.mustChangePin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthDriverPost200Response other) {
    _$v = other as _$AuthDriverPost200Response;
  }

  @override
  void update(void Function(AuthDriverPost200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthDriverPost200Response build() => _build();

  _$AuthDriverPost200Response _build() {
    _$AuthDriverPost200Response _$result;
    try {
      _$result = _$v ??
          _$AuthDriverPost200Response._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'AuthDriverPost200Response', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'AuthDriverPost200Response', 'refreshToken'),
            user: user.build(),
            driver: driver.build(),
            mustChangePin: BuiltValueNullFieldError.checkNotNull(
                mustChangePin, r'AuthDriverPost200Response', 'mustChangePin'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
        _$failedField = 'driver';
        driver.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthDriverPost200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
