// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stops_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminStopsPostRequest extends AdminStopsPostRequest {
  @override
  final String name;
  @override
  final num latitude;
  @override
  final num longitude;

  factory _$AdminStopsPostRequest(
          [void Function(AdminStopsPostRequestBuilder)? updates]) =>
      (AdminStopsPostRequestBuilder()..update(updates))._build();

  _$AdminStopsPostRequest._(
      {required this.name, required this.latitude, required this.longitude})
      : super._();
  @override
  AdminStopsPostRequest rebuild(
          void Function(AdminStopsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminStopsPostRequestBuilder toBuilder() =>
      AdminStopsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminStopsPostRequest &&
        name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminStopsPostRequest')
          ..add('name', name)
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class AdminStopsPostRequestBuilder
    implements Builder<AdminStopsPostRequest, AdminStopsPostRequestBuilder> {
  _$AdminStopsPostRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  AdminStopsPostRequestBuilder() {
    AdminStopsPostRequest._defaults(this);
  }

  AdminStopsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminStopsPostRequest other) {
    _$v = other as _$AdminStopsPostRequest;
  }

  @override
  void update(void Function(AdminStopsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminStopsPostRequest build() => _build();

  _$AdminStopsPostRequest _build() {
    final _$result = _$v ??
        _$AdminStopsPostRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AdminStopsPostRequest', 'name'),
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'AdminStopsPostRequest', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'AdminStopsPostRequest', 'longitude'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
