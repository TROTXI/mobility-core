// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_operations.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BootstrapOperations extends BootstrapOperations {
  @override
  final String? phone;
  @override
  final String? whatsapp;
  @override
  final String? email;
  @override
  final String? hours;

  factory _$BootstrapOperations(
          [void Function(BootstrapOperationsBuilder)? updates]) =>
      (BootstrapOperationsBuilder()..update(updates))._build();

  _$BootstrapOperations._({this.phone, this.whatsapp, this.email, this.hours})
      : super._();
  @override
  BootstrapOperations rebuild(
          void Function(BootstrapOperationsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BootstrapOperationsBuilder toBuilder() =>
      BootstrapOperationsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BootstrapOperations &&
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
    return (newBuiltValueToStringHelper(r'BootstrapOperations')
          ..add('phone', phone)
          ..add('whatsapp', whatsapp)
          ..add('email', email)
          ..add('hours', hours))
        .toString();
  }
}

class BootstrapOperationsBuilder
    implements Builder<BootstrapOperations, BootstrapOperationsBuilder> {
  _$BootstrapOperations? _$v;

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

  BootstrapOperationsBuilder() {
    BootstrapOperations._defaults(this);
  }

  BootstrapOperationsBuilder get _$this {
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
  void replace(BootstrapOperations other) {
    _$v = other as _$BootstrapOperations;
  }

  @override
  void update(void Function(BootstrapOperationsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BootstrapOperations build() => _build();

  _$BootstrapOperations _build() {
    final _$result = _$v ??
        _$BootstrapOperations._(
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
