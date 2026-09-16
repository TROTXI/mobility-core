// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsPurchasePlanEnum _$opsPurchasePlanEnum_monthly =
    const OpsPurchasePlanEnum._('monthly');
const OpsPurchasePlanEnum _$opsPurchasePlanEnum_annual =
    const OpsPurchasePlanEnum._('annual');

OpsPurchasePlanEnum _$opsPurchasePlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$opsPurchasePlanEnum_monthly;
    case 'annual':
      return _$opsPurchasePlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchasePlanEnum> _$opsPurchasePlanEnumValues =
    BuiltSet<OpsPurchasePlanEnum>(const <OpsPurchasePlanEnum>[
  _$opsPurchasePlanEnum_monthly,
  _$opsPurchasePlanEnum_annual,
]);

const OpsPurchaseStateEnum _$opsPurchaseStateEnum_awaitingPayment =
    const OpsPurchaseStateEnum._('awaitingPayment');
const OpsPurchaseStateEnum _$opsPurchaseStateEnum_processing =
    const OpsPurchaseStateEnum._('processing');
const OpsPurchaseStateEnum _$opsPurchaseStateEnum_fulfilled =
    const OpsPurchaseStateEnum._('fulfilled');
const OpsPurchaseStateEnum _$opsPurchaseStateEnum_failed =
    const OpsPurchaseStateEnum._('failed');
const OpsPurchaseStateEnum _$opsPurchaseStateEnum_cancelled =
    const OpsPurchaseStateEnum._('cancelled');
const OpsPurchaseStateEnum _$opsPurchaseStateEnum_reviewRequired =
    const OpsPurchaseStateEnum._('reviewRequired');

OpsPurchaseStateEnum _$opsPurchaseStateEnumValueOf(String name) {
  switch (name) {
    case 'awaitingPayment':
      return _$opsPurchaseStateEnum_awaitingPayment;
    case 'processing':
      return _$opsPurchaseStateEnum_processing;
    case 'fulfilled':
      return _$opsPurchaseStateEnum_fulfilled;
    case 'failed':
      return _$opsPurchaseStateEnum_failed;
    case 'cancelled':
      return _$opsPurchaseStateEnum_cancelled;
    case 'reviewRequired':
      return _$opsPurchaseStateEnum_reviewRequired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseStateEnum> _$opsPurchaseStateEnumValues =
    BuiltSet<OpsPurchaseStateEnum>(const <OpsPurchaseStateEnum>[
  _$opsPurchaseStateEnum_awaitingPayment,
  _$opsPurchaseStateEnum_processing,
  _$opsPurchaseStateEnum_fulfilled,
  _$opsPurchaseStateEnum_failed,
  _$opsPurchaseStateEnum_cancelled,
  _$opsPurchaseStateEnum_reviewRequired,
]);

const OpsPurchaseCollectionStateEnum _$opsPurchaseCollectionStateEnum_pending =
    const OpsPurchaseCollectionStateEnum._('pending');
const OpsPurchaseCollectionStateEnum
    _$opsPurchaseCollectionStateEnum_successful =
    const OpsPurchaseCollectionStateEnum._('successful');
const OpsPurchaseCollectionStateEnum _$opsPurchaseCollectionStateEnum_failed =
    const OpsPurchaseCollectionStateEnum._('failed');
const OpsPurchaseCollectionStateEnum _$opsPurchaseCollectionStateEnum_unknown =
    const OpsPurchaseCollectionStateEnum._('unknown');

OpsPurchaseCollectionStateEnum _$opsPurchaseCollectionStateEnumValueOf(
    String name) {
  switch (name) {
    case 'pending':
      return _$opsPurchaseCollectionStateEnum_pending;
    case 'successful':
      return _$opsPurchaseCollectionStateEnum_successful;
    case 'failed':
      return _$opsPurchaseCollectionStateEnum_failed;
    case 'unknown':
      return _$opsPurchaseCollectionStateEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseCollectionStateEnum>
    _$opsPurchaseCollectionStateEnumValues = BuiltSet<
        OpsPurchaseCollectionStateEnum>(const <OpsPurchaseCollectionStateEnum>[
  _$opsPurchaseCollectionStateEnum_pending,
  _$opsPurchaseCollectionStateEnum_successful,
  _$opsPurchaseCollectionStateEnum_failed,
  _$opsPurchaseCollectionStateEnum_unknown,
]);

Serializer<OpsPurchasePlanEnum> _$opsPurchasePlanEnumSerializer =
    _$OpsPurchasePlanEnumSerializer();
Serializer<OpsPurchaseStateEnum> _$opsPurchaseStateEnumSerializer =
    _$OpsPurchaseStateEnumSerializer();
Serializer<OpsPurchaseCollectionStateEnum>
    _$opsPurchaseCollectionStateEnumSerializer =
    _$OpsPurchaseCollectionStateEnumSerializer();

class _$OpsPurchasePlanEnumSerializer
    implements PrimitiveSerializer<OpsPurchasePlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsPurchasePlanEnum];
  @override
  final String wireName = 'OpsPurchasePlanEnum';

  @override
  Object serialize(Serializers serializers, OpsPurchasePlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchasePlanEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchasePlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseStateEnumSerializer
    implements PrimitiveSerializer<OpsPurchaseStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'awaitingPayment': 'awaiting_payment',
    'processing': 'processing',
    'fulfilled': 'fulfilled',
    'failed': 'failed',
    'cancelled': 'cancelled',
    'reviewRequired': 'review_required',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'awaiting_payment': 'awaitingPayment',
    'processing': 'processing',
    'fulfilled': 'fulfilled',
    'failed': 'failed',
    'cancelled': 'cancelled',
    'review_required': 'reviewRequired',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsPurchaseStateEnum];
  @override
  final String wireName = 'OpsPurchaseStateEnum';

  @override
  Object serialize(Serializers serializers, OpsPurchaseStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseStateEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseCollectionStateEnumSerializer
    implements PrimitiveSerializer<OpsPurchaseCollectionStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'successful': 'successful',
    'failed': 'failed',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'successful': 'successful',
    'failed': 'failed',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsPurchaseCollectionStateEnum];
  @override
  final String wireName = 'OpsPurchaseCollectionStateEnum';

  @override
  Object serialize(
          Serializers serializers, OpsPurchaseCollectionStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseCollectionStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseCollectionStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchase extends OpsPurchase {
  @override
  final String id;
  @override
  final OpsPurchasePlanEnum plan;
  @override
  final OpsPurchaseStateEnum state;
  @override
  final OpsPurchaseCollectionStateEnum collectionState;
  @override
  final Money price;
  @override
  final Money appliedCredit;
  @override
  final Money cashDue;
  @override
  final OpsPurchaseCheckout? checkout;
  @override
  final String? billingPeriodId;
  @override
  final String? failureCode;
  @override
  final DateTime createdAt;
  @override
  final String riderId;
  @override
  final BuiltList<OpsPurchaseAttemptsInner> attempts;

  factory _$OpsPurchase([void Function(OpsPurchaseBuilder)? updates]) =>
      (OpsPurchaseBuilder()..update(updates))._build();

  _$OpsPurchase._(
      {required this.id,
      required this.plan,
      required this.state,
      required this.collectionState,
      required this.price,
      required this.appliedCredit,
      required this.cashDue,
      this.checkout,
      this.billingPeriodId,
      this.failureCode,
      required this.createdAt,
      required this.riderId,
      required this.attempts})
      : super._();
  @override
  OpsPurchase rebuild(void Function(OpsPurchaseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseBuilder toBuilder() => OpsPurchaseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchase &&
        id == other.id &&
        plan == other.plan &&
        state == other.state &&
        collectionState == other.collectionState &&
        price == other.price &&
        appliedCredit == other.appliedCredit &&
        cashDue == other.cashDue &&
        checkout == other.checkout &&
        billingPeriodId == other.billingPeriodId &&
        failureCode == other.failureCode &&
        createdAt == other.createdAt &&
        riderId == other.riderId &&
        attempts == other.attempts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, collectionState.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, appliedCredit.hashCode);
    _$hash = $jc(_$hash, cashDue.hashCode);
    _$hash = $jc(_$hash, checkout.hashCode);
    _$hash = $jc(_$hash, billingPeriodId.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsPurchase')
          ..add('id', id)
          ..add('plan', plan)
          ..add('state', state)
          ..add('collectionState', collectionState)
          ..add('price', price)
          ..add('appliedCredit', appliedCredit)
          ..add('cashDue', cashDue)
          ..add('checkout', checkout)
          ..add('billingPeriodId', billingPeriodId)
          ..add('failureCode', failureCode)
          ..add('createdAt', createdAt)
          ..add('riderId', riderId)
          ..add('attempts', attempts))
        .toString();
  }
}

class OpsPurchaseBuilder implements Builder<OpsPurchase, OpsPurchaseBuilder> {
  _$OpsPurchase? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OpsPurchasePlanEnum? _plan;
  OpsPurchasePlanEnum? get plan => _$this._plan;
  set plan(OpsPurchasePlanEnum? plan) => _$this._plan = plan;

  OpsPurchaseStateEnum? _state;
  OpsPurchaseStateEnum? get state => _$this._state;
  set state(OpsPurchaseStateEnum? state) => _$this._state = state;

  OpsPurchaseCollectionStateEnum? _collectionState;
  OpsPurchaseCollectionStateEnum? get collectionState =>
      _$this._collectionState;
  set collectionState(OpsPurchaseCollectionStateEnum? collectionState) =>
      _$this._collectionState = collectionState;

  MoneyBuilder? _price;
  MoneyBuilder get price => _$this._price ??= MoneyBuilder();
  set price(MoneyBuilder? price) => _$this._price = price;

  MoneyBuilder? _appliedCredit;
  MoneyBuilder get appliedCredit => _$this._appliedCredit ??= MoneyBuilder();
  set appliedCredit(MoneyBuilder? appliedCredit) =>
      _$this._appliedCredit = appliedCredit;

  MoneyBuilder? _cashDue;
  MoneyBuilder get cashDue => _$this._cashDue ??= MoneyBuilder();
  set cashDue(MoneyBuilder? cashDue) => _$this._cashDue = cashDue;

  OpsPurchaseCheckoutBuilder? _checkout;
  OpsPurchaseCheckoutBuilder get checkout =>
      _$this._checkout ??= OpsPurchaseCheckoutBuilder();
  set checkout(OpsPurchaseCheckoutBuilder? checkout) =>
      _$this._checkout = checkout;

  String? _billingPeriodId;
  String? get billingPeriodId => _$this._billingPeriodId;
  set billingPeriodId(String? billingPeriodId) =>
      _$this._billingPeriodId = billingPeriodId;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  ListBuilder<OpsPurchaseAttemptsInner>? _attempts;
  ListBuilder<OpsPurchaseAttemptsInner> get attempts =>
      _$this._attempts ??= ListBuilder<OpsPurchaseAttemptsInner>();
  set attempts(ListBuilder<OpsPurchaseAttemptsInner>? attempts) =>
      _$this._attempts = attempts;

  OpsPurchaseBuilder() {
    OpsPurchase._defaults(this);
  }

  OpsPurchaseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _plan = $v.plan;
      _state = $v.state;
      _collectionState = $v.collectionState;
      _price = $v.price.toBuilder();
      _appliedCredit = $v.appliedCredit.toBuilder();
      _cashDue = $v.cashDue.toBuilder();
      _checkout = $v.checkout?.toBuilder();
      _billingPeriodId = $v.billingPeriodId;
      _failureCode = $v.failureCode;
      _createdAt = $v.createdAt;
      _riderId = $v.riderId;
      _attempts = $v.attempts.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchase other) {
    _$v = other as _$OpsPurchase;
  }

  @override
  void update(void Function(OpsPurchaseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchase build() => _build();

  _$OpsPurchase _build() {
    _$OpsPurchase _$result;
    try {
      _$result = _$v ??
          _$OpsPurchase._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'OpsPurchase', 'id'),
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'OpsPurchase', 'plan'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'OpsPurchase', 'state'),
            collectionState: BuiltValueNullFieldError.checkNotNull(
                collectionState, r'OpsPurchase', 'collectionState'),
            price: price.build(),
            appliedCredit: appliedCredit.build(),
            cashDue: cashDue.build(),
            checkout: _checkout?.build(),
            billingPeriodId: billingPeriodId,
            failureCode: failureCode,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OpsPurchase', 'createdAt'),
            riderId: BuiltValueNullFieldError.checkNotNull(
                riderId, r'OpsPurchase', 'riderId'),
            attempts: attempts.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'price';
        price.build();
        _$failedField = 'appliedCredit';
        appliedCredit.build();
        _$failedField = 'cashDue';
        cashDue.build();
        _$failedField = 'checkout';
        _checkout?.build();

        _$failedField = 'attempts';
        attempts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsPurchase', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
