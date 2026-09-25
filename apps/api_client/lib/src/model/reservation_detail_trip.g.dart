// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_detail_trip.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReservationDetailTripStatusEnum
    _$reservationDetailTripStatusEnum_scheduled =
    const ReservationDetailTripStatusEnum._('scheduled');
const ReservationDetailTripStatusEnum _$reservationDetailTripStatusEnum_active =
    const ReservationDetailTripStatusEnum._('active');
const ReservationDetailTripStatusEnum
    _$reservationDetailTripStatusEnum_completed =
    const ReservationDetailTripStatusEnum._('completed');
const ReservationDetailTripStatusEnum
    _$reservationDetailTripStatusEnum_cancelled =
    const ReservationDetailTripStatusEnum._('cancelled');

ReservationDetailTripStatusEnum _$reservationDetailTripStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'scheduled':
      return _$reservationDetailTripStatusEnum_scheduled;
    case 'active':
      return _$reservationDetailTripStatusEnum_active;
    case 'completed':
      return _$reservationDetailTripStatusEnum_completed;
    case 'cancelled':
      return _$reservationDetailTripStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReservationDetailTripStatusEnum>
    _$reservationDetailTripStatusEnumValues = BuiltSet<
        ReservationDetailTripStatusEnum>(const <ReservationDetailTripStatusEnum>[
  _$reservationDetailTripStatusEnum_scheduled,
  _$reservationDetailTripStatusEnum_active,
  _$reservationDetailTripStatusEnum_completed,
  _$reservationDetailTripStatusEnum_cancelled,
]);

Serializer<ReservationDetailTripStatusEnum>
    _$reservationDetailTripStatusEnumSerializer =
    _$ReservationDetailTripStatusEnumSerializer();

class _$ReservationDetailTripStatusEnumSerializer
    implements PrimitiveSerializer<ReservationDetailTripStatusEnum> {
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
  final Iterable<Type> types = const <Type>[ReservationDetailTripStatusEnum];
  @override
  final String wireName = 'ReservationDetailTripStatusEnum';

  @override
  Object serialize(
          Serializers serializers, ReservationDetailTripStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReservationDetailTripStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReservationDetailTripStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ReservationDetailTrip extends ReservationDetailTrip {
  @override
  final String id;
  @override
  final DateTime scheduledAt;
  @override
  final ReservationDetailTripStatusEnum status;
  @override
  final String? vehicleLabel;
  @override
  final String? vehiclePlate;

  factory _$ReservationDetailTrip(
          [void Function(ReservationDetailTripBuilder)? updates]) =>
      (ReservationDetailTripBuilder()..update(updates))._build();

  _$ReservationDetailTrip._(
      {required this.id,
      required this.scheduledAt,
      required this.status,
      this.vehicleLabel,
      this.vehiclePlate})
      : super._();
  @override
  ReservationDetailTrip rebuild(
          void Function(ReservationDetailTripBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReservationDetailTripBuilder toBuilder() =>
      ReservationDetailTripBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReservationDetailTrip &&
        id == other.id &&
        scheduledAt == other.scheduledAt &&
        status == other.status &&
        vehicleLabel == other.vehicleLabel &&
        vehiclePlate == other.vehiclePlate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, vehicleLabel.hashCode);
    _$hash = $jc(_$hash, vehiclePlate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReservationDetailTrip')
          ..add('id', id)
          ..add('scheduledAt', scheduledAt)
          ..add('status', status)
          ..add('vehicleLabel', vehicleLabel)
          ..add('vehiclePlate', vehiclePlate))
        .toString();
  }
}

class ReservationDetailTripBuilder
    implements Builder<ReservationDetailTrip, ReservationDetailTripBuilder> {
  _$ReservationDetailTrip? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  ReservationDetailTripStatusEnum? _status;
  ReservationDetailTripStatusEnum? get status => _$this._status;
  set status(ReservationDetailTripStatusEnum? status) =>
      _$this._status = status;

  String? _vehicleLabel;
  String? get vehicleLabel => _$this._vehicleLabel;
  set vehicleLabel(String? vehicleLabel) => _$this._vehicleLabel = vehicleLabel;

  String? _vehiclePlate;
  String? get vehiclePlate => _$this._vehiclePlate;
  set vehiclePlate(String? vehiclePlate) => _$this._vehiclePlate = vehiclePlate;

  ReservationDetailTripBuilder() {
    ReservationDetailTrip._defaults(this);
  }

  ReservationDetailTripBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _scheduledAt = $v.scheduledAt;
      _status = $v.status;
      _vehicleLabel = $v.vehicleLabel;
      _vehiclePlate = $v.vehiclePlate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReservationDetailTrip other) {
    _$v = other as _$ReservationDetailTrip;
  }

  @override
  void update(void Function(ReservationDetailTripBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReservationDetailTrip build() => _build();

  _$ReservationDetailTrip _build() {
    final _$result = _$v ??
        _$ReservationDetailTrip._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ReservationDetailTrip', 'id'),
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'ReservationDetailTrip', 'scheduledAt'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ReservationDetailTrip', 'status'),
          vehicleLabel: vehicleLabel,
          vehiclePlate: vehiclePlate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
