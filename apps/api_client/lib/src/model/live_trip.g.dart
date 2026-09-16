// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_trip.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LiveTripStateEnum _$liveTripStateEnum_notStarted =
    const LiveTripStateEnum._('notStarted');
const LiveTripStateEnum _$liveTripStateEnum_awaitingFix =
    const LiveTripStateEnum._('awaitingFix');
const LiveTripStateEnum _$liveTripStateEnum_live =
    const LiveTripStateEnum._('live');
const LiveTripStateEnum _$liveTripStateEnum_stale =
    const LiveTripStateEnum._('stale');
const LiveTripStateEnum _$liveTripStateEnum_ended =
    const LiveTripStateEnum._('ended');

LiveTripStateEnum _$liveTripStateEnumValueOf(String name) {
  switch (name) {
    case 'notStarted':
      return _$liveTripStateEnum_notStarted;
    case 'awaitingFix':
      return _$liveTripStateEnum_awaitingFix;
    case 'live':
      return _$liveTripStateEnum_live;
    case 'stale':
      return _$liveTripStateEnum_stale;
    case 'ended':
      return _$liveTripStateEnum_ended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LiveTripStateEnum> _$liveTripStateEnumValues =
    BuiltSet<LiveTripStateEnum>(const <LiveTripStateEnum>[
  _$liveTripStateEnum_notStarted,
  _$liveTripStateEnum_awaitingFix,
  _$liveTripStateEnum_live,
  _$liveTripStateEnum_stale,
  _$liveTripStateEnum_ended,
]);

Serializer<LiveTripStateEnum> _$liveTripStateEnumSerializer =
    _$LiveTripStateEnumSerializer();

class _$LiveTripStateEnumSerializer
    implements PrimitiveSerializer<LiveTripStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'notStarted': 'not_started',
    'awaitingFix': 'awaiting_fix',
    'live': 'live',
    'stale': 'stale',
    'ended': 'ended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'not_started': 'notStarted',
    'awaiting_fix': 'awaitingFix',
    'live': 'live',
    'stale': 'stale',
    'ended': 'ended',
  };

  @override
  final Iterable<Type> types = const <Type>[LiveTripStateEnum];
  @override
  final String wireName = 'LiveTripStateEnum';

  @override
  Object serialize(Serializers serializers, LiveTripStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LiveTripStateEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LiveTripStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LiveTrip extends LiveTrip {
  @override
  final String tripId;
  @override
  final String patternVersionId;
  @override
  final String? geometryId;
  @override
  final String? riderPickupOccurrenceId;
  @override
  final LiveTripStateEnum state;
  @override
  final LiveTripPosition? position;
  @override
  final BuiltList<StopEta> etas;
  @override
  final DateTime serverTime;

  factory _$LiveTrip([void Function(LiveTripBuilder)? updates]) =>
      (LiveTripBuilder()..update(updates))._build();

  _$LiveTrip._(
      {required this.tripId,
      required this.patternVersionId,
      this.geometryId,
      this.riderPickupOccurrenceId,
      required this.state,
      this.position,
      required this.etas,
      required this.serverTime})
      : super._();
  @override
  LiveTrip rebuild(void Function(LiveTripBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LiveTripBuilder toBuilder() => LiveTripBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LiveTrip &&
        tripId == other.tripId &&
        patternVersionId == other.patternVersionId &&
        geometryId == other.geometryId &&
        riderPickupOccurrenceId == other.riderPickupOccurrenceId &&
        state == other.state &&
        position == other.position &&
        etas == other.etas &&
        serverTime == other.serverTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, geometryId.hashCode);
    _$hash = $jc(_$hash, riderPickupOccurrenceId.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, position.hashCode);
    _$hash = $jc(_$hash, etas.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LiveTrip')
          ..add('tripId', tripId)
          ..add('patternVersionId', patternVersionId)
          ..add('geometryId', geometryId)
          ..add('riderPickupOccurrenceId', riderPickupOccurrenceId)
          ..add('state', state)
          ..add('position', position)
          ..add('etas', etas)
          ..add('serverTime', serverTime))
        .toString();
  }
}

class LiveTripBuilder implements Builder<LiveTrip, LiveTripBuilder> {
  _$LiveTrip? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  String? _geometryId;
  String? get geometryId => _$this._geometryId;
  set geometryId(String? geometryId) => _$this._geometryId = geometryId;

  String? _riderPickupOccurrenceId;
  String? get riderPickupOccurrenceId => _$this._riderPickupOccurrenceId;
  set riderPickupOccurrenceId(String? riderPickupOccurrenceId) =>
      _$this._riderPickupOccurrenceId = riderPickupOccurrenceId;

  LiveTripStateEnum? _state;
  LiveTripStateEnum? get state => _$this._state;
  set state(LiveTripStateEnum? state) => _$this._state = state;

  LiveTripPositionBuilder? _position;
  LiveTripPositionBuilder get position =>
      _$this._position ??= LiveTripPositionBuilder();
  set position(LiveTripPositionBuilder? position) =>
      _$this._position = position;

  ListBuilder<StopEta>? _etas;
  ListBuilder<StopEta> get etas => _$this._etas ??= ListBuilder<StopEta>();
  set etas(ListBuilder<StopEta>? etas) => _$this._etas = etas;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  LiveTripBuilder() {
    LiveTrip._defaults(this);
  }

  LiveTripBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _patternVersionId = $v.patternVersionId;
      _geometryId = $v.geometryId;
      _riderPickupOccurrenceId = $v.riderPickupOccurrenceId;
      _state = $v.state;
      _position = $v.position?.toBuilder();
      _etas = $v.etas.toBuilder();
      _serverTime = $v.serverTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LiveTrip other) {
    _$v = other as _$LiveTrip;
  }

  @override
  void update(void Function(LiveTripBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LiveTrip build() => _build();

  _$LiveTrip _build() {
    _$LiveTrip _$result;
    try {
      _$result = _$v ??
          _$LiveTrip._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'LiveTrip', 'tripId'),
            patternVersionId: BuiltValueNullFieldError.checkNotNull(
                patternVersionId, r'LiveTrip', 'patternVersionId'),
            geometryId: geometryId,
            riderPickupOccurrenceId: riderPickupOccurrenceId,
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'LiveTrip', 'state'),
            position: _position?.build(),
            etas: etas.build(),
            serverTime: BuiltValueNullFieldError.checkNotNull(
                serverTime, r'LiveTrip', 'serverTime'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'position';
        _position?.build();
        _$failedField = 'etas';
        etas.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LiveTrip', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
