// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_renewal_upcoming.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AutoRenewalUpcomingStateEnum _$autoRenewalUpcomingStateEnum_scheduled =
    const AutoRenewalUpcomingStateEnum._('scheduled');
const AutoRenewalUpcomingStateEnum _$autoRenewalUpcomingStateEnum_reminded =
    const AutoRenewalUpcomingStateEnum._('reminded');
const AutoRenewalUpcomingStateEnum _$autoRenewalUpcomingStateEnum_charging =
    const AutoRenewalUpcomingStateEnum._('charging');
const AutoRenewalUpcomingStateEnum _$autoRenewalUpcomingStateEnum_failed =
    const AutoRenewalUpcomingStateEnum._('failed');
const AutoRenewalUpcomingStateEnum _$autoRenewalUpcomingStateEnum_needsOffer =
    const AutoRenewalUpcomingStateEnum._('needsOffer');

AutoRenewalUpcomingStateEnum _$autoRenewalUpcomingStateEnumValueOf(
    String name) {
  switch (name) {
    case 'scheduled':
      return _$autoRenewalUpcomingStateEnum_scheduled;
    case 'reminded':
      return _$autoRenewalUpcomingStateEnum_reminded;
    case 'charging':
      return _$autoRenewalUpcomingStateEnum_charging;
    case 'failed':
      return _$autoRenewalUpcomingStateEnum_failed;
    case 'needsOffer':
      return _$autoRenewalUpcomingStateEnum_needsOffer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AutoRenewalUpcomingStateEnum>
    _$autoRenewalUpcomingStateEnumValues =
    BuiltSet<AutoRenewalUpcomingStateEnum>(const <AutoRenewalUpcomingStateEnum>[
  _$autoRenewalUpcomingStateEnum_scheduled,
  _$autoRenewalUpcomingStateEnum_reminded,
  _$autoRenewalUpcomingStateEnum_charging,
  _$autoRenewalUpcomingStateEnum_failed,
  _$autoRenewalUpcomingStateEnum_needsOffer,
]);

const AutoRenewalUpcomingFailureCodeEnum
    _$autoRenewalUpcomingFailureCodeEnum_cardDeclined =
    const AutoRenewalUpcomingFailureCodeEnum._('cardDeclined');
const AutoRenewalUpcomingFailureCodeEnum
    _$autoRenewalUpcomingFailureCodeEnum_chargeUnconfirmed =
    const AutoRenewalUpcomingFailureCodeEnum._('chargeUnconfirmed');
const AutoRenewalUpcomingFailureCodeEnum
    _$autoRenewalUpcomingFailureCodeEnum_fareChanged =
    const AutoRenewalUpcomingFailureCodeEnum._('fareChanged');
const AutoRenewalUpcomingFailureCodeEnum
    _$autoRenewalUpcomingFailureCodeEnum_serviceChanged =
    const AutoRenewalUpcomingFailureCodeEnum._('serviceChanged');
const AutoRenewalUpcomingFailureCodeEnum
    _$autoRenewalUpcomingFailureCodeEnum_noCard =
    const AutoRenewalUpcomingFailureCodeEnum._('noCard');
const AutoRenewalUpcomingFailureCodeEnum
    _$autoRenewalUpcomingFailureCodeEnum_coverageConflict =
    const AutoRenewalUpcomingFailureCodeEnum._('coverageConflict');
const AutoRenewalUpcomingFailureCodeEnum
    _$autoRenewalUpcomingFailureCodeEnum_renewalBlocked =
    const AutoRenewalUpcomingFailureCodeEnum._('renewalBlocked');

AutoRenewalUpcomingFailureCodeEnum _$autoRenewalUpcomingFailureCodeEnumValueOf(
    String name) {
  switch (name) {
    case 'cardDeclined':
      return _$autoRenewalUpcomingFailureCodeEnum_cardDeclined;
    case 'chargeUnconfirmed':
      return _$autoRenewalUpcomingFailureCodeEnum_chargeUnconfirmed;
    case 'fareChanged':
      return _$autoRenewalUpcomingFailureCodeEnum_fareChanged;
    case 'serviceChanged':
      return _$autoRenewalUpcomingFailureCodeEnum_serviceChanged;
    case 'noCard':
      return _$autoRenewalUpcomingFailureCodeEnum_noCard;
    case 'coverageConflict':
      return _$autoRenewalUpcomingFailureCodeEnum_coverageConflict;
    case 'renewalBlocked':
      return _$autoRenewalUpcomingFailureCodeEnum_renewalBlocked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AutoRenewalUpcomingFailureCodeEnum>
    _$autoRenewalUpcomingFailureCodeEnumValues = BuiltSet<
        AutoRenewalUpcomingFailureCodeEnum>(const <AutoRenewalUpcomingFailureCodeEnum>[
  _$autoRenewalUpcomingFailureCodeEnum_cardDeclined,
  _$autoRenewalUpcomingFailureCodeEnum_chargeUnconfirmed,
  _$autoRenewalUpcomingFailureCodeEnum_fareChanged,
  _$autoRenewalUpcomingFailureCodeEnum_serviceChanged,
  _$autoRenewalUpcomingFailureCodeEnum_noCard,
  _$autoRenewalUpcomingFailureCodeEnum_coverageConflict,
  _$autoRenewalUpcomingFailureCodeEnum_renewalBlocked,
]);

Serializer<AutoRenewalUpcomingStateEnum>
    _$autoRenewalUpcomingStateEnumSerializer =
    _$AutoRenewalUpcomingStateEnumSerializer();
Serializer<AutoRenewalUpcomingFailureCodeEnum>
    _$autoRenewalUpcomingFailureCodeEnumSerializer =
    _$AutoRenewalUpcomingFailureCodeEnumSerializer();

class _$AutoRenewalUpcomingStateEnumSerializer
    implements PrimitiveSerializer<AutoRenewalUpcomingStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'scheduled': 'scheduled',
    'reminded': 'reminded',
    'charging': 'charging',
    'failed': 'failed',
    'needsOffer': 'needs_offer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'scheduled': 'scheduled',
    'reminded': 'reminded',
    'charging': 'charging',
    'failed': 'failed',
    'needs_offer': 'needsOffer',
  };

  @override
  final Iterable<Type> types = const <Type>[AutoRenewalUpcomingStateEnum];
  @override
  final String wireName = 'AutoRenewalUpcomingStateEnum';

  @override
  Object serialize(Serializers serializers, AutoRenewalUpcomingStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AutoRenewalUpcomingStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AutoRenewalUpcomingStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AutoRenewalUpcomingFailureCodeEnumSerializer
    implements PrimitiveSerializer<AutoRenewalUpcomingFailureCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cardDeclined': 'card_declined',
    'chargeUnconfirmed': 'charge_unconfirmed',
    'fareChanged': 'fare_changed',
    'serviceChanged': 'service_changed',
    'noCard': 'no_card',
    'coverageConflict': 'coverage_conflict',
    'renewalBlocked': 'renewal_blocked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'card_declined': 'cardDeclined',
    'charge_unconfirmed': 'chargeUnconfirmed',
    'fare_changed': 'fareChanged',
    'service_changed': 'serviceChanged',
    'no_card': 'noCard',
    'coverage_conflict': 'coverageConflict',
    'renewal_blocked': 'renewalBlocked',
  };

  @override
  final Iterable<Type> types = const <Type>[AutoRenewalUpcomingFailureCodeEnum];
  @override
  final String wireName = 'AutoRenewalUpcomingFailureCodeEnum';

  @override
  Object serialize(
          Serializers serializers, AutoRenewalUpcomingFailureCodeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AutoRenewalUpcomingFailureCodeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AutoRenewalUpcomingFailureCodeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AutoRenewalUpcoming extends AutoRenewalUpcoming {
  @override
  final AutoRenewalUpcomingStateEnum state;
  @override
  final DateTime periodEndsAt;
  @override
  final DateTime chargeFrom;
  @override
  final DateTime? nextAttemptAt;
  @override
  final Money price;
  @override
  final AutoRenewalUpcomingFailureCodeEnum? failureCode;

  factory _$AutoRenewalUpcoming(
          [void Function(AutoRenewalUpcomingBuilder)? updates]) =>
      (AutoRenewalUpcomingBuilder()..update(updates))._build();

  _$AutoRenewalUpcoming._(
      {required this.state,
      required this.periodEndsAt,
      required this.chargeFrom,
      this.nextAttemptAt,
      required this.price,
      this.failureCode})
      : super._();
  @override
  AutoRenewalUpcoming rebuild(
          void Function(AutoRenewalUpcomingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoRenewalUpcomingBuilder toBuilder() =>
      AutoRenewalUpcomingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoRenewalUpcoming &&
        state == other.state &&
        periodEndsAt == other.periodEndsAt &&
        chargeFrom == other.chargeFrom &&
        nextAttemptAt == other.nextAttemptAt &&
        price == other.price &&
        failureCode == other.failureCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, periodEndsAt.hashCode);
    _$hash = $jc(_$hash, chargeFrom.hashCode);
    _$hash = $jc(_$hash, nextAttemptAt.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoRenewalUpcoming')
          ..add('state', state)
          ..add('periodEndsAt', periodEndsAt)
          ..add('chargeFrom', chargeFrom)
          ..add('nextAttemptAt', nextAttemptAt)
          ..add('price', price)
          ..add('failureCode', failureCode))
        .toString();
  }
}

class AutoRenewalUpcomingBuilder
    implements Builder<AutoRenewalUpcoming, AutoRenewalUpcomingBuilder> {
  _$AutoRenewalUpcoming? _$v;

  AutoRenewalUpcomingStateEnum? _state;
  AutoRenewalUpcomingStateEnum? get state => _$this._state;
  set state(AutoRenewalUpcomingStateEnum? state) => _$this._state = state;

  DateTime? _periodEndsAt;
  DateTime? get periodEndsAt => _$this._periodEndsAt;
  set periodEndsAt(DateTime? periodEndsAt) =>
      _$this._periodEndsAt = periodEndsAt;

  DateTime? _chargeFrom;
  DateTime? get chargeFrom => _$this._chargeFrom;
  set chargeFrom(DateTime? chargeFrom) => _$this._chargeFrom = chargeFrom;

  DateTime? _nextAttemptAt;
  DateTime? get nextAttemptAt => _$this._nextAttemptAt;
  set nextAttemptAt(DateTime? nextAttemptAt) =>
      _$this._nextAttemptAt = nextAttemptAt;

  MoneyBuilder? _price;
  MoneyBuilder get price => _$this._price ??= MoneyBuilder();
  set price(MoneyBuilder? price) => _$this._price = price;

  AutoRenewalUpcomingFailureCodeEnum? _failureCode;
  AutoRenewalUpcomingFailureCodeEnum? get failureCode => _$this._failureCode;
  set failureCode(AutoRenewalUpcomingFailureCodeEnum? failureCode) =>
      _$this._failureCode = failureCode;

  AutoRenewalUpcomingBuilder() {
    AutoRenewalUpcoming._defaults(this);
  }

  AutoRenewalUpcomingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _state = $v.state;
      _periodEndsAt = $v.periodEndsAt;
      _chargeFrom = $v.chargeFrom;
      _nextAttemptAt = $v.nextAttemptAt;
      _price = $v.price.toBuilder();
      _failureCode = $v.failureCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoRenewalUpcoming other) {
    _$v = other as _$AutoRenewalUpcoming;
  }

  @override
  void update(void Function(AutoRenewalUpcomingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoRenewalUpcoming build() => _build();

  _$AutoRenewalUpcoming _build() {
    _$AutoRenewalUpcoming _$result;
    try {
      _$result = _$v ??
          _$AutoRenewalUpcoming._(
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'AutoRenewalUpcoming', 'state'),
            periodEndsAt: BuiltValueNullFieldError.checkNotNull(
                periodEndsAt, r'AutoRenewalUpcoming', 'periodEndsAt'),
            chargeFrom: BuiltValueNullFieldError.checkNotNull(
                chargeFrom, r'AutoRenewalUpcoming', 'chargeFrom'),
            nextAttemptAt: nextAttemptAt,
            price: price.build(),
            failureCode: failureCode,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'price';
        price.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AutoRenewalUpcoming', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
