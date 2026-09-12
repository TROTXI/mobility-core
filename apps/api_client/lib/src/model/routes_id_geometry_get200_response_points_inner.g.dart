// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_id_geometry_get200_response_points_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RoutesIdGeometryGet200ResponsePointsInner
    extends RoutesIdGeometryGet200ResponsePointsInner {
  @override
  final num latitude;
  @override
  final num longitude;

  factory _$RoutesIdGeometryGet200ResponsePointsInner(
          [void Function(RoutesIdGeometryGet200ResponsePointsInnerBuilder)?
              updates]) =>
      (RoutesIdGeometryGet200ResponsePointsInnerBuilder()..update(updates))
          ._build();

  _$RoutesIdGeometryGet200ResponsePointsInner._(
      {required this.latitude, required this.longitude})
      : super._();
  @override
  RoutesIdGeometryGet200ResponsePointsInner rebuild(
          void Function(RoutesIdGeometryGet200ResponsePointsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoutesIdGeometryGet200ResponsePointsInnerBuilder toBuilder() =>
      RoutesIdGeometryGet200ResponsePointsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutesIdGeometryGet200ResponsePointsInner &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'RoutesIdGeometryGet200ResponsePointsInner')
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class RoutesIdGeometryGet200ResponsePointsInnerBuilder
    implements
        Builder<RoutesIdGeometryGet200ResponsePointsInner,
            RoutesIdGeometryGet200ResponsePointsInnerBuilder> {
  _$RoutesIdGeometryGet200ResponsePointsInner? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  RoutesIdGeometryGet200ResponsePointsInnerBuilder() {
    RoutesIdGeometryGet200ResponsePointsInner._defaults(this);
  }

  RoutesIdGeometryGet200ResponsePointsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoutesIdGeometryGet200ResponsePointsInner other) {
    _$v = other as _$RoutesIdGeometryGet200ResponsePointsInner;
  }

  @override
  void update(
      void Function(RoutesIdGeometryGet200ResponsePointsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  RoutesIdGeometryGet200ResponsePointsInner build() => _build();

  _$RoutesIdGeometryGet200ResponsePointsInner _build() {
    final _$result = _$v ??
        _$RoutesIdGeometryGet200ResponsePointsInner._(
          latitude: BuiltValueNullFieldError.checkNotNull(latitude,
              r'RoutesIdGeometryGet200ResponsePointsInner', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(longitude,
              r'RoutesIdGeometryGet200ResponsePointsInner', 'longitude'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
