// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripRunNumberEnum _$tripRunNumberEnum_number1 =
    const TripRunNumberEnum._('number1');

TripRunNumberEnum _$tripRunNumberEnumValueOf(String name) {
  switch (name) {
    case 'number1':
      return _$tripRunNumberEnum_number1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripRunNumberEnum> _$tripRunNumberEnumValues =
    BuiltSet<TripRunNumberEnum>(const <TripRunNumberEnum>[
  _$tripRunNumberEnum_number1,
]);

const TripDirectionEnum _$tripDirectionEnum_outbound =
    const TripDirectionEnum._('outbound');
const TripDirectionEnum _$tripDirectionEnum_return_ =
    const TripDirectionEnum._('return_');

TripDirectionEnum _$tripDirectionEnumValueOf(String name) {
  switch (name) {
    case 'outbound':
      return _$tripDirectionEnum_outbound;
    case 'return_':
      return _$tripDirectionEnum_return_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripDirectionEnum> _$tripDirectionEnumValues =
    BuiltSet<TripDirectionEnum>(const <TripDirectionEnum>[
  _$tripDirectionEnum_outbound,
  _$tripDirectionEnum_return_,
]);

const TripStatusEnum _$tripStatusEnum_scheduled =
    const TripStatusEnum._('scheduled');
const TripStatusEnum _$tripStatusEnum_active = const TripStatusEnum._('active');
const TripStatusEnum _$tripStatusEnum_completed =
    const TripStatusEnum._('completed');
const TripStatusEnum _$tripStatusEnum_cancelled =
    const TripStatusEnum._('cancelled');

TripStatusEnum _$tripStatusEnumValueOf(String name) {
  switch (name) {
    case 'scheduled':
      return _$tripStatusEnum_scheduled;
    case 'active':
      return _$tripStatusEnum_active;
    case 'completed':
      return _$tripStatusEnum_completed;
    case 'cancelled':
      return _$tripStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripStatusEnum> _$tripStatusEnumValues =
    BuiltSet<TripStatusEnum>(const <TripStatusEnum>[
  _$tripStatusEnum_scheduled,
  _$tripStatusEnum_active,
  _$tripStatusEnum_completed,
  _$tripStatusEnum_cancelled,
]);

Serializer<TripRunNumberEnum> _$tripRunNumberEnumSerializer =
    _$TripRunNumberEnumSerializer();
Serializer<TripDirectionEnum> _$tripDirectionEnumSerializer =
    _$TripDirectionEnumSerializer();
Serializer<TripStatusEnum> _$tripStatusEnumSerializer =
    _$TripStatusEnumSerializer();

class _$TripRunNumberEnumSerializer
    implements PrimitiveSerializer<TripRunNumberEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'number1': 1,
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    1: 'number1',
  };

  @override
  final Iterable<Type> types = const <Type>[TripRunNumberEnum];
  @override
  final String wireName = 'TripRunNumberEnum';

  @override
  Object serialize(Serializers serializers, TripRunNumberEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripRunNumberEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripRunNumberEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripDirectionEnumSerializer
    implements PrimitiveSerializer<TripDirectionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'outbound': 'outbound',
    'return_': 'return',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'outbound': 'outbound',
    'return': 'return_',
  };

  @override
  final Iterable<Type> types = const <Type>[TripDirectionEnum];
  @override
  final String wireName = 'TripDirectionEnum';

  @override
  Object serialize(Serializers serializers, TripDirectionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripDirectionEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripDirectionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripStatusEnumSerializer
    implements PrimitiveSerializer<TripStatusEnum> {
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
  final Iterable<Type> types = const <Type>[TripStatusEnum];
  @override
  final String wireName = 'TripStatusEnum';

  @override
  Object serialize(Serializers serializers, TripStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Trip extends Trip {
  @override
  final String id;
  @override
  final String departureId;
  @override
  final Date serviceDate;
  @override
  final TripRunNumberEnum runNumber;
  @override
  final String routeId;
  @override
  final String patternId;
  @override
  final String patternVersionId;
  @override
  final TripDirectionEnum direction;
  @override
  final DateTime scheduledAt;
  @override
  final TripStatusEnum status;
  @override
  final String? vehicleLabel;

  factory _$Trip([void Function(TripBuilder)? updates]) =>
      (TripBuilder()..update(updates))._build();

  _$Trip._(
      {required this.id,
      required this.departureId,
      required this.serviceDate,
      required this.runNumber,
      required this.routeId,
      required this.patternId,
      required this.patternVersionId,
      required this.direction,
      required this.scheduledAt,
      required this.status,
      this.vehicleLabel})
      : super._();
  @override
  Trip rebuild(void Function(TripBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripBuilder toBuilder() => TripBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Trip &&
        id == other.id &&
        departureId == other.departureId &&
        serviceDate == other.serviceDate &&
        runNumber == other.runNumber &&
        routeId == other.routeId &&
        patternId == other.patternId &&
        patternVersionId == other.patternVersionId &&
        direction == other.direction &&
        scheduledAt == other.scheduledAt &&
        status == other.status &&
        vehicleLabel == other.vehicleLabel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, departureId.hashCode);
    _$hash = $jc(_$hash, serviceDate.hashCode);
    _$hash = $jc(_$hash, runNumber.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, patternId.hashCode);
    _$hash = $jc(_$hash, patternVersionId.hashCode);
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, vehicleLabel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Trip')
          ..add('id', id)
          ..add('departureId', departureId)
          ..add('serviceDate', serviceDate)
          ..add('runNumber', runNumber)
          ..add('routeId', routeId)
          ..add('patternId', patternId)
          ..add('patternVersionId', patternVersionId)
          ..add('direction', direction)
          ..add('scheduledAt', scheduledAt)
          ..add('status', status)
          ..add('vehicleLabel', vehicleLabel))
        .toString();
  }
}

class TripBuilder implements Builder<Trip, TripBuilder> {
  _$Trip? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _departureId;
  String? get departureId => _$this._departureId;
  set departureId(String? departureId) => _$this._departureId = departureId;

  Date? _serviceDate;
  Date? get serviceDate => _$this._serviceDate;
  set serviceDate(Date? serviceDate) => _$this._serviceDate = serviceDate;

  TripRunNumberEnum? _runNumber;
  TripRunNumberEnum? get runNumber => _$this._runNumber;
  set runNumber(TripRunNumberEnum? runNumber) => _$this._runNumber = runNumber;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _patternId;
  String? get patternId => _$this._patternId;
  set patternId(String? patternId) => _$this._patternId = patternId;

  String? _patternVersionId;
  String? get patternVersionId => _$this._patternVersionId;
  set patternVersionId(String? patternVersionId) =>
      _$this._patternVersionId = patternVersionId;

  TripDirectionEnum? _direction;
  TripDirectionEnum? get direction => _$this._direction;
  set direction(TripDirectionEnum? direction) => _$this._direction = direction;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  TripStatusEnum? _status;
  TripStatusEnum? get status => _$this._status;
  set status(TripStatusEnum? status) => _$this._status = status;

  String? _vehicleLabel;
  String? get vehicleLabel => _$this._vehicleLabel;
  set vehicleLabel(String? vehicleLabel) => _$this._vehicleLabel = vehicleLabel;

  TripBuilder() {
    Trip._defaults(this);
  }

  TripBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _departureId = $v.departureId;
      _serviceDate = $v.serviceDate;
      _runNumber = $v.runNumber;
      _routeId = $v.routeId;
      _patternId = $v.patternId;
      _patternVersionId = $v.patternVersionId;
      _direction = $v.direction;
      _scheduledAt = $v.scheduledAt;
      _status = $v.status;
      _vehicleLabel = $v.vehicleLabel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Trip other) {
    _$v = other as _$Trip;
  }

  @override
  void update(void Function(TripBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Trip build() => _build();

  _$Trip _build() {
    final _$result = _$v ??
        _$Trip._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Trip', 'id'),
          departureId: BuiltValueNullFieldError.checkNotNull(
              departureId, r'Trip', 'departureId'),
          serviceDate: BuiltValueNullFieldError.checkNotNull(
              serviceDate, r'Trip', 'serviceDate'),
          runNumber: BuiltValueNullFieldError.checkNotNull(
              runNumber, r'Trip', 'runNumber'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'Trip', 'routeId'),
          patternId: BuiltValueNullFieldError.checkNotNull(
              patternId, r'Trip', 'patternId'),
          patternVersionId: BuiltValueNullFieldError.checkNotNull(
              patternVersionId, r'Trip', 'patternVersionId'),
          direction: BuiltValueNullFieldError.checkNotNull(
              direction, r'Trip', 'direction'),
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'Trip', 'scheduledAt'),
          status:
              BuiltValueNullFieldError.checkNotNull(status, r'Trip', 'status'),
          vehicleLabel: vehicleLabel,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
