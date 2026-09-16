// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleResponse extends VehicleResponse {
  @override
  final Vehicle data;

  factory _$VehicleResponse([void Function(VehicleResponseBuilder)? updates]) =>
      (VehicleResponseBuilder()..update(updates))._build();

  _$VehicleResponse._({required this.data}) : super._();
  @override
  VehicleResponse rebuild(void Function(VehicleResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleResponseBuilder toBuilder() => VehicleResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'VehicleResponse')..add('data', data))
        .toString();
  }
}

class VehicleResponseBuilder
    implements Builder<VehicleResponse, VehicleResponseBuilder> {
  _$VehicleResponse? _$v;

  VehicleBuilder? _data;
  VehicleBuilder get data => _$this._data ??= VehicleBuilder();
  set data(VehicleBuilder? data) => _$this._data = data;

  VehicleResponseBuilder() {
    VehicleResponse._defaults(this);
  }

  VehicleResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleResponse other) {
    _$v = other as _$VehicleResponse;
  }

  @override
  void update(void Function(VehicleResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleResponse build() => _build();

  _$VehicleResponse _build() {
    _$VehicleResponse _$result;
    try {
      _$result = _$v ??
          _$VehicleResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'VehicleResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
