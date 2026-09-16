// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripSummaryStatusEnum _$tripSummaryStatusEnum_scheduled =
    const TripSummaryStatusEnum._('scheduled');
const TripSummaryStatusEnum _$tripSummaryStatusEnum_active =
    const TripSummaryStatusEnum._('active');
const TripSummaryStatusEnum _$tripSummaryStatusEnum_completed =
    const TripSummaryStatusEnum._('completed');
const TripSummaryStatusEnum _$tripSummaryStatusEnum_cancelled =
    const TripSummaryStatusEnum._('cancelled');

TripSummaryStatusEnum _$tripSummaryStatusEnumValueOf(String name) {
  switch (name) {
    case 'scheduled':
      return _$tripSummaryStatusEnum_scheduled;
    case 'active':
      return _$tripSummaryStatusEnum_active;
    case 'completed':
      return _$tripSummaryStatusEnum_completed;
    case 'cancelled':
      return _$tripSummaryStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripSummaryStatusEnum> _$tripSummaryStatusEnumValues =
    BuiltSet<TripSummaryStatusEnum>(const <TripSummaryStatusEnum>[
  _$tripSummaryStatusEnum_scheduled,
  _$tripSummaryStatusEnum_active,
  _$tripSummaryStatusEnum_completed,
  _$tripSummaryStatusEnum_cancelled,
]);

Serializer<TripSummaryStatusEnum> _$tripSummaryStatusEnumSerializer =
    _$TripSummaryStatusEnumSerializer();

class _$TripSummaryStatusEnumSerializer
    implements PrimitiveSerializer<TripSummaryStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'scheduled': 'scheduled',
    'active': 'active',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'scheduled': 'scheduled',
    'active': 'active',
    'completed': 'completed',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[TripSummaryStatusEnum];
  @override
  final String wireName = 'TripSummaryStatusEnum';

  @override
  Object serialize(Serializers serializers, TripSummaryStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripSummaryStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripSummaryStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripSummary extends TripSummary {
  @override
  final String tripId;
  @override
  final TripSummaryStatusEnum status;
  @override
  final int boarded;
  @override
  final int noShows;
  @override
  final int unseated;
  @override
  final int scanned;
  @override
  final int codeVerified;
  @override
  final int photoVerified;

  factory _$TripSummary([void Function(TripSummaryBuilder)? updates]) =>
      (TripSummaryBuilder()..update(updates))._build();

  _$TripSummary._(
      {required this.tripId,
      required this.status,
      required this.boarded,
      required this.noShows,
      required this.unseated,
      required this.scanned,
      required this.codeVerified,
      required this.photoVerified})
      : super._();
  @override
  TripSummary rebuild(void Function(TripSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripSummaryBuilder toBuilder() => TripSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripSummary &&
        tripId == other.tripId &&
        status == other.status &&
        boarded == other.boarded &&
        noShows == other.noShows &&
        unseated == other.unseated &&
        scanned == other.scanned &&
        codeVerified == other.codeVerified &&
        photoVerified == other.photoVerified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, boarded.hashCode);
    _$hash = $jc(_$hash, noShows.hashCode);
    _$hash = $jc(_$hash, unseated.hashCode);
    _$hash = $jc(_$hash, scanned.hashCode);
    _$hash = $jc(_$hash, codeVerified.hashCode);
    _$hash = $jc(_$hash, photoVerified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripSummary')
          ..add('tripId', tripId)
          ..add('status', status)
          ..add('boarded', boarded)
          ..add('noShows', noShows)
          ..add('unseated', unseated)
          ..add('scanned', scanned)
          ..add('codeVerified', codeVerified)
          ..add('photoVerified', photoVerified))
        .toString();
  }
}

class TripSummaryBuilder implements Builder<TripSummary, TripSummaryBuilder> {
  _$TripSummary? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  TripSummaryStatusEnum? _status;
  TripSummaryStatusEnum? get status => _$this._status;
  set status(TripSummaryStatusEnum? status) => _$this._status = status;

  int? _boarded;
  int? get boarded => _$this._boarded;
  set boarded(int? boarded) => _$this._boarded = boarded;

  int? _noShows;
  int? get noShows => _$this._noShows;
  set noShows(int? noShows) => _$this._noShows = noShows;

  int? _unseated;
  int? get unseated => _$this._unseated;
  set unseated(int? unseated) => _$this._unseated = unseated;

  int? _scanned;
  int? get scanned => _$this._scanned;
  set scanned(int? scanned) => _$this._scanned = scanned;

  int? _codeVerified;
  int? get codeVerified => _$this._codeVerified;
  set codeVerified(int? codeVerified) => _$this._codeVerified = codeVerified;

  int? _photoVerified;
  int? get photoVerified => _$this._photoVerified;
  set photoVerified(int? photoVerified) =>
      _$this._photoVerified = photoVerified;

  TripSummaryBuilder() {
    TripSummary._defaults(this);
  }

  TripSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _status = $v.status;
      _boarded = $v.boarded;
      _noShows = $v.noShows;
      _unseated = $v.unseated;
      _scanned = $v.scanned;
      _codeVerified = $v.codeVerified;
      _photoVerified = $v.photoVerified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripSummary other) {
    _$v = other as _$TripSummary;
  }

  @override
  void update(void Function(TripSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripSummary build() => _build();

  _$TripSummary _build() {
    final _$result = _$v ??
        _$TripSummary._(
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'TripSummary', 'tripId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'TripSummary', 'status'),
          boarded: BuiltValueNullFieldError.checkNotNull(
              boarded, r'TripSummary', 'boarded'),
          noShows: BuiltValueNullFieldError.checkNotNull(
              noShows, r'TripSummary', 'noShows'),
          unseated: BuiltValueNullFieldError.checkNotNull(
              unseated, r'TripSummary', 'unseated'),
          scanned: BuiltValueNullFieldError.checkNotNull(
              scanned, r'TripSummary', 'scanned'),
          codeVerified: BuiltValueNullFieldError.checkNotNull(
              codeVerified, r'TripSummary', 'codeVerified'),
          photoVerified: BuiltValueNullFieldError.checkNotNull(
              photoVerified, r'TripSummary', 'photoVerified'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
