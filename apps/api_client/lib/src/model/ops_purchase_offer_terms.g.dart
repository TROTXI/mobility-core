// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_offer_terms.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OpsPurchaseOfferTerms extends OpsPurchaseOfferTerms {
  @override
  final Date coverageStart;
  @override
  final Date coverageEnd;
  @override
  final Money price;
  @override
  final BuiltList<SubscriptionOfferLeg> legs;

  factory _$OpsPurchaseOfferTerms(
          [void Function(OpsPurchaseOfferTermsBuilder)? updates]) =>
      (OpsPurchaseOfferTermsBuilder()..update(updates))._build();

  _$OpsPurchaseOfferTerms._(
      {required this.coverageStart,
      required this.coverageEnd,
      required this.price,
      required this.legs})
      : super._();
  @override
  OpsPurchaseOfferTerms rebuild(
          void Function(OpsPurchaseOfferTermsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseOfferTermsBuilder toBuilder() =>
      OpsPurchaseOfferTermsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchaseOfferTerms &&
        coverageStart == other.coverageStart &&
        coverageEnd == other.coverageEnd &&
        price == other.price &&
        legs == other.legs;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, coverageStart.hashCode);
    _$hash = $jc(_$hash, coverageEnd.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, legs.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OpsPurchaseOfferTerms')
          ..add('coverageStart', coverageStart)
          ..add('coverageEnd', coverageEnd)
          ..add('price', price)
          ..add('legs', legs))
        .toString();
  }
}

class OpsPurchaseOfferTermsBuilder
    implements Builder<OpsPurchaseOfferTerms, OpsPurchaseOfferTermsBuilder> {
  _$OpsPurchaseOfferTerms? _$v;

  Date? _coverageStart;
  Date? get coverageStart => _$this._coverageStart;
  set coverageStart(Date? coverageStart) =>
      _$this._coverageStart = coverageStart;

  Date? _coverageEnd;
  Date? get coverageEnd => _$this._coverageEnd;
  set coverageEnd(Date? coverageEnd) => _$this._coverageEnd = coverageEnd;

  MoneyBuilder? _price;
  MoneyBuilder get price => _$this._price ??= MoneyBuilder();
  set price(MoneyBuilder? price) => _$this._price = price;

  ListBuilder<SubscriptionOfferLeg>? _legs;
  ListBuilder<SubscriptionOfferLeg> get legs =>
      _$this._legs ??= ListBuilder<SubscriptionOfferLeg>();
  set legs(ListBuilder<SubscriptionOfferLeg>? legs) => _$this._legs = legs;

  OpsPurchaseOfferTermsBuilder() {
    OpsPurchaseOfferTerms._defaults(this);
  }

  OpsPurchaseOfferTermsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _coverageStart = $v.coverageStart;
      _coverageEnd = $v.coverageEnd;
      _price = $v.price.toBuilder();
      _legs = $v.legs.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchaseOfferTerms other) {
    _$v = other as _$OpsPurchaseOfferTerms;
  }

  @override
  void update(void Function(OpsPurchaseOfferTermsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchaseOfferTerms build() => _build();

  _$OpsPurchaseOfferTerms _build() {
    _$OpsPurchaseOfferTerms _$result;
    try {
      _$result = _$v ??
          _$OpsPurchaseOfferTerms._(
            coverageStart: BuiltValueNullFieldError.checkNotNull(
                coverageStart, r'OpsPurchaseOfferTerms', 'coverageStart'),
            coverageEnd: BuiltValueNullFieldError.checkNotNull(
                coverageEnd, r'OpsPurchaseOfferTerms', 'coverageEnd'),
            price: price.build(),
            legs: legs.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'price';
        price.build();
        _$failedField = 'legs';
        legs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OpsPurchaseOfferTerms', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
