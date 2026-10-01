// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standby_application_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandbyApplicationResponse extends StandbyApplicationResponse {
  @override
  final StandbyApplication data;

  factory _$StandbyApplicationResponse(
          [void Function(StandbyApplicationResponseBuilder)? updates]) =>
      (StandbyApplicationResponseBuilder()..update(updates))._build();

  _$StandbyApplicationResponse._({required this.data}) : super._();
  @override
  StandbyApplicationResponse rebuild(
          void Function(StandbyApplicationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandbyApplicationResponseBuilder toBuilder() =>
      StandbyApplicationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandbyApplicationResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'StandbyApplicationResponse')
          ..add('data', data))
        .toString();
  }
}

class StandbyApplicationResponseBuilder
    implements
        Builder<StandbyApplicationResponse, StandbyApplicationResponseBuilder> {
  _$StandbyApplicationResponse? _$v;

  StandbyApplicationBuilder? _data;
  StandbyApplicationBuilder get data =>
      _$this._data ??= StandbyApplicationBuilder();
  set data(StandbyApplicationBuilder? data) => _$this._data = data;

  StandbyApplicationResponseBuilder() {
    StandbyApplicationResponse._defaults(this);
  }

  StandbyApplicationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandbyApplicationResponse other) {
    _$v = other as _$StandbyApplicationResponse;
  }

  @override
  void update(void Function(StandbyApplicationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandbyApplicationResponse build() => _build();

  _$StandbyApplicationResponse _build() {
    _$StandbyApplicationResponse _$result;
    try {
      _$result = _$v ??
          _$StandbyApplicationResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StandbyApplicationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
