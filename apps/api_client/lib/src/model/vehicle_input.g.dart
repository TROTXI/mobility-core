// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleInput extends VehicleInput {
  @override
  final String plate;
  @override
  final String? label;
  @override
  final String? make;
  @override
  final String? colour;
  @override
  final int capacity;

  factory _$VehicleInput([void Function(VehicleInputBuilder)? updates]) =>
      (VehicleInputBuilder()..update(updates))._build();

  _$VehicleInput._(
      {required this.plate,
      this.label,
      this.make,
      this.colour,
      required this.capacity})
      : super._();
  @override
  VehicleInput rebuild(void Function(VehicleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleInputBuilder toBuilder() => VehicleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleInput &&
        plate == other.plate &&
        label == other.label &&
        make == other.make &&
        colour == other.colour &&
        capacity == other.capacity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plate.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, make.hashCode);
    _$hash = $jc(_$hash, colour.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleInput')
          ..add('plate', plate)
          ..add('label', label)
          ..add('make', make)
          ..add('colour', colour)
          ..add('capacity', capacity))
        .toString();
  }
}

class VehicleInputBuilder
    implements Builder<VehicleInput, VehicleInputBuilder> {
  _$VehicleInput? _$v;

  String? _plate;
  String? get plate => _$this._plate;
  set plate(String? plate) => _$this._plate = plate;

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

  VehicleInputBuilder() {
    VehicleInput._defaults(this);
  }

  VehicleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plate = $v.plate;
      _label = $v.label;
      _make = $v.make;
      _colour = $v.colour;
      _capacity = $v.capacity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleInput other) {
    _$v = other as _$VehicleInput;
  }

  @override
  void update(void Function(VehicleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleInput build() => _build();

  _$VehicleInput _build() {
    final _$result = _$v ??
        _$VehicleInput._(
          plate: BuiltValueNullFieldError.checkNotNull(
              plate, r'VehicleInput', 'plate'),
          label: label,
          make: make,
          colour: colour,
          capacity: BuiltValueNullFieldError.checkNotNull(
              capacity, r'VehicleInput', 'capacity'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
