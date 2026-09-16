// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_pricing.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PlanPricingPlanEnum _$planPricingPlanEnum_monthly =
    const PlanPricingPlanEnum._('monthly');
const PlanPricingPlanEnum _$planPricingPlanEnum_annual =
    const PlanPricingPlanEnum._('annual');

PlanPricingPlanEnum _$planPricingPlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$planPricingPlanEnum_monthly;
    case 'annual':
      return _$planPricingPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PlanPricingPlanEnum> _$planPricingPlanEnumValues =
    BuiltSet<PlanPricingPlanEnum>(const <PlanPricingPlanEnum>[
  _$planPricingPlanEnum_monthly,
  _$planPricingPlanEnum_annual,
]);

Serializer<PlanPricingPlanEnum> _$planPricingPlanEnumSerializer =
    _$PlanPricingPlanEnumSerializer();

class _$PlanPricingPlanEnumSerializer
    implements PrimitiveSerializer<PlanPricingPlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[PlanPricingPlanEnum];
  @override
  final String wireName = 'PlanPricingPlanEnum';

  @override
  Object serialize(Serializers serializers, PlanPricingPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PlanPricingPlanEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PlanPricingPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PlanPricing extends PlanPricing {
  @override
  final PlanPricingPlanEnum plan;
  @override
  final int ridesPerPeriod;
  @override
  final int priceMultiplierBp;
  @override
  final int takeRateBp;
  @override
  final Money creditPerRide;
  @override
  final int version;

  factory _$PlanPricing([void Function(PlanPricingBuilder)? updates]) =>
      (PlanPricingBuilder()..update(updates))._build();

  _$PlanPricing._(
      {required this.plan,
      required this.ridesPerPeriod,
      required this.priceMultiplierBp,
      required this.takeRateBp,
      required this.creditPerRide,
      required this.version})
      : super._();
  @override
  PlanPricing rebuild(void Function(PlanPricingBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlanPricingBuilder toBuilder() => PlanPricingBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlanPricing &&
        plan == other.plan &&
        ridesPerPeriod == other.ridesPerPeriod &&
        priceMultiplierBp == other.priceMultiplierBp &&
        takeRateBp == other.takeRateBp &&
        creditPerRide == other.creditPerRide &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, ridesPerPeriod.hashCode);
    _$hash = $jc(_$hash, priceMultiplierBp.hashCode);
    _$hash = $jc(_$hash, takeRateBp.hashCode);
    _$hash = $jc(_$hash, creditPerRide.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlanPricing')
          ..add('plan', plan)
          ..add('ridesPerPeriod', ridesPerPeriod)
          ..add('priceMultiplierBp', priceMultiplierBp)
          ..add('takeRateBp', takeRateBp)
          ..add('creditPerRide', creditPerRide)
          ..add('version', version))
        .toString();
  }
}

class PlanPricingBuilder implements Builder<PlanPricing, PlanPricingBuilder> {
  _$PlanPricing? _$v;

  PlanPricingPlanEnum? _plan;
  PlanPricingPlanEnum? get plan => _$this._plan;
  set plan(PlanPricingPlanEnum? plan) => _$this._plan = plan;

  int? _ridesPerPeriod;
  int? get ridesPerPeriod => _$this._ridesPerPeriod;
  set ridesPerPeriod(int? ridesPerPeriod) =>
      _$this._ridesPerPeriod = ridesPerPeriod;

  int? _priceMultiplierBp;
  int? get priceMultiplierBp => _$this._priceMultiplierBp;
  set priceMultiplierBp(int? priceMultiplierBp) =>
      _$this._priceMultiplierBp = priceMultiplierBp;

  int? _takeRateBp;
  int? get takeRateBp => _$this._takeRateBp;
  set takeRateBp(int? takeRateBp) => _$this._takeRateBp = takeRateBp;

  MoneyBuilder? _creditPerRide;
  MoneyBuilder get creditPerRide => _$this._creditPerRide ??= MoneyBuilder();
  set creditPerRide(MoneyBuilder? creditPerRide) =>
      _$this._creditPerRide = creditPerRide;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PlanPricingBuilder() {
    PlanPricing._defaults(this);
  }

  PlanPricingBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plan = $v.plan;
      _ridesPerPeriod = $v.ridesPerPeriod;
      _priceMultiplierBp = $v.priceMultiplierBp;
      _takeRateBp = $v.takeRateBp;
      _creditPerRide = $v.creditPerRide.toBuilder();
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlanPricing other) {
    _$v = other as _$PlanPricing;
  }

  @override
  void update(void Function(PlanPricingBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlanPricing build() => _build();

  _$PlanPricing _build() {
    _$PlanPricing _$result;
    try {
      _$result = _$v ??
          _$PlanPricing._(
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'PlanPricing', 'plan'),
            ridesPerPeriod: BuiltValueNullFieldError.checkNotNull(
                ridesPerPeriod, r'PlanPricing', 'ridesPerPeriod'),
            priceMultiplierBp: BuiltValueNullFieldError.checkNotNull(
                priceMultiplierBp, r'PlanPricing', 'priceMultiplierBp'),
            takeRateBp: BuiltValueNullFieldError.checkNotNull(
                takeRateBp, r'PlanPricing', 'takeRateBp'),
            creditPerRide: creditPerRide.build(),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'PlanPricing', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'creditPerRide';
        creditPerRide.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlanPricing', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
