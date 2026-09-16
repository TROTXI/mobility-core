// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceResponse extends DeviceResponse {
  @override
  final Device data;

  factory _$DeviceResponse([void Function(DeviceResponseBuilder)? updates]) =>
      (DeviceResponseBuilder()..update(updates))._build();

  _$DeviceResponse._({required this.data}) : super._();
  @override
  DeviceResponse rebuild(void Function(DeviceResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceResponseBuilder toBuilder() => DeviceResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'DeviceResponse')..add('data', data))
        .toString();
  }
}

class DeviceResponseBuilder
    implements Builder<DeviceResponse, DeviceResponseBuilder> {
  _$DeviceResponse? _$v;

  DeviceBuilder? _data;
  DeviceBuilder get data => _$this._data ??= DeviceBuilder();
  set data(DeviceBuilder? data) => _$this._data = data;

  DeviceResponseBuilder() {
    DeviceResponse._defaults(this);
  }

  DeviceResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceResponse other) {
    _$v = other as _$DeviceResponse;
  }

  @override
  void update(void Function(DeviceResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceResponse build() => _build();

  _$DeviceResponse _build() {
    _$DeviceResponse _$result;
    try {
      _$result = _$v ??
          _$DeviceResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DeviceResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
