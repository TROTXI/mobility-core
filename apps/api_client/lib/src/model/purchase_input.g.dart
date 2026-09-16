// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PurchaseInputPlanEnum _$purchaseInputPlanEnum_monthly =
    const PurchaseInputPlanEnum._('monthly');
const PurchaseInputPlanEnum _$purchaseInputPlanEnum_annual =
    const PurchaseInputPlanEnum._('annual');

PurchaseInputPlanEnum _$purchaseInputPlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$purchaseInputPlanEnum_monthly;
    case 'annual':
      return _$purchaseInputPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchaseInputPlanEnum> _$purchaseInputPlanEnumValues =
    BuiltSet<PurchaseInputPlanEnum>(const <PurchaseInputPlanEnum>[
  _$purchaseInputPlanEnum_monthly,
  _$purchaseInputPlanEnum_annual,
]);

Serializer<PurchaseInputPlanEnum> _$purchaseInputPlanEnumSerializer =
    _$PurchaseInputPlanEnumSerializer();

class _$PurchaseInputPlanEnumSerializer
    implements PrimitiveSerializer<PurchaseInputPlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[PurchaseInputPlanEnum];
  @override
  final String wireName = 'PurchaseInputPlanEnum';

  @override
  Object serialize(Serializers serializers, PurchaseInputPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchaseInputPlanEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchaseInputPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurchaseInput extends PurchaseInput {
  @override
  final PurchaseInputPlanEnum plan;
  @override
  final String routeId;
  @override
  final BuiltList<CommuteLeg> legs;
  @override
  final bool useCredit;

  factory _$PurchaseInput([void Function(PurchaseInputBuilder)? updates]) =>
      (PurchaseInputBuilder()..update(updates))._build();

  _$PurchaseInput._(
      {required this.plan,
      required this.routeId,
      required this.legs,
      required this.useCredit})
      : super._();
  @override
  PurchaseInput rebuild(void Function(PurchaseInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchaseInputBuilder toBuilder() => PurchaseInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchaseInput &&
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
    return (newBuiltValueToStringHelper(r'PurchaseInput')
          ..add('plan', plan)
          ..add('routeId', routeId)
          ..add('legs', legs)
          ..add('useCredit', useCredit))
        .toString();
  }
}

class PurchaseInputBuilder
    implements Builder<PurchaseInput, PurchaseInputBuilder> {
  _$PurchaseInput? _$v;

  PurchaseInputPlanEnum? _plan;
  PurchaseInputPlanEnum? get plan => _$this._plan;
  set plan(PurchaseInputPlanEnum? plan) => _$this._plan = plan;

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

  PurchaseInputBuilder() {
    PurchaseInput._defaults(this);
  }

  PurchaseInputBuilder get _$this {
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
  void replace(PurchaseInput other) {
    _$v = other as _$PurchaseInput;
  }

  @override
  void update(void Function(PurchaseInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurchaseInput build() => _build();

  _$PurchaseInput _build() {
    _$PurchaseInput _$result;
    try {
      _$result = _$v ??
          _$PurchaseInput._(
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'PurchaseInput', 'plan'),
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'PurchaseInput', 'routeId'),
            legs: legs.build(),
            useCredit: BuiltValueNullFieldError.checkNotNull(
                useCredit, r'PurchaseInput', 'useCredit'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'legs';
        legs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PurchaseInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
