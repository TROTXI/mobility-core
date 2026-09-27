// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_credential_sms.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverCredentialSmsPurposeEnum
    _$driverCredentialSmsPurposeEnum_onboarding =
    const DriverCredentialSmsPurposeEnum._('onboarding');
const DriverCredentialSmsPurposeEnum _$driverCredentialSmsPurposeEnum_pinReset =
    const DriverCredentialSmsPurposeEnum._('pinReset');

DriverCredentialSmsPurposeEnum _$driverCredentialSmsPurposeEnumValueOf(
    String name) {
  switch (name) {
    case 'onboarding':
      return _$driverCredentialSmsPurposeEnum_onboarding;
    case 'pinReset':
      return _$driverCredentialSmsPurposeEnum_pinReset;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverCredentialSmsPurposeEnum>
    _$driverCredentialSmsPurposeEnumValues = BuiltSet<
        DriverCredentialSmsPurposeEnum>(const <DriverCredentialSmsPurposeEnum>[
  _$driverCredentialSmsPurposeEnum_onboarding,
  _$driverCredentialSmsPurposeEnum_pinReset,
]);

const DriverCredentialSmsStateEnum _$driverCredentialSmsStateEnum_queued =
    const DriverCredentialSmsStateEnum._('queued');
const DriverCredentialSmsStateEnum _$driverCredentialSmsStateEnum_sending =
    const DriverCredentialSmsStateEnum._('sending');
const DriverCredentialSmsStateEnum
    _$driverCredentialSmsStateEnum_providerAccepted =
    const DriverCredentialSmsStateEnum._('providerAccepted');
const DriverCredentialSmsStateEnum _$driverCredentialSmsStateEnum_cancelled =
    const DriverCredentialSmsStateEnum._('cancelled');
const DriverCredentialSmsStateEnum _$driverCredentialSmsStateEnum_unknown =
    const DriverCredentialSmsStateEnum._('unknown');

DriverCredentialSmsStateEnum _$driverCredentialSmsStateEnumValueOf(
    String name) {
  switch (name) {
    case 'queued':
      return _$driverCredentialSmsStateEnum_queued;
    case 'sending':
      return _$driverCredentialSmsStateEnum_sending;
    case 'providerAccepted':
      return _$driverCredentialSmsStateEnum_providerAccepted;
    case 'cancelled':
      return _$driverCredentialSmsStateEnum_cancelled;
    case 'unknown':
      return _$driverCredentialSmsStateEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverCredentialSmsStateEnum>
    _$driverCredentialSmsStateEnumValues =
    BuiltSet<DriverCredentialSmsStateEnum>(const <DriverCredentialSmsStateEnum>[
  _$driverCredentialSmsStateEnum_queued,
  _$driverCredentialSmsStateEnum_sending,
  _$driverCredentialSmsStateEnum_providerAccepted,
  _$driverCredentialSmsStateEnum_cancelled,
  _$driverCredentialSmsStateEnum_unknown,
]);

Serializer<DriverCredentialSmsPurposeEnum>
    _$driverCredentialSmsPurposeEnumSerializer =
    _$DriverCredentialSmsPurposeEnumSerializer();
Serializer<DriverCredentialSmsStateEnum>
    _$driverCredentialSmsStateEnumSerializer =
    _$DriverCredentialSmsStateEnumSerializer();

class _$DriverCredentialSmsPurposeEnumSerializer
    implements PrimitiveSerializer<DriverCredentialSmsPurposeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'onboarding': 'onboarding',
    'pinReset': 'pin_reset',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'onboarding': 'onboarding',
    'pin_reset': 'pinReset',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverCredentialSmsPurposeEnum];
  @override
  final String wireName = 'DriverCredentialSmsPurposeEnum';

  @override
  Object serialize(
          Serializers serializers, DriverCredentialSmsPurposeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverCredentialSmsPurposeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverCredentialSmsPurposeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverCredentialSmsStateEnumSerializer
    implements PrimitiveSerializer<DriverCredentialSmsStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'sending': 'sending',
    'providerAccepted': 'provider_accepted',
    'cancelled': 'cancelled',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'sending': 'sending',
    'provider_accepted': 'providerAccepted',
    'cancelled': 'cancelled',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverCredentialSmsStateEnum];
  @override
  final String wireName = 'DriverCredentialSmsStateEnum';

  @override
  Object serialize(Serializers serializers, DriverCredentialSmsStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverCredentialSmsStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverCredentialSmsStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverCredentialSms extends DriverCredentialSms {
  @override
  final DriverCredentialSmsPurposeEnum purpose;
  @override
  final DriverCredentialSmsStateEnum state;
  @override
  final String? failureCode;
  @override
  final DateTime queuedAt;

  factory _$DriverCredentialSms(
          [void Function(DriverCredentialSmsBuilder)? updates]) =>
      (DriverCredentialSmsBuilder()..update(updates))._build();

  _$DriverCredentialSms._(
      {required this.purpose,
      required this.state,
      this.failureCode,
      required this.queuedAt})
      : super._();
  @override
  DriverCredentialSms rebuild(
          void Function(DriverCredentialSmsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverCredentialSmsBuilder toBuilder() =>
      DriverCredentialSmsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverCredentialSms &&
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
    return (newBuiltValueToStringHelper(r'DriverCredentialSms')
          ..add('purpose', purpose)
          ..add('state', state)
          ..add('failureCode', failureCode)
          ..add('queuedAt', queuedAt))
        .toString();
  }
}

class DriverCredentialSmsBuilder
    implements Builder<DriverCredentialSms, DriverCredentialSmsBuilder> {
  _$DriverCredentialSms? _$v;

  DriverCredentialSmsPurposeEnum? _purpose;
  DriverCredentialSmsPurposeEnum? get purpose => _$this._purpose;
  set purpose(DriverCredentialSmsPurposeEnum? purpose) =>
      _$this._purpose = purpose;

  DriverCredentialSmsStateEnum? _state;
  DriverCredentialSmsStateEnum? get state => _$this._state;
  set state(DriverCredentialSmsStateEnum? state) => _$this._state = state;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  DateTime? _queuedAt;
  DateTime? get queuedAt => _$this._queuedAt;
  set queuedAt(DateTime? queuedAt) => _$this._queuedAt = queuedAt;

  DriverCredentialSmsBuilder() {
    DriverCredentialSms._defaults(this);
  }

  DriverCredentialSmsBuilder get _$this {
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
  void replace(DriverCredentialSms other) {
    _$v = other as _$DriverCredentialSms;
  }

  @override
  void update(void Function(DriverCredentialSmsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverCredentialSms build() => _build();

  _$DriverCredentialSms _build() {
    final _$result = _$v ??
        _$DriverCredentialSms._(
          purpose: BuiltValueNullFieldError.checkNotNull(
              purpose, r'DriverCredentialSms', 'purpose'),
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'DriverCredentialSms', 'state'),
          failureCode: failureCode,
          queuedAt: BuiltValueNullFieldError.checkNotNull(
              queuedAt, r'DriverCredentialSms', 'queuedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
