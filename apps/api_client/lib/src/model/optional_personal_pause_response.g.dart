// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'optional_personal_pause_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OptionalPersonalPauseResponse extends OptionalPersonalPauseResponse {
  @override
  final OptionalPersonalPause? data;

  factory _$OptionalPersonalPauseResponse(
          [void Function(OptionalPersonalPauseResponseBuilder)? updates]) =>
      (OptionalPersonalPauseResponseBuilder()..update(updates))._build();

  _$OptionalPersonalPauseResponse._({this.data}) : super._();
  @override
  OptionalPersonalPauseResponse rebuild(
          void Function(OptionalPersonalPauseResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OptionalPersonalPauseResponseBuilder toBuilder() =>
      OptionalPersonalPauseResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OptionalPersonalPauseResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OptionalPersonalPauseResponse')
          ..add('data', data))
        .toString();
  }
}

class OptionalPersonalPauseResponseBuilder
    implements
        Builder<OptionalPersonalPauseResponse,
            OptionalPersonalPauseResponseBuilder> {
  _$OptionalPersonalPauseResponse? _$v;

  OptionalPersonalPauseBuilder? _data;
  OptionalPersonalPauseBuilder get data =>
      _$this._data ??= OptionalPersonalPauseBuilder();
  set data(OptionalPersonalPauseBuilder? data) => _$this._data = data;

  OptionalPersonalPauseResponseBuilder() {
    OptionalPersonalPauseResponse._defaults(this);
  }

  OptionalPersonalPauseResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OptionalPersonalPauseResponse other) {
    _$v = other as _$OptionalPersonalPauseResponse;
  }

  @override
  void update(void Function(OptionalPersonalPauseResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OptionalPersonalPauseResponse build() => _build();

  _$OptionalPersonalPauseResponse _build() {
    _$OptionalPersonalPauseResponse _$result;
    try {
      _$result = _$v ??
          _$OptionalPersonalPauseResponse._(
            data: _data?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OptionalPersonalPauseResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
