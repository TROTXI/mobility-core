// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_drivers_id_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDriversIdPatchRequest extends AdminDriversIdPatchRequest {
  @override
  final String? fullName;
  @override
  final String? phone;
  @override
  final String? licenseNumber;
  @override
  final String? userId;

  factory _$AdminDriversIdPatchRequest(
          [void Function(AdminDriversIdPatchRequestBuilder)? updates]) =>
      (AdminDriversIdPatchRequestBuilder()..update(updates))._build();

  _$AdminDriversIdPatchRequest._(
      {this.fullName, this.phone, this.licenseNumber, this.userId})
      : super._();
  @override
  AdminDriversIdPatchRequest rebuild(
          void Function(AdminDriversIdPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriversIdPatchRequestBuilder toBuilder() =>
      AdminDriversIdPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriversIdPatchRequest &&
        fullName == other.fullName &&
        phone == other.phone &&
        licenseNumber == other.licenseNumber &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, licenseNumber.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminDriversIdPatchRequest')
          ..add('fullName', fullName)
          ..add('phone', phone)
          ..add('licenseNumber', licenseNumber)
          ..add('userId', userId))
        .toString();
  }
}

class AdminDriversIdPatchRequestBuilder
    implements
        Builder<AdminDriversIdPatchRequest, AdminDriversIdPatchRequestBuilder> {
  _$AdminDriversIdPatchRequest? _$v;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _licenseNumber;
  String? get licenseNumber => _$this._licenseNumber;
  set licenseNumber(String? licenseNumber) =>
      _$this._licenseNumber = licenseNumber;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  AdminDriversIdPatchRequestBuilder() {
    AdminDriversIdPatchRequest._defaults(this);
  }

  AdminDriversIdPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fullName = $v.fullName;
      _phone = $v.phone;
      _licenseNumber = $v.licenseNumber;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriversIdPatchRequest other) {
    _$v = other as _$AdminDriversIdPatchRequest;
  }

  @override
  void update(void Function(AdminDriversIdPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriversIdPatchRequest build() => _build();

  _$AdminDriversIdPatchRequest _build() {
    final _$result = _$v ??
        _$AdminDriversIdPatchRequest._(
          fullName: fullName,
          phone: phone,
          licenseNumber: licenseNumber,
          userId: userId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
