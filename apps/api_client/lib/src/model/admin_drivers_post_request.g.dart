// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_drivers_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDriversPostRequest extends AdminDriversPostRequest {
  @override
  final String fullName;
  @override
  final String? phone;
  @override
  final String? licenseNumber;
  @override
  final String? userId;

  factory _$AdminDriversPostRequest(
          [void Function(AdminDriversPostRequestBuilder)? updates]) =>
      (AdminDriversPostRequestBuilder()..update(updates))._build();

  _$AdminDriversPostRequest._(
      {required this.fullName, this.phone, this.licenseNumber, this.userId})
      : super._();
  @override
  AdminDriversPostRequest rebuild(
          void Function(AdminDriversPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriversPostRequestBuilder toBuilder() =>
      AdminDriversPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriversPostRequest &&
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
    return (newBuiltValueToStringHelper(r'AdminDriversPostRequest')
          ..add('fullName', fullName)
          ..add('phone', phone)
          ..add('licenseNumber', licenseNumber)
          ..add('userId', userId))
        .toString();
  }
}

class AdminDriversPostRequestBuilder
    implements
        Builder<AdminDriversPostRequest, AdminDriversPostRequestBuilder> {
  _$AdminDriversPostRequest? _$v;

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

  AdminDriversPostRequestBuilder() {
    AdminDriversPostRequest._defaults(this);
  }

  AdminDriversPostRequestBuilder get _$this {
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
  void replace(AdminDriversPostRequest other) {
    _$v = other as _$AdminDriversPostRequest;
  }

  @override
  void update(void Function(AdminDriversPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriversPostRequest build() => _build();

  _$AdminDriversPostRequest _build() {
    final _$result = _$v ??
        _$AdminDriversPostRequest._(
          fullName: BuiltValueNullFieldError.checkNotNull(
              fullName, r'AdminDriversPostRequest', 'fullName'),
          phone: phone,
          licenseNumber: licenseNumber,
          userId: userId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
