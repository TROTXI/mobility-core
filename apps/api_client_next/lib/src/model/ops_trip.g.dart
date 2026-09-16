// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_trip.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsTripRunNumberEnum _$opsTripRunNumberEnum_number1 =
    const OpsTripRunNumberEnum._('number1');

OpsTripRunNumberEnum _$opsTripRunNumberEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$opsTripRunNumberEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsTripRunNumberEnum> _$opsTripRunNumberEnumValues =
    BuiltSet<OpsTripRunNumberEnum>(const <OpsTripRunNumberEnum>[
  _$opsTripRunNumberEnum_number1,
]);

const OpsTripDirectionEnum _$opsTripDirectionEnum_outbound =
    const OpsTripDirectionEnum._('outbound');
const OpsTripDirectionEnum _$opsTripDirectionEnum_return_ =
    const OpsTripDirectionEnum._('return_');

OpsTripDirectionEnum _$opsTripDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$opsTripDirectionEnum_outbound;
    case 'return_':
      return _$opsTripDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsTripDirectionEnum> _$opsTripDirectionEnumValues =
    BuiltSet<OpsTripDirectionEnum>(const <OpsTripDirectionEnum>[
  _$opsTripDirectionEnum_outbound,
  _$opsTripDirectionEnum_return_,
]);

const OpsTripStatusEnum _$opsTripStatusEnum_scheduled =
    const OpsTripStatusEnum._('scheduled');
const OpsTripStatusEnum _$opsTripStatusEnum_active =
    const OpsTripStatusEnum._('active');
const OpsTripStatusEnum _$opsTripStatusEnum_completed =
    const OpsTripStatusEnum._('completed');
const OpsTripStatusEnum _$opsTripStatusEnum_cancelled =
    const OpsTripStatusEnum._('cancelled');

OpsTripStatusEnum _$opsTripStatusEnumValueOf(String name) {
  switch (name) {
    case 'scheduled':
      return _$opsTripStatusEnum_scheduled;
    case 'active':
      return _$opsTripStatusEnum_active;
    case 'completed':
      return _$opsTripStatusEnum_completed;
    case 'cancelled':
      return _$opsTripStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsTripStatusEnum> _$opsTripStatusEnumValues =
    BuiltSet<OpsTripStatusEnum>(const <OpsTripStatusEnum>[
  _$opsTripStatusEnum_scheduled,
  _$opsTripStatusEnum_active,
  _$opsTripStatusEnum_completed,
  _$opsTripStatusEnum_cancelled,
]);

Serializer<OpsTripRunNumberEnum> _$opsTripRunNumberEnumSerializer =
    _$OpsTripRunNumberEnumSerializer();
Serializer<OpsTripDirectionEnum> _$opsTripDirectionEnumSerializer =
    _$OpsTripDirectionEnumSerializer();
Serializer<OpsTripStatusEnum> _$opsTripStatusEnumSerializer =
    _$OpsTripStatusEnumSerializer();

class _$OpsTripRunNumberEnumSerializer
    implements PrimitiveSerializer<OpsTripRunNumberEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsTripRunNumberEnum];
  @override
  final String wireName = 'OpsTripRunNumberEnum';

  @override
  Object serialize(Serializers serializers, OpsTripRunNumberEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsTripRunNumberEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsTripRunNumberEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsTripDirectionEnumSerializer
    implements PrimitiveSerializer<OpsTripDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsTripDirectionEnum];
  @override
  final String wireName = 'OpsTripDirectionEnum';

  @override
  Object serialize(Serializers serializers, OpsTripDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsTripDirectionEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsTripDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsTripStatusEnumSerializer
    implements PrimitiveSerializer<OpsTripStatusEnum> {
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
  final Iterable<Type> types = const <Type>[OpsTripStatusEnum];
  @override
  final String wireName = 'OpsTripStatusEnum';

  @override
  Object serialize(Serializers serializers, OpsTripStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsTripStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsTripStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsTrip extends OpsTrip {
  @override
  final String id;
  @override
  final String departureId;
  @override
  final Date serviceDate;
  @override
  final OpsTripRunNumberEnum runNumber;
  @override
  final String routeId;
  @override
  final String patternVersionId;
  @override
  final OpsTripDirectionEnum direction;
  @override
  final DateTime scheduledAt;
  @override
  final OpsTripStatusEnum status;
  @override
  final String? vehicleLabel;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? currentStopOccurrenceId;
  @override
  final BuiltList<StopOccurrence> stops;
  @override
  final int version;
  @override
  final String editToken;
  @override
  final String scheduleId;
  @override
  final String? assignedDriverId;
  @override
  final String? vehicleId;

  factory _$OpsTrip([void Function(OpsTripBuilder)? updates]) =>
      (OpsTripBuilder()..update(updates))._build();

  _$OpsTrip._(
      {required this.id,
      required this.departureId,
      required this.serviceDate,
      required this.runNumber,
      required this.routeId,
      required this.patternVersionId,
      required this.direction,
      required this.scheduledAt,
      required this.status,
      this.vehicleLabel,
      this.startedAt,
      this.completedAt,
      this.currentStopOccurrenceId,
      required this.stops,
      required this.version,
      required this.editToken,
      required this.scheduleId,
      this.assignedDriverId,
      this.vehicleId})
      : super._();
  @override
  OpsTrip rebuild(void Function(OpsTripBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsTripBuilder toBuilder() => OpsTripBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsTrip &&
        id == other.id &&
        departureId == other.departureId &&
        serviceDate == other.serviceDate &&
        runNumber == other.runNumber &&
        routeId == other.routeId &&
        patternVersionId == other.patternVersionId &&
        direction == other.direction &&
        scheduledAt == other.scheduledAt &&
        status == other.status &&
        vehicleLabel == other.vehicleLabel &&
        startedAt == other.startedAt &&
        completedAt == other.completedAt &&
        currentStopOccurrenceId == other.currentStopOccurrenceId &&
        stops == other.stops &&
        version == other.version &&
        editToken == other.editToken &&
        scheduleId == other.scheduleId &&
        assignedDriverId == other.assignedDriverId &&
        vehicleId == other.vehicleId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, departureId.hashCode);
    _$hash = $jc(_$hash, serviceDate.hashCode);
    _$hash = $jc(_$hash, runNumber.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, vehicleLabel.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, currentStopOccurrenceId.hashCode);
    _$hash = $jc(_$hash, stops.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, scheduleId.hashCode);
    _$hash = $jc(_$hash, assignedDriverId.hashCode);
    _$hash = $jc(_$hash, vehicleId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsTrip')
          ..add('id', id)
          ..add('departureId', departureId)
          ..add('serviceDate', serviceDate)
          ..add('runNumber', runNumber)
          ..add('routeId', routeId)
          ..add('patternVersionId', patternVersionId)
          ..add('direction', direction)
          ..add('scheduledAt', scheduledAt)
          ..add('status', status)
          ..add('vehicleLabel', vehicleLabel)
          ..add('startedAt', startedAt)
          ..add('completedAt', completedAt)
          ..add('currentStopOccurrenceId', currentStopOccurrenceId)
          ..add('stops', stops)
          ..add('version', version)
          ..add('editToken', editToken)
          ..add('scheduleId', scheduleId)
          ..add('assignedDriverId', assignedDriverId)
          ..add('vehicleId', vehicleId))
        .toString();
  }
}

class OpsTripBuilder implements Builder<OpsTrip, OpsTripBuilder> {
  _$OpsTrip? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _departureId;
  String? get departureId => _$this._departureId;
  set departureId(String? departureId) => _$this._departureId = departureId;

  Date? _serviceDate;
  Date? get serviceDate => _$this._serviceDate;
  set serviceDate(Date? serviceDate) => _$this._serviceDate = serviceDate;

  OpsTripRunNumberEnum? _runNumber;
  OpsTripRunNumberEnum? get runNumber => _$this._runNumber;
  set runNumber(OpsTripRunNumberEnum? runNumber) =>
      _$this._runNumber = runNumber;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  OpsTripDirectionEnum? _direction;
  OpsTripDirectionEnum? get direction => _$this._direction;
  set direction(OpsTripDirectionEnum? direction) =>
      _$this._direction = direction;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  OpsTripStatusEnum? _status;
  OpsTripStatusEnum? get status => _$this._status;
  set status(OpsTripStatusEnum? status) => _$this._status = status;

  String? _vehicleLabel;
  String? get vehicleLabel => _$this._vehicleLabel;
  set vehicleLabel(String? vehicleLabel) => _$this._vehicleLabel = vehicleLabel;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  String? _currentStopOccurrenceId;
  String? get currentStopOccurrenceId => _$this._currentStopOccurrenceId;
  set currentStopOccurrenceId(String? currentStopOccurrenceId) =>
      _$this._currentStopOccurrenceId = currentStopOccurrenceId;

  ListBuilder<StopOccurrence>? _stops;
  ListBuilder<StopOccurrence> get stops =>
      _$this._stops ??= ListBuilder<StopOccurrence>();
  set stops(ListBuilder<StopOccurrence>? stops) => _$this._stops = stops;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  String? _scheduleId;
  String? get scheduleId => _$this._scheduleId;
  set scheduleId(String? scheduleId) => _$this._scheduleId = scheduleId;

  String? _assignedDriverId;
  String? get assignedDriverId => _$this._assignedDriverId;
  set assignedDriverId(String? assignedDriverId) =>
      _$this._assignedDriverId = assignedDriverId;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  OpsTripBuilder() {
    OpsTrip._defaults(this);
  }

  OpsTripBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _departureId = $v.departureId;
      _serviceDate = $v.serviceDate;
      _runNumber = $v.runNumber;
      _routeId = $v.routeId;
      _patternVersionId = $v.patternVersionId;
      _direction = $v.direction;
      _scheduledAt = $v.scheduledAt;
      _status = $v.status;
      _vehicleLabel = $v.vehicleLabel;
      _startedAt = $v.startedAt;
      _completedAt = $v.completedAt;
      _currentStopOccurrenceId = $v.currentStopOccurrenceId;
      _stops = $v.stops.toBuilder();
      _version = $v.version;
      _editToken = $v.editToken;
      _scheduleId = $v.scheduleId;
      _assignedDriverId = $v.assignedDriverId;
      _vehicleId = $v.vehicleId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsTrip other) {
    _$v = other as _$OpsTrip;
  }

  @override
  void update(void Function(OpsTripBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsTrip build() => _build();

  _$OpsTrip _build() {
    _$OpsTrip _$result;
    try {
      _$result = _$v ??
          _$OpsTrip._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'OpsTrip', 'id'),
            departureId: BuiltValueNullFieldError.checkNotNull(
                departureId, r'OpsTrip', 'departureId'),
            serviceDate: BuiltValueNullFieldError.checkNotNull(
                serviceDate, r'OpsTrip', 'serviceDate'),
            runNumber: BuiltValueNullFieldError.checkNotNull(
                runNumber, r'OpsTrip', 'runNumber'),
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'OpsTrip', 'routeId'),
            patternVersionId: BuiltValueNullFieldError.checkNotNull(
                patternVersionId, r'OpsTrip', 'patternVersionId'),
            direction: BuiltValueNullFieldError.checkNotNull(
                direction, r'OpsTrip', 'direction'),
            scheduledAt: BuiltValueNullFieldError.checkNotNull(
                scheduledAt, r'OpsTrip', 'scheduledAt'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'OpsTrip', 'status'),
            vehicleLabel: vehicleLabel,
            startedAt: startedAt,
            completedAt: completedAt,
            currentStopOccurrenceId: currentStopOccurrenceId,
            stops: stops.build(),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'OpsTrip', 'version'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'OpsTrip', 'editToken'),
            scheduleId: BuiltValueNullFieldError.checkNotNull(
                scheduleId, r'OpsTrip', 'scheduleId'),
            assignedDriverId: assignedDriverId,
            vehicleId: vehicleId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stops';
        stops.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsTrip', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
