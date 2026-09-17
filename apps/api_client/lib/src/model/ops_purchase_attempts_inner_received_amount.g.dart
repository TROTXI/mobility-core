// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ops_purchase_attempts_inner_received_amount.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum
    _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnum_GHS =
    const OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum._('GHS');

OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum
    _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumValueOf(String name) {
  switch (name) {
    case 'GHS':
      return _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnum_GHS;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum>
    _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumValues = BuiltSet<
        OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum>(const <OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum>[
  _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnum_GHS,
]);

Serializer<OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum>
    _$opsPurchaseAttemptsInnerReceivedAmountCurrencyEnumSerializer =
    _$OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnumSerializer();

class _$OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnumSerializer
    implements
        PrimitiveSerializer<
            OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'GHS': 'GHS',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'GHS': 'GHS',
  };

  @override
  final Iterable<Type> types = const <Type>[
    OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum
  ];
  @override
  final String wireName = 'OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum';

  @override
  Object serialize(Serializers serializers,
          OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OpsPurchaseAttemptsInnerReceivedAmount
    extends OpsPurchaseAttemptsInnerReceivedAmount {
  @override
  final int amountMinor;
  @override
  final OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum currency;

  factory _$OpsPurchaseAttemptsInnerReceivedAmount(
          [void Function(OpsPurchaseAttemptsInnerReceivedAmountBuilder)?
              updates]) =>
      (OpsPurchaseAttemptsInnerReceivedAmountBuilder()..update(updates))
          ._build();

  _$OpsPurchaseAttemptsInnerReceivedAmount._(
      {required this.amountMinor, required this.currency})
      : super._();
  @override
  OpsPurchaseAttemptsInnerReceivedAmount rebuild(
          void Function(OpsPurchaseAttemptsInnerReceivedAmountBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OpsPurchaseAttemptsInnerReceivedAmountBuilder toBuilder() =>
      OpsPurchaseAttemptsInnerReceivedAmountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OpsPurchaseAttemptsInnerReceivedAmount &&
        amountMinor == other.amountMinor &&
        currency == other.currency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amountMinor.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'OpsPurchaseAttemptsInnerReceivedAmount')
          ..add('amountMinor', amountMinor)
          ..add('currency', currency))
        .toString();
  }
}

class OpsPurchaseAttemptsInnerReceivedAmountBuilder
    implements
        Builder<OpsPurchaseAttemptsInnerReceivedAmount,
            OpsPurchaseAttemptsInnerReceivedAmountBuilder> {
  _$OpsPurchaseAttemptsInnerReceivedAmount? _$v;

  int? _amountMinor;
  int? get amountMinor => _$this._amountMinor;
  set amountMinor(int? amountMinor) => _$this._amountMinor = amountMinor;

  OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum? _currency;
  OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum? get currency =>
      _$this._currency;
  set currency(OpsPurchaseAttemptsInnerReceivedAmountCurrencyEnum? currency) =>
      _$this._currency = currency;

  OpsPurchaseAttemptsInnerReceivedAmountBuilder() {
    OpsPurchaseAttemptsInnerReceivedAmount._defaults(this);
  }

  OpsPurchaseAttemptsInnerReceivedAmountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amountMinor = $v.amountMinor;
      _currency = $v.currency;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OpsPurchaseAttemptsInnerReceivedAmount other) {
    _$v = other as _$OpsPurchaseAttemptsInnerReceivedAmount;
  }

  @override
  void update(
      void Function(OpsPurchaseAttemptsInnerReceivedAmountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OpsPurchaseAttemptsInnerReceivedAmount build() => _build();

  _$OpsPurchaseAttemptsInnerReceivedAmount _build() {
    final _$result = _$v ??
        _$OpsPurchaseAttemptsInnerReceivedAmount._(
          amountMinor: BuiltValueNullFieldError.checkNotNull(amountMinor,
              r'OpsPurchaseAttemptsInnerReceivedAmount', 'amountMinor'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'OpsPurchaseAttemptsInnerReceivedAmount', 'currency'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
