// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_auto_renewal_card.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsAutoRenewalCard extends OpsAutoRenewalCard {
  @override
  final String brand;
  @override
  final String last4;

  factory _$OpsAutoRenewalCard(
          [void Function(OpsAutoRenewalCardBuilder)? updates]) =>
      (OpsAutoRenewalCardBuilder()..update(updates))._build();

  _$OpsAutoRenewalCard._({required this.brand, required this.last4})
      : super._();
  @override
  OpsAutoRenewalCard rebuild(
          void Function(OpsAutoRenewalCardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsAutoRenewalCardBuilder toBuilder() =>
      OpsAutoRenewalCardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsAutoRenewalCard &&
        brand == other.brand &&
        last4 == other.last4;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, brand.hashCode);
    _$hash = $jc(_$hash, last4.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsAutoRenewalCard')
          ..add('brand', brand)
          ..add('last4', last4))
        .toString();
  }
}

class OpsAutoRenewalCardBuilder
    implements Builder<OpsAutoRenewalCard, OpsAutoRenewalCardBuilder> {
  _$OpsAutoRenewalCard? _$v;

  String? _brand;
  String? get brand => _$this._brand;
  set brand(String? brand) => _$this._brand = brand;

  String? _last4;
  String? get last4 => _$this._last4;
  set last4(String? last4) => _$this._last4 = last4;

  OpsAutoRenewalCardBuilder() {
    OpsAutoRenewalCard._defaults(this);
  }

  OpsAutoRenewalCardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _brand = $v.brand;
      _last4 = $v.last4;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsAutoRenewalCard other) {
    _$v = other as _$OpsAutoRenewalCard;
  }

  @override
  void update(void Function(OpsAutoRenewalCardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsAutoRenewalCard build() => _build();

  _$OpsAutoRenewalCard _build() {
    final _$result = _$v ??
        _$OpsAutoRenewalCard._(
          brand: BuiltValueNullFieldError.checkNotNull(
              brand, r'OpsAutoRenewalCard', 'brand'),
          last4: BuiltValueNullFieldError.checkNotNull(
              last4, r'OpsAutoRenewalCard', 'last4'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
