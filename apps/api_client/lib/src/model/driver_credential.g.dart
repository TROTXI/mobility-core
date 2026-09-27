// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_credential.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverCredentialStatusEnum _$driverCredentialStatusEnum_active =
    const DriverCredentialStatusEnum._('active');
const DriverCredentialStatusEnum _$driverCredentialStatusEnum_suspended =
    const DriverCredentialStatusEnum._('suspended');

DriverCredentialStatusEnum _$driverCredentialStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$driverCredentialStatusEnum_active;
    case 'suspended':
      return _$driverCredentialStatusEnum_suspended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverCredentialStatusEnum> _$driverCredentialStatusEnumValues =
    BuiltSet<DriverCredentialStatusEnum>(const <DriverCredentialStatusEnum>[
  _$driverCredentialStatusEnum_active,
  _$driverCredentialStatusEnum_suspended,
]);

Serializer<DriverCredentialStatusEnum> _$driverCredentialStatusEnumSerializer =
    _$DriverCredentialStatusEnumSerializer();

class _$DriverCredentialStatusEnumSerializer
    implements PrimitiveSerializer<DriverCredentialStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'suspended': 'suspended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'suspended': 'suspended',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverCredentialStatusEnum];
  @override
  final String wireName = 'DriverCredentialStatusEnum';

  @override
  Object serialize(Serializers serializers, DriverCredentialStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverCredentialStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverCredentialStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverCredential extends DriverCredential {
  @override
  final String driverCode;
  @override
  final DriverCredentialStatusEnum status;
  @override
  final bool mustChangePin;
  @override
  final DateTime? temporaryPinExpiresAt;
  @override
  final DateTime? lockedUntil;

  factory _$DriverCredential(
          [void Function(DriverCredentialBuilder)? updates]) =>
      (DriverCredentialBuilder()..update(updates))._build();

  _$DriverCredential._(
      {required this.driverCode,
      required this.status,
      required this.mustChangePin,
      this.temporaryPinExpiresAt,
      this.lockedUntil})
      : super._();
  @override
  DriverCredential rebuild(void Function(DriverCredentialBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverCredentialBuilder toBuilder() =>
      DriverCredentialBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverCredential &&
        driverCode == other.driverCode &&
        status == other.status &&
        mustChangePin == other.mustChangePin &&
        temporaryPinExpiresAt == other.temporaryPinExpiresAt &&
        lockedUntil == other.lockedUntil;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverCode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, mustChangePin.hashCode);
    _$hash = $jc(_$hash, temporaryPinExpiresAt.hashCode);
    _$hash = $jc(_$hash, lockedUntil.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverCredential')
          ..add('driverCode', driverCode)
          ..add('status', status)
          ..add('mustChangePin', mustChangePin)
          ..add('temporaryPinExpiresAt', temporaryPinExpiresAt)
          ..add('lockedUntil', lockedUntil))
        .toString();
  }
}

class DriverCredentialBuilder
    implements Builder<DriverCredential, DriverCredentialBuilder> {
  _$DriverCredential? _$v;

  String? _driverCode;
  String? get driverCode => _$this._driverCode;
  set driverCode(String? driverCode) => _$this._driverCode = driverCode;

  DriverCredentialStatusEnum? _status;
  DriverCredentialStatusEnum? get status => _$this._status;
  set status(DriverCredentialStatusEnum? status) => _$this._status = status;

  bool? _mustChangePin;
  bool? get mustChangePin => _$this._mustChangePin;
  set mustChangePin(bool? mustChangePin) =>
      _$this._mustChangePin = mustChangePin;

  DateTime? _temporaryPinExpiresAt;
  DateTime? get temporaryPinExpiresAt => _$this._temporaryPinExpiresAt;
  set temporaryPinExpiresAt(DateTime? temporaryPinExpiresAt) =>
      _$this._temporaryPinExpiresAt = temporaryPinExpiresAt;

  DateTime? _lockedUntil;
  DateTime? get lockedUntil => _$this._lockedUntil;
  set lockedUntil(DateTime? lockedUntil) => _$this._lockedUntil = lockedUntil;

  DriverCredentialBuilder() {
    DriverCredential._defaults(this);
  }

  DriverCredentialBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverCode = $v.driverCode;
      _status = $v.status;
      _mustChangePin = $v.mustChangePin;
      _temporaryPinExpiresAt = $v.temporaryPinExpiresAt;
      _lockedUntil = $v.lockedUntil;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverCredential other) {
    _$v = other as _$DriverCredential;
  }

  @override
  void update(void Function(DriverCredentialBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverCredential build() => _build();

  _$DriverCredential _build() {
    final _$result = _$v ??
        _$DriverCredential._(
          driverCode: BuiltValueNullFieldError.checkNotNull(
              driverCode, r'DriverCredential', 'driverCode'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'DriverCredential', 'status'),
          mustChangePin: BuiltValueNullFieldError.checkNotNull(
              mustChangePin, r'DriverCredential', 'mustChangePin'),
          temporaryPinExpiresAt: temporaryPinExpiresAt,
          lockedUntil: lockedUntil,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
