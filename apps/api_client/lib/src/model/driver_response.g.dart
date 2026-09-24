// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverResponse extends DriverResponse {
  @override
  final Driver data;

  factory _$DriverResponse([void Function(DriverResponseBuilder)? updates]) =>
      (DriverResponseBuilder()..update(updates))._build();

  _$DriverResponse._({required this.data}) : super._();
  @override
  DriverResponse rebuild(void Function(DriverResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverResponseBuilder toBuilder() => DriverResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'DriverResponse')..add('data', data))
        .toString();
  }
}

class DriverResponseBuilder
    implements Builder<DriverResponse, DriverResponseBuilder> {
  _$DriverResponse? _$v;

  DriverBuilder? _data;
  DriverBuilder get data => _$this._data ??= DriverBuilder();
  set data(DriverBuilder? data) => _$this._data = data;

  DriverResponseBuilder() {
    DriverResponse._defaults(this);
  }

  DriverResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverResponse other) {
    _$v = other as _$DriverResponse;
  }

  @override
  void update(void Function(DriverResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverResponse build() => _build();

  _$DriverResponse _build() {
    _$DriverResponse _$result;
    try {
      _$result = _$v ??
          _$DriverResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
