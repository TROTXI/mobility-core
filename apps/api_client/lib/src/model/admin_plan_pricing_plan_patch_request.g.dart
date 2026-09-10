// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_plan_pricing_plan_patch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminPlanPricingPlanPatchRequest
    extends AdminPlanPricingPlanPatchRequest {
  @override
  final int? ridesPerPeriod;
  @override
  final int? priceMultiplierBp;
  @override
  final int? takeRateBp;
  @override
  final int? creditPesewasPerRide;

  factory _$AdminPlanPricingPlanPatchRequest(
          [void Function(AdminPlanPricingPlanPatchRequestBuilder)? updates]) =>
      (AdminPlanPricingPlanPatchRequestBuilder()..update(updates))._build();

  _$AdminPlanPricingPlanPatchRequest._(
      {this.ridesPerPeriod,
      this.priceMultiplierBp,
      this.takeRateBp,
      this.creditPesewasPerRide})
      : super._();
  @override
  AdminPlanPricingPlanPatchRequest rebuild(
          void Function(AdminPlanPricingPlanPatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminPlanPricingPlanPatchRequestBuilder toBuilder() =>
      AdminPlanPricingPlanPatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminPlanPricingPlanPatchRequest &&
        ridesPerPeriod == other.ridesPerPeriod &&
        priceMultiplierBp == other.priceMultiplierBp &&
        takeRateBp == other.takeRateBp &&
        creditPesewasPerRide == other.creditPesewasPerRide;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ridesPerPeriod.hashCode);
    _$hash = $jc(_$hash, priceMultiplierBp.hashCode);
    _$hash = $jc(_$hash, takeRateBp.hashCode);
    _$hash = $jc(_$hash, creditPesewasPerRide.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminPlanPricingPlanPatchRequest')
          ..add('ridesPerPeriod', ridesPerPeriod)
          ..add('priceMultiplierBp', priceMultiplierBp)
          ..add('takeRateBp', takeRateBp)
          ..add('creditPesewasPerRide', creditPesewasPerRide))
        .toString();
  }
}

class AdminPlanPricingPlanPatchRequestBuilder
    implements
        Builder<AdminPlanPricingPlanPatchRequest,
            AdminPlanPricingPlanPatchRequestBuilder> {
  _$AdminPlanPricingPlanPatchRequest? _$v;

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

  AdminPlanPricingPlanPatchRequestBuilder() {
    AdminPlanPricingPlanPatchRequest._defaults(this);
  }

  AdminPlanPricingPlanPatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ridesPerPeriod = $v.ridesPerPeriod;
      _priceMultiplierBp = $v.priceMultiplierBp;
      _takeRateBp = $v.takeRateBp;
      _creditPesewasPerRide = $v.creditPesewasPerRide;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminPlanPricingPlanPatchRequest other) {
    _$v = other as _$AdminPlanPricingPlanPatchRequest;
  }

  @override
  void update(void Function(AdminPlanPricingPlanPatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminPlanPricingPlanPatchRequest build() => _build();

  _$AdminPlanPricingPlanPatchRequest _build() {
    final _$result = _$v ??
        _$AdminPlanPricingPlanPatchRequest._(
          ridesPerPeriod: ridesPerPeriod,
          priceMultiplierBp: priceMultiplierBp,
          takeRateBp: takeRateBp,
          creditPesewasPerRide: creditPesewasPerRide,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
