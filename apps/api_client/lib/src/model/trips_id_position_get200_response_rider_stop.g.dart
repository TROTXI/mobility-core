// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_position_get200_response_rider_stop.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdPositionGet200ResponseRiderStop
    extends TripsIdPositionGet200ResponseRiderStop {
  @override
  final String stopId;
  @override
  final int seq;
  @override
  final String name;
  @override
  final num distanceMeters;
  @override
  final num etaSeconds;

  factory _$TripsIdPositionGet200ResponseRiderStop(
          [void Function(TripsIdPositionGet200ResponseRiderStopBuilder)?
              updates]) =>
      (TripsIdPositionGet200ResponseRiderStopBuilder()..update(updates))
          ._build();

  _$TripsIdPositionGet200ResponseRiderStop._(
      {required this.stopId,
      required this.seq,
      required this.name,
      required this.distanceMeters,
      required this.etaSeconds})
      : super._();
  @override
  TripsIdPositionGet200ResponseRiderStop rebuild(
          void Function(TripsIdPositionGet200ResponseRiderStopBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdPositionGet200ResponseRiderStopBuilder toBuilder() =>
      TripsIdPositionGet200ResponseRiderStopBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdPositionGet200ResponseRiderStop &&
        stopId == other.stopId &&
        seq == other.seq &&
        name == other.name &&
        distanceMeters == other.distanceMeters &&
        etaSeconds == other.etaSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stopId.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, distanceMeters.hashCode);
    _$hash = $jc(_$hash, etaSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'TripsIdPositionGet200ResponseRiderStop')
          ..add('stopId', stopId)
          ..add('seq', seq)
          ..add('name', name)
          ..add('distanceMeters', distanceMeters)
          ..add('etaSeconds', etaSeconds))
        .toString();
  }
}

class TripsIdPositionGet200ResponseRiderStopBuilder
    implements
        Builder<TripsIdPositionGet200ResponseRiderStop,
            TripsIdPositionGet200ResponseRiderStopBuilder> {
  _$TripsIdPositionGet200ResponseRiderStop? _$v;

  String? _stopId;
  String? get stopId => _$this._stopId;
  set stopId(String? stopId) => _$this._stopId = stopId;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _distanceMeters;
  num? get distanceMeters => _$this._distanceMeters;
  set distanceMeters(num? distanceMeters) =>
      _$this._distanceMeters = distanceMeters;

  num? _etaSeconds;
  num? get etaSeconds => _$this._etaSeconds;
  set etaSeconds(num? etaSeconds) => _$this._etaSeconds = etaSeconds;

  TripsIdPositionGet200ResponseRiderStopBuilder() {
    TripsIdPositionGet200ResponseRiderStop._defaults(this);
  }

  TripsIdPositionGet200ResponseRiderStopBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stopId = $v.stopId;
      _seq = $v.seq;
      _name = $v.name;
      _distanceMeters = $v.distanceMeters;
      _etaSeconds = $v.etaSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdPositionGet200ResponseRiderStop other) {
    _$v = other as _$TripsIdPositionGet200ResponseRiderStop;
  }

  @override
  void update(
      void Function(TripsIdPositionGet200ResponseRiderStopBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdPositionGet200ResponseRiderStop build() => _build();

  _$TripsIdPositionGet200ResponseRiderStop _build() {
    final _$result = _$v ??
        _$TripsIdPositionGet200ResponseRiderStop._(
          stopId: BuiltValueNullFieldError.checkNotNull(
              stopId, r'TripsIdPositionGet200ResponseRiderStop', 'stopId'),
          seq: BuiltValueNullFieldError.checkNotNull(
              seq, r'TripsIdPositionGet200ResponseRiderStop', 'seq'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TripsIdPositionGet200ResponseRiderStop', 'name'),
          distanceMeters: BuiltValueNullFieldError.checkNotNull(distanceMeters,
              r'TripsIdPositionGet200ResponseRiderStop', 'distanceMeters'),
          etaSeconds: BuiltValueNullFieldError.checkNotNull(etaSeconds,
              r'TripsIdPositionGet200ResponseRiderStop', 'etaSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
