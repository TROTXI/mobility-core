// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trace_hold_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TraceHoldResponse extends TraceHoldResponse {
  @override
  final TraceHold data;

  factory _$TraceHoldResponse(
          [void Function(TraceHoldResponseBuilder)? updates]) =>
      (TraceHoldResponseBuilder()..update(updates))._build();

  _$TraceHoldResponse._({required this.data}) : super._();
  @override
  TraceHoldResponse rebuild(void Function(TraceHoldResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TraceHoldResponseBuilder toBuilder() =>
      TraceHoldResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TraceHoldResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TraceHoldResponse')
          ..add('data', data))
        .toString();
  }
}

class TraceHoldResponseBuilder
    implements Builder<TraceHoldResponse, TraceHoldResponseBuilder> {
  _$TraceHoldResponse? _$v;

  TraceHoldBuilder? _data;
  TraceHoldBuilder get data => _$this._data ??= TraceHoldBuilder();
  set data(TraceHoldBuilder? data) => _$this._data = data;

  TraceHoldResponseBuilder() {
    TraceHoldResponse._defaults(this);
  }

  TraceHoldResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TraceHoldResponse other) {
    _$v = other as _$TraceHoldResponse;
  }

  @override
  void update(void Function(TraceHoldResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TraceHoldResponse build() => _build();

  _$TraceHoldResponse _build() {
    _$TraceHoldResponse _$result;
    try {
      _$result = _$v ??
          _$TraceHoldResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TraceHoldResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
