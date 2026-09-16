// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PurchasePlanEnum _$purchasePlanEnum_monthly =
    const PurchasePlanEnum._('monthly');
const PurchasePlanEnum _$purchasePlanEnum_annual =
    const PurchasePlanEnum._('annual');

PurchasePlanEnum _$purchasePlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$purchasePlanEnum_monthly;
    case 'annual':
      return _$purchasePlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchasePlanEnum> _$purchasePlanEnumValues =
    BuiltSet<PurchasePlanEnum>(const <PurchasePlanEnum>[
  _$purchasePlanEnum_monthly,
  _$purchasePlanEnum_annual,
]);

const PurchaseStateEnum _$purchaseStateEnum_awaitingPayment =
    const PurchaseStateEnum._('awaitingPayment');
const PurchaseStateEnum _$purchaseStateEnum_processing =
    const PurchaseStateEnum._('processing');
const PurchaseStateEnum _$purchaseStateEnum_fulfilled =
    const PurchaseStateEnum._('fulfilled');
const PurchaseStateEnum _$purchaseStateEnum_failed =
    const PurchaseStateEnum._('failed');
const PurchaseStateEnum _$purchaseStateEnum_cancelled =
    const PurchaseStateEnum._('cancelled');
const PurchaseStateEnum _$purchaseStateEnum_reviewRequired =
    const PurchaseStateEnum._('reviewRequired');

PurchaseStateEnum _$purchaseStateEnumValueOf(String name) {
  switch (name) {
    case 'awaitingPayment':
      return _$purchaseStateEnum_awaitingPayment;
    case 'processing':
      return _$purchaseStateEnum_processing;
    case 'fulfilled':
      return _$purchaseStateEnum_fulfilled;
    case 'failed':
      return _$purchaseStateEnum_failed;
    case 'cancelled':
      return _$purchaseStateEnum_cancelled;
    case 'reviewRequired':
      return _$purchaseStateEnum_reviewRequired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchaseStateEnum> _$purchaseStateEnumValues =
    BuiltSet<PurchaseStateEnum>(const <PurchaseStateEnum>[
  _$purchaseStateEnum_awaitingPayment,
  _$purchaseStateEnum_processing,
  _$purchaseStateEnum_fulfilled,
  _$purchaseStateEnum_failed,
  _$purchaseStateEnum_cancelled,
  _$purchaseStateEnum_reviewRequired,
]);

const PurchaseCollectionStateEnum _$purchaseCollectionStateEnum_pending =
    const PurchaseCollectionStateEnum._('pending');
const PurchaseCollectionStateEnum _$purchaseCollectionStateEnum_successful =
    const PurchaseCollectionStateEnum._('successful');
const PurchaseCollectionStateEnum _$purchaseCollectionStateEnum_failed =
    const PurchaseCollectionStateEnum._('failed');
const PurchaseCollectionStateEnum _$purchaseCollectionStateEnum_unknown =
    const PurchaseCollectionStateEnum._('unknown');

PurchaseCollectionStateEnum _$purchaseCollectionStateEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$purchaseCollectionStateEnum_pending;
    case 'successful':
      return _$purchaseCollectionStateEnum_successful;
    case 'failed':
      return _$purchaseCollectionStateEnum_failed;
    case 'unknown':
      return _$purchaseCollectionStateEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchaseCollectionStateEnum>
    _$purchaseCollectionStateEnumValues =
    BuiltSet<PurchaseCollectionStateEnum>(const <PurchaseCollectionStateEnum>[
  _$purchaseCollectionStateEnum_pending,
  _$purchaseCollectionStateEnum_successful,
  _$purchaseCollectionStateEnum_failed,
  _$purchaseCollectionStateEnum_unknown,
]);

Serializer<PurchasePlanEnum> _$purchasePlanEnumSerializer =
    _$PurchasePlanEnumSerializer();
Serializer<PurchaseStateEnum> _$purchaseStateEnumSerializer =
    _$PurchaseStateEnumSerializer();
Serializer<PurchaseCollectionStateEnum>
    _$purchaseCollectionStateEnumSerializer =
    _$PurchaseCollectionStateEnumSerializer();

class _$PurchasePlanEnumSerializer
    implements PrimitiveSerializer<PurchasePlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[PurchasePlanEnum];
  @override
  final String wireName = 'PurchasePlanEnum';

  @override
  Object serialize(Serializers serializers, PurchasePlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchasePlanEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchasePlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurchaseStateEnumSerializer
    implements PrimitiveSerializer<PurchaseStateEnum> {
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
  final Iterable<Type> types = const <Type>[PurchaseStateEnum];
  @override
  final String wireName = 'PurchaseStateEnum';

  @override
  Object serialize(Serializers serializers, PurchaseStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchaseStateEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchaseStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurchaseCollectionStateEnumSerializer
    implements PrimitiveSerializer<PurchaseCollectionStateEnum> {
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
  final Iterable<Type> types = const <Type>[PurchaseCollectionStateEnum];
  @override
  final String wireName = 'PurchaseCollectionStateEnum';

  @override
  Object serialize(Serializers serializers, PurchaseCollectionStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchaseCollectionStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchaseCollectionStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Purchase extends Purchase {
  @override
  final String id;
  @override
  final PurchasePlanEnum plan;
  @override
  final PurchaseStateEnum state;
  @override
  final PurchaseCollectionStateEnum collectionState;
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

  factory _$Purchase([void Function(PurchaseBuilder)? updates]) =>
      (PurchaseBuilder()..update(updates))._build();

  _$Purchase._(
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
      required this.createdAt})
      : super._();
  @override
  Purchase rebuild(void Function(PurchaseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchaseBuilder toBuilder() => PurchaseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Purchase &&
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
        createdAt == other.createdAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Purchase')
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
          ..add('createdAt', createdAt))
        .toString();
  }
}

class PurchaseBuilder implements Builder<Purchase, PurchaseBuilder> {
  _$Purchase? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PurchasePlanEnum? _plan;
  PurchasePlanEnum? get plan => _$this._plan;
  set plan(PurchasePlanEnum? plan) => _$this._plan = plan;

  PurchaseStateEnum? _state;
  PurchaseStateEnum? get state => _$this._state;
  set state(PurchaseStateEnum? state) => _$this._state = state;

  PurchaseCollectionStateEnum? _collectionState;
  PurchaseCollectionStateEnum? get collectionState => _$this._collectionState;
  set collectionState(PurchaseCollectionStateEnum? collectionState) =>
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

  PurchaseBuilder() {
    Purchase._defaults(this);
  }

  PurchaseBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Purchase other) {
    _$v = other as _$Purchase;
  }

  @override
  void update(void Function(PurchaseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Purchase build() => _build();

  _$Purchase _build() {
    _$Purchase _$result;
    try {
      _$result = _$v ??
          _$Purchase._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Purchase', 'id'),
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'Purchase', 'plan'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'Purchase', 'state'),
            collectionState: BuiltValueNullFieldError.checkNotNull(
                collectionState, r'Purchase', 'collectionState'),
            price: price.build(),
            appliedCredit: appliedCredit.build(),
            cashDue: cashDue.build(),
            checkout: _checkout?.build(),
            billingPeriodId: billingPeriodId,
            failureCode: failureCode,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Purchase', 'createdAt'),
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
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Purchase', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
