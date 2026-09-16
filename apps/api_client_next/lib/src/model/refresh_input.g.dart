// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefreshInput extends RefreshInput {
  @override
  final String refreshToken;

  factory _$RefreshInput([void Function(RefreshInputBuilder)? updates]) =>
      (RefreshInputBuilder()..update(updates))._build();

  _$RefreshInput._({required this.refreshToken}) : super._();
  @override
  RefreshInput rebuild(void Function(RefreshInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshInputBuilder toBuilder() => RefreshInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshInput && refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefreshInput')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class RefreshInputBuilder
    implements Builder<RefreshInput, RefreshInputBuilder> {
  _$RefreshInput? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  RefreshInputBuilder() {
    RefreshInput._defaults(this);
  }

  RefreshInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshInput other) {
    _$v = other as _$RefreshInput;
  }

  @override
  void update(void Function(RefreshInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefreshInput build() => _build();

  _$RefreshInput _build() {
    final _$result = _$v ??
        _$RefreshInput._(
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'RefreshInput', 'refreshToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
