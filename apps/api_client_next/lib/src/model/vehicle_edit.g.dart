// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleEdit extends VehicleEdit {
  @override
  final String? plate;
  @override
  final String? label;
  @override
  final String? make;
  @override
  final String? colour;
  @override
  final int? capacity;
  @override
  final bool? archived;

  factory _$VehicleEdit([void Function(VehicleEditBuilder)? updates]) =>
      (VehicleEditBuilder()..update(updates))._build();

  _$VehicleEdit._(
      {this.plate,
      this.label,
      this.make,
      this.colour,
      this.capacity,
      this.archived})
      : super._();
  @override
  VehicleEdit rebuild(void Function(VehicleEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleEditBuilder toBuilder() => VehicleEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleEdit &&
        plate == other.plate &&
        label == other.label &&
        make == other.make &&
        colour == other.colour &&
        capacity == other.capacity &&
        archived == other.archived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plate.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, make.hashCode);
    _$hash = $jc(_$hash, colour.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleEdit')
          ..add('plate', plate)
          ..add('label', label)
          ..add('make', make)
          ..add('colour', colour)
          ..add('capacity', capacity)
          ..add('archived', archived))
        .toString();
  }
}

class VehicleEditBuilder implements Builder<VehicleEdit, VehicleEditBuilder> {
  _$VehicleEdit? _$v;

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

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  VehicleEditBuilder() {
    VehicleEdit._defaults(this);
  }

  VehicleEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plate = $v.plate;
      _label = $v.label;
      _make = $v.make;
      _colour = $v.colour;
      _capacity = $v.capacity;
      _archived = $v.archived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleEdit other) {
    _$v = other as _$VehicleEdit;
  }

  @override
  void update(void Function(VehicleEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleEdit build() => _build();

  _$VehicleEdit _build() {
    final _$result = _$v ??
        _$VehicleEdit._(
          plate: plate,
          label: label,
          make: make,
          colour: colour,
          capacity: capacity,
          archived: archived,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
