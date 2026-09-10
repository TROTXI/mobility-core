// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_vehicles_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminVehiclesIdPatchRequest extends AdminVehiclesIdPatchRequest {
  @override
  final String? registration;
  @override
  final String? label;
  @override
  final String? make;
  @override
  final String? colour;
  @override
  final int? capacity;

  factory _$AdminVehiclesIdPatchRequest(
          [void Function(AdminVehiclesIdPatchRequestBuilder)? updates]) =>
      (AdminVehiclesIdPatchRequestBuilder()..update(updates))._build();

  _$AdminVehiclesIdPatchRequest._(
      {this.registration, this.label, this.make, this.colour, this.capacity})
      : super._();
  @override
  AdminVehiclesIdPatchRequest rebuild(
          void Function(AdminVehiclesIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminVehiclesIdPatchRequestBuilder toBuilder() =>
      AdminVehiclesIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminVehiclesIdPatchRequest &&
        registration == other.registration &&
        label == other.label &&
        make == other.make &&
        colour == other.colour &&
        capacity == other.capacity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registration.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, make.hashCode);
    _$hash = $jc(_$hash, colour.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminVehiclesIdPatchRequest')
          ..add('registration', registration)
          ..add('label', label)
          ..add('make', make)
          ..add('colour', colour)
          ..add('capacity', capacity))
        .toString();
  }
}

class AdminVehiclesIdPatchRequestBuilder
    implements
        Builder<AdminVehiclesIdPatchRequest,
            AdminVehiclesIdPatchRequestBuilder> {
  _$AdminVehiclesIdPatchRequest? _$v;

  String? _registration;
  String? get registration => _$this._registration;
  set registration(String? registration) => _$this._registration = registration;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _make;
  String? get make => _$this._make;
  set make(String? make) => _$this._make = make;

  String? _colour;
  String? get colour => _$this._colour;
  set colour(String? colour) => _$this._colour = colour;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  AdminVehiclesIdPatchRequestBuilder() {
    AdminVehiclesIdPatchRequest._defaults(this);
  }

  AdminVehiclesIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registration = $v.registration;
      _label = $v.label;
      _make = $v.make;
      _colour = $v.colour;
      _capacity = $v.capacity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminVehiclesIdPatchRequest other) {
    _$v = other as _$AdminVehiclesIdPatchRequest;
  }

  @override
  void update(void Function(AdminVehiclesIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminVehiclesIdPatchRequest build() => _build();

  _$AdminVehiclesIdPatchRequest _build() {
    final _$result = _$v ??
        _$AdminVehiclesIdPatchRequest._(
          registration: registration,
          label: label,
          make: make,
          colour: colour,
          capacity: capacity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
