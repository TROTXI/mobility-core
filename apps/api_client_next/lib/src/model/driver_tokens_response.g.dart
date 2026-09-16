// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_tokens_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverTokensResponse extends DriverTokensResponse {
  @override
  final DriverTokens data;

  factory _$DriverTokensResponse(
          [void Function(DriverTokensResponseBuilder)? updates]) =>
      (DriverTokensResponseBuilder()..update(updates))._build();

  _$DriverTokensResponse._({required this.data}) : super._();
  @override
  DriverTokensResponse rebuild(
          void Function(DriverTokensResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverTokensResponseBuilder toBuilder() =>
      DriverTokensResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverTokensResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'DriverTokensResponse')
          ..add('data', data))
        .toString();
  }
}

class DriverTokensResponseBuilder
    implements Builder<DriverTokensResponse, DriverTokensResponseBuilder> {
  _$DriverTokensResponse? _$v;

  DriverTokensBuilder? _data;
  DriverTokensBuilder get data => _$this._data ??= DriverTokensBuilder();
  set data(DriverTokensBuilder? data) => _$this._data = data;

  DriverTokensResponseBuilder() {
    DriverTokensResponse._defaults(this);
  }

  DriverTokensResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverTokensResponse other) {
    _$v = other as _$DriverTokensResponse;
  }

  @override
  void update(void Function(DriverTokensResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverTokensResponse build() => _build();

  _$DriverTokensResponse _build() {
    _$DriverTokensResponse _$result;
    try {
      _$result = _$v ??
          _$DriverTokensResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverTokensResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
