// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_status_phone.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VerificationStatusPhoneStatusEnum
    _$verificationStatusPhoneStatusEnum_incomplete =
    const VerificationStatusPhoneStatusEnum._('incomplete');
const VerificationStatusPhoneStatusEnum
    _$verificationStatusPhoneStatusEnum_pending =
    const VerificationStatusPhoneStatusEnum._('pending');
const VerificationStatusPhoneStatusEnum
    _$verificationStatusPhoneStatusEnum_verified =
    const VerificationStatusPhoneStatusEnum._('verified');
const VerificationStatusPhoneStatusEnum
    _$verificationStatusPhoneStatusEnum_review =
    const VerificationStatusPhoneStatusEnum._('review');
const VerificationStatusPhoneStatusEnum
    _$verificationStatusPhoneStatusEnum_unavailable =
    const VerificationStatusPhoneStatusEnum._('unavailable');

VerificationStatusPhoneStatusEnum _$verificationStatusPhoneStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'incomplete':
      return _$verificationStatusPhoneStatusEnum_incomplete;
    case 'pending':
      return _$verificationStatusPhoneStatusEnum_pending;
    case 'verified':
      return _$verificationStatusPhoneStatusEnum_verified;
    case 'review':
      return _$verificationStatusPhoneStatusEnum_review;
    case 'unavailable':
      return _$verificationStatusPhoneStatusEnum_unavailable;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VerificationStatusPhoneStatusEnum>
    _$verificationStatusPhoneStatusEnumValues = BuiltSet<
        VerificationStatusPhoneStatusEnum>(const <VerificationStatusPhoneStatusEnum>[
  _$verificationStatusPhoneStatusEnum_incomplete,
  _$verificationStatusPhoneStatusEnum_pending,
  _$verificationStatusPhoneStatusEnum_verified,
  _$verificationStatusPhoneStatusEnum_review,
  _$verificationStatusPhoneStatusEnum_unavailable,
]);

Serializer<VerificationStatusPhoneStatusEnum>
    _$verificationStatusPhoneStatusEnumSerializer =
    _$VerificationStatusPhoneStatusEnumSerializer();

class _$VerificationStatusPhoneStatusEnumSerializer
    implements PrimitiveSerializer<VerificationStatusPhoneStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'incomplete': 'incomplete',
    'pending': 'pending',
    'verified': 'verified',
    'review': 'review',
    'unavailable': 'unavailable',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'incomplete': 'incomplete',
    'pending': 'pending',
    'verified': 'verified',
    'review': 'review',
    'unavailable': 'unavailable',
  };

  @override
  final Iterable<Type> types = const <Type>[VerificationStatusPhoneStatusEnum];
  @override
  final String wireName = 'VerificationStatusPhoneStatusEnum';

  @override
  Object serialize(
          Serializers serializers, VerificationStatusPhoneStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  VerificationStatusPhoneStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      VerificationStatusPhoneStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$VerificationStatusPhone extends VerificationStatusPhone {
  @override
  final VerificationStatusPhoneStatusEnum status;
  @override
  final String? maskedNumber;
  @override
  final DateTime? verifiedAt;

  factory _$VerificationStatusPhone(
          [void Function(VerificationStatusPhoneBuilder)? updates]) =>
      (VerificationStatusPhoneBuilder()..update(updates))._build();

  _$VerificationStatusPhone._(
      {required this.status, this.maskedNumber, this.verifiedAt})
      : super._();
  @override
  VerificationStatusPhone rebuild(
          void Function(VerificationStatusPhoneBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerificationStatusPhoneBuilder toBuilder() =>
      VerificationStatusPhoneBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerificationStatusPhone &&
        status == other.status &&
        maskedNumber == other.maskedNumber &&
        verifiedAt == other.verifiedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, maskedNumber.hashCode);
    _$hash = $jc(_$hash, verifiedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerificationStatusPhone')
          ..add('status', status)
          ..add('maskedNumber', maskedNumber)
          ..add('verifiedAt', verifiedAt))
        .toString();
  }
}

class VerificationStatusPhoneBuilder
    implements
        Builder<VerificationStatusPhone, VerificationStatusPhoneBuilder> {
  _$VerificationStatusPhone? _$v;

  VerificationStatusPhoneStatusEnum? _status;
  VerificationStatusPhoneStatusEnum? get status => _$this._status;
  set status(VerificationStatusPhoneStatusEnum? status) =>
      _$this._status = status;

  String? _maskedNumber;
  String? get maskedNumber => _$this._maskedNumber;
  set maskedNumber(String? maskedNumber) => _$this._maskedNumber = maskedNumber;

  DateTime? _verifiedAt;
  DateTime? get verifiedAt => _$this._verifiedAt;
  set verifiedAt(DateTime? verifiedAt) => _$this._verifiedAt = verifiedAt;

  VerificationStatusPhoneBuilder() {
    VerificationStatusPhone._defaults(this);
  }

  VerificationStatusPhoneBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _maskedNumber = $v.maskedNumber;
      _verifiedAt = $v.verifiedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerificationStatusPhone other) {
    _$v = other as _$VerificationStatusPhone;
  }

  @override
  void update(void Function(VerificationStatusPhoneBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerificationStatusPhone build() => _build();

  _$VerificationStatusPhone _build() {
    final _$result = _$v ??
        _$VerificationStatusPhone._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'VerificationStatusPhone', 'status'),
          maskedNumber: maskedNumber,
          verifiedAt: verifiedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
