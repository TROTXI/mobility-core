// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RouteResponse extends RouteResponse {
  @override
  final Route data;

  factory _$RouteResponse([void Function(RouteResponseBuilder)? updates]) =>
      (RouteResponseBuilder()..update(updates))._build();

  _$RouteResponse._({required this.data}) : super._();
  @override
  RouteResponse rebuild(void Function(RouteResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteResponseBuilder toBuilder() => RouteResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteResponse && data == other.data;
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
    return (newBuiltValueToStringHelper(r'RouteResponse')..add('data', data))
        .toString();
  }
}

class RouteResponseBuilder
    implements Builder<RouteResponse, RouteResponseBuilder> {
  _$RouteResponse? _$v;

  RouteBuilder? _data;
  RouteBuilder get data => _$this._data ??= RouteBuilder();
  set data(RouteBuilder? data) => _$this._data = data;

  RouteResponseBuilder() {
    RouteResponse._defaults(this);
  }

  RouteResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteResponse other) {
    _$v = other as _$RouteResponse;
  }

  @override
  void update(void Function(RouteResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteResponse build() => _build();

  _$RouteResponse _build() {
    _$RouteResponse _$result;
    try {
      _$result = _$v ??
          _$RouteResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RouteResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
