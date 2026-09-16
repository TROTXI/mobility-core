// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_trip.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverTripRunNumberEnum _$driverTripRunNumberEnum_number1 =
    const DriverTripRunNumberEnum._('number1');

DriverTripRunNumberEnum _$driverTripRunNumberEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$driverTripRunNumberEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverTripRunNumberEnum> _$driverTripRunNumberEnumValues =
    BuiltSet<DriverTripRunNumberEnum>(const <DriverTripRunNumberEnum>[
  _$driverTripRunNumberEnum_number1,
]);

const DriverTripDirectionEnum _$driverTripDirectionEnum_outbound =
    const DriverTripDirectionEnum._('outbound');
const DriverTripDirectionEnum _$driverTripDirectionEnum_return_ =
    const DriverTripDirectionEnum._('return_');

DriverTripDirectionEnum _$driverTripDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$driverTripDirectionEnum_outbound;
    case 'return_':
      return _$driverTripDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverTripDirectionEnum> _$driverTripDirectionEnumValues =
    BuiltSet<DriverTripDirectionEnum>(const <DriverTripDirectionEnum>[
  _$driverTripDirectionEnum_outbound,
  _$driverTripDirectionEnum_return_,
]);

const DriverTripStatusEnum _$driverTripStatusEnum_scheduled =
    const DriverTripStatusEnum._('scheduled');
const DriverTripStatusEnum _$driverTripStatusEnum_active =
    const DriverTripStatusEnum._('active');
const DriverTripStatusEnum _$driverTripStatusEnum_completed =
    const DriverTripStatusEnum._('completed');
const DriverTripStatusEnum _$driverTripStatusEnum_cancelled =
    const DriverTripStatusEnum._('cancelled');

DriverTripStatusEnum _$driverTripStatusEnumValueOf(String name) {
  switch (name) {
    case 'scheduled':
      return _$driverTripStatusEnum_scheduled;
    case 'active':
      return _$driverTripStatusEnum_active;
    case 'completed':
      return _$driverTripStatusEnum_completed;
    case 'cancelled':
      return _$driverTripStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverTripStatusEnum> _$driverTripStatusEnumValues =
    BuiltSet<DriverTripStatusEnum>(const <DriverTripStatusEnum>[
  _$driverTripStatusEnum_scheduled,
  _$driverTripStatusEnum_active,
  _$driverTripStatusEnum_completed,
  _$driverTripStatusEnum_cancelled,
]);

Serializer<DriverTripRunNumberEnum> _$driverTripRunNumberEnumSerializer =
    _$DriverTripRunNumberEnumSerializer();
Serializer<DriverTripDirectionEnum> _$driverTripDirectionEnumSerializer =
    _$DriverTripDirectionEnumSerializer();
Serializer<DriverTripStatusEnum> _$driverTripStatusEnumSerializer =
    _$DriverTripStatusEnumSerializer();

class _$DriverTripRunNumberEnumSerializer
    implements PrimitiveSerializer<DriverTripRunNumberEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverTripRunNumberEnum];
  @override
  final String wireName = 'DriverTripRunNumberEnum';

  @override
  Object serialize(Serializers serializers, DriverTripRunNumberEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverTripRunNumberEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverTripRunNumberEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverTripDirectionEnumSerializer
    implements PrimitiveSerializer<DriverTripDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverTripDirectionEnum];
  @override
  final String wireName = 'DriverTripDirectionEnum';

  @override
  Object serialize(Serializers serializers, DriverTripDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverTripDirectionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverTripDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverTripStatusEnumSerializer
    implements PrimitiveSerializer<DriverTripStatusEnum> {
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
  final Iterable<Type> types = const <Type>[DriverTripStatusEnum];
  @override
  final String wireName = 'DriverTripStatusEnum';

  @override
  Object serialize(Serializers serializers, DriverTripStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverTripStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverTripStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverTrip extends DriverTrip {
  @override
  final String id;
  @override
  final String departureId;
  @override
  final Date serviceDate;
  @override
  final DriverTripRunNumberEnum runNumber;
  @override
  final String routeId;
  @override
  final String patternVersionId;
  @override
  final DriverTripDirectionEnum direction;
  @override
  final DateTime scheduledAt;
  @override
  final DriverTripStatusEnum status;
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

  factory _$DriverTrip([void Function(DriverTripBuilder)? updates]) =>
      (DriverTripBuilder()..update(updates))._build();

  _$DriverTrip._(
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
      required this.editToken})
      : super._();
  @override
  DriverTrip rebuild(void Function(DriverTripBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverTripBuilder toBuilder() => DriverTripBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverTrip &&
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
        editToken == other.editToken;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverTrip')
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
          ..add('editToken', editToken))
        .toString();
  }
}

class DriverTripBuilder implements Builder<DriverTrip, DriverTripBuilder> {
  _$DriverTrip? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _departureId;
  String? get departureId => _$this._departureId;
  set departureId(String? departureId) => _$this._departureId = departureId;

  Date? _serviceDate;
  Date? get serviceDate => _$this._serviceDate;
  set serviceDate(Date? serviceDate) => _$this._serviceDate = serviceDate;

  DriverTripRunNumberEnum? _runNumber;
  DriverTripRunNumberEnum? get runNumber => _$this._runNumber;
  set runNumber(DriverTripRunNumberEnum? runNumber) =>
      _$this._runNumber = runNumber;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  DriverTripDirectionEnum? _direction;
  DriverTripDirectionEnum? get direction => _$this._direction;
  set direction(DriverTripDirectionEnum? direction) =>
      _$this._direction = direction;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  DriverTripStatusEnum? _status;
  DriverTripStatusEnum? get status => _$this._status;
  set status(DriverTripStatusEnum? status) => _$this._status = status;

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

  DriverTripBuilder() {
    DriverTrip._defaults(this);
  }

  DriverTripBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverTrip other) {
    _$v = other as _$DriverTrip;
  }

  @override
  void update(void Function(DriverTripBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverTrip build() => _build();

  _$DriverTrip _build() {
    _$DriverTrip _$result;
    try {
      _$result = _$v ??
          _$DriverTrip._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'DriverTrip', 'id'),
            departureId: BuiltValueNullFieldError.checkNotNull(
                departureId, r'DriverTrip', 'departureId'),
            serviceDate: BuiltValueNullFieldError.checkNotNull(
                serviceDate, r'DriverTrip', 'serviceDate'),
            runNumber: BuiltValueNullFieldError.checkNotNull(
                runNumber, r'DriverTrip', 'runNumber'),
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'DriverTrip', 'routeId'),
            patternVersionId: BuiltValueNullFieldError.checkNotNull(
                patternVersionId, r'DriverTrip', 'patternVersionId'),
            direction: BuiltValueNullFieldError.checkNotNull(
                direction, r'DriverTrip', 'direction'),
            scheduledAt: BuiltValueNullFieldError.checkNotNull(
                scheduledAt, r'DriverTrip', 'scheduledAt'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'DriverTrip', 'status'),
            vehicleLabel: vehicleLabel,
            startedAt: startedAt,
            completedAt: completedAt,
            currentStopOccurrenceId: currentStopOccurrenceId,
            stops: stops.build(),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'DriverTrip', 'version'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'DriverTrip', 'editToken'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stops';
        stops.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverTrip', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
