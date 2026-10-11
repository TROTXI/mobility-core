// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_selection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PurchaseSelectionPlanEnum _$purchaseSelectionPlanEnum_weekly =
    const PurchaseSelectionPlanEnum._('weekly');
const PurchaseSelectionPlanEnum _$purchaseSelectionPlanEnum_biweekly =
    const PurchaseSelectionPlanEnum._('biweekly');
const PurchaseSelectionPlanEnum _$purchaseSelectionPlanEnum_monthly =
    const PurchaseSelectionPlanEnum._('monthly');
const PurchaseSelectionPlanEnum _$purchaseSelectionPlanEnum_annual =
    const PurchaseSelectionPlanEnum._('annual');

PurchaseSelectionPlanEnum _$purchaseSelectionPlanEnumValueOf(String name) {
  switch (name) {
    case 'weekly':
      return _$purchaseSelectionPlanEnum_weekly;
    case 'biweekly':
      return _$purchaseSelectionPlanEnum_biweekly;
    case 'monthly':
      return _$purchaseSelectionPlanEnum_monthly;
    case 'annual':
      return _$purchaseSelectionPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchaseSelectionPlanEnum> _$purchaseSelectionPlanEnumValues =
    BuiltSet<PurchaseSelectionPlanEnum>(const <PurchaseSelectionPlanEnum>[
  _$purchaseSelectionPlanEnum_weekly,
  _$purchaseSelectionPlanEnum_biweekly,
  _$purchaseSelectionPlanEnum_monthly,
  _$purchaseSelectionPlanEnum_annual,
]);

Serializer<PurchaseSelectionPlanEnum> _$purchaseSelectionPlanEnumSerializer =
    _$PurchaseSelectionPlanEnumSerializer();

class _$PurchaseSelectionPlanEnumSerializer
    implements PrimitiveSerializer<PurchaseSelectionPlanEnum> {
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
  final Iterable<Type> types = const <Type>[PurchaseSelectionPlanEnum];
  @override
  final String wireName = 'PurchaseSelectionPlanEnum';

  @override
  Object serialize(Serializers serializers, PurchaseSelectionPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchaseSelectionPlanEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchaseSelectionPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurchaseSelection extends PurchaseSelection {
  @override
  final PurchaseSelectionPlanEnum plan;
  @override
  final String routeId;
  @override
  final BuiltList<CommuteLeg> legs;
  @override
  final bool useCredit;

  factory _$PurchaseSelection(
          [void Function(PurchaseSelectionBuilder)? updates]) =>
      (PurchaseSelectionBuilder()..update(updates))._build();

  _$PurchaseSelection._(
      {required this.plan,
      required this.routeId,
      required this.legs,
      required this.useCredit})
      : super._();
  @override
  PurchaseSelection rebuild(void Function(PurchaseSelectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchaseSelectionBuilder toBuilder() =>
      PurchaseSelectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchaseSelection &&
        plan == other.plan &&
        routeId == other.routeId &&
        legs == other.legs &&
        useCredit == other.useCredit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, legs.hashCode);
    _$hash = $jc(_$hash, useCredit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PurchaseSelection')
          ..add('plan', plan)
          ..add('routeId', routeId)
          ..add('legs', legs)
          ..add('useCredit', useCredit))
        .toString();
  }
}

class PurchaseSelectionBuilder
    implements Builder<PurchaseSelection, PurchaseSelectionBuilder> {
  _$PurchaseSelection? _$v;

  PurchaseSelectionPlanEnum? _plan;
  PurchaseSelectionPlanEnum? get plan => _$this._plan;
  set plan(PurchaseSelectionPlanEnum? plan) => _$this._plan = plan;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  ListBuilder<CommuteLeg>? _legs;
  ListBuilder<CommuteLeg> get legs =>
      _$this._legs ??= ListBuilder<CommuteLeg>();
  set legs(ListBuilder<CommuteLeg>? legs) => _$this._legs = legs;

  bool? _useCredit;
  bool? get useCredit => _$this._useCredit;
  set useCredit(bool? useCredit) => _$this._useCredit = useCredit;

  PurchaseSelectionBuilder() {
    PurchaseSelection._defaults(this);
  }

  PurchaseSelectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plan = $v.plan;
      _routeId = $v.routeId;
      _legs = $v.legs.toBuilder();
      _useCredit = $v.useCredit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurchaseSelection other) {
    _$v = other as _$PurchaseSelection;
  }

  @override
  void update(void Function(PurchaseSelectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurchaseSelection build() => _build();

  _$PurchaseSelection _build() {
    _$PurchaseSelection _$result;
    try {
      _$result = _$v ??
          _$PurchaseSelection._(
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'PurchaseSelection', 'plan'),
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'PurchaseSelection', 'routeId'),
            legs: legs.build(),
            useCredit: BuiltValueNullFieldError.checkNotNull(
                useCredit, r'PurchaseSelection', 'useCredit'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'legs';
        legs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PurchaseSelection', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
