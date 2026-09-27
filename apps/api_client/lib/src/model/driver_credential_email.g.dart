// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_credential_email.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverCredentialEmailPurposeEnum
    _$driverCredentialEmailPurposeEnum_onboarding =
    const DriverCredentialEmailPurposeEnum._('onboarding');
const DriverCredentialEmailPurposeEnum
    _$driverCredentialEmailPurposeEnum_pinReset =
    const DriverCredentialEmailPurposeEnum._('pinReset');

DriverCredentialEmailPurposeEnum _$driverCredentialEmailPurposeEnumValueOf(
    String name) {
  switch (name) {
    case 'onboarding':
      return _$driverCredentialEmailPurposeEnum_onboarding;
    case 'pinReset':
      return _$driverCredentialEmailPurposeEnum_pinReset;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverCredentialEmailPurposeEnum>
    _$driverCredentialEmailPurposeEnumValues = BuiltSet<
        DriverCredentialEmailPurposeEnum>(const <DriverCredentialEmailPurposeEnum>[
  _$driverCredentialEmailPurposeEnum_onboarding,
  _$driverCredentialEmailPurposeEnum_pinReset,
]);

const DriverCredentialEmailStateEnum _$driverCredentialEmailStateEnum_queued =
    const DriverCredentialEmailStateEnum._('queued');
const DriverCredentialEmailStateEnum
    _$driverCredentialEmailStateEnum_providerAccepted =
    const DriverCredentialEmailStateEnum._('providerAccepted');
const DriverCredentialEmailStateEnum
    _$driverCredentialEmailStateEnum_cancelled =
    const DriverCredentialEmailStateEnum._('cancelled');
const DriverCredentialEmailStateEnum _$driverCredentialEmailStateEnum_failed =
    const DriverCredentialEmailStateEnum._('failed');
const DriverCredentialEmailStateEnum _$driverCredentialEmailStateEnum_unknown =
    const DriverCredentialEmailStateEnum._('unknown');

DriverCredentialEmailStateEnum _$driverCredentialEmailStateEnumValueOf(
    String name) {
  switch (name) {
    case 'queued':
      return _$driverCredentialEmailStateEnum_queued;
    case 'providerAccepted':
      return _$driverCredentialEmailStateEnum_providerAccepted;
    case 'cancelled':
      return _$driverCredentialEmailStateEnum_cancelled;
    case 'failed':
      return _$driverCredentialEmailStateEnum_failed;
    case 'unknown':
      return _$driverCredentialEmailStateEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverCredentialEmailStateEnum>
    _$driverCredentialEmailStateEnumValues = BuiltSet<
        DriverCredentialEmailStateEnum>(const <DriverCredentialEmailStateEnum>[
  _$driverCredentialEmailStateEnum_queued,
  _$driverCredentialEmailStateEnum_providerAccepted,
  _$driverCredentialEmailStateEnum_cancelled,
  _$driverCredentialEmailStateEnum_failed,
  _$driverCredentialEmailStateEnum_unknown,
]);

Serializer<DriverCredentialEmailPurposeEnum>
    _$driverCredentialEmailPurposeEnumSerializer =
    _$DriverCredentialEmailPurposeEnumSerializer();
Serializer<DriverCredentialEmailStateEnum>
    _$driverCredentialEmailStateEnumSerializer =
    _$DriverCredentialEmailStateEnumSerializer();

class _$DriverCredentialEmailPurposeEnumSerializer
    implements PrimitiveSerializer<DriverCredentialEmailPurposeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'onboarding': 'onboarding',
    'pinReset': 'pin_reset',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'onboarding': 'onboarding',
    'pin_reset': 'pinReset',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverCredentialEmailPurposeEnum];
  @override
  final String wireName = 'DriverCredentialEmailPurposeEnum';

  @override
  Object serialize(
          Serializers serializers, DriverCredentialEmailPurposeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverCredentialEmailPurposeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverCredentialEmailPurposeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverCredentialEmailStateEnumSerializer
    implements PrimitiveSerializer<DriverCredentialEmailStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'providerAccepted': 'provider_accepted',
    'cancelled': 'cancelled',
    'failed': 'failed',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'provider_accepted': 'providerAccepted',
    'cancelled': 'cancelled',
    'failed': 'failed',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverCredentialEmailStateEnum];
  @override
  final String wireName = 'DriverCredentialEmailStateEnum';

  @override
  Object serialize(
          Serializers serializers, DriverCredentialEmailStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverCredentialEmailStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverCredentialEmailStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverCredentialEmail extends DriverCredentialEmail {
  @override
  final DriverCredentialEmailPurposeEnum purpose;
  @override
  final DriverCredentialEmailStateEnum state;
  @override
  final String? failureCode;
  @override
  final DateTime queuedAt;

  factory _$DriverCredentialEmail(
          [void Function(DriverCredentialEmailBuilder)? updates]) =>
      (DriverCredentialEmailBuilder()..update(updates))._build();

  _$DriverCredentialEmail._(
      {required this.purpose,
      required this.state,
      this.failureCode,
      required this.queuedAt})
      : super._();
  @override
  DriverCredentialEmail rebuild(
          void Function(DriverCredentialEmailBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverCredentialEmailBuilder toBuilder() =>
      DriverCredentialEmailBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverCredentialEmail &&
        purpose == other.purpose &&
        state == other.state &&
        failureCode == other.failureCode &&
        queuedAt == other.queuedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, purpose.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jc(_$hash, queuedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverCredentialEmail')
          ..add('purpose', purpose)
          ..add('state', state)
          ..add('failureCode', failureCode)
          ..add('queuedAt', queuedAt))
        .toString();
  }
}

class DriverCredentialEmailBuilder
    implements Builder<DriverCredentialEmail, DriverCredentialEmailBuilder> {
  _$DriverCredentialEmail? _$v;

  DriverCredentialEmailPurposeEnum? _purpose;
  DriverCredentialEmailPurposeEnum? get purpose => _$this._purpose;
  set purpose(DriverCredentialEmailPurposeEnum? purpose) =>
      _$this._purpose = purpose;

  DriverCredentialEmailStateEnum? _state;
  DriverCredentialEmailStateEnum? get state => _$this._state;
  set state(DriverCredentialEmailStateEnum? state) => _$this._state = state;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  DateTime? _queuedAt;
  DateTime? get queuedAt => _$this._queuedAt;
  set queuedAt(DateTime? queuedAt) => _$this._queuedAt = queuedAt;

  DriverCredentialEmailBuilder() {
    DriverCredentialEmail._defaults(this);
  }

  DriverCredentialEmailBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _purpose = $v.purpose;
      _state = $v.state;
      _failureCode = $v.failureCode;
      _queuedAt = $v.queuedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverCredentialEmail other) {
    _$v = other as _$DriverCredentialEmail;
  }

  @override
  void update(void Function(DriverCredentialEmailBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverCredentialEmail build() => _build();

  _$DriverCredentialEmail _build() {
    final _$result = _$v ??
        _$DriverCredentialEmail._(
          purpose: BuiltValueNullFieldError.checkNotNull(
              purpose, r'DriverCredentialEmail', 'purpose'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'DriverCredentialEmail', 'state'),
          failureCode: failureCode,
          queuedAt: BuiltValueNullFieldError.checkNotNull(
              queuedAt, r'DriverCredentialEmail', 'queuedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
