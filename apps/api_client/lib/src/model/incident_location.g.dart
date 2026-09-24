// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_location.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IncidentLocation extends IncidentLocation {
  @override
  final num latitude;
  @override
  final num longitude;

  factory _$IncidentLocation(
          [void Function(IncidentLocationBuilder)? updates]) =>
      (IncidentLocationBuilder()..update(updates))._build();

  _$IncidentLocation._({required this.latitude, required this.longitude})
      : super._();
  @override
  IncidentLocation rebuild(void Function(IncidentLocationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IncidentLocationBuilder toBuilder() =>
      IncidentLocationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentLocation &&
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
    return (newBuiltValueToStringHelper(r'IncidentLocation')
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class IncidentLocationBuilder
    implements Builder<IncidentLocation, IncidentLocationBuilder> {
  _$IncidentLocation? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  IncidentLocationBuilder() {
    IncidentLocation._defaults(this);
  }

  IncidentLocationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentLocation other) {
    _$v = other as _$IncidentLocation;
  }

  @override
  void update(void Function(IncidentLocationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentLocation build() => _build();

  _$IncidentLocation _build() {
    final _$result = _$v ??
        _$IncidentLocation._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'IncidentLocation', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'IncidentLocation', 'longitude'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
