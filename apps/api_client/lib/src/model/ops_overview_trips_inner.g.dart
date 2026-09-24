// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_overview_trips_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsOverviewTripsInnerStatusEnum
    _$opsOverviewTripsInnerStatusEnum_scheduled =
    const OpsOverviewTripsInnerStatusEnum._('scheduled');
const OpsOverviewTripsInnerStatusEnum _$opsOverviewTripsInnerStatusEnum_active =
    const OpsOverviewTripsInnerStatusEnum._('active');
const OpsOverviewTripsInnerStatusEnum
    _$opsOverviewTripsInnerStatusEnum_completed =
    const OpsOverviewTripsInnerStatusEnum._('completed');
const OpsOverviewTripsInnerStatusEnum
    _$opsOverviewTripsInnerStatusEnum_cancelled =
    const OpsOverviewTripsInnerStatusEnum._('cancelled');

OpsOverviewTripsInnerStatusEnum _$opsOverviewTripsInnerStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'scheduled':
      return _$opsOverviewTripsInnerStatusEnum_scheduled;
    case 'active':
      return _$opsOverviewTripsInnerStatusEnum_active;
    case 'completed':
      return _$opsOverviewTripsInnerStatusEnum_completed;
    case 'cancelled':
      return _$opsOverviewTripsInnerStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsOverviewTripsInnerStatusEnum>
    _$opsOverviewTripsInnerStatusEnumValues = BuiltSet<
        OpsOverviewTripsInnerStatusEnum>(const <OpsOverviewTripsInnerStatusEnum>[
  _$opsOverviewTripsInnerStatusEnum_scheduled,
  _$opsOverviewTripsInnerStatusEnum_active,
  _$opsOverviewTripsInnerStatusEnum_completed,
  _$opsOverviewTripsInnerStatusEnum_cancelled,
]);

const OpsOverviewTripsInnerBadgeEnum _$opsOverviewTripsInnerBadgeEnum_onTime =
    const OpsOverviewTripsInnerBadgeEnum._('onTime');
const OpsOverviewTripsInnerBadgeEnum _$opsOverviewTripsInnerBadgeEnum_staleGps =
    const OpsOverviewTripsInnerBadgeEnum._('staleGps');
const OpsOverviewTripsInnerBadgeEnum
    _$opsOverviewTripsInnerBadgeEnum_unassigned =
    const OpsOverviewTripsInnerBadgeEnum._('unassigned');

OpsOverviewTripsInnerBadgeEnum _$opsOverviewTripsInnerBadgeEnumValueOf(
    String name) {
  switch (name) {
    case 'onTime':
      return _$opsOverviewTripsInnerBadgeEnum_onTime;
    case 'staleGps':
      return _$opsOverviewTripsInnerBadgeEnum_staleGps;
    case 'unassigned':
      return _$opsOverviewTripsInnerBadgeEnum_unassigned;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsOverviewTripsInnerBadgeEnum>
    _$opsOverviewTripsInnerBadgeEnumValues = BuiltSet<
        OpsOverviewTripsInnerBadgeEnum>(const <OpsOverviewTripsInnerBadgeEnum>[
  _$opsOverviewTripsInnerBadgeEnum_onTime,
  _$opsOverviewTripsInnerBadgeEnum_staleGps,
  _$opsOverviewTripsInnerBadgeEnum_unassigned,
]);

Serializer<OpsOverviewTripsInnerStatusEnum>
    _$opsOverviewTripsInnerStatusEnumSerializer =
    _$OpsOverviewTripsInnerStatusEnumSerializer();
Serializer<OpsOverviewTripsInnerBadgeEnum>
    _$opsOverviewTripsInnerBadgeEnumSerializer =
    _$OpsOverviewTripsInnerBadgeEnumSerializer();

class _$OpsOverviewTripsInnerStatusEnumSerializer
    implements PrimitiveSerializer<OpsOverviewTripsInnerStatusEnum> {
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
  final Iterable<Type> types = const <Type>[OpsOverviewTripsInnerStatusEnum];
  @override
  final String wireName = 'OpsOverviewTripsInnerStatusEnum';

  @override
  Object serialize(
          Serializers serializers, OpsOverviewTripsInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsOverviewTripsInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsOverviewTripsInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsOverviewTripsInnerBadgeEnumSerializer
    implements PrimitiveSerializer<OpsOverviewTripsInnerBadgeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'onTime': 'on_time',
    'staleGps': 'stale_gps',
    'unassigned': 'unassigned',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'on_time': 'onTime',
    'stale_gps': 'staleGps',
    'unassigned': 'unassigned',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsOverviewTripsInnerBadgeEnum];
  @override
  final String wireName = 'OpsOverviewTripsInnerBadgeEnum';

  @override
  Object serialize(
          Serializers serializers, OpsOverviewTripsInnerBadgeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsOverviewTripsInnerBadgeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsOverviewTripsInnerBadgeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsOverviewTripsInner extends OpsOverviewTripsInner {
  @override
  final String tripId;
  @override
  final DateTime scheduledAt;
  @override
  final OpsOverviewTripsInnerStatusEnum status;
  @override
  final String? routeName;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final String? vehicleId;
  @override
  final String? vehicleLabel;
  @override
  final int? capacity;
  @override
  final int confirmed;
  @override
  final int boarded;
  @override
  final int noShow;
  @override
  final DateTime? lastFixAt;
  @override
  final int? fixAgeSeconds;
  @override
  final IncidentLocation? lastPosition;
  @override
  final OpsOverviewTripsInnerBadgeEnum badge;

  factory _$OpsOverviewTripsInner(
          [void Function(OpsOverviewTripsInnerBuilder)? updates]) =>
      (OpsOverviewTripsInnerBuilder()..update(updates))._build();

  _$OpsOverviewTripsInner._(
      {required this.tripId,
      required this.scheduledAt,
      required this.status,
      this.routeName,
      this.driverId,
      this.driverName,
      this.vehicleId,
      this.vehicleLabel,
      this.capacity,
      required this.confirmed,
      required this.boarded,
      required this.noShow,
      this.lastFixAt,
      this.fixAgeSeconds,
      this.lastPosition,
      required this.badge})
      : super._();
  @override
  OpsOverviewTripsInner rebuild(
          void Function(OpsOverviewTripsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsOverviewTripsInnerBuilder toBuilder() =>
      OpsOverviewTripsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsOverviewTripsInner &&
        tripId == other.tripId &&
        scheduledAt == other.scheduledAt &&
        status == other.status &&
        routeName == other.routeName &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        vehicleId == other.vehicleId &&
        vehicleLabel == other.vehicleLabel &&
        capacity == other.capacity &&
        confirmed == other.confirmed &&
        boarded == other.boarded &&
        noShow == other.noShow &&
        lastFixAt == other.lastFixAt &&
        fixAgeSeconds == other.fixAgeSeconds &&
        lastPosition == other.lastPosition &&
        badge == other.badge;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, routeName.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, vehicleId.hashCode);
    _$hash = $jc(_$hash, vehicleLabel.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jc(_$hash, confirmed.hashCode);
    _$hash = $jc(_$hash, boarded.hashCode);
    _$hash = $jc(_$hash, noShow.hashCode);
    _$hash = $jc(_$hash, lastFixAt.hashCode);
    _$hash = $jc(_$hash, fixAgeSeconds.hashCode);
    _$hash = $jc(_$hash, lastPosition.hashCode);
    _$hash = $jc(_$hash, badge.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsOverviewTripsInner')
          ..add('tripId', tripId)
          ..add('scheduledAt', scheduledAt)
          ..add('status', status)
          ..add('routeName', routeName)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('vehicleId', vehicleId)
          ..add('vehicleLabel', vehicleLabel)
          ..add('capacity', capacity)
          ..add('confirmed', confirmed)
          ..add('boarded', boarded)
          ..add('noShow', noShow)
          ..add('lastFixAt', lastFixAt)
          ..add('fixAgeSeconds', fixAgeSeconds)
          ..add('lastPosition', lastPosition)
          ..add('badge', badge))
        .toString();
  }
}

class OpsOverviewTripsInnerBuilder
    implements Builder<OpsOverviewTripsInner, OpsOverviewTripsInnerBuilder> {
  _$OpsOverviewTripsInner? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  OpsOverviewTripsInnerStatusEnum? _status;
  OpsOverviewTripsInnerStatusEnum? get status => _$this._status;
  set status(OpsOverviewTripsInnerStatusEnum? status) =>
      _$this._status = status;

  String? _routeName;
  String? get routeName => _$this._routeName;
  set routeName(String? routeName) => _$this._routeName = routeName;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  String? _vehicleLabel;
  String? get vehicleLabel => _$this._vehicleLabel;
  set vehicleLabel(String? vehicleLabel) => _$this._vehicleLabel = vehicleLabel;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  int? _confirmed;
  int? get confirmed => _$this._confirmed;
  set confirmed(int? confirmed) => _$this._confirmed = confirmed;

  int? _boarded;
  int? get boarded => _$this._boarded;
  set boarded(int? boarded) => _$this._boarded = boarded;

  int? _noShow;
  int? get noShow => _$this._noShow;
  set noShow(int? noShow) => _$this._noShow = noShow;

  DateTime? _lastFixAt;
  DateTime? get lastFixAt => _$this._lastFixAt;
  set lastFixAt(DateTime? lastFixAt) => _$this._lastFixAt = lastFixAt;

  int? _fixAgeSeconds;
  int? get fixAgeSeconds => _$this._fixAgeSeconds;
  set fixAgeSeconds(int? fixAgeSeconds) =>
      _$this._fixAgeSeconds = fixAgeSeconds;

  IncidentLocationBuilder? _lastPosition;
  IncidentLocationBuilder get lastPosition =>
      _$this._lastPosition ??= IncidentLocationBuilder();
  set lastPosition(IncidentLocationBuilder? lastPosition) =>
      _$this._lastPosition = lastPosition;

  OpsOverviewTripsInnerBadgeEnum? _badge;
  OpsOverviewTripsInnerBadgeEnum? get badge => _$this._badge;
  set badge(OpsOverviewTripsInnerBadgeEnum? badge) => _$this._badge = badge;

  OpsOverviewTripsInnerBuilder() {
    OpsOverviewTripsInner._defaults(this);
  }

  OpsOverviewTripsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _scheduledAt = $v.scheduledAt;
      _status = $v.status;
      _routeName = $v.routeName;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _vehicleId = $v.vehicleId;
      _vehicleLabel = $v.vehicleLabel;
      _capacity = $v.capacity;
      _confirmed = $v.confirmed;
      _boarded = $v.boarded;
      _noShow = $v.noShow;
      _lastFixAt = $v.lastFixAt;
      _fixAgeSeconds = $v.fixAgeSeconds;
      _lastPosition = $v.lastPosition?.toBuilder();
      _badge = $v.badge;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsOverviewTripsInner other) {
    _$v = other as _$OpsOverviewTripsInner;
  }

  @override
  void update(void Function(OpsOverviewTripsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsOverviewTripsInner build() => _build();

  _$OpsOverviewTripsInner _build() {
    _$OpsOverviewTripsInner _$result;
    try {
      _$result = _$v ??
          _$OpsOverviewTripsInner._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'OpsOverviewTripsInner', 'tripId'),
            scheduledAt: BuiltValueNullFieldError.checkNotNull(
                scheduledAt, r'OpsOverviewTripsInner', 'scheduledAt'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OpsOverviewTripsInner', 'status'),
            routeName: routeName,
            driverId: driverId,
            driverName: driverName,
            vehicleId: vehicleId,
            vehicleLabel: vehicleLabel,
            capacity: capacity,
            confirmed: BuiltValueNullFieldError.checkNotNull(
                confirmed, r'OpsOverviewTripsInner', 'confirmed'),
            boarded: BuiltValueNullFieldError.checkNotNull(
                boarded, r'OpsOverviewTripsInner', 'boarded'),
            noShow: BuiltValueNullFieldError.checkNotNull(
                noShow, r'OpsOverviewTripsInner', 'noShow'),
            lastFixAt: lastFixAt,
            fixAgeSeconds: fixAgeSeconds,
            lastPosition: _lastPosition?.build(),
            badge: BuiltValueNullFieldError.checkNotNull(
                badge, r'OpsOverviewTripsInner', 'badge'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lastPosition';
        _lastPosition?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsOverviewTripsInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
