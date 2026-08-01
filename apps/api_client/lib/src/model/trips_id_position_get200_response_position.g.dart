// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_position_get200_response_position.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdPositionGet200ResponsePosition
    extends TripsIdPositionGet200ResponsePosition {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final DateTime recordedAt;

  factory _$TripsIdPositionGet200ResponsePosition(
          [void Function(TripsIdPositionGet200ResponsePositionBuilder)?
              updates]) =>
      (TripsIdPositionGet200ResponsePositionBuilder()..update(updates))
          ._build();

  _$TripsIdPositionGet200ResponsePosition._(
      {required this.latitude,
      required this.longitude,
      required this.recordedAt})
      : super._();
  @override
  TripsIdPositionGet200ResponsePosition rebuild(
          void Function(TripsIdPositionGet200ResponsePositionBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdPositionGet200ResponsePositionBuilder toBuilder() =>
      TripsIdPositionGet200ResponsePositionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdPositionGet200ResponsePosition &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        recordedAt == other.recordedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, recordedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'TripsIdPositionGet200ResponsePosition')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('recordedAt', recordedAt))
        .toString();
  }
}

class TripsIdPositionGet200ResponsePositionBuilder
    implements
        Builder<TripsIdPositionGet200ResponsePosition,
            TripsIdPositionGet200ResponsePositionBuilder> {
  _$TripsIdPositionGet200ResponsePosition? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  DateTime? _recordedAt;
  DateTime? get recordedAt => _$this._recordedAt;
  set recordedAt(DateTime? recordedAt) => _$this._recordedAt = recordedAt;

  TripsIdPositionGet200ResponsePositionBuilder() {
    TripsIdPositionGet200ResponsePosition._defaults(this);
  }

  TripsIdPositionGet200ResponsePositionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _recordedAt = $v.recordedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdPositionGet200ResponsePosition other) {
    _$v = other as _$TripsIdPositionGet200ResponsePosition;
  }

  @override
  void update(
      void Function(TripsIdPositionGet200ResponsePositionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdPositionGet200ResponsePosition build() => _build();

  _$TripsIdPositionGet200ResponsePosition _build() {
    final _$result = _$v ??
        _$TripsIdPositionGet200ResponsePosition._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'TripsIdPositionGet200ResponsePosition', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'TripsIdPositionGet200ResponsePosition', 'longitude'),
          recordedAt: BuiltValueNullFieldError.checkNotNull(recordedAt,
              r'TripsIdPositionGet200ResponsePosition', 'recordedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
