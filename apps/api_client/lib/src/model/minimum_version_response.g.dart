// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minimum_version_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MinimumVersionResponse extends MinimumVersionResponse {
  @override
  final MinimumVersion data;

  factory _$MinimumVersionResponse(
          [void Function(MinimumVersionResponseBuilder)? updates]) =>
      (MinimumVersionResponseBuilder()..update(updates))._build();

  _$MinimumVersionResponse._({required this.data}) : super._();
  @override
  MinimumVersionResponse rebuild(
          void Function(MinimumVersionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MinimumVersionResponseBuilder toBuilder() =>
      MinimumVersionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MinimumVersionResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'MinimumVersionResponse')
          ..add('data', data))
        .toString();
  }
}

class MinimumVersionResponseBuilder
    implements Builder<MinimumVersionResponse, MinimumVersionResponseBuilder> {
  _$MinimumVersionResponse? _$v;

  MinimumVersionBuilder? _data;
  MinimumVersionBuilder get data => _$this._data ??= MinimumVersionBuilder();
  set data(MinimumVersionBuilder? data) => _$this._data = data;

  MinimumVersionResponseBuilder() {
    MinimumVersionResponse._defaults(this);
  }

  MinimumVersionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MinimumVersionResponse other) {
    _$v = other as _$MinimumVersionResponse;
  }

  @override
  void update(void Function(MinimumVersionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MinimumVersionResponse build() => _build();

  _$MinimumVersionResponse _build() {
    _$MinimumVersionResponse _$result;
    try {
      _$result = _$v ??
          _$MinimumVersionResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MinimumVersionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
