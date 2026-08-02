// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stops_get200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminStopsGet200ResponseInner extends AdminStopsGet200ResponseInner {
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

  factory _$AdminStopsGet200ResponseInner(
          [void Function(AdminStopsGet200ResponseInnerBuilder)? updates]) =>
      (AdminStopsGet200ResponseInnerBuilder()..update(updates))._build();

  _$AdminStopsGet200ResponseInner._(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.createdAt})
      : super._();
  @override
  AdminStopsGet200ResponseInner rebuild(
          void Function(AdminStopsGet200ResponseInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminStopsGet200ResponseInnerBuilder toBuilder() =>
      AdminStopsGet200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminStopsGet200ResponseInner &&
        id == other.id &&
        name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminStopsGet200ResponseInner')
          ..add('id', id)
          ..add('name', name)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminStopsGet200ResponseInnerBuilder
    implements
        Builder<AdminStopsGet200ResponseInner,
            AdminStopsGet200ResponseInnerBuilder> {
  _$AdminStopsGet200ResponseInner? _$v;

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

  AdminStopsGet200ResponseInnerBuilder() {
    AdminStopsGet200ResponseInner._defaults(this);
  }

  AdminStopsGet200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminStopsGet200ResponseInner other) {
    _$v = other as _$AdminStopsGet200ResponseInner;
  }

  @override
  void update(void Function(AdminStopsGet200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminStopsGet200ResponseInner build() => _build();

  _$AdminStopsGet200ResponseInner _build() {
    final _$result = _$v ??
        _$AdminStopsGet200ResponseInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminStopsGet200ResponseInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AdminStopsGet200ResponseInner', 'name'),
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'AdminStopsGet200ResponseInner', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'AdminStopsGet200ResponseInner', 'longitude'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminStopsGet200ResponseInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
