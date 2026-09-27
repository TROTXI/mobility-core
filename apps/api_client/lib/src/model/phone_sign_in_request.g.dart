// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_sign_in_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneSignInRequest extends PhoneSignInRequest {
  @override
  final String phone;

  factory _$PhoneSignInRequest(
          [void Function(PhoneSignInRequestBuilder)? updates]) =>
      (PhoneSignInRequestBuilder()..update(updates))._build();

  _$PhoneSignInRequest._({required this.phone}) : super._();
  @override
  PhoneSignInRequest rebuild(
          void Function(PhoneSignInRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneSignInRequestBuilder toBuilder() =>
      PhoneSignInRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneSignInRequest && phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhoneSignInRequest')
          ..add('phone', phone))
        .toString();
  }
}

class PhoneSignInRequestBuilder
    implements Builder<PhoneSignInRequest, PhoneSignInRequestBuilder> {
  _$PhoneSignInRequest? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  PhoneSignInRequestBuilder() {
    PhoneSignInRequest._defaults(this);
  }

  PhoneSignInRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneSignInRequest other) {
    _$v = other as _$PhoneSignInRequest;
  }

  @override
  void update(void Function(PhoneSignInRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneSignInRequest build() => _build();

  _$PhoneSignInRequest _build() {
    final _$result = _$v ??
        _$PhoneSignInRequest._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'PhoneSignInRequest', 'phone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
