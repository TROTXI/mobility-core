// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_trips_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTripsPostRequestStatusEnum
    _$adminTripsPostRequestStatusEnum_scheduled =
    const AdminTripsPostRequestStatusEnum._('scheduled');
const AdminTripsPostRequestStatusEnum _$adminTripsPostRequestStatusEnum_active =
    const AdminTripsPostRequestStatusEnum._('active');
const AdminTripsPostRequestStatusEnum
    _$adminTripsPostRequestStatusEnum_completed =
    const AdminTripsPostRequestStatusEnum._('completed');
const AdminTripsPostRequestStatusEnum
    _$adminTripsPostRequestStatusEnum_cancelled =
    const AdminTripsPostRequestStatusEnum._('cancelled');

AdminTripsPostRequestStatusEnum _$adminTripsPostRequestStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'scheduled':
      return _$adminTripsPostRequestStatusEnum_scheduled;
    case 'active':
      return _$adminTripsPostRequestStatusEnum_active;
    case 'completed':
      return _$adminTripsPostRequestStatusEnum_completed;
    case 'cancelled':
      return _$adminTripsPostRequestStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminTripsPostRequestStatusEnum>
    _$adminTripsPostRequestStatusEnumValues = BuiltSet<
        AdminTripsPostRequestStatusEnum>(const <AdminTripsPostRequestStatusEnum>[
  _$adminTripsPostRequestStatusEnum_scheduled,
  _$adminTripsPostRequestStatusEnum_active,
  _$adminTripsPostRequestStatusEnum_completed,
  _$adminTripsPostRequestStatusEnum_cancelled,
]);

Serializer<AdminTripsPostRequestStatusEnum>
    _$adminTripsPostRequestStatusEnumSerializer =
    _$AdminTripsPostRequestStatusEnumSerializer();

class _$AdminTripsPostRequestStatusEnumSerializer
    implements PrimitiveSerializer<AdminTripsPostRequestStatusEnum> {
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
  final Iterable<Type> types = const <Type>[AdminTripsPostRequestStatusEnum];
  @override
  final String wireName = 'AdminTripsPostRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, AdminTripsPostRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminTripsPostRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminTripsPostRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminTripsPostRequest extends AdminTripsPostRequest {
  @override
  final String routeId;
  @override
  final String? vehicleId;
  @override
  final String? assignedDriverId;
  @override
  final AdminTripsPostRequestStatusEnum? status;
  @override
  final DateTime scheduledAt;

  factory _$AdminTripsPostRequest(
          [void Function(AdminTripsPostRequestBuilder)? updates]) =>
      (AdminTripsPostRequestBuilder()..update(updates))._build();

  _$AdminTripsPostRequest._(
      {required this.routeId,
      this.vehicleId,
      this.assignedDriverId,
      this.status,
      required this.scheduledAt})
      : super._();
  @override
  AdminTripsPostRequest rebuild(
          void Function(AdminTripsPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminTripsPostRequestBuilder toBuilder() =>
      AdminTripsPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTripsPostRequest &&
        routeId == other.routeId &&
        vehicleId == other.vehicleId &&
        assignedDriverId == other.assignedDriverId &&
        status == other.status &&
        scheduledAt == other.scheduledAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, vehicleId.hashCode);
    _$hash = $jc(_$hash, assignedDriverId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminTripsPostRequest')
          ..add('routeId', routeId)
          ..add('vehicleId', vehicleId)
          ..add('assignedDriverId', assignedDriverId)
          ..add('status', status)
          ..add('scheduledAt', scheduledAt))
        .toString();
  }
}

class AdminTripsPostRequestBuilder
    implements Builder<AdminTripsPostRequest, AdminTripsPostRequestBuilder> {
  _$AdminTripsPostRequest? _$v;

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

  AdminTripsPostRequestStatusEnum? _status;
  AdminTripsPostRequestStatusEnum? get status => _$this._status;
  set status(AdminTripsPostRequestStatusEnum? status) =>
      _$this._status = status;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  AdminTripsPostRequestBuilder() {
    AdminTripsPostRequest._defaults(this);
  }

  AdminTripsPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _vehicleId = $v.vehicleId;
      _assignedDriverId = $v.assignedDriverId;
      _status = $v.status;
      _scheduledAt = $v.scheduledAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminTripsPostRequest other) {
    _$v = other as _$AdminTripsPostRequest;
  }

  @override
  void update(void Function(AdminTripsPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTripsPostRequest build() => _build();

  _$AdminTripsPostRequest _build() {
    final _$result = _$v ??
        _$AdminTripsPostRequest._(
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'AdminTripsPostRequest', 'routeId'),
          vehicleId: vehicleId,
          assignedDriverId: assignedDriverId,
          status: status,
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'AdminTripsPostRequest', 'scheduledAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
