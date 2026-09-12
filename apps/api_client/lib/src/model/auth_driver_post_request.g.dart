// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_driver_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthDriverPostRequest extends AuthDriverPostRequest {
  @override
  final String driverCode;
  @override
  final String pin;
  @override
  final bool? rememberDevice;

  factory _$AuthDriverPostRequest(
          [void Function(AuthDriverPostRequestBuilder)? updates]) =>
      (AuthDriverPostRequestBuilder()..update(updates))._build();

  _$AuthDriverPostRequest._(
      {required this.driverCode, required this.pin, this.rememberDevice})
      : super._();
  @override
  AuthDriverPostRequest rebuild(
          void Function(AuthDriverPostRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthDriverPostRequestBuilder toBuilder() =>
      AuthDriverPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthDriverPostRequest &&
        driverCode == other.driverCode &&
        pin == other.pin &&
        rememberDevice == other.rememberDevice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverCode.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, rememberDevice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthDriverPostRequest')
          ..add('driverCode', driverCode)
          ..add('pin', pin)
          ..add('rememberDevice', rememberDevice))
        .toString();
  }
}

class AuthDriverPostRequestBuilder
    implements Builder<AuthDriverPostRequest, AuthDriverPostRequestBuilder> {
  _$AuthDriverPostRequest? _$v;

  String? _driverCode;
  String? get driverCode => _$this._driverCode;
  set driverCode(String? driverCode) => _$this._driverCode = driverCode;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  bool? _rememberDevice;
  bool? get rememberDevice => _$this._rememberDevice;
  set rememberDevice(bool? rememberDevice) =>
      _$this._rememberDevice = rememberDevice;

  AuthDriverPostRequestBuilder() {
    AuthDriverPostRequest._defaults(this);
  }

  AuthDriverPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverCode = $v.driverCode;
      _pin = $v.pin;
      _rememberDevice = $v.rememberDevice;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthDriverPostRequest other) {
    _$v = other as _$AuthDriverPostRequest;
  }

  @override
  void update(void Function(AuthDriverPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthDriverPostRequest build() => _build();

  _$AuthDriverPostRequest _build() {
    final _$result = _$v ??
        _$AuthDriverPostRequest._(
          driverCode: BuiltValueNullFieldError.checkNotNull(
              driverCode, r'AuthDriverPostRequest', 'driverCode'),
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'AuthDriverPostRequest', 'pin'),
          rememberDevice: rememberDevice,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
