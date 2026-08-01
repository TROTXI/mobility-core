// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_trips_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminTripsIdPatchRequestStatusEnum
    _$adminTripsIdPatchRequestStatusEnum_scheduled =
    const AdminTripsIdPatchRequestStatusEnum._('scheduled');
const AdminTripsIdPatchRequestStatusEnum
    _$adminTripsIdPatchRequestStatusEnum_active =
    const AdminTripsIdPatchRequestStatusEnum._('active');
const AdminTripsIdPatchRequestStatusEnum
    _$adminTripsIdPatchRequestStatusEnum_completed =
    const AdminTripsIdPatchRequestStatusEnum._('completed');
const AdminTripsIdPatchRequestStatusEnum
    _$adminTripsIdPatchRequestStatusEnum_cancelled =
    const AdminTripsIdPatchRequestStatusEnum._('cancelled');

AdminTripsIdPatchRequestStatusEnum _$adminTripsIdPatchRequestStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'scheduled':
      return _$adminTripsIdPatchRequestStatusEnum_scheduled;
    case 'active':
      return _$adminTripsIdPatchRequestStatusEnum_active;
    case 'completed':
      return _$adminTripsIdPatchRequestStatusEnum_completed;
    case 'cancelled':
      return _$adminTripsIdPatchRequestStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminTripsIdPatchRequestStatusEnum>
    _$adminTripsIdPatchRequestStatusEnumValues = BuiltSet<
        AdminTripsIdPatchRequestStatusEnum>(const <AdminTripsIdPatchRequestStatusEnum>[
  _$adminTripsIdPatchRequestStatusEnum_scheduled,
  _$adminTripsIdPatchRequestStatusEnum_active,
  _$adminTripsIdPatchRequestStatusEnum_completed,
  _$adminTripsIdPatchRequestStatusEnum_cancelled,
]);

Serializer<AdminTripsIdPatchRequestStatusEnum>
    _$adminTripsIdPatchRequestStatusEnumSerializer =
    _$AdminTripsIdPatchRequestStatusEnumSerializer();

class _$AdminTripsIdPatchRequestStatusEnumSerializer
    implements PrimitiveSerializer<AdminTripsIdPatchRequestStatusEnum> {
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
  final Iterable<Type> types = const <Type>[AdminTripsIdPatchRequestStatusEnum];
  @override
  final String wireName = 'AdminTripsIdPatchRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, AdminTripsIdPatchRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminTripsIdPatchRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminTripsIdPatchRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminTripsIdPatchRequest extends AdminTripsIdPatchRequest {
  @override
  final AdminTripsIdPatchRequestStatusEnum? status;
  @override
  final DateTime? scheduledAt;

  factory _$AdminTripsIdPatchRequest(
          [void Function(AdminTripsIdPatchRequestBuilder)? updates]) =>
      (AdminTripsIdPatchRequestBuilder()..update(updates))._build();

  _$AdminTripsIdPatchRequest._({this.status, this.scheduledAt}) : super._();
  @override
  AdminTripsIdPatchRequest rebuild(
          void Function(AdminTripsIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminTripsIdPatchRequestBuilder toBuilder() =>
      AdminTripsIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTripsIdPatchRequest &&
        status == other.status &&
        scheduledAt == other.scheduledAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminTripsIdPatchRequest')
          ..add('status', status)
          ..add('scheduledAt', scheduledAt))
        .toString();
  }
}

class AdminTripsIdPatchRequestBuilder
    implements
        Builder<AdminTripsIdPatchRequest, AdminTripsIdPatchRequestBuilder> {
  _$AdminTripsIdPatchRequest? _$v;

  AdminTripsIdPatchRequestStatusEnum? _status;
  AdminTripsIdPatchRequestStatusEnum? get status => _$this._status;
  set status(AdminTripsIdPatchRequestStatusEnum? status) =>
      _$this._status = status;

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  AdminTripsIdPatchRequestBuilder() {
    AdminTripsIdPatchRequest._defaults(this);
  }

  AdminTripsIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _scheduledAt = $v.scheduledAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminTripsIdPatchRequest other) {
    _$v = other as _$AdminTripsIdPatchRequest;
  }

  @override
  void update(void Function(AdminTripsIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTripsIdPatchRequest build() => _build();

  _$AdminTripsIdPatchRequest _build() {
    final _$result = _$v ??
        _$AdminTripsIdPatchRequest._(
          status: status,
          scheduledAt: scheduledAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
