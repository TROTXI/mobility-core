// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripsIdGet200ResponseStatusEnum
    _$tripsIdGet200ResponseStatusEnum_scheduled =
    const TripsIdGet200ResponseStatusEnum._('scheduled');
const TripsIdGet200ResponseStatusEnum _$tripsIdGet200ResponseStatusEnum_active =
    const TripsIdGet200ResponseStatusEnum._('active');
const TripsIdGet200ResponseStatusEnum
    _$tripsIdGet200ResponseStatusEnum_completed =
    const TripsIdGet200ResponseStatusEnum._('completed');
const TripsIdGet200ResponseStatusEnum
    _$tripsIdGet200ResponseStatusEnum_cancelled =
    const TripsIdGet200ResponseStatusEnum._('cancelled');

TripsIdGet200ResponseStatusEnum _$tripsIdGet200ResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'scheduled':
      return _$tripsIdGet200ResponseStatusEnum_scheduled;
    case 'active':
      return _$tripsIdGet200ResponseStatusEnum_active;
    case 'completed':
      return _$tripsIdGet200ResponseStatusEnum_completed;
    case 'cancelled':
      return _$tripsIdGet200ResponseStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripsIdGet200ResponseStatusEnum>
    _$tripsIdGet200ResponseStatusEnumValues = BuiltSet<
        TripsIdGet200ResponseStatusEnum>(const <TripsIdGet200ResponseStatusEnum>[
  _$tripsIdGet200ResponseStatusEnum_scheduled,
  _$tripsIdGet200ResponseStatusEnum_active,
  _$tripsIdGet200ResponseStatusEnum_completed,
  _$tripsIdGet200ResponseStatusEnum_cancelled,
]);

Serializer<TripsIdGet200ResponseStatusEnum>
    _$tripsIdGet200ResponseStatusEnumSerializer =
    _$TripsIdGet200ResponseStatusEnumSerializer();

class _$TripsIdGet200ResponseStatusEnumSerializer
    implements PrimitiveSerializer<TripsIdGet200ResponseStatusEnum> {
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
  final Iterable<Type> types = const <Type>[TripsIdGet200ResponseStatusEnum];
  @override
  final String wireName = 'TripsIdGet200ResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, TripsIdGet200ResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripsIdGet200ResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripsIdGet200ResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripsIdGet200Response extends TripsIdGet200Response {
  @override
  final String id;
  @override
  final String routeId;
  @override
  final String? vehicleId;
  @override
  final String? assignedDriverId;
  @override
  final TripsIdGet200ResponseStatusEnum status;
  @override
  final DateTime scheduledAt;
  @override
  final int? currentStopSeq;
  @override
  final DateTime? assignmentChangedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final int? durationSeconds;
  @override
  final int stopCount;
  @override
  final TripsIdGet200ResponseVehicle? vehicle;

  factory _$TripsIdGet200Response(
          [void Function(TripsIdGet200ResponseBuilder)? updates]) =>
      (TripsIdGet200ResponseBuilder()..update(updates))._build();

  _$TripsIdGet200Response._(
      {required this.id,
      required this.routeId,
      this.vehicleId,
      this.assignedDriverId,
      required this.status,
      required this.scheduledAt,
      this.currentStopSeq,
      this.assignmentChangedAt,
      required this.createdAt,
      this.startedAt,
      this.completedAt,
      this.durationSeconds,
      required this.stopCount,
      this.vehicle})
      : super._();
  @override
  TripsIdGet200Response rebuild(
          void Function(TripsIdGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdGet200ResponseBuilder toBuilder() =>
      TripsIdGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdGet200Response &&
        id == other.id &&
        routeId == other.routeId &&
        vehicleId == other.vehicleId &&
        assignedDriverId == other.assignedDriverId &&
        status == other.status &&
        scheduledAt == other.scheduledAt &&
        currentStopSeq == other.currentStopSeq &&
        assignmentChangedAt == other.assignmentChangedAt &&
        createdAt == other.createdAt &&
        startedAt == other.startedAt &&
        completedAt == other.completedAt &&
        durationSeconds == other.durationSeconds &&
        stopCount == other.stopCount &&
        vehicle == other.vehicle;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, vehicleId.hashCode);
    _$hash = $jc(_$hash, assignedDriverId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, currentStopSeq.hashCode);
    _$hash = $jc(_$hash, assignmentChangedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, durationSeconds.hashCode);
    _$hash = $jc(_$hash, stopCount.hashCode);
    _$hash = $jc(_$hash, vehicle.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdGet200Response')
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('vehicleId', vehicleId)
          ..add('assignedDriverId', assignedDriverId)
          ..add('status', status)
          ..add('scheduledAt', scheduledAt)
          ..add('currentStopSeq', currentStopSeq)
          ..add('assignmentChangedAt', assignmentChangedAt)
          ..add('createdAt', createdAt)
          ..add('startedAt', startedAt)
          ..add('completedAt', completedAt)
          ..add('durationSeconds', durationSeconds)
          ..add('stopCount', stopCount)
          ..add('vehicle', vehicle))
        .toString();
  }
}

class TripsIdGet200ResponseBuilder
    implements Builder<TripsIdGet200Response, TripsIdGet200ResponseBuilder> {
  _$TripsIdGet200Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  String? _assignedDriverId;
  String? get assignedDriverId => _$this._assignedDriverId;
  set assignedDriverId(String? assignedDriverId) =>
      _$this._assignedDriverId = assignedDriverId;

  TripsIdGet200ResponseStatusEnum? _status;
  TripsIdGet200ResponseStatusEnum? get status => _$this._status;
  set status(TripsIdGet200ResponseStatusEnum? status) =>
      _$this._status = status;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  int? _currentStopSeq;
  int? get currentStopSeq => _$this._currentStopSeq;
  set currentStopSeq(int? currentStopSeq) =>
      _$this._currentStopSeq = currentStopSeq;

  DateTime? _assignmentChangedAt;
  DateTime? get assignmentChangedAt => _$this._assignmentChangedAt;
  set assignmentChangedAt(DateTime? assignmentChangedAt) =>
      _$this._assignmentChangedAt = assignmentChangedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  int? _durationSeconds;
  int? get durationSeconds => _$this._durationSeconds;
  set durationSeconds(int? durationSeconds) =>
      _$this._durationSeconds = durationSeconds;

  int? _stopCount;
  int? get stopCount => _$this._stopCount;
  set stopCount(int? stopCount) => _$this._stopCount = stopCount;

  TripsIdGet200ResponseVehicleBuilder? _vehicle;
  TripsIdGet200ResponseVehicleBuilder get vehicle =>
      _$this._vehicle ??= TripsIdGet200ResponseVehicleBuilder();
  set vehicle(TripsIdGet200ResponseVehicleBuilder? vehicle) =>
      _$this._vehicle = vehicle;

  TripsIdGet200ResponseBuilder() {
    TripsIdGet200Response._defaults(this);
  }

  TripsIdGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _routeId = $v.routeId;
      _vehicleId = $v.vehicleId;
      _assignedDriverId = $v.assignedDriverId;
      _status = $v.status;
      _scheduledAt = $v.scheduledAt;
      _currentStopSeq = $v.currentStopSeq;
      _assignmentChangedAt = $v.assignmentChangedAt;
      _createdAt = $v.createdAt;
      _startedAt = $v.startedAt;
      _completedAt = $v.completedAt;
      _durationSeconds = $v.durationSeconds;
      _stopCount = $v.stopCount;
      _vehicle = $v.vehicle?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdGet200Response other) {
    _$v = other as _$TripsIdGet200Response;
  }

  @override
  void update(void Function(TripsIdGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdGet200Response build() => _build();

  _$TripsIdGet200Response _build() {
    _$TripsIdGet200Response _$result;
    try {
      _$result = _$v ??
          _$TripsIdGet200Response._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'TripsIdGet200Response', 'id'),
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'TripsIdGet200Response', 'routeId'),
            vehicleId: vehicleId,
            assignedDriverId: assignedDriverId,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'TripsIdGet200Response', 'status'),
            scheduledAt: BuiltValueNullFieldError.checkNotNull(
                scheduledAt, r'TripsIdGet200Response', 'scheduledAt'),
            currentStopSeq: currentStopSeq,
            assignmentChangedAt: assignmentChangedAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'TripsIdGet200Response', 'createdAt'),
            startedAt: startedAt,
            completedAt: completedAt,
            durationSeconds: durationSeconds,
            stopCount: BuiltValueNullFieldError.checkNotNull(
                stopCount, r'TripsIdGet200Response', 'stopCount'),
            vehicle: _vehicle?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vehicle';
        _vehicle?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripsIdGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
