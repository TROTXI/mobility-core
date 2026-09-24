// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_self_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverSelfResponse extends DriverSelfResponse {
  @override
  final DriverSelf data;

  factory _$DriverSelfResponse(
          [void Function(DriverSelfResponseBuilder)? updates]) =>
      (DriverSelfResponseBuilder()..update(updates))._build();

  _$DriverSelfResponse._({required this.data}) : super._();
  @override
  DriverSelfResponse rebuild(
          void Function(DriverSelfResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverSelfResponseBuilder toBuilder() =>
      DriverSelfResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverSelfResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'DriverSelfResponse')
          ..add('data', data))
        .toString();
  }
}

class DriverSelfResponseBuilder
    implements Builder<DriverSelfResponse, DriverSelfResponseBuilder> {
  _$DriverSelfResponse? _$v;

  DriverSelfBuilder? _data;
  DriverSelfBuilder get data => _$this._data ??= DriverSelfBuilder();
  set data(DriverSelfBuilder? data) => _$this._data = data;

  DriverSelfResponseBuilder() {
    DriverSelfResponse._defaults(this);
  }

  DriverSelfResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverSelfResponse other) {
    _$v = other as _$DriverSelfResponse;
  }

  @override
  void update(void Function(DriverSelfResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverSelfResponse build() => _build();

  _$DriverSelfResponse _build() {
    _$DriverSelfResponse _$result;
    try {
      _$result = _$v ??
          _$DriverSelfResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverSelfResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
