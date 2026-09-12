// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flags_get200_response_operations.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagsGet200ResponseOperations extends FlagsGet200ResponseOperations {
  @override
  final String? phone;
  @override
  final String? whatsapp;
  @override
  final String? email;
  @override
  final String? hours;

  factory _$FlagsGet200ResponseOperations(
          [void Function(FlagsGet200ResponseOperationsBuilder)? updates]) =>
      (FlagsGet200ResponseOperationsBuilder()..update(updates))._build();

  _$FlagsGet200ResponseOperations._(
      {this.phone, this.whatsapp, this.email, this.hours})
      : super._();
  @override
  FlagsGet200ResponseOperations rebuild(
          void Function(FlagsGet200ResponseOperationsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagsGet200ResponseOperationsBuilder toBuilder() =>
      FlagsGet200ResponseOperationsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagsGet200ResponseOperations &&
        phone == other.phone &&
        whatsapp == other.whatsapp &&
        email == other.email &&
        hours == other.hours;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, whatsapp.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, hours.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FlagsGet200ResponseOperations')
          ..add('phone', phone)
          ..add('whatsapp', whatsapp)
          ..add('email', email)
          ..add('hours', hours))
        .toString();
  }
}

class FlagsGet200ResponseOperationsBuilder
    implements
        Builder<FlagsGet200ResponseOperations,
            FlagsGet200ResponseOperationsBuilder> {
  _$FlagsGet200ResponseOperations? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _whatsapp;
  String? get whatsapp => _$this._whatsapp;
  set whatsapp(String? whatsapp) => _$this._whatsapp = whatsapp;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _hours;
  String? get hours => _$this._hours;
  set hours(String? hours) => _$this._hours = hours;

  FlagsGet200ResponseOperationsBuilder() {
    FlagsGet200ResponseOperations._defaults(this);
  }

  FlagsGet200ResponseOperationsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _whatsapp = $v.whatsapp;
      _email = $v.email;
      _hours = $v.hours;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagsGet200ResponseOperations other) {
    _$v = other as _$FlagsGet200ResponseOperations;
  }

  @override
  void update(void Function(FlagsGet200ResponseOperationsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagsGet200ResponseOperations build() => _build();

  _$FlagsGet200ResponseOperations _build() {
    final _$result = _$v ??
        _$FlagsGet200ResponseOperations._(
          phone: phone,
          whatsapp: whatsapp,
          email: email,
          hours: hours,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
