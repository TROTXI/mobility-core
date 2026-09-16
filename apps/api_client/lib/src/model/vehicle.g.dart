// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Vehicle extends Vehicle {
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
  @override
  final String id;
  @override
  final bool archived;
  @override
  final String editToken;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int version;

  factory _$Vehicle([void Function(VehicleBuilder)? updates]) =>
      (VehicleBuilder()..update(updates))._build();

  _$Vehicle._(
      {required this.plate,
      this.label,
      this.make,
      this.colour,
      required this.capacity,
      required this.id,
      required this.archived,
      required this.editToken,
      required this.createdAt,
      required this.updatedAt,
      required this.version})
      : super._();
  @override
  Vehicle rebuild(void Function(VehicleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleBuilder toBuilder() => VehicleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Vehicle &&
        plate == other.plate &&
        label == other.label &&
        make == other.make &&
        colour == other.colour &&
        capacity == other.capacity &&
        id == other.id &&
        archived == other.archived &&
        editToken == other.editToken &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plate.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, make.hashCode);
    _$hash = $jc(_$hash, colour.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Vehicle')
          ..add('plate', plate)
          ..add('label', label)
          ..add('make', make)
          ..add('colour', colour)
          ..add('capacity', capacity)
          ..add('id', id)
          ..add('archived', archived)
          ..add('editToken', editToken)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('version', version))
        .toString();
  }
}

class VehicleBuilder implements Builder<Vehicle, VehicleBuilder> {
  _$Vehicle? _$v;

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

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  VehicleBuilder() {
    Vehicle._defaults(this);
  }

  VehicleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plate = $v.plate;
      _label = $v.label;
      _make = $v.make;
      _colour = $v.colour;
      _capacity = $v.capacity;
      _id = $v.id;
      _archived = $v.archived;
      _editToken = $v.editToken;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Vehicle other) {
    _$v = other as _$Vehicle;
  }

  @override
  void update(void Function(VehicleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Vehicle build() => _build();

  _$Vehicle _build() {
    final _$result = _$v ??
        _$Vehicle._(
          plate:
              BuiltValueNullFieldError.checkNotNull(plate, r'Vehicle', 'plate'),
          label: label,
          make: make,
          colour: colour,
          capacity: BuiltValueNullFieldError.checkNotNull(
              capacity, r'Vehicle', 'capacity'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'Vehicle', 'id'),
          archived: BuiltValueNullFieldError.checkNotNull(
              archived, r'Vehicle', 'archived'),
          editToken: BuiltValueNullFieldError.checkNotNull(
              editToken, r'Vehicle', 'editToken'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'Vehicle', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Vehicle', 'updatedAt'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'Vehicle', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
