// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_vehicles_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminVehiclesPostRequest extends AdminVehiclesPostRequest {
  @override
  final String registration;
  @override
  final String? label;
  @override
  final int? capacity;

  factory _$AdminVehiclesPostRequest(
          [void Function(AdminVehiclesPostRequestBuilder)? updates]) =>
      (AdminVehiclesPostRequestBuilder()..update(updates))._build();

  _$AdminVehiclesPostRequest._(
      {required this.registration, this.label, this.capacity})
      : super._();
  @override
  AdminVehiclesPostRequest rebuild(
          void Function(AdminVehiclesPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminVehiclesPostRequestBuilder toBuilder() =>
      AdminVehiclesPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminVehiclesPostRequest &&
        registration == other.registration &&
        label == other.label &&
        capacity == other.capacity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, registration.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, capacity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminVehiclesPostRequest')
          ..add('registration', registration)
          ..add('label', label)
          ..add('capacity', capacity))
        .toString();
  }
}

class AdminVehiclesPostRequestBuilder
    implements
        Builder<AdminVehiclesPostRequest, AdminVehiclesPostRequestBuilder> {
  _$AdminVehiclesPostRequest? _$v;

  String? _registration;
  String? get registration => _$this._registration;
  set registration(String? registration) => _$this._registration = registration;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  int? _capacity;
  int? get capacity => _$this._capacity;
  set capacity(int? capacity) => _$this._capacity = capacity;

  AdminVehiclesPostRequestBuilder() {
    AdminVehiclesPostRequest._defaults(this);
  }

  AdminVehiclesPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _registration = $v.registration;
      _label = $v.label;
      _capacity = $v.capacity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminVehiclesPostRequest other) {
    _$v = other as _$AdminVehiclesPostRequest;
  }

  @override
  void update(void Function(AdminVehiclesPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminVehiclesPostRequest build() => _build();

  _$AdminVehiclesPostRequest _build() {
    final _$result = _$v ??
        _$AdminVehiclesPostRequest._(
          registration: BuiltValueNullFieldError.checkNotNull(
              registration, r'AdminVehiclesPostRequest', 'registration'),
          label: label,
          capacity: capacity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
