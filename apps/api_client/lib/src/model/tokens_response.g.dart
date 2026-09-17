// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TokensResponse extends TokensResponse {
  @override
  final Tokens data;

  factory _$TokensResponse([void Function(TokensResponseBuilder)? updates]) =>
      (TokensResponseBuilder()..update(updates))._build();

  _$TokensResponse._({required this.data}) : super._();
  @override
  TokensResponse rebuild(void Function(TokensResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TokensResponseBuilder toBuilder() => TokensResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TokensResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TokensResponse')..add('data', data))
        .toString();
  }
}

class TokensResponseBuilder
    implements Builder<TokensResponse, TokensResponseBuilder> {
  _$TokensResponse? _$v;

  TokensBuilder? _data;
  TokensBuilder get data => _$this._data ??= TokensBuilder();
  set data(TokensBuilder? data) => _$this._data = data;

  TokensResponseBuilder() {
    TokensResponse._defaults(this);
  }

  TokensResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TokensResponse other) {
    _$v = other as _$TokensResponse;
  }

  @override
  void update(void Function(TokensResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TokensResponse build() => _build();

  _$TokensResponse _build() {
    _$TokensResponse _$result;
    try {
      _$result = _$v ??
          _$TokensResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TokensResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
