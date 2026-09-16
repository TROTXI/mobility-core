// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_tokens.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverTokens extends DriverTokens {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DateTime accessExpiresAt;
  @override
  final DateTime refreshExpiresAt;
  @override
  final Account account;
  @override
  final DriverTokensDriver driver;
  @override
  final bool mustChangePin;

  factory _$DriverTokens([void Function(DriverTokensBuilder)? updates]) =>
      (DriverTokensBuilder()..update(updates))._build();

  _$DriverTokens._(
      {required this.accessToken,
      required this.refreshToken,
      required this.accessExpiresAt,
      required this.refreshExpiresAt,
      required this.account,
      required this.driver,
      required this.mustChangePin})
      : super._();
  @override
  DriverTokens rebuild(void Function(DriverTokensBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverTokensBuilder toBuilder() => DriverTokensBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverTokens &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        accessExpiresAt == other.accessExpiresAt &&
        refreshExpiresAt == other.refreshExpiresAt &&
        account == other.account &&
        driver == other.driver &&
        mustChangePin == other.mustChangePin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, accessExpiresAt.hashCode);
    _$hash = $jc(_$hash, refreshExpiresAt.hashCode);
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jc(_$hash, driver.hashCode);
    _$hash = $jc(_$hash, mustChangePin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverTokens')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('accessExpiresAt', accessExpiresAt)
          ..add('refreshExpiresAt', refreshExpiresAt)
          ..add('account', account)
          ..add('driver', driver)
          ..add('mustChangePin', mustChangePin))
        .toString();
  }
}

class DriverTokensBuilder
    implements Builder<DriverTokens, DriverTokensBuilder> {
  _$DriverTokens? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  DateTime? _accessExpiresAt;
  DateTime? get accessExpiresAt => _$this._accessExpiresAt;
  set accessExpiresAt(DateTime? accessExpiresAt) =>
      _$this._accessExpiresAt = accessExpiresAt;

  DateTime? _refreshExpiresAt;
  DateTime? get refreshExpiresAt => _$this._refreshExpiresAt;
  set refreshExpiresAt(DateTime? refreshExpiresAt) =>
      _$this._refreshExpiresAt = refreshExpiresAt;

  AccountBuilder? _account;
  AccountBuilder get account => _$this._account ??= AccountBuilder();
  set account(AccountBuilder? account) => _$this._account = account;

  DriverTokensDriverBuilder? _driver;
  DriverTokensDriverBuilder get driver =>
      _$this._driver ??= DriverTokensDriverBuilder();
  set driver(DriverTokensDriverBuilder? driver) => _$this._driver = driver;

  bool? _mustChangePin;
  bool? get mustChangePin => _$this._mustChangePin;
  set mustChangePin(bool? mustChangePin) =>
      _$this._mustChangePin = mustChangePin;

  DriverTokensBuilder() {
    DriverTokens._defaults(this);
  }

  DriverTokensBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _accessExpiresAt = $v.accessExpiresAt;
      _refreshExpiresAt = $v.refreshExpiresAt;
      _account = $v.account.toBuilder();
      _driver = $v.driver.toBuilder();
      _mustChangePin = $v.mustChangePin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverTokens other) {
    _$v = other as _$DriverTokens;
  }

  @override
  void update(void Function(DriverTokensBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverTokens build() => _build();

  _$DriverTokens _build() {
    _$DriverTokens _$result;
    try {
      _$result = _$v ??
          _$DriverTokens._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'DriverTokens', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'DriverTokens', 'refreshToken'),
            accessExpiresAt: BuiltValueNullFieldError.checkNotNull(
                accessExpiresAt, r'DriverTokens', 'accessExpiresAt'),
            refreshExpiresAt: BuiltValueNullFieldError.checkNotNull(
                refreshExpiresAt, r'DriverTokens', 'refreshExpiresAt'),
            account: account.build(),
            driver: driver.build(),
            mustChangePin: BuiltValueNullFieldError.checkNotNull(
                mustChangePin, r'DriverTokens', 'mustChangePin'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'account';
        account.build();
        _$failedField = 'driver';
        driver.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverTokens', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
