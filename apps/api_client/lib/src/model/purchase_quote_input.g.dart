// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_quote_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PurchaseQuoteInputPlanEnum _$purchaseQuoteInputPlanEnum_monthly =
    const PurchaseQuoteInputPlanEnum._('monthly');
const PurchaseQuoteInputPlanEnum _$purchaseQuoteInputPlanEnum_annual =
    const PurchaseQuoteInputPlanEnum._('annual');

PurchaseQuoteInputPlanEnum _$purchaseQuoteInputPlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$purchaseQuoteInputPlanEnum_monthly;
    case 'annual':
      return _$purchaseQuoteInputPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchaseQuoteInputPlanEnum> _$purchaseQuoteInputPlanEnumValues =
    BuiltSet<PurchaseQuoteInputPlanEnum>(const <PurchaseQuoteInputPlanEnum>[
  _$purchaseQuoteInputPlanEnum_monthly,
  _$purchaseQuoteInputPlanEnum_annual,
]);

Serializer<PurchaseQuoteInputPlanEnum> _$purchaseQuoteInputPlanEnumSerializer =
    _$PurchaseQuoteInputPlanEnumSerializer();

class _$PurchaseQuoteInputPlanEnumSerializer
    implements PrimitiveSerializer<PurchaseQuoteInputPlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[PurchaseQuoteInputPlanEnum];
  @override
  final String wireName = 'PurchaseQuoteInputPlanEnum';

  @override
  Object serialize(Serializers serializers, PurchaseQuoteInputPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchaseQuoteInputPlanEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchaseQuoteInputPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurchaseQuoteInput extends PurchaseQuoteInput {
  @override
  final PurchaseQuoteInputPlanEnum plan;
  @override
  final String routeId;
  @override
  final bool useCredit;

  factory _$PurchaseQuoteInput(
          [void Function(PurchaseQuoteInputBuilder)? updates]) =>
      (PurchaseQuoteInputBuilder()..update(updates))._build();

  _$PurchaseQuoteInput._(
      {required this.plan, required this.routeId, required this.useCredit})
      : super._();
  @override
  PurchaseQuoteInput rebuild(
          void Function(PurchaseQuoteInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchaseQuoteInputBuilder toBuilder() =>
      PurchaseQuoteInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchaseQuoteInput &&
        plan == other.plan &&
        routeId == other.routeId &&
        useCredit == other.useCredit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, useCredit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PurchaseQuoteInput')
          ..add('plan', plan)
          ..add('routeId', routeId)
          ..add('useCredit', useCredit))
        .toString();
  }
}

class PurchaseQuoteInputBuilder
    implements Builder<PurchaseQuoteInput, PurchaseQuoteInputBuilder> {
  _$PurchaseQuoteInput? _$v;

  PurchaseQuoteInputPlanEnum? _plan;
  PurchaseQuoteInputPlanEnum? get plan => _$this._plan;
  set plan(PurchaseQuoteInputPlanEnum? plan) => _$this._plan = plan;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  bool? _useCredit;
  bool? get useCredit => _$this._useCredit;
  set useCredit(bool? useCredit) => _$this._useCredit = useCredit;

  PurchaseQuoteInputBuilder() {
    PurchaseQuoteInput._defaults(this);
  }

  PurchaseQuoteInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plan = $v.plan;
      _routeId = $v.routeId;
      _useCredit = $v.useCredit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurchaseQuoteInput other) {
    _$v = other as _$PurchaseQuoteInput;
  }

  @override
  void update(void Function(PurchaseQuoteInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurchaseQuoteInput build() => _build();

  _$PurchaseQuoteInput _build() {
    final _$result = _$v ??
        _$PurchaseQuoteInput._(
          plan: BuiltValueNullFieldError.checkNotNull(
              plan, r'PurchaseQuoteInput', 'plan'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'PurchaseQuoteInput', 'routeId'),
          useCredit: BuiltValueNullFieldError.checkNotNull(
              useCredit, r'PurchaseQuoteInput', 'useCredit'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
