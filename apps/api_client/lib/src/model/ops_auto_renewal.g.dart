// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_auto_renewal.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_scheduled =
    const OpsAutoRenewalStateEnum._('scheduled');
const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_reminded =
    const OpsAutoRenewalStateEnum._('reminded');
const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_charging =
    const OpsAutoRenewalStateEnum._('charging');
const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_paid =
    const OpsAutoRenewalStateEnum._('paid');
const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_failed =
    const OpsAutoRenewalStateEnum._('failed');
const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_needsOffer =
    const OpsAutoRenewalStateEnum._('needsOffer');
const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_lapsed =
    const OpsAutoRenewalStateEnum._('lapsed');
const OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnum_cancelled =
    const OpsAutoRenewalStateEnum._('cancelled');

OpsAutoRenewalStateEnum _$opsAutoRenewalStateEnumValueOf(String name) {
  switch (name) {
    case 'scheduled':
      return _$opsAutoRenewalStateEnum_scheduled;
    case 'reminded':
      return _$opsAutoRenewalStateEnum_reminded;
    case 'charging':
      return _$opsAutoRenewalStateEnum_charging;
    case 'paid':
      return _$opsAutoRenewalStateEnum_paid;
    case 'failed':
      return _$opsAutoRenewalStateEnum_failed;
    case 'needsOffer':
      return _$opsAutoRenewalStateEnum_needsOffer;
    case 'lapsed':
      return _$opsAutoRenewalStateEnum_lapsed;
    case 'cancelled':
      return _$opsAutoRenewalStateEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsAutoRenewalStateEnum> _$opsAutoRenewalStateEnumValues =
    BuiltSet<OpsAutoRenewalStateEnum>(const <OpsAutoRenewalStateEnum>[
  _$opsAutoRenewalStateEnum_scheduled,
  _$opsAutoRenewalStateEnum_reminded,
  _$opsAutoRenewalStateEnum_charging,
  _$opsAutoRenewalStateEnum_paid,
  _$opsAutoRenewalStateEnum_failed,
  _$opsAutoRenewalStateEnum_needsOffer,
  _$opsAutoRenewalStateEnum_lapsed,
  _$opsAutoRenewalStateEnum_cancelled,
]);

Serializer<OpsAutoRenewalStateEnum> _$opsAutoRenewalStateEnumSerializer =
    _$OpsAutoRenewalStateEnumSerializer();

class _$OpsAutoRenewalStateEnumSerializer
    implements PrimitiveSerializer<OpsAutoRenewalStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'scheduled': 'scheduled',
    'reminded': 'reminded',
    'charging': 'charging',
    'paid': 'paid',
    'failed': 'failed',
    'needsOffer': 'needs_offer',
    'lapsed': 'lapsed',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'scheduled': 'scheduled',
    'reminded': 'reminded',
    'charging': 'charging',
    'paid': 'paid',
    'failed': 'failed',
    'needs_offer': 'needsOffer',
    'lapsed': 'lapsed',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsAutoRenewalStateEnum];
  @override
  final String wireName = 'OpsAutoRenewalStateEnum';

  @override
  Object serialize(Serializers serializers, OpsAutoRenewalStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsAutoRenewalStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsAutoRenewalStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsAutoRenewal extends OpsAutoRenewal {
  @override
  final String id;
  @override
  final String riderId;
  @override
  final String? riderName;
  @override
  final OpsAutoRenewalStateEnum state;
  @override
  final String? failureCode;
  @override
  final int attempts;
  @override
  final DateTime periodEndsAt;
  @override
  final DateTime? nextAttemptAt;
  @override
  final Money price;
  @override
  final OpsAutoRenewalCard? card;
  @override
  final String? renewalPurchaseId;
  @override
  final DateTime updatedAt;

  factory _$OpsAutoRenewal([void Function(OpsAutoRenewalBuilder)? updates]) =>
      (OpsAutoRenewalBuilder()..update(updates))._build();

  _$OpsAutoRenewal._(
      {required this.id,
      required this.riderId,
      this.riderName,
      required this.state,
      this.failureCode,
      required this.attempts,
      required this.periodEndsAt,
      this.nextAttemptAt,
      required this.price,
      this.card,
      this.renewalPurchaseId,
      required this.updatedAt})
      : super._();
  @override
  OpsAutoRenewal rebuild(void Function(OpsAutoRenewalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsAutoRenewalBuilder toBuilder() => OpsAutoRenewalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsAutoRenewal &&
        id == other.id &&
        riderId == other.riderId &&
        riderName == other.riderName &&
        state == other.state &&
        failureCode == other.failureCode &&
        attempts == other.attempts &&
        periodEndsAt == other.periodEndsAt &&
        nextAttemptAt == other.nextAttemptAt &&
        price == other.price &&
        card == other.card &&
        renewalPurchaseId == other.renewalPurchaseId &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, riderName.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, periodEndsAt.hashCode);
    _$hash = $jc(_$hash, nextAttemptAt.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, card.hashCode);
    _$hash = $jc(_$hash, renewalPurchaseId.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsAutoRenewal')
          ..add('id', id)
          ..add('riderId', riderId)
          ..add('riderName', riderName)
          ..add('state', state)
          ..add('failureCode', failureCode)
          ..add('attempts', attempts)
          ..add('periodEndsAt', periodEndsAt)
          ..add('nextAttemptAt', nextAttemptAt)
          ..add('price', price)
          ..add('card', card)
          ..add('renewalPurchaseId', renewalPurchaseId)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OpsAutoRenewalBuilder
    implements Builder<OpsAutoRenewal, OpsAutoRenewalBuilder> {
  _$OpsAutoRenewal? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  String? _riderName;
  String? get riderName => _$this._riderName;
  set riderName(String? riderName) => _$this._riderName = riderName;

  OpsAutoRenewalStateEnum? _state;
  OpsAutoRenewalStateEnum? get state => _$this._state;
  set state(OpsAutoRenewalStateEnum? state) => _$this._state = state;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  DateTime? _periodEndsAt;
  DateTime? get periodEndsAt => _$this._periodEndsAt;
  set periodEndsAt(DateTime? periodEndsAt) =>
      _$this._periodEndsAt = periodEndsAt;

  DateTime? _nextAttemptAt;
  DateTime? get nextAttemptAt => _$this._nextAttemptAt;
  set nextAttemptAt(DateTime? nextAttemptAt) =>
      _$this._nextAttemptAt = nextAttemptAt;

  MoneyBuilder? _price;
  MoneyBuilder get price => _$this._price ??= MoneyBuilder();
  set price(MoneyBuilder? price) => _$this._price = price;

  OpsAutoRenewalCardBuilder? _card;
  OpsAutoRenewalCardBuilder get card =>
      _$this._card ??= OpsAutoRenewalCardBuilder();
  set card(OpsAutoRenewalCardBuilder? card) => _$this._card = card;

  String? _renewalPurchaseId;
  String? get renewalPurchaseId => _$this._renewalPurchaseId;
  set renewalPurchaseId(String? renewalPurchaseId) =>
      _$this._renewalPurchaseId = renewalPurchaseId;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OpsAutoRenewalBuilder() {
    OpsAutoRenewal._defaults(this);
  }

  OpsAutoRenewalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _riderId = $v.riderId;
      _riderName = $v.riderName;
      _state = $v.state;
      _failureCode = $v.failureCode;
      _attempts = $v.attempts;
      _periodEndsAt = $v.periodEndsAt;
      _nextAttemptAt = $v.nextAttemptAt;
      _price = $v.price.toBuilder();
      _card = $v.card?.toBuilder();
      _renewalPurchaseId = $v.renewalPurchaseId;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsAutoRenewal other) {
    _$v = other as _$OpsAutoRenewal;
  }

  @override
  void update(void Function(OpsAutoRenewalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsAutoRenewal build() => _build();

  _$OpsAutoRenewal _build() {
    _$OpsAutoRenewal _$result;
    try {
      _$result = _$v ??
          _$OpsAutoRenewal._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OpsAutoRenewal', 'id'),
            riderId: BuiltValueNullFieldError.checkNotNull(
                riderId, r'OpsAutoRenewal', 'riderId'),
            riderName: riderName,
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'OpsAutoRenewal', 'state'),
            failureCode: failureCode,
            attempts: BuiltValueNullFieldError.checkNotNull(
                attempts, r'OpsAutoRenewal', 'attempts'),
            periodEndsAt: BuiltValueNullFieldError.checkNotNull(
                periodEndsAt, r'OpsAutoRenewal', 'periodEndsAt'),
            nextAttemptAt: nextAttemptAt,
            price: price.build(),
            card: _card?.build(),
            renewalPurchaseId: renewalPurchaseId,
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'OpsAutoRenewal', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'price';
        price.build();
        _$failedField = 'card';
        _card?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsAutoRenewal', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
