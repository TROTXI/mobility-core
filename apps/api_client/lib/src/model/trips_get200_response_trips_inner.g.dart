// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_get200_response_trips_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripsGet200ResponseTripsInnerStatusEnum
    _$tripsGet200ResponseTripsInnerStatusEnum_scheduled =
    const TripsGet200ResponseTripsInnerStatusEnum._('scheduled');
const TripsGet200ResponseTripsInnerStatusEnum
    _$tripsGet200ResponseTripsInnerStatusEnum_active =
    const TripsGet200ResponseTripsInnerStatusEnum._('active');
const TripsGet200ResponseTripsInnerStatusEnum
    _$tripsGet200ResponseTripsInnerStatusEnum_completed =
    const TripsGet200ResponseTripsInnerStatusEnum._('completed');
const TripsGet200ResponseTripsInnerStatusEnum
    _$tripsGet200ResponseTripsInnerStatusEnum_cancelled =
    const TripsGet200ResponseTripsInnerStatusEnum._('cancelled');

TripsGet200ResponseTripsInnerStatusEnum
    _$tripsGet200ResponseTripsInnerStatusEnumValueOf(String name) {
  switch (name) {
    case 'scheduled':
      return _$tripsGet200ResponseTripsInnerStatusEnum_scheduled;
    case 'active':
      return _$tripsGet200ResponseTripsInnerStatusEnum_active;
    case 'completed':
      return _$tripsGet200ResponseTripsInnerStatusEnum_completed;
    case 'cancelled':
      return _$tripsGet200ResponseTripsInnerStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripsGet200ResponseTripsInnerStatusEnum>
    _$tripsGet200ResponseTripsInnerStatusEnumValues = BuiltSet<
        TripsGet200ResponseTripsInnerStatusEnum>(const <TripsGet200ResponseTripsInnerStatusEnum>[
  _$tripsGet200ResponseTripsInnerStatusEnum_scheduled,
  _$tripsGet200ResponseTripsInnerStatusEnum_active,
  _$tripsGet200ResponseTripsInnerStatusEnum_completed,
  _$tripsGet200ResponseTripsInnerStatusEnum_cancelled,
]);

Serializer<TripsGet200ResponseTripsInnerStatusEnum>
    _$tripsGet200ResponseTripsInnerStatusEnumSerializer =
    _$TripsGet200ResponseTripsInnerStatusEnumSerializer();

class _$TripsGet200ResponseTripsInnerStatusEnumSerializer
    implements PrimitiveSerializer<TripsGet200ResponseTripsInnerStatusEnum> {
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
  final Iterable<Type> types = const <Type>[
    TripsGet200ResponseTripsInnerStatusEnum
  ];
  @override
  final String wireName = 'TripsGet200ResponseTripsInnerStatusEnum';

  @override
  Object serialize(Serializers serializers,
          TripsGet200ResponseTripsInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripsGet200ResponseTripsInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripsGet200ResponseTripsInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripsGet200ResponseTripsInner extends TripsGet200ResponseTripsInner {
  @override
  final String id;
  @override
  final String routeId;
  @override
  final String? vehicleId;
  @override
  final String? assignedDriverId;
  @override
  final TripsGet200ResponseTripsInnerStatusEnum status;
  @override
  final DateTime scheduledAt;
  @override
  final DateTime createdAt;

  factory _$TripsGet200ResponseTripsInner(
          [void Function(TripsGet200ResponseTripsInnerBuilder)? updates]) =>
      (TripsGet200ResponseTripsInnerBuilder()..update(updates))._build();

  _$TripsGet200ResponseTripsInner._(
      {required this.id,
      required this.routeId,
      this.vehicleId,
      this.assignedDriverId,
      required this.status,
      required this.scheduledAt,
      required this.createdAt})
      : super._();
  @override
  TripsGet200ResponseTripsInner rebuild(
          void Function(TripsGet200ResponseTripsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsGet200ResponseTripsInnerBuilder toBuilder() =>
      TripsGet200ResponseTripsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsGet200ResponseTripsInner &&
        id == other.id &&
        routeId == other.routeId &&
        vehicleId == other.vehicleId &&
        assignedDriverId == other.assignedDriverId &&
        status == other.status &&
        scheduledAt == other.scheduledAt &&
        createdAt == other.createdAt;
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsGet200ResponseTripsInner')
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('vehicleId', vehicleId)
          ..add('assignedDriverId', assignedDriverId)
          ..add('status', status)
          ..add('scheduledAt', scheduledAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class TripsGet200ResponseTripsInnerBuilder
    implements
        Builder<TripsGet200ResponseTripsInner,
            TripsGet200ResponseTripsInnerBuilder> {
  _$TripsGet200ResponseTripsInner? _$v;

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

  TripsGet200ResponseTripsInnerStatusEnum? _status;
  TripsGet200ResponseTripsInnerStatusEnum? get status => _$this._status;
  set status(TripsGet200ResponseTripsInnerStatusEnum? status) =>
      _$this._status = status;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  TripsGet200ResponseTripsInnerBuilder() {
    TripsGet200ResponseTripsInner._defaults(this);
  }

  TripsGet200ResponseTripsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _routeId = $v.routeId;
      _vehicleId = $v.vehicleId;
      _assignedDriverId = $v.assignedDriverId;
      _status = $v.status;
      _scheduledAt = $v.scheduledAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsGet200ResponseTripsInner other) {
    _$v = other as _$TripsGet200ResponseTripsInner;
  }

  @override
  void update(void Function(TripsGet200ResponseTripsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsGet200ResponseTripsInner build() => _build();

  _$TripsGet200ResponseTripsInner _build() {
    final _$result = _$v ??
        _$TripsGet200ResponseTripsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'TripsGet200ResponseTripsInner', 'id'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'TripsGet200ResponseTripsInner', 'routeId'),
          vehicleId: vehicleId,
          assignedDriverId: assignedDriverId,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'TripsGet200ResponseTripsInner', 'status'),
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'TripsGet200ResponseTripsInner', 'scheduledAt'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'TripsGet200ResponseTripsInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
