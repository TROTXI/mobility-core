// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stops_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminStopsIdPatchRequest extends AdminStopsIdPatchRequest {
  @override
  final String? name;
  @override
  final num? latitude;
  @override
  final num? longitude;

  factory _$AdminStopsIdPatchRequest(
          [void Function(AdminStopsIdPatchRequestBuilder)? updates]) =>
      (AdminStopsIdPatchRequestBuilder()..update(updates))._build();

  _$AdminStopsIdPatchRequest._({this.name, this.latitude, this.longitude})
      : super._();
  @override
  AdminStopsIdPatchRequest rebuild(
          void Function(AdminStopsIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminStopsIdPatchRequestBuilder toBuilder() =>
      AdminStopsIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminStopsIdPatchRequest &&
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
    return (newBuiltValueToStringHelper(r'AdminStopsIdPatchRequest')
          ..add('name', name)
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class AdminStopsIdPatchRequestBuilder
    implements
        Builder<AdminStopsIdPatchRequest, AdminStopsIdPatchRequestBuilder> {
  _$AdminStopsIdPatchRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  AdminStopsIdPatchRequestBuilder() {
    AdminStopsIdPatchRequest._defaults(this);
  }

  AdminStopsIdPatchRequestBuilder get _$this {
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
  void replace(AdminStopsIdPatchRequest other) {
    _$v = other as _$AdminStopsIdPatchRequest;
  }

  @override
  void update(void Function(AdminStopsIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminStopsIdPatchRequest build() => _build();

  _$AdminStopsIdPatchRequest _build() {
    final _$result = _$v ??
        _$AdminStopsIdPatchRequest._(
          name: name,
          latitude: latitude,
          longitude: longitude,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
