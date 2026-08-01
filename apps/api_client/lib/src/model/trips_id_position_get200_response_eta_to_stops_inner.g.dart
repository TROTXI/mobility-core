// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_position_get200_response_eta_to_stops_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdPositionGet200ResponseEtaToStopsInner
    extends TripsIdPositionGet200ResponseEtaToStopsInner {
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

  factory _$TripsIdPositionGet200ResponseEtaToStopsInner(
          [void Function(TripsIdPositionGet200ResponseEtaToStopsInnerBuilder)?
              updates]) =>
      (TripsIdPositionGet200ResponseEtaToStopsInnerBuilder()..update(updates))
          ._build();

  _$TripsIdPositionGet200ResponseEtaToStopsInner._(
      {required this.stopId,
      required this.seq,
      required this.name,
      required this.distanceMeters,
      required this.etaSeconds})
      : super._();
  @override
  TripsIdPositionGet200ResponseEtaToStopsInner rebuild(
          void Function(TripsIdPositionGet200ResponseEtaToStopsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdPositionGet200ResponseEtaToStopsInnerBuilder toBuilder() =>
      TripsIdPositionGet200ResponseEtaToStopsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdPositionGet200ResponseEtaToStopsInner &&
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
            r'TripsIdPositionGet200ResponseEtaToStopsInner')
          ..add('stopId', stopId)
          ..add('seq', seq)
          ..add('name', name)
          ..add('distanceMeters', distanceMeters)
          ..add('etaSeconds', etaSeconds))
        .toString();
  }
}

class TripsIdPositionGet200ResponseEtaToStopsInnerBuilder
    implements
        Builder<TripsIdPositionGet200ResponseEtaToStopsInner,
            TripsIdPositionGet200ResponseEtaToStopsInnerBuilder> {
  _$TripsIdPositionGet200ResponseEtaToStopsInner? _$v;

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

  TripsIdPositionGet200ResponseEtaToStopsInnerBuilder() {
    TripsIdPositionGet200ResponseEtaToStopsInner._defaults(this);
  }

  TripsIdPositionGet200ResponseEtaToStopsInnerBuilder get _$this {
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
  void replace(TripsIdPositionGet200ResponseEtaToStopsInner other) {
    _$v = other as _$TripsIdPositionGet200ResponseEtaToStopsInner;
  }

  @override
  void update(
      void Function(TripsIdPositionGet200ResponseEtaToStopsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdPositionGet200ResponseEtaToStopsInner build() => _build();

  _$TripsIdPositionGet200ResponseEtaToStopsInner _build() {
    final _$result = _$v ??
        _$TripsIdPositionGet200ResponseEtaToStopsInner._(
          stopId: BuiltValueNullFieldError.checkNotNull(stopId,
              r'TripsIdPositionGet200ResponseEtaToStopsInner', 'stopId'),
          seq: BuiltValueNullFieldError.checkNotNull(
              seq, r'TripsIdPositionGet200ResponseEtaToStopsInner', 'seq'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TripsIdPositionGet200ResponseEtaToStopsInner', 'name'),
          distanceMeters: BuiltValueNullFieldError.checkNotNull(
              distanceMeters,
              r'TripsIdPositionGet200ResponseEtaToStopsInner',
              'distanceMeters'),
          etaSeconds: BuiltValueNullFieldError.checkNotNull(etaSeconds,
              r'TripsIdPositionGet200ResponseEtaToStopsInner', 'etaSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
