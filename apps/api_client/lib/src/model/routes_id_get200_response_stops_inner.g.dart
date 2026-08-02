// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes_id_get200_response_stops_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RoutesIdGet200ResponseStopsInner
    extends RoutesIdGet200ResponseStopsInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final DateTime createdAt;
  @override
  final int seq;

  factory _$RoutesIdGet200ResponseStopsInner(
          [void Function(RoutesIdGet200ResponseStopsInnerBuilder)? updates]) =>
      (RoutesIdGet200ResponseStopsInnerBuilder()..update(updates))._build();

  _$RoutesIdGet200ResponseStopsInner._(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.createdAt,
      required this.seq})
      : super._();
  @override
  RoutesIdGet200ResponseStopsInner rebuild(
          void Function(RoutesIdGet200ResponseStopsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RoutesIdGet200ResponseStopsInnerBuilder toBuilder() =>
      RoutesIdGet200ResponseStopsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RoutesIdGet200ResponseStopsInner &&
        id == other.id &&
        name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        createdAt == other.createdAt &&
        seq == other.seq;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RoutesIdGet200ResponseStopsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('createdAt', createdAt)
          ..add('seq', seq))
        .toString();
  }
}

class RoutesIdGet200ResponseStopsInnerBuilder
    implements
        Builder<RoutesIdGet200ResponseStopsInner,
            RoutesIdGet200ResponseStopsInnerBuilder> {
  _$RoutesIdGet200ResponseStopsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  RoutesIdGet200ResponseStopsInnerBuilder() {
    RoutesIdGet200ResponseStopsInner._defaults(this);
  }

  RoutesIdGet200ResponseStopsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _createdAt = $v.createdAt;
      _seq = $v.seq;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RoutesIdGet200ResponseStopsInner other) {
    _$v = other as _$RoutesIdGet200ResponseStopsInner;
  }

  @override
  void update(void Function(RoutesIdGet200ResponseStopsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RoutesIdGet200ResponseStopsInner build() => _build();

  _$RoutesIdGet200ResponseStopsInner _build() {
    final _$result = _$v ??
        _$RoutesIdGet200ResponseStopsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RoutesIdGet200ResponseStopsInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'RoutesIdGet200ResponseStopsInner', 'name'),
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'RoutesIdGet200ResponseStopsInner', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'RoutesIdGet200ResponseStopsInner', 'longitude'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RoutesIdGet200ResponseStopsInner', 'createdAt'),
          seq: BuiltValueNullFieldError.checkNotNull(
              seq, r'RoutesIdGet200ResponseStopsInner', 'seq'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
