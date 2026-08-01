// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_vehicles_get200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminVehiclesGet200ResponseInner
    extends AdminVehiclesGet200ResponseInner {
  @override
  final String id;
  @override
  final String registration;
  @override
  final String? label;
  @override
  final int capacity;
  @override
  final DateTime createdAt;

  factory _$AdminVehiclesGet200ResponseInner(
          [void Function(AdminVehiclesGet200ResponseInnerBuilder)? updates]) =>
      (AdminVehiclesGet200ResponseInnerBuilder()..update(updates))._build();

  _$AdminVehiclesGet200ResponseInner._(
      {required this.id,
      required this.registration,
      this.label,
      required this.capacity,
      required this.createdAt})
      : super._();
  @override
  AdminVehiclesGet200ResponseInner rebuild(
          void Function(AdminVehiclesGet200ResponseInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminVehiclesGet200ResponseInnerBuilder toBuilder() =>
      AdminVehiclesGet200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminVehiclesGet200ResponseInner &&
        id == other.id &&
        registration == other.registration &&
        label == other.label &&
        capacity == other.capacity &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, registration.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminVehiclesGet200ResponseInner')
          ..add('id', id)
          ..add('registration', registration)
          ..add('label', label)
          ..add('capacity', capacity)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdminVehiclesGet200ResponseInnerBuilder
    implements
        Builder<AdminVehiclesGet200ResponseInner,
            AdminVehiclesGet200ResponseInnerBuilder> {
  _$AdminVehiclesGet200ResponseInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _registration;
  String? get registration => _$this._registration;
  set registration(String? registration) => _$this._registration = registration;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminVehiclesGet200ResponseInnerBuilder() {
    AdminVehiclesGet200ResponseInner._defaults(this);
  }

  AdminVehiclesGet200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _registration = $v.registration;
      _label = $v.label;
      _capacity = $v.capacity;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminVehiclesGet200ResponseInner other) {
    _$v = other as _$AdminVehiclesGet200ResponseInner;
  }

  @override
  void update(void Function(AdminVehiclesGet200ResponseInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminVehiclesGet200ResponseInner build() => _build();

  _$AdminVehiclesGet200ResponseInner _build() {
    final _$result = _$v ??
        _$AdminVehiclesGet200ResponseInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminVehiclesGet200ResponseInner', 'id'),
          registration: BuiltValueNullFieldError.checkNotNull(registration,
              r'AdminVehiclesGet200ResponseInner', 'registration'),
          label: label,
          capacity: BuiltValueNullFieldError.checkNotNull(
              capacity, r'AdminVehiclesGet200ResponseInner', 'capacity'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdminVehiclesGet200ResponseInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
