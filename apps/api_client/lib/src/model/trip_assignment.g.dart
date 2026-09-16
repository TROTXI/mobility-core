// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_assignment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripAssignment extends TripAssignment {
  @override
  final String? driverId;
  @override
  final String? vehicleId;

  factory _$TripAssignment([void Function(TripAssignmentBuilder)? updates]) =>
      (TripAssignmentBuilder()..update(updates))._build();

  _$TripAssignment._({this.driverId, this.vehicleId}) : super._();
  @override
  TripAssignment rebuild(void Function(TripAssignmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripAssignmentBuilder toBuilder() => TripAssignmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripAssignment &&
        driverId == other.driverId &&
        vehicleId == other.vehicleId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, vehicleId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripAssignment')
          ..add('driverId', driverId)
          ..add('vehicleId', vehicleId))
        .toString();
  }
}

class TripAssignmentBuilder
    implements Builder<TripAssignment, TripAssignmentBuilder> {
  _$TripAssignment? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _vehicleId;
  String? get vehicleId => _$this._vehicleId;
  set vehicleId(String? vehicleId) => _$this._vehicleId = vehicleId;

  TripAssignmentBuilder() {
    TripAssignment._defaults(this);
  }

  TripAssignmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _vehicleId = $v.vehicleId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripAssignment other) {
    _$v = other as _$TripAssignment;
  }

  @override
  void update(void Function(TripAssignmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripAssignment build() => _build();

  _$TripAssignment _build() {
    final _$result = _$v ??
        _$TripAssignment._(
          driverId: driverId,
          vehicleId: vehicleId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
