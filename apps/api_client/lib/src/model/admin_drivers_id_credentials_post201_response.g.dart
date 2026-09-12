// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_drivers_id_credentials_post201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDriversIdCredentialsPost201Response
    extends AdminDriversIdCredentialsPost201Response {
  @override
  final String driverCode;
  @override
  final String pin;

  factory _$AdminDriversIdCredentialsPost201Response(
          [void Function(AdminDriversIdCredentialsPost201ResponseBuilder)?
              updates]) =>
      (AdminDriversIdCredentialsPost201ResponseBuilder()..update(updates))
          ._build();

  _$AdminDriversIdCredentialsPost201Response._(
      {required this.driverCode, required this.pin})
      : super._();
  @override
  AdminDriversIdCredentialsPost201Response rebuild(
          void Function(AdminDriversIdCredentialsPost201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriversIdCredentialsPost201ResponseBuilder toBuilder() =>
      AdminDriversIdCredentialsPost201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriversIdCredentialsPost201Response &&
        driverCode == other.driverCode &&
        pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverCode.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminDriversIdCredentialsPost201Response')
          ..add('driverCode', driverCode)
          ..add('pin', pin))
        .toString();
  }
}

class AdminDriversIdCredentialsPost201ResponseBuilder
    implements
        Builder<AdminDriversIdCredentialsPost201Response,
            AdminDriversIdCredentialsPost201ResponseBuilder> {
  _$AdminDriversIdCredentialsPost201Response? _$v;

  String? _driverCode;
  String? get driverCode => _$this._driverCode;
  set driverCode(String? driverCode) => _$this._driverCode = driverCode;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  AdminDriversIdCredentialsPost201ResponseBuilder() {
    AdminDriversIdCredentialsPost201Response._defaults(this);
  }

  AdminDriversIdCredentialsPost201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverCode = $v.driverCode;
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriversIdCredentialsPost201Response other) {
    _$v = other as _$AdminDriversIdCredentialsPost201Response;
  }

  @override
  void update(
      void Function(AdminDriversIdCredentialsPost201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriversIdCredentialsPost201Response build() => _build();

  _$AdminDriversIdCredentialsPost201Response _build() {
    final _$result = _$v ??
        _$AdminDriversIdCredentialsPost201Response._(
          driverCode: BuiltValueNullFieldError.checkNotNull(driverCode,
              r'AdminDriversIdCredentialsPost201Response', 'driverCode'),
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'AdminDriversIdCredentialsPost201Response', 'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
