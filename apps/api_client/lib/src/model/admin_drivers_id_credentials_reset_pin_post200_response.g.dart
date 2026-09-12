// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_drivers_id_credentials_reset_pin_post200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminDriversIdCredentialsResetPinPost200Response
    extends AdminDriversIdCredentialsResetPinPost200Response {
  @override
  final String pin;

  factory _$AdminDriversIdCredentialsResetPinPost200Response(
          [void Function(
                  AdminDriversIdCredentialsResetPinPost200ResponseBuilder)?
              updates]) =>
      (AdminDriversIdCredentialsResetPinPost200ResponseBuilder()
            ..update(updates))
          ._build();

  _$AdminDriversIdCredentialsResetPinPost200Response._({required this.pin})
      : super._();
  @override
  AdminDriversIdCredentialsResetPinPost200Response rebuild(
          void Function(AdminDriversIdCredentialsResetPinPost200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminDriversIdCredentialsResetPinPost200ResponseBuilder toBuilder() =>
      AdminDriversIdCredentialsResetPinPost200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminDriversIdCredentialsResetPinPost200Response &&
        pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminDriversIdCredentialsResetPinPost200Response')
          ..add('pin', pin))
        .toString();
  }
}

class AdminDriversIdCredentialsResetPinPost200ResponseBuilder
    implements
        Builder<AdminDriversIdCredentialsResetPinPost200Response,
            AdminDriversIdCredentialsResetPinPost200ResponseBuilder> {
  _$AdminDriversIdCredentialsResetPinPost200Response? _$v;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  AdminDriversIdCredentialsResetPinPost200ResponseBuilder() {
    AdminDriversIdCredentialsResetPinPost200Response._defaults(this);
  }

  AdminDriversIdCredentialsResetPinPost200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminDriversIdCredentialsResetPinPost200Response other) {
    _$v = other as _$AdminDriversIdCredentialsResetPinPost200Response;
  }

  @override
  void update(
      void Function(AdminDriversIdCredentialsResetPinPost200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminDriversIdCredentialsResetPinPost200Response build() => _build();

  _$AdminDriversIdCredentialsResetPinPost200Response _build() {
    final _$result = _$v ??
        _$AdminDriversIdCredentialsResetPinPost200Response._(
          pin: BuiltValueNullFieldError.checkNotNull(
              pin, r'AdminDriversIdCredentialsResetPinPost200Response', 'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
