// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_trips_id_assignment_put_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminTripsIdAssignmentPutRequest
    extends AdminTripsIdAssignmentPutRequest {
  @override
  final String? vehicleId;
  @override
  final String? assignedDriverId;

  factory _$AdminTripsIdAssignmentPutRequest(
          [void Function(AdminTripsIdAssignmentPutRequestBuilder)? updates]) =>
      (AdminTripsIdAssignmentPutRequestBuilder()..update(updates))._build();

  _$AdminTripsIdAssignmentPutRequest._({this.vehicleId, this.assignedDriverId})
      : super._();
  @override
  AdminTripsIdAssignmentPutRequest rebuild(
          void Function(AdminTripsIdAssignmentPutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminTripsIdAssignmentPutRequestBuilder toBuilder() =>
      AdminTripsIdAssignmentPutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminTripsIdAssignmentPutRequest &&
        vehicleId == other.vehicleId &&
        assignedDriverId == other.assignedDriverId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vehicleId.hashCode);
    _$hash = $jc(_$hash, assignedDriverId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminTripsIdAssignmentPutRequest')
          ..add('vehicleId', vehicleId)
          ..add('assignedDriverId', assignedDriverId))
        .toString();
  }
}

class AdminTripsIdAssignmentPutRequestBuilder
    implements
        Builder<AdminTripsIdAssignmentPutRequest,
            AdminTripsIdAssignmentPutRequestBuilder> {
  _$AdminTripsIdAssignmentPutRequest? _$v;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  String? _assignedDriverId;
  String? get assignedDriverId => _$this._assignedDriverId;
  set assignedDriverId(String? assignedDriverId) =>
      _$this._assignedDriverId = assignedDriverId;

  AdminTripsIdAssignmentPutRequestBuilder() {
    AdminTripsIdAssignmentPutRequest._defaults(this);
  }

  AdminTripsIdAssignmentPutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vehicleId = $v.vehicleId;
      _assignedDriverId = $v.assignedDriverId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminTripsIdAssignmentPutRequest other) {
    _$v = other as _$AdminTripsIdAssignmentPutRequest;
  }

  @override
  void update(void Function(AdminTripsIdAssignmentPutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminTripsIdAssignmentPutRequest build() => _build();

  _$AdminTripsIdAssignmentPutRequest _build() {
    final _$result = _$v ??
        _$AdminTripsIdAssignmentPutRequest._(
          vehicleId: vehicleId,
          assignedDriverId: assignedDriverId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
