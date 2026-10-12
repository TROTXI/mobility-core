// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsPurchaseRowPlanEnum _$opsPurchaseRowPlanEnum_weekly =
    const OpsPurchaseRowPlanEnum._('weekly');
const OpsPurchaseRowPlanEnum _$opsPurchaseRowPlanEnum_biweekly =
    const OpsPurchaseRowPlanEnum._('biweekly');
const OpsPurchaseRowPlanEnum _$opsPurchaseRowPlanEnum_monthly =
    const OpsPurchaseRowPlanEnum._('monthly');
const OpsPurchaseRowPlanEnum _$opsPurchaseRowPlanEnum_annual =
    const OpsPurchaseRowPlanEnum._('annual');

OpsPurchaseRowPlanEnum _$opsPurchaseRowPlanEnumValueOf(String name) {
  switch (name) {
    case 'weekly':
      return _$opsPurchaseRowPlanEnum_weekly;
    case 'biweekly':
      return _$opsPurchaseRowPlanEnum_biweekly;
    case 'monthly':
      return _$opsPurchaseRowPlanEnum_monthly;
    case 'annual':
      return _$opsPurchaseRowPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseRowPlanEnum> _$opsPurchaseRowPlanEnumValues =
    BuiltSet<OpsPurchaseRowPlanEnum>(const <OpsPurchaseRowPlanEnum>[
  _$opsPurchaseRowPlanEnum_weekly,
  _$opsPurchaseRowPlanEnum_biweekly,
  _$opsPurchaseRowPlanEnum_monthly,
  _$opsPurchaseRowPlanEnum_annual,
]);

const OpsPurchaseRowStateEnum _$opsPurchaseRowStateEnum_awaitingPayment =
    const OpsPurchaseRowStateEnum._('awaitingPayment');
const OpsPurchaseRowStateEnum _$opsPurchaseRowStateEnum_processing =
    const OpsPurchaseRowStateEnum._('processing');
const OpsPurchaseRowStateEnum _$opsPurchaseRowStateEnum_fulfilled =
    const OpsPurchaseRowStateEnum._('fulfilled');
const OpsPurchaseRowStateEnum _$opsPurchaseRowStateEnum_failed =
    const OpsPurchaseRowStateEnum._('failed');
const OpsPurchaseRowStateEnum _$opsPurchaseRowStateEnum_cancelled =
    const OpsPurchaseRowStateEnum._('cancelled');
const OpsPurchaseRowStateEnum _$opsPurchaseRowStateEnum_reviewRequired =
    const OpsPurchaseRowStateEnum._('reviewRequired');

OpsPurchaseRowStateEnum _$opsPurchaseRowStateEnumValueOf(String name) {
  switch (name) {
    case 'awaitingPayment':
      return _$opsPurchaseRowStateEnum_awaitingPayment;
    case 'processing':
      return _$opsPurchaseRowStateEnum_processing;
    case 'fulfilled':
      return _$opsPurchaseRowStateEnum_fulfilled;
    case 'failed':
      return _$opsPurchaseRowStateEnum_failed;
    case 'cancelled':
      return _$opsPurchaseRowStateEnum_cancelled;
    case 'reviewRequired':
      return _$opsPurchaseRowStateEnum_reviewRequired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseRowStateEnum> _$opsPurchaseRowStateEnumValues =
    BuiltSet<OpsPurchaseRowStateEnum>(const <OpsPurchaseRowStateEnum>[
  _$opsPurchaseRowStateEnum_awaitingPayment,
  _$opsPurchaseRowStateEnum_processing,
  _$opsPurchaseRowStateEnum_fulfilled,
  _$opsPurchaseRowStateEnum_failed,
  _$opsPurchaseRowStateEnum_cancelled,
  _$opsPurchaseRowStateEnum_reviewRequired,
]);

const OpsPurchaseRowCollectionStateEnum
    _$opsPurchaseRowCollectionStateEnum_pending =
    const OpsPurchaseRowCollectionStateEnum._('pending');
const OpsPurchaseRowCollectionStateEnum
    _$opsPurchaseRowCollectionStateEnum_successful =
    const OpsPurchaseRowCollectionStateEnum._('successful');
const OpsPurchaseRowCollectionStateEnum
    _$opsPurchaseRowCollectionStateEnum_failed =
    const OpsPurchaseRowCollectionStateEnum._('failed');
const OpsPurchaseRowCollectionStateEnum
    _$opsPurchaseRowCollectionStateEnum_unknown =
    const OpsPurchaseRowCollectionStateEnum._('unknown');

OpsPurchaseRowCollectionStateEnum _$opsPurchaseRowCollectionStateEnumValueOf(
    String name) {
  switch (name) {
    case 'pending':
      return _$opsPurchaseRowCollectionStateEnum_pending;
    case 'successful':
      return _$opsPurchaseRowCollectionStateEnum_successful;
    case 'failed':
      return _$opsPurchaseRowCollectionStateEnum_failed;
    case 'unknown':
      return _$opsPurchaseRowCollectionStateEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseRowCollectionStateEnum>
    _$opsPurchaseRowCollectionStateEnumValues = BuiltSet<
        OpsPurchaseRowCollectionStateEnum>(const <OpsPurchaseRowCollectionStateEnum>[
  _$opsPurchaseRowCollectionStateEnum_pending,
  _$opsPurchaseRowCollectionStateEnum_successful,
  _$opsPurchaseRowCollectionStateEnum_failed,
  _$opsPurchaseRowCollectionStateEnum_unknown,
]);

Serializer<OpsPurchaseRowPlanEnum> _$opsPurchaseRowPlanEnumSerializer =
    _$OpsPurchaseRowPlanEnumSerializer();
Serializer<OpsPurchaseRowStateEnum> _$opsPurchaseRowStateEnumSerializer =
    _$OpsPurchaseRowStateEnumSerializer();
Serializer<OpsPurchaseRowCollectionStateEnum>
    _$opsPurchaseRowCollectionStateEnumSerializer =
    _$OpsPurchaseRowCollectionStateEnumSerializer();

class _$OpsPurchaseRowPlanEnumSerializer
    implements PrimitiveSerializer<OpsPurchaseRowPlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'weekly': 'weekly',
    'biweekly': 'biweekly',
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'weekly': 'weekly',
    'biweekly': 'biweekly',
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[OpsPurchaseRowPlanEnum];
  @override
  final String wireName = 'OpsPurchaseRowPlanEnum';

  @override
  Object serialize(Serializers serializers, OpsPurchaseRowPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseRowPlanEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseRowPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseRowStateEnumSerializer
    implements PrimitiveSerializer<OpsPurchaseRowStateEnum> {
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
  final Iterable<Type> types = const <Type>[OpsPurchaseRowStateEnum];
  @override
  final String wireName = 'OpsPurchaseRowStateEnum';

  @override
  Object serialize(Serializers serializers, OpsPurchaseRowStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseRowStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseRowStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseRowCollectionStateEnumSerializer
    implements PrimitiveSerializer<OpsPurchaseRowCollectionStateEnum> {
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
  final Iterable<Type> types = const <Type>[OpsPurchaseRowCollectionStateEnum];
  @override
  final String wireName = 'OpsPurchaseRowCollectionStateEnum';

  @override
  Object serialize(
          Serializers serializers, OpsPurchaseRowCollectionStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseRowCollectionStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseRowCollectionStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseRow extends OpsPurchaseRow {
  @override
  final String id;
  @override
  final OpsPurchaseRowPlanEnum plan;
  @override
  final OpsPurchaseRowStateEnum state;
  @override
  final OpsPurchaseRowCollectionStateEnum collectionState;
  @override
  final Money price;
  @override
  final Money appliedCredit;
  @override
  final Money cashDue;
  @override
  final String? failureCode;
  @override
  final DateTime createdAt;
  @override
  final String riderId;
  @override
  final String? riderName;

  factory _$OpsPurchaseRow([void Function(OpsPurchaseRowBuilder)? updates]) =>
      (OpsPurchaseRowBuilder()..update(updates))._build();

  _$OpsPurchaseRow._(
      {required this.id,
      required this.plan,
      required this.state,
      required this.collectionState,
      required this.price,
      required this.appliedCredit,
      required this.cashDue,
      this.failureCode,
      required this.createdAt,
      required this.riderId,
      this.riderName})
      : super._();
  @override
  OpsPurchaseRow rebuild(void Function(OpsPurchaseRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseRowBuilder toBuilder() => OpsPurchaseRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchaseRow &&
        id == other.id &&
        plan == other.plan &&
        state == other.state &&
        collectionState == other.collectionState &&
        price == other.price &&
        appliedCredit == other.appliedCredit &&
        cashDue == other.cashDue &&
        failureCode == other.failureCode &&
        createdAt == other.createdAt &&
        riderId == other.riderId &&
        riderName == other.riderName;
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
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, riderId.hashCode);
    _$hash = $jc(_$hash, riderName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsPurchaseRow')
          ..add('id', id)
          ..add('plan', plan)
          ..add('state', state)
          ..add('collectionState', collectionState)
          ..add('price', price)
          ..add('appliedCredit', appliedCredit)
          ..add('cashDue', cashDue)
          ..add('failureCode', failureCode)
          ..add('createdAt', createdAt)
          ..add('riderId', riderId)
          ..add('riderName', riderName))
        .toString();
  }
}

class OpsPurchaseRowBuilder
    implements Builder<OpsPurchaseRow, OpsPurchaseRowBuilder> {
  _$OpsPurchaseRow? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OpsPurchaseRowPlanEnum? _plan;
  OpsPurchaseRowPlanEnum? get plan => _$this._plan;
  set plan(OpsPurchaseRowPlanEnum? plan) => _$this._plan = plan;

  OpsPurchaseRowStateEnum? _state;
  OpsPurchaseRowStateEnum? get state => _$this._state;
  set state(OpsPurchaseRowStateEnum? state) => _$this._state = state;

  OpsPurchaseRowCollectionStateEnum? _collectionState;
  OpsPurchaseRowCollectionStateEnum? get collectionState =>
      _$this._collectionState;
  set collectionState(OpsPurchaseRowCollectionStateEnum? collectionState) =>
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

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _riderId;
  String? get riderId => _$this._riderId;
  set riderId(String? riderId) => _$this._riderId = riderId;

  String? _riderName;
  String? get riderName => _$this._riderName;
  set riderName(String? riderName) => _$this._riderName = riderName;

  OpsPurchaseRowBuilder() {
    OpsPurchaseRow._defaults(this);
  }

  OpsPurchaseRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _plan = $v.plan;
      _state = $v.state;
      _collectionState = $v.collectionState;
      _price = $v.price.toBuilder();
      _appliedCredit = $v.appliedCredit.toBuilder();
      _cashDue = $v.cashDue.toBuilder();
      _failureCode = $v.failureCode;
      _createdAt = $v.createdAt;
      _riderId = $v.riderId;
      _riderName = $v.riderName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchaseRow other) {
    _$v = other as _$OpsPurchaseRow;
  }

  @override
  void update(void Function(OpsPurchaseRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchaseRow build() => _build();

  _$OpsPurchaseRow _build() {
    _$OpsPurchaseRow _$result;
    try {
      _$result = _$v ??
          _$OpsPurchaseRow._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OpsPurchaseRow', 'id'),
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'OpsPurchaseRow', 'plan'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'OpsPurchaseRow', 'state'),
            collectionState: BuiltValueNullFieldError.checkNotNull(
                collectionState, r'OpsPurchaseRow', 'collectionState'),
            price: price.build(),
            appliedCredit: appliedCredit.build(),
            cashDue: cashDue.build(),
            failureCode: failureCode,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OpsPurchaseRow', 'createdAt'),
            riderId: BuiltValueNullFieldError.checkNotNull(
                riderId, r'OpsPurchaseRow', 'riderId'),
            riderName: riderName,
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
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsPurchaseRow', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
