// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StopResponse extends StopResponse {
  @override
  final Stop data;

  factory _$StopResponse([void Function(StopResponseBuilder)? updates]) =>
      (StopResponseBuilder()..update(updates))._build();

  _$StopResponse._({required this.data}) : super._();
  @override
  StopResponse rebuild(void Function(StopResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StopResponseBuilder toBuilder() => StopResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StopResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'StopResponse')..add('data', data))
        .toString();
  }
}

class StopResponseBuilder
    implements Builder<StopResponse, StopResponseBuilder> {
  _$StopResponse? _$v;

  StopBuilder? _data;
  StopBuilder get data => _$this._data ??= StopBuilder();
  set data(StopBuilder? data) => _$this._data = data;

  StopResponseBuilder() {
    StopResponse._defaults(this);
  }

  StopResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StopResponse other) {
    _$v = other as _$StopResponse;
  }

  @override
  void update(void Function(StopResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StopResponse build() => _build();

  _$StopResponse _build() {
    _$StopResponse _$result;
    try {
      _$result = _$v ??
          _$StopResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StopResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
