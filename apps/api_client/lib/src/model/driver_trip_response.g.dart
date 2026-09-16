// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_trip_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverTripResponse extends DriverTripResponse {
  @override
  final DriverTrip data;

  factory _$DriverTripResponse(
          [void Function(DriverTripResponseBuilder)? updates]) =>
      (DriverTripResponseBuilder()..update(updates))._build();

  _$DriverTripResponse._({required this.data}) : super._();
  @override
  DriverTripResponse rebuild(
          void Function(DriverTripResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverTripResponseBuilder toBuilder() =>
      DriverTripResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverTripResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'DriverTripResponse')
          ..add('data', data))
        .toString();
  }
}

class DriverTripResponseBuilder
    implements Builder<DriverTripResponse, DriverTripResponseBuilder> {
  _$DriverTripResponse? _$v;

  DriverTripBuilder? _data;
  DriverTripBuilder get data => _$this._data ??= DriverTripBuilder();
  set data(DriverTripBuilder? data) => _$this._data = data;

  DriverTripResponseBuilder() {
    DriverTripResponse._defaults(this);
  }

  DriverTripResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverTripResponse other) {
    _$v = other as _$DriverTripResponse;
  }

  @override
  void update(void Function(DriverTripResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverTripResponse build() => _build();

  _$DriverTripResponse _build() {
    _$DriverTripResponse _$result;
    try {
      _$result = _$v ??
          _$DriverTripResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverTripResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
