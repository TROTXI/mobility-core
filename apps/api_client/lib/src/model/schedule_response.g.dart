// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ScheduleResponse extends ScheduleResponse {
  @override
  final Schedule data;

  factory _$ScheduleResponse(
          [void Function(ScheduleResponseBuilder)? updates]) =>
      (ScheduleResponseBuilder()..update(updates))._build();

  _$ScheduleResponse._({required this.data}) : super._();
  @override
  ScheduleResponse rebuild(void Function(ScheduleResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScheduleResponseBuilder toBuilder() =>
      ScheduleResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ScheduleResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'ScheduleResponse')..add('data', data))
        .toString();
  }
}

class ScheduleResponseBuilder
    implements Builder<ScheduleResponse, ScheduleResponseBuilder> {
  _$ScheduleResponse? _$v;

  ScheduleBuilder? _data;
  ScheduleBuilder get data => _$this._data ??= ScheduleBuilder();
  set data(ScheduleBuilder? data) => _$this._data = data;

  ScheduleResponseBuilder() {
    ScheduleResponse._defaults(this);
  }

  ScheduleResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ScheduleResponse other) {
    _$v = other as _$ScheduleResponse;
  }

  @override
  void update(void Function(ScheduleResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ScheduleResponse build() => _build();

  _$ScheduleResponse _build() {
    _$ScheduleResponse _$result;
    try {
      _$result = _$v ??
          _$ScheduleResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ScheduleResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
