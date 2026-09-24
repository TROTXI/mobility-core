// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_self_credential.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverSelfCredentialStatusEnum _$driverSelfCredentialStatusEnum_active =
    const DriverSelfCredentialStatusEnum._('active');
const DriverSelfCredentialStatusEnum
    _$driverSelfCredentialStatusEnum_suspended =
    const DriverSelfCredentialStatusEnum._('suspended');
const DriverSelfCredentialStatusEnum _$driverSelfCredentialStatusEnum_revoked =
    const DriverSelfCredentialStatusEnum._('revoked');

DriverSelfCredentialStatusEnum _$driverSelfCredentialStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'active':
      return _$driverSelfCredentialStatusEnum_active;
    case 'suspended':
      return _$driverSelfCredentialStatusEnum_suspended;
    case 'revoked':
      return _$driverSelfCredentialStatusEnum_revoked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverSelfCredentialStatusEnum>
    _$driverSelfCredentialStatusEnumValues = BuiltSet<
        DriverSelfCredentialStatusEnum>(const <DriverSelfCredentialStatusEnum>[
  _$driverSelfCredentialStatusEnum_active,
  _$driverSelfCredentialStatusEnum_suspended,
  _$driverSelfCredentialStatusEnum_revoked,
]);

Serializer<DriverSelfCredentialStatusEnum>
    _$driverSelfCredentialStatusEnumSerializer =
    _$DriverSelfCredentialStatusEnumSerializer();

class _$DriverSelfCredentialStatusEnumSerializer
    implements PrimitiveSerializer<DriverSelfCredentialStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'suspended': 'suspended',
    'revoked': 'revoked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'suspended': 'suspended',
    'revoked': 'revoked',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverSelfCredentialStatusEnum];
  @override
  final String wireName = 'DriverSelfCredentialStatusEnum';

  @override
  Object serialize(
          Serializers serializers, DriverSelfCredentialStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverSelfCredentialStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverSelfCredentialStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverSelfCredential extends DriverSelfCredential {
  @override
  final String driverCode;
  @override
  final DriverSelfCredentialStatusEnum status;
  @override
  final bool mustChangePin;
  @override
  final DateTime? lockedUntil;

  factory _$DriverSelfCredential(
          [void Function(DriverSelfCredentialBuilder)? updates]) =>
      (DriverSelfCredentialBuilder()..update(updates))._build();

  _$DriverSelfCredential._(
      {required this.driverCode,
      required this.status,
      required this.mustChangePin,
      this.lockedUntil})
      : super._();
  @override
  DriverSelfCredential rebuild(
          void Function(DriverSelfCredentialBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverSelfCredentialBuilder toBuilder() =>
      DriverSelfCredentialBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverSelfCredential &&
        driverCode == other.driverCode &&
        status == other.status &&
        mustChangePin == other.mustChangePin &&
        lockedUntil == other.lockedUntil;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverCode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, mustChangePin.hashCode);
    _$hash = $jc(_$hash, lockedUntil.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverSelfCredential')
          ..add('driverCode', driverCode)
          ..add('status', status)
          ..add('mustChangePin', mustChangePin)
          ..add('lockedUntil', lockedUntil))
        .toString();
  }
}

class DriverSelfCredentialBuilder
    implements Builder<DriverSelfCredential, DriverSelfCredentialBuilder> {
  _$DriverSelfCredential? _$v;

  String? _driverCode;
  String? get driverCode => _$this._driverCode;
  set driverCode(String? driverCode) => _$this._driverCode = driverCode;

  DriverSelfCredentialStatusEnum? _status;
  DriverSelfCredentialStatusEnum? get status => _$this._status;
  set status(DriverSelfCredentialStatusEnum? status) => _$this._status = status;

  bool? _mustChangePin;
  bool? get mustChangePin => _$this._mustChangePin;
  set mustChangePin(bool? mustChangePin) =>
      _$this._mustChangePin = mustChangePin;

  DateTime? _lockedUntil;
  DateTime? get lockedUntil => _$this._lockedUntil;
  set lockedUntil(DateTime? lockedUntil) => _$this._lockedUntil = lockedUntil;

  DriverSelfCredentialBuilder() {
    DriverSelfCredential._defaults(this);
  }

  DriverSelfCredentialBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverCode = $v.driverCode;
      _status = $v.status;
      _mustChangePin = $v.mustChangePin;
      _lockedUntil = $v.lockedUntil;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverSelfCredential other) {
    _$v = other as _$DriverSelfCredential;
  }

  @override
  void update(void Function(DriverSelfCredentialBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverSelfCredential build() => _build();

  _$DriverSelfCredential _build() {
    final _$result = _$v ??
        _$DriverSelfCredential._(
          driverCode: BuiltValueNullFieldError.checkNotNull(
              driverCode, r'DriverSelfCredential', 'driverCode'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'DriverSelfCredential', 'status'),
          mustChangePin: BuiltValueNullFieldError.checkNotNull(
              mustChangePin, r'DriverSelfCredential', 'mustChangePin'),
          lockedUntil: lockedUntil,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
