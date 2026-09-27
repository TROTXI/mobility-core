// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_rider_detail_purchases_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsRiderDetailPurchasesInnerPlanEnum
    _$opsRiderDetailPurchasesInnerPlanEnum_monthly =
    const OpsRiderDetailPurchasesInnerPlanEnum._('monthly');
const OpsRiderDetailPurchasesInnerPlanEnum
    _$opsRiderDetailPurchasesInnerPlanEnum_annual =
    const OpsRiderDetailPurchasesInnerPlanEnum._('annual');

OpsRiderDetailPurchasesInnerPlanEnum
    _$opsRiderDetailPurchasesInnerPlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$opsRiderDetailPurchasesInnerPlanEnum_monthly;
    case 'annual':
      return _$opsRiderDetailPurchasesInnerPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsRiderDetailPurchasesInnerPlanEnum>
    _$opsRiderDetailPurchasesInnerPlanEnumValues = BuiltSet<
        OpsRiderDetailPurchasesInnerPlanEnum>(const <OpsRiderDetailPurchasesInnerPlanEnum>[
  _$opsRiderDetailPurchasesInnerPlanEnum_monthly,
  _$opsRiderDetailPurchasesInnerPlanEnum_annual,
]);

Serializer<OpsRiderDetailPurchasesInnerPlanEnum>
    _$opsRiderDetailPurchasesInnerPlanEnumSerializer =
    _$OpsRiderDetailPurchasesInnerPlanEnumSerializer();

class _$OpsRiderDetailPurchasesInnerPlanEnumSerializer
    implements PrimitiveSerializer<OpsRiderDetailPurchasesInnerPlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OpsRiderDetailPurchasesInnerPlanEnum
  ];
  @override
  final String wireName = 'OpsRiderDetailPurchasesInnerPlanEnum';

  @override
  Object serialize(
          Serializers serializers, OpsRiderDetailPurchasesInnerPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsRiderDetailPurchasesInnerPlanEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsRiderDetailPurchasesInnerPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsRiderDetailPurchasesInner extends OpsRiderDetailPurchasesInner {
  @override
  final String id;
  @override
  final OpsRiderDetailPurchasesInnerPlanEnum plan;
  @override
  final String state;
  @override
  final Money cashDue;
  @override
  final DateTime createdAt;

  factory _$OpsRiderDetailPurchasesInner(
          [void Function(OpsRiderDetailPurchasesInnerBuilder)? updates]) =>
      (OpsRiderDetailPurchasesInnerBuilder()..update(updates))._build();

  _$OpsRiderDetailPurchasesInner._(
      {required this.id,
      required this.plan,
      required this.state,
      required this.cashDue,
      required this.createdAt})
      : super._();
  @override
  OpsRiderDetailPurchasesInner rebuild(
          void Function(OpsRiderDetailPurchasesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsRiderDetailPurchasesInnerBuilder toBuilder() =>
      OpsRiderDetailPurchasesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsRiderDetailPurchasesInner &&
        id == other.id &&
        plan == other.plan &&
        state == other.state &&
        cashDue == other.cashDue &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, cashDue.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsRiderDetailPurchasesInner')
          ..add('id', id)
          ..add('plan', plan)
          ..add('state', state)
          ..add('cashDue', cashDue)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class OpsRiderDetailPurchasesInnerBuilder
    implements
        Builder<OpsRiderDetailPurchasesInner,
            OpsRiderDetailPurchasesInnerBuilder> {
  _$OpsRiderDetailPurchasesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OpsRiderDetailPurchasesInnerPlanEnum? _plan;
  OpsRiderDetailPurchasesInnerPlanEnum? get plan => _$this._plan;
  set plan(OpsRiderDetailPurchasesInnerPlanEnum? plan) => _$this._plan = plan;

  String? _state;
  String? get state => _$this._state;
  set state(String? state) => _$this._state = state;

  MoneyBuilder? _cashDue;
  MoneyBuilder get cashDue => _$this._cashDue ??= MoneyBuilder();
  set cashDue(MoneyBuilder? cashDue) => _$this._cashDue = cashDue;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  OpsRiderDetailPurchasesInnerBuilder() {
    OpsRiderDetailPurchasesInner._defaults(this);
  }

  OpsRiderDetailPurchasesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _plan = $v.plan;
      _state = $v.state;
      _cashDue = $v.cashDue.toBuilder();
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsRiderDetailPurchasesInner other) {
    _$v = other as _$OpsRiderDetailPurchasesInner;
  }

  @override
  void update(void Function(OpsRiderDetailPurchasesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsRiderDetailPurchasesInner build() => _build();

  _$OpsRiderDetailPurchasesInner _build() {
    _$OpsRiderDetailPurchasesInner _$result;
    try {
      _$result = _$v ??
          _$OpsRiderDetailPurchasesInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'OpsRiderDetailPurchasesInner', 'id'),
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'OpsRiderDetailPurchasesInner', 'plan'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'OpsRiderDetailPurchasesInner', 'state'),
            cashDue: cashDue.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'OpsRiderDetailPurchasesInner', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cashDue';
        cashDue.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsRiderDetailPurchasesInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
