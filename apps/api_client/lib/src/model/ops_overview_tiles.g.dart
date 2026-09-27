// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_overview_tiles.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsOverviewTiles extends OpsOverviewTiles {
  @override
  final int trips;
  @override
  final int inProgress;
  @override
  final int completed;
  @override
  final int cancelled;
  @override
  final int seatCapacity;
  @override
  final int seatsConfirmed;
  @override
  final int boarded;
  @override
  final int noShows;
  @override
  final int awaitingResolution;
  @override
  final int staleGps;
  @override
  final int unassigned;

  factory _$OpsOverviewTiles(
          [void Function(OpsOverviewTilesBuilder)? updates]) =>
      (OpsOverviewTilesBuilder()..update(updates))._build();

  _$OpsOverviewTiles._(
      {required this.trips,
      required this.inProgress,
      required this.completed,
      required this.cancelled,
      required this.seatCapacity,
      required this.seatsConfirmed,
      required this.boarded,
      required this.noShows,
      required this.awaitingResolution,
      required this.staleGps,
      required this.unassigned})
      : super._();
  @override
  OpsOverviewTiles rebuild(void Function(OpsOverviewTilesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsOverviewTilesBuilder toBuilder() =>
      OpsOverviewTilesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsOverviewTiles &&
        trips == other.trips &&
        inProgress == other.inProgress &&
        completed == other.completed &&
        cancelled == other.cancelled &&
        seatCapacity == other.seatCapacity &&
        seatsConfirmed == other.seatsConfirmed &&
        boarded == other.boarded &&
        noShows == other.noShows &&
        awaitingResolution == other.awaitingResolution &&
        staleGps == other.staleGps &&
        unassigned == other.unassigned;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trips.hashCode);
    _$hash = $jc(_$hash, inProgress.hashCode);
    _$hash = $jc(_$hash, completed.hashCode);
    _$hash = $jc(_$hash, cancelled.hashCode);
    _$hash = $jc(_$hash, seatCapacity.hashCode);
    _$hash = $jc(_$hash, seatsConfirmed.hashCode);
    _$hash = $jc(_$hash, boarded.hashCode);
    _$hash = $jc(_$hash, noShows.hashCode);
    _$hash = $jc(_$hash, awaitingResolution.hashCode);
    _$hash = $jc(_$hash, staleGps.hashCode);
    _$hash = $jc(_$hash, unassigned.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsOverviewTiles')
          ..add('trips', trips)
          ..add('inProgress', inProgress)
          ..add('completed', completed)
          ..add('cancelled', cancelled)
          ..add('seatCapacity', seatCapacity)
          ..add('seatsConfirmed', seatsConfirmed)
          ..add('boarded', boarded)
          ..add('noShows', noShows)
          ..add('awaitingResolution', awaitingResolution)
          ..add('staleGps', staleGps)
          ..add('unassigned', unassigned))
        .toString();
  }
}

class OpsOverviewTilesBuilder
    implements Builder<OpsOverviewTiles, OpsOverviewTilesBuilder> {
  _$OpsOverviewTiles? _$v;

  int? _trips;
  int? get trips => _$this._trips;
  set trips(int? trips) => _$this._trips = trips;

  int? _inProgress;
  int? get inProgress => _$this._inProgress;
  set inProgress(int? inProgress) => _$this._inProgress = inProgress;

  int? _completed;
  int? get completed => _$this._completed;
  set completed(int? completed) => _$this._completed = completed;

  int? _cancelled;
  int? get cancelled => _$this._cancelled;
  set cancelled(int? cancelled) => _$this._cancelled = cancelled;

  int? _seatCapacity;
  int? get seatCapacity => _$this._seatCapacity;
  set seatCapacity(int? seatCapacity) => _$this._seatCapacity = seatCapacity;

  int? _seatsConfirmed;
  int? get seatsConfirmed => _$this._seatsConfirmed;
  set seatsConfirmed(int? seatsConfirmed) =>
      _$this._seatsConfirmed = seatsConfirmed;

  int? _boarded;
  int? get boarded => _$this._boarded;
  set boarded(int? boarded) => _$this._boarded = boarded;

  int? _noShows;
  int? get noShows => _$this._noShows;
  set noShows(int? noShows) => _$this._noShows = noShows;

  int? _awaitingResolution;
  int? get awaitingResolution => _$this._awaitingResolution;
  set awaitingResolution(int? awaitingResolution) =>
      _$this._awaitingResolution = awaitingResolution;

  int? _staleGps;
  int? get staleGps => _$this._staleGps;
  set staleGps(int? staleGps) => _$this._staleGps = staleGps;

  int? _unassigned;
  int? get unassigned => _$this._unassigned;
  set unassigned(int? unassigned) => _$this._unassigned = unassigned;

  OpsOverviewTilesBuilder() {
    OpsOverviewTiles._defaults(this);
  }

  OpsOverviewTilesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trips = $v.trips;
      _inProgress = $v.inProgress;
      _completed = $v.completed;
      _cancelled = $v.cancelled;
      _seatCapacity = $v.seatCapacity;
      _seatsConfirmed = $v.seatsConfirmed;
      _boarded = $v.boarded;
      _noShows = $v.noShows;
      _awaitingResolution = $v.awaitingResolution;
      _staleGps = $v.staleGps;
      _unassigned = $v.unassigned;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsOverviewTiles other) {
    _$v = other as _$OpsOverviewTiles;
  }

  @override
  void update(void Function(OpsOverviewTilesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsOverviewTiles build() => _build();

  _$OpsOverviewTiles _build() {
    final _$result = _$v ??
        _$OpsOverviewTiles._(
          trips: BuiltValueNullFieldError.checkNotNull(
              trips, r'OpsOverviewTiles', 'trips'),
          inProgress: BuiltValueNullFieldError.checkNotNull(
              inProgress, r'OpsOverviewTiles', 'inProgress'),
          completed: BuiltValueNullFieldError.checkNotNull(
              completed, r'OpsOverviewTiles', 'completed'),
          cancelled: BuiltValueNullFieldError.checkNotNull(
              cancelled, r'OpsOverviewTiles', 'cancelled'),
          seatCapacity: BuiltValueNullFieldError.checkNotNull(
              seatCapacity, r'OpsOverviewTiles', 'seatCapacity'),
          seatsConfirmed: BuiltValueNullFieldError.checkNotNull(
              seatsConfirmed, r'OpsOverviewTiles', 'seatsConfirmed'),
          boarded: BuiltValueNullFieldError.checkNotNull(
              boarded, r'OpsOverviewTiles', 'boarded'),
          noShows: BuiltValueNullFieldError.checkNotNull(
              noShows, r'OpsOverviewTiles', 'noShows'),
          awaitingResolution: BuiltValueNullFieldError.checkNotNull(
              awaitingResolution, r'OpsOverviewTiles', 'awaitingResolution'),
          staleGps: BuiltValueNullFieldError.checkNotNull(
              staleGps, r'OpsOverviewTiles', 'staleGps'),
          unassigned: BuiltValueNullFieldError.checkNotNull(
              unassigned, r'OpsOverviewTiles', 'unassigned'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
