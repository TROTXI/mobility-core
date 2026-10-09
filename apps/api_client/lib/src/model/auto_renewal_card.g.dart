// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_renewal_card.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoRenewalCard extends AutoRenewalCard {
  @override
  final String brand;
  @override
  final String last4;
  @override
  final int expMonth;
  @override
  final int expYear;

  factory _$AutoRenewalCard([void Function(AutoRenewalCardBuilder)? updates]) =>
      (AutoRenewalCardBuilder()..update(updates))._build();

  _$AutoRenewalCard._(
      {required this.brand,
      required this.last4,
      required this.expMonth,
      required this.expYear})
      : super._();
  @override
  AutoRenewalCard rebuild(void Function(AutoRenewalCardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoRenewalCardBuilder toBuilder() => AutoRenewalCardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoRenewalCard &&
        brand == other.brand &&
        last4 == other.last4 &&
        expMonth == other.expMonth &&
        expYear == other.expYear;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, brand.hashCode);
    _$hash = $jc(_$hash, last4.hashCode);
    _$hash = $jc(_$hash, expMonth.hashCode);
    _$hash = $jc(_$hash, expYear.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoRenewalCard')
          ..add('brand', brand)
          ..add('last4', last4)
          ..add('expMonth', expMonth)
          ..add('expYear', expYear))
        .toString();
  }
}

class AutoRenewalCardBuilder
    implements Builder<AutoRenewalCard, AutoRenewalCardBuilder> {
  _$AutoRenewalCard? _$v;

  String? _brand;
  String? get brand => _$this._brand;
  set brand(String? brand) => _$this._brand = brand;

  String? _last4;
  String? get last4 => _$this._last4;
  set last4(String? last4) => _$this._last4 = last4;

  int? _expMonth;
  int? get expMonth => _$this._expMonth;
  set expMonth(int? expMonth) => _$this._expMonth = expMonth;

  int? _expYear;
  int? get expYear => _$this._expYear;
  set expYear(int? expYear) => _$this._expYear = expYear;

  AutoRenewalCardBuilder() {
    AutoRenewalCard._defaults(this);
  }

  AutoRenewalCardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _brand = $v.brand;
      _last4 = $v.last4;
      _expMonth = $v.expMonth;
      _expYear = $v.expYear;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoRenewalCard other) {
    _$v = other as _$AutoRenewalCard;
  }

  @override
  void update(void Function(AutoRenewalCardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoRenewalCard build() => _build();

  _$AutoRenewalCard _build() {
    final _$result = _$v ??
        _$AutoRenewalCard._(
          brand: BuiltValueNullFieldError.checkNotNull(
              brand, r'AutoRenewalCard', 'brand'),
          last4: BuiltValueNullFieldError.checkNotNull(
              last4, r'AutoRenewalCard', 'last4'),
          expMonth: BuiltValueNullFieldError.checkNotNull(
              expMonth, r'AutoRenewalCard', 'expMonth'),
          expYear: BuiltValueNullFieldError.checkNotNull(
              expYear, r'AutoRenewalCard', 'expYear'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
