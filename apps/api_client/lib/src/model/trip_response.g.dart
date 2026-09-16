// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripResponse extends TripResponse {
  @override
  final Trip data;

  factory _$TripResponse([void Function(TripResponseBuilder)? updates]) =>
      (TripResponseBuilder()..update(updates))._build();

  _$TripResponse._({required this.data}) : super._();
  @override
  TripResponse rebuild(void Function(TripResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripResponseBuilder toBuilder() => TripResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'TripResponse')..add('data', data))
        .toString();
  }
}

class TripResponseBuilder
    implements Builder<TripResponse, TripResponseBuilder> {
  _$TripResponse? _$v;

  TripBuilder? _data;
  TripBuilder get data => _$this._data ??= TripBuilder();
  set data(TripBuilder? data) => _$this._data = data;

  TripResponseBuilder() {
    TripResponse._defaults(this);
  }

  TripResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripResponse other) {
    _$v = other as _$TripResponse;
  }

  @override
  void update(void Function(TripResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripResponse build() => _build();

  _$TripResponse _build() {
    _$TripResponse _$result;
    try {
      _$result = _$v ??
          _$TripResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
