// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_sign_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverSignIn extends DriverSignIn {
  @override
  final String code;
  @override
  final String pin;
  @override
  final bool ownDevice;

  factory _$DriverSignIn([void Function(DriverSignInBuilder)? updates]) =>
      (DriverSignInBuilder()..update(updates))._build();

  _$DriverSignIn._(
      {required this.code, required this.pin, required this.ownDevice})
      : super._();
  @override
  DriverSignIn rebuild(void Function(DriverSignInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverSignInBuilder toBuilder() => DriverSignInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverSignIn &&
        code == other.code &&
        pin == other.pin &&
        ownDevice == other.ownDevice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, ownDevice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverSignIn')
          ..add('code', code)
          ..add('pin', pin)
          ..add('ownDevice', ownDevice))
        .toString();
  }
}

class DriverSignInBuilder
    implements Builder<DriverSignIn, DriverSignInBuilder> {
  _$DriverSignIn? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  bool? _ownDevice;
  bool? get ownDevice => _$this._ownDevice;
  set ownDevice(bool? ownDevice) => _$this._ownDevice = ownDevice;

  DriverSignInBuilder() {
    DriverSignIn._defaults(this);
  }

  DriverSignInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _pin = $v.pin;
      _ownDevice = $v.ownDevice;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverSignIn other) {
    _$v = other as _$DriverSignIn;
  }

  @override
  void update(void Function(DriverSignInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverSignIn build() => _build();

  _$DriverSignIn _build() {
    final _$result = _$v ??
        _$DriverSignIn._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'DriverSignIn', 'code'),
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'DriverSignIn', 'pin'),
          ownDevice: BuiltValueNullFieldError.checkNotNull(
              ownDevice, r'DriverSignIn', 'ownDevice'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
