// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Tokens extends Tokens {
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

  factory _$Tokens([void Function(TokensBuilder)? updates]) =>
      (TokensBuilder()..update(updates))._build();

  _$Tokens._(
      {required this.accessToken,
      required this.refreshToken,
      required this.accessExpiresAt,
      required this.refreshExpiresAt,
      required this.account})
      : super._();
  @override
  Tokens rebuild(void Function(TokensBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TokensBuilder toBuilder() => TokensBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Tokens &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        accessExpiresAt == other.accessExpiresAt &&
        refreshExpiresAt == other.refreshExpiresAt &&
        account == other.account;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, accessExpiresAt.hashCode);
    _$hash = $jc(_$hash, refreshExpiresAt.hashCode);
    _$hash = $jc(_$hash, account.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Tokens')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('accessExpiresAt', accessExpiresAt)
          ..add('refreshExpiresAt', refreshExpiresAt)
          ..add('account', account))
        .toString();
  }
}

class TokensBuilder implements Builder<Tokens, TokensBuilder> {
  _$Tokens? _$v;

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

  TokensBuilder() {
    Tokens._defaults(this);
  }

  TokensBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _accessExpiresAt = $v.accessExpiresAt;
      _refreshExpiresAt = $v.refreshExpiresAt;
      _account = $v.account.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Tokens other) {
    _$v = other as _$Tokens;
  }

  @override
  void update(void Function(TokensBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Tokens build() => _build();

  _$Tokens _build() {
    _$Tokens _$result;
    try {
      _$result = _$v ??
          _$Tokens._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'Tokens', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'Tokens', 'refreshToken'),
            accessExpiresAt: BuiltValueNullFieldError.checkNotNull(
                accessExpiresAt, r'Tokens', 'accessExpiresAt'),
            refreshExpiresAt: BuiltValueNullFieldError.checkNotNull(
                refreshExpiresAt, r'Tokens', 'refreshExpiresAt'),
            account: account.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'account';
        account.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Tokens', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
