// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_get200_response_vehicle.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdGet200ResponseVehicle extends TripsIdGet200ResponseVehicle {
  @override
  final String registration;
  @override
  final String? make;
  @override
  final String? colour;
  @override
  final int? capacity;

  factory _$TripsIdGet200ResponseVehicle(
          [void Function(TripsIdGet200ResponseVehicleBuilder)? updates]) =>
      (TripsIdGet200ResponseVehicleBuilder()..update(updates))._build();

  _$TripsIdGet200ResponseVehicle._(
      {required this.registration, this.make, this.colour, this.capacity})
      : super._();
  @override
  TripsIdGet200ResponseVehicle rebuild(
          void Function(TripsIdGet200ResponseVehicleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdGet200ResponseVehicleBuilder toBuilder() =>
      TripsIdGet200ResponseVehicleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdGet200ResponseVehicle &&
        registration == other.registration &&
        make == other.make &&
        colour == other.colour &&
        capacity == other.capacity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registration.hashCode);
    _$hash = $jc(_$hash, make.hashCode);
    _$hash = $jc(_$hash, colour.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripsIdGet200ResponseVehicle')
          ..add('registration', registration)
          ..add('make', make)
          ..add('colour', colour)
          ..add('capacity', capacity))
        .toString();
  }
}

class TripsIdGet200ResponseVehicleBuilder
    implements
        Builder<TripsIdGet200ResponseVehicle,
            TripsIdGet200ResponseVehicleBuilder> {
  _$TripsIdGet200ResponseVehicle? _$v;

  String? _registration;
  String? get registration => _$this._registration;
  set registration(String? registration) => _$this._registration = registration;

  String? _make;
  String? get make => _$this._make;
  set make(String? make) => _$this._make = make;

  String? _colour;
  String? get colour => _$this._colour;
  set colour(String? colour) => _$this._colour = colour;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  TripsIdGet200ResponseVehicleBuilder() {
    TripsIdGet200ResponseVehicle._defaults(this);
  }

  TripsIdGet200ResponseVehicleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registration = $v.registration;
      _make = $v.make;
      _colour = $v.colour;
      _capacity = $v.capacity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdGet200ResponseVehicle other) {
    _$v = other as _$TripsIdGet200ResponseVehicle;
  }

  @override
  void update(void Function(TripsIdGet200ResponseVehicleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdGet200ResponseVehicle build() => _build();

  _$TripsIdGet200ResponseVehicle _build() {
    final _$result = _$v ??
        _$TripsIdGet200ResponseVehicle._(
          registration: BuiltValueNullFieldError.checkNotNull(
              registration, r'TripsIdGet200ResponseVehicle', 'registration'),
          make: make,
          colour: colour,
          capacity: capacity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
