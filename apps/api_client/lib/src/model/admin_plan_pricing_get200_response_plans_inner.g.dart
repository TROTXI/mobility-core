// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_plan_pricing_get200_response_plans_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminPlanPricingGet200ResponsePlansInnerPlanEnum
    _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_monthly =
    const AdminPlanPricingGet200ResponsePlansInnerPlanEnum._('monthly');
const AdminPlanPricingGet200ResponsePlansInnerPlanEnum
    _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_annual =
    const AdminPlanPricingGet200ResponsePlansInnerPlanEnum._('annual');

AdminPlanPricingGet200ResponsePlansInnerPlanEnum
    _$adminPlanPricingGet200ResponsePlansInnerPlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_monthly;
    case 'annual':
      return _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminPlanPricingGet200ResponsePlansInnerPlanEnum>
    _$adminPlanPricingGet200ResponsePlansInnerPlanEnumValues = BuiltSet<
        AdminPlanPricingGet200ResponsePlansInnerPlanEnum>(const <AdminPlanPricingGet200ResponsePlansInnerPlanEnum>[
  _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_monthly,
  _$adminPlanPricingGet200ResponsePlansInnerPlanEnum_annual,
]);

Serializer<AdminPlanPricingGet200ResponsePlansInnerPlanEnum>
    _$adminPlanPricingGet200ResponsePlansInnerPlanEnumSerializer =
    _$AdminPlanPricingGet200ResponsePlansInnerPlanEnumSerializer();

class _$AdminPlanPricingGet200ResponsePlansInnerPlanEnumSerializer
    implements
        PrimitiveSerializer<AdminPlanPricingGet200ResponsePlansInnerPlanEnum> {
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
    AdminPlanPricingGet200ResponsePlansInnerPlanEnum
  ];
  @override
  final String wireName = 'AdminPlanPricingGet200ResponsePlansInnerPlanEnum';

  @override
  Object serialize(Serializers serializers,
          AdminPlanPricingGet200ResponsePlansInnerPlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminPlanPricingGet200ResponsePlansInnerPlanEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminPlanPricingGet200ResponsePlansInnerPlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminPlanPricingGet200ResponsePlansInner
    extends AdminPlanPricingGet200ResponsePlansInner {
  @override
  final AdminPlanPricingGet200ResponsePlansInnerPlanEnum plan;
  @override
  final int ridesPerPeriod;
  @override
  final int priceMultiplierBp;
  @override
  final int takeRateBp;
  @override
  final int creditPesewasPerRide;

  factory _$AdminPlanPricingGet200ResponsePlansInner(
          [void Function(AdminPlanPricingGet200ResponsePlansInnerBuilder)?
              updates]) =>
      (AdminPlanPricingGet200ResponsePlansInnerBuilder()..update(updates))
          ._build();

  _$AdminPlanPricingGet200ResponsePlansInner._(
      {required this.plan,
      required this.ridesPerPeriod,
      required this.priceMultiplierBp,
      required this.takeRateBp,
      required this.creditPesewasPerRide})
      : super._();
  @override
  AdminPlanPricingGet200ResponsePlansInner rebuild(
          void Function(AdminPlanPricingGet200ResponsePlansInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminPlanPricingGet200ResponsePlansInnerBuilder toBuilder() =>
      AdminPlanPricingGet200ResponsePlansInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminPlanPricingGet200ResponsePlansInner &&
        plan == other.plan &&
        ridesPerPeriod == other.ridesPerPeriod &&
        priceMultiplierBp == other.priceMultiplierBp &&
        takeRateBp == other.takeRateBp &&
        creditPesewasPerRide == other.creditPesewasPerRide;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, ridesPerPeriod.hashCode);
    _$hash = $jc(_$hash, priceMultiplierBp.hashCode);
    _$hash = $jc(_$hash, takeRateBp.hashCode);
    _$hash = $jc(_$hash, creditPesewasPerRide.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminPlanPricingGet200ResponsePlansInner')
          ..add('plan', plan)
          ..add('ridesPerPeriod', ridesPerPeriod)
          ..add('priceMultiplierBp', priceMultiplierBp)
          ..add('takeRateBp', takeRateBp)
          ..add('creditPesewasPerRide', creditPesewasPerRide))
        .toString();
  }
}

class AdminPlanPricingGet200ResponsePlansInnerBuilder
    implements
        Builder<AdminPlanPricingGet200ResponsePlansInner,
            AdminPlanPricingGet200ResponsePlansInnerBuilder> {
  _$AdminPlanPricingGet200ResponsePlansInner? _$v;

  AdminPlanPricingGet200ResponsePlansInnerPlanEnum? _plan;
  AdminPlanPricingGet200ResponsePlansInnerPlanEnum? get plan => _$this._plan;
  set plan(AdminPlanPricingGet200ResponsePlansInnerPlanEnum? plan) =>
      _$this._plan = plan;

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

  int? _creditPesewasPerRide;
  int? get creditPesewasPerRide => _$this._creditPesewasPerRide;
  set creditPesewasPerRide(int? creditPesewasPerRide) =>
      _$this._creditPesewasPerRide = creditPesewasPerRide;

  AdminPlanPricingGet200ResponsePlansInnerBuilder() {
    AdminPlanPricingGet200ResponsePlansInner._defaults(this);
  }

  AdminPlanPricingGet200ResponsePlansInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _plan = $v.plan;
      _ridesPerPeriod = $v.ridesPerPeriod;
      _priceMultiplierBp = $v.priceMultiplierBp;
      _takeRateBp = $v.takeRateBp;
      _creditPesewasPerRide = $v.creditPesewasPerRide;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminPlanPricingGet200ResponsePlansInner other) {
    _$v = other as _$AdminPlanPricingGet200ResponsePlansInner;
  }

  @override
  void update(
      void Function(AdminPlanPricingGet200ResponsePlansInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminPlanPricingGet200ResponsePlansInner build() => _build();

  _$AdminPlanPricingGet200ResponsePlansInner _build() {
    final _$result = _$v ??
        _$AdminPlanPricingGet200ResponsePlansInner._(
          plan: BuiltValueNullFieldError.checkNotNull(
              plan, r'AdminPlanPricingGet200ResponsePlansInner', 'plan'),
          ridesPerPeriod: BuiltValueNullFieldError.checkNotNull(ridesPerPeriod,
              r'AdminPlanPricingGet200ResponsePlansInner', 'ridesPerPeriod'),
          priceMultiplierBp: BuiltValueNullFieldError.checkNotNull(
              priceMultiplierBp,
              r'AdminPlanPricingGet200ResponsePlansInner',
              'priceMultiplierBp'),
          takeRateBp: BuiltValueNullFieldError.checkNotNull(takeRateBp,
              r'AdminPlanPricingGet200ResponsePlansInner', 'takeRateBp'),
          creditPesewasPerRide: BuiltValueNullFieldError.checkNotNull(
              creditPesewasPerRide,
              r'AdminPlanPricingGet200ResponsePlansInner',
              'creditPesewasPerRide'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
