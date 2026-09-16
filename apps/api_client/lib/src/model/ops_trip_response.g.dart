// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_trip_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsTripResponse extends OpsTripResponse {
  @override
  final OpsTrip data;

  factory _$OpsTripResponse([void Function(OpsTripResponseBuilder)? updates]) =>
      (OpsTripResponseBuilder()..update(updates))._build();

  _$OpsTripResponse._({required this.data}) : super._();
  @override
  OpsTripResponse rebuild(void Function(OpsTripResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsTripResponseBuilder toBuilder() => OpsTripResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsTripResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'OpsTripResponse')..add('data', data))
        .toString();
  }
}

class OpsTripResponseBuilder
    implements Builder<OpsTripResponse, OpsTripResponseBuilder> {
  _$OpsTripResponse? _$v;

  OpsTripBuilder? _data;
  OpsTripBuilder get data => _$this._data ??= OpsTripBuilder();
  set data(OpsTripBuilder? data) => _$this._data = data;

  OpsTripResponseBuilder() {
    OpsTripResponse._defaults(this);
  }

  OpsTripResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsTripResponse other) {
    _$v = other as _$OpsTripResponse;
  }

  @override
  void update(void Function(OpsTripResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsTripResponse build() => _build();

  _$OpsTripResponse _build() {
    _$OpsTripResponse _$result;
    try {
      _$result = _$v ??
          _$OpsTripResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsTripResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
