// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geometry_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GeometryResponse extends GeometryResponse {
  @override
  final Geometry data;

  factory _$GeometryResponse(
          [void Function(GeometryResponseBuilder)? updates]) =>
      (GeometryResponseBuilder()..update(updates))._build();

  _$GeometryResponse._({required this.data}) : super._();
  @override
  GeometryResponse rebuild(void Function(GeometryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeometryResponseBuilder toBuilder() =>
      GeometryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeometryResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'GeometryResponse')..add('data', data))
        .toString();
  }
}

class GeometryResponseBuilder
    implements Builder<GeometryResponse, GeometryResponseBuilder> {
  _$GeometryResponse? _$v;

  GeometryBuilder? _data;
  GeometryBuilder get data => _$this._data ??= GeometryBuilder();
  set data(GeometryBuilder? data) => _$this._data = data;

  GeometryResponseBuilder() {
    GeometryResponse._defaults(this);
  }

  GeometryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeometryResponse other) {
    _$v = other as _$GeometryResponse;
  }

  @override
  void update(void Function(GeometryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeometryResponse build() => _build();

  _$GeometryResponse _build() {
    _$GeometryResponse _$result;
    try {
      _$result = _$v ??
          _$GeometryResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GeometryResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
