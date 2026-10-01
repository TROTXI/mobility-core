// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_verification_start.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhoneVerificationStart extends PhoneVerificationStart {
  @override
  final String phone;

  factory _$PhoneVerificationStart(
          [void Function(PhoneVerificationStartBuilder)? updates]) =>
      (PhoneVerificationStartBuilder()..update(updates))._build();

  _$PhoneVerificationStart._({required this.phone}) : super._();
  @override
  PhoneVerificationStart rebuild(
          void Function(PhoneVerificationStartBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhoneVerificationStartBuilder toBuilder() =>
      PhoneVerificationStartBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhoneVerificationStart && phone == other.phone;
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
    return (newBuiltValueToStringHelper(r'PhoneVerificationStart')
          ..add('phone', phone))
        .toString();
  }
}

class PhoneVerificationStartBuilder
    implements Builder<PhoneVerificationStart, PhoneVerificationStartBuilder> {
  _$PhoneVerificationStart? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  PhoneVerificationStartBuilder() {
    PhoneVerificationStart._defaults(this);
  }

  PhoneVerificationStartBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhoneVerificationStart other) {
    _$v = other as _$PhoneVerificationStart;
  }

  @override
  void update(void Function(PhoneVerificationStartBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhoneVerificationStart build() => _build();

  _$PhoneVerificationStart _build() {
    final _$result = _$v ??
        _$PhoneVerificationStart._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'PhoneVerificationStart', 'phone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
