// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_quote.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PurchaseQuotePlanEnum _$purchaseQuotePlanEnum_monthly =
    const PurchaseQuotePlanEnum._('monthly');
const PurchaseQuotePlanEnum _$purchaseQuotePlanEnum_annual =
    const PurchaseQuotePlanEnum._('annual');

PurchaseQuotePlanEnum _$purchaseQuotePlanEnumValueOf(String name) {
  switch (name) {
    case 'monthly':
      return _$purchaseQuotePlanEnum_monthly;
    case 'annual':
      return _$purchaseQuotePlanEnum_annual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchaseQuotePlanEnum> _$purchaseQuotePlanEnumValues =
    BuiltSet<PurchaseQuotePlanEnum>(const <PurchaseQuotePlanEnum>[
  _$purchaseQuotePlanEnum_monthly,
  _$purchaseQuotePlanEnum_annual,
]);

const PurchaseQuoteRenewalModeEnum _$purchaseQuoteRenewalModeEnum_manual =
    const PurchaseQuoteRenewalModeEnum._('manual');

PurchaseQuoteRenewalModeEnum _$purchaseQuoteRenewalModeEnumValueOf(
    String name) {
  switch (name) {
    case 'manual':
      return _$purchaseQuoteRenewalModeEnum_manual;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PurchaseQuoteRenewalModeEnum>
    _$purchaseQuoteRenewalModeEnumValues =
    BuiltSet<PurchaseQuoteRenewalModeEnum>(const <PurchaseQuoteRenewalModeEnum>[
  _$purchaseQuoteRenewalModeEnum_manual,
]);

Serializer<PurchaseQuotePlanEnum> _$purchaseQuotePlanEnumSerializer =
    _$PurchaseQuotePlanEnumSerializer();
Serializer<PurchaseQuoteRenewalModeEnum>
    _$purchaseQuoteRenewalModeEnumSerializer =
    _$PurchaseQuoteRenewalModeEnumSerializer();

class _$PurchaseQuotePlanEnumSerializer
    implements PrimitiveSerializer<PurchaseQuotePlanEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthly': 'monthly',
    'annual': 'annual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'monthly': 'monthly',
    'annual': 'annual',
  };

  @override
  final Iterable<Type> types = const <Type>[PurchaseQuotePlanEnum];
  @override
  final String wireName = 'PurchaseQuotePlanEnum';

  @override
  Object serialize(Serializers serializers, PurchaseQuotePlanEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchaseQuotePlanEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchaseQuotePlanEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurchaseQuoteRenewalModeEnumSerializer
    implements PrimitiveSerializer<PurchaseQuoteRenewalModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'manual': 'manual',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'manual': 'manual',
  };

  @override
  final Iterable<Type> types = const <Type>[PurchaseQuoteRenewalModeEnum];
  @override
  final String wireName = 'PurchaseQuoteRenewalModeEnum';

  @override
  Object serialize(Serializers serializers, PurchaseQuoteRenewalModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PurchaseQuoteRenewalModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PurchaseQuoteRenewalModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PurchaseQuote extends PurchaseQuote {
  @override
  final String routeId;
  @override
  final PurchaseQuotePlanEnum plan;
  @override
  final int ridesGranted;
  @override
  final Money fare;
  @override
  final Money price;
  @override
  final Money availableCredit;
  @override
  final Money appliedCredit;
  @override
  final Money cashDue;
  @override
  final Money minimumCashDue;
  @override
  final PurchaseQuoteRenewalModeEnum renewalMode;
  @override
  final bool binding;
  @override
  final DateTime quotedAt;

  factory _$PurchaseQuote([void Function(PurchaseQuoteBuilder)? updates]) =>
      (PurchaseQuoteBuilder()..update(updates))._build();

  _$PurchaseQuote._(
      {required this.routeId,
      required this.plan,
      required this.ridesGranted,
      required this.fare,
      required this.price,
      required this.availableCredit,
      required this.appliedCredit,
      required this.cashDue,
      required this.minimumCashDue,
      required this.renewalMode,
      required this.binding,
      required this.quotedAt})
      : super._();
  @override
  PurchaseQuote rebuild(void Function(PurchaseQuoteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PurchaseQuoteBuilder toBuilder() => PurchaseQuoteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PurchaseQuote &&
        routeId == other.routeId &&
        plan == other.plan &&
        ridesGranted == other.ridesGranted &&
        fare == other.fare &&
        price == other.price &&
        availableCredit == other.availableCredit &&
        appliedCredit == other.appliedCredit &&
        cashDue == other.cashDue &&
        minimumCashDue == other.minimumCashDue &&
        renewalMode == other.renewalMode &&
        binding == other.binding &&
        quotedAt == other.quotedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, ridesGranted.hashCode);
    _$hash = $jc(_$hash, fare.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, availableCredit.hashCode);
    _$hash = $jc(_$hash, appliedCredit.hashCode);
    _$hash = $jc(_$hash, cashDue.hashCode);
    _$hash = $jc(_$hash, minimumCashDue.hashCode);
    _$hash = $jc(_$hash, renewalMode.hashCode);
    _$hash = $jc(_$hash, binding.hashCode);
    _$hash = $jc(_$hash, quotedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PurchaseQuote')
          ..add('routeId', routeId)
          ..add('plan', plan)
          ..add('ridesGranted', ridesGranted)
          ..add('fare', fare)
          ..add('price', price)
          ..add('availableCredit', availableCredit)
          ..add('appliedCredit', appliedCredit)
          ..add('cashDue', cashDue)
          ..add('minimumCashDue', minimumCashDue)
          ..add('renewalMode', renewalMode)
          ..add('binding', binding)
          ..add('quotedAt', quotedAt))
        .toString();
  }
}

class PurchaseQuoteBuilder
    implements Builder<PurchaseQuote, PurchaseQuoteBuilder> {
  _$PurchaseQuote? _$v;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  PurchaseQuotePlanEnum? _plan;
  PurchaseQuotePlanEnum? get plan => _$this._plan;
  set plan(PurchaseQuotePlanEnum? plan) => _$this._plan = plan;

  int? _ridesGranted;
  int? get ridesGranted => _$this._ridesGranted;
  set ridesGranted(int? ridesGranted) => _$this._ridesGranted = ridesGranted;

  MoneyBuilder? _fare;
  MoneyBuilder get fare => _$this._fare ??= MoneyBuilder();
  set fare(MoneyBuilder? fare) => _$this._fare = fare;

  MoneyBuilder? _price;
  MoneyBuilder get price => _$this._price ??= MoneyBuilder();
  set price(MoneyBuilder? price) => _$this._price = price;

  MoneyBuilder? _availableCredit;
  MoneyBuilder get availableCredit =>
      _$this._availableCredit ??= MoneyBuilder();
  set availableCredit(MoneyBuilder? availableCredit) =>
      _$this._availableCredit = availableCredit;

  MoneyBuilder? _appliedCredit;
  MoneyBuilder get appliedCredit => _$this._appliedCredit ??= MoneyBuilder();
  set appliedCredit(MoneyBuilder? appliedCredit) =>
      _$this._appliedCredit = appliedCredit;

  MoneyBuilder? _cashDue;
  MoneyBuilder get cashDue => _$this._cashDue ??= MoneyBuilder();
  set cashDue(MoneyBuilder? cashDue) => _$this._cashDue = cashDue;

  MoneyBuilder? _minimumCashDue;
  MoneyBuilder get minimumCashDue => _$this._minimumCashDue ??= MoneyBuilder();
  set minimumCashDue(MoneyBuilder? minimumCashDue) =>
      _$this._minimumCashDue = minimumCashDue;

  PurchaseQuoteRenewalModeEnum? _renewalMode;
  PurchaseQuoteRenewalModeEnum? get renewalMode => _$this._renewalMode;
  set renewalMode(PurchaseQuoteRenewalModeEnum? renewalMode) =>
      _$this._renewalMode = renewalMode;

  bool? _binding;
  bool? get binding => _$this._binding;
  set binding(bool? binding) => _$this._binding = binding;

  DateTime? _quotedAt;
  DateTime? get quotedAt => _$this._quotedAt;
  set quotedAt(DateTime? quotedAt) => _$this._quotedAt = quotedAt;

  PurchaseQuoteBuilder() {
    PurchaseQuote._defaults(this);
  }

  PurchaseQuoteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeId = $v.routeId;
      _plan = $v.plan;
      _ridesGranted = $v.ridesGranted;
      _fare = $v.fare.toBuilder();
      _price = $v.price.toBuilder();
      _availableCredit = $v.availableCredit.toBuilder();
      _appliedCredit = $v.appliedCredit.toBuilder();
      _cashDue = $v.cashDue.toBuilder();
      _minimumCashDue = $v.minimumCashDue.toBuilder();
      _renewalMode = $v.renewalMode;
      _binding = $v.binding;
      _quotedAt = $v.quotedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PurchaseQuote other) {
    _$v = other as _$PurchaseQuote;
  }

  @override
  void update(void Function(PurchaseQuoteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PurchaseQuote build() => _build();

  _$PurchaseQuote _build() {
    _$PurchaseQuote _$result;
    try {
      _$result = _$v ??
          _$PurchaseQuote._(
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'PurchaseQuote', 'routeId'),
            plan: BuiltValueNullFieldError.checkNotNull(
                plan, r'PurchaseQuote', 'plan'),
            ridesGranted: BuiltValueNullFieldError.checkNotNull(
                ridesGranted, r'PurchaseQuote', 'ridesGranted'),
            fare: fare.build(),
            price: price.build(),
            availableCredit: availableCredit.build(),
            appliedCredit: appliedCredit.build(),
            cashDue: cashDue.build(),
            minimumCashDue: minimumCashDue.build(),
            renewalMode: BuiltValueNullFieldError.checkNotNull(
                renewalMode, r'PurchaseQuote', 'renewalMode'),
            binding: BuiltValueNullFieldError.checkNotNull(
                binding, r'PurchaseQuote', 'binding'),
            quotedAt: BuiltValueNullFieldError.checkNotNull(
                quotedAt, r'PurchaseQuote', 'quotedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fare';
        fare.build();
        _$failedField = 'price';
        price.build();
        _$failedField = 'availableCredit';
        availableCredit.build();
        _$failedField = 'appliedCredit';
        appliedCredit.build();
        _$failedField = 'cashDue';
        cashDue.build();
        _$failedField = 'minimumCashDue';
        minimumCashDue.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PurchaseQuote', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
