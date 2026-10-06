// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_edit.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PricingEdit extends PricingEdit {
  @override
  final int? ridesPerPeriod;
  @override
  final int? priceMultiplierBp;
  @override
  final int? takeRateBp;
  @override
  final Money? creditPerRide;
  @override
  final String reason;

  factory _$PricingEdit([void Function(PricingEditBuilder)? updates]) =>
      (PricingEditBuilder()..update(updates))._build();

  _$PricingEdit._(
      {this.ridesPerPeriod,
      this.priceMultiplierBp,
      this.takeRateBp,
      this.creditPerRide,
      required this.reason})
      : super._();
  @override
  PricingEdit rebuild(void Function(PricingEditBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PricingEditBuilder toBuilder() => PricingEditBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PricingEdit &&
        ridesPerPeriod == other.ridesPerPeriod &&
        priceMultiplierBp == other.priceMultiplierBp &&
        takeRateBp == other.takeRateBp &&
        creditPerRide == other.creditPerRide &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ridesPerPeriod.hashCode);
    _$hash = $jc(_$hash, priceMultiplierBp.hashCode);
    _$hash = $jc(_$hash, takeRateBp.hashCode);
    _$hash = $jc(_$hash, creditPerRide.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PricingEdit')
          ..add('ridesPerPeriod', ridesPerPeriod)
          ..add('priceMultiplierBp', priceMultiplierBp)
          ..add('takeRateBp', takeRateBp)
          ..add('creditPerRide', creditPerRide)
          ..add('reason', reason))
        .toString();
  }
}

class PricingEditBuilder implements Builder<PricingEdit, PricingEditBuilder> {
  _$PricingEdit? _$v;

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

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PricingEditBuilder() {
    PricingEdit._defaults(this);
  }

  PricingEditBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ridesPerPeriod = $v.ridesPerPeriod;
      _priceMultiplierBp = $v.priceMultiplierBp;
      _takeRateBp = $v.takeRateBp;
      _creditPerRide = $v.creditPerRide?.toBuilder();
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PricingEdit other) {
    _$v = other as _$PricingEdit;
  }

  @override
  void update(void Function(PricingEditBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PricingEdit build() => _build();

  _$PricingEdit _build() {
    _$PricingEdit _$result;
    try {
      _$result = _$v ??
          _$PricingEdit._(
            ridesPerPeriod: ridesPerPeriod,
            priceMultiplierBp: priceMultiplierBp,
            takeRateBp: takeRateBp,
            creditPerRide: _creditPerRide?.build(),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'PricingEdit', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'creditPerRide';
        _creditPerRide?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PricingEdit', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
