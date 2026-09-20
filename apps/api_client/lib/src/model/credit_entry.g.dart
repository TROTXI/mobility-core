// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreditEntryCurrencyEnum _$creditEntryCurrencyEnum_GHS =
    const CreditEntryCurrencyEnum._('GHS');

CreditEntryCurrencyEnum _$creditEntryCurrencyEnumValueOf(String name) {
  switch (name) {
    case 'GHS':
      return _$creditEntryCurrencyEnum_GHS;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreditEntryCurrencyEnum> _$creditEntryCurrencyEnumValues =
    BuiltSet<CreditEntryCurrencyEnum>(const <CreditEntryCurrencyEnum>[
  _$creditEntryCurrencyEnum_GHS,
]);

const CreditEntryReasonEnum _$creditEntryReasonEnum_monthEndConversion =
    const CreditEntryReasonEnum._('monthEndConversion');
const CreditEntryReasonEnum _$creditEntryReasonEnum_purchaseApplied =
    const CreditEntryReasonEnum._('purchaseApplied');
const CreditEntryReasonEnum _$creditEntryReasonEnum_refundRestored =
    const CreditEntryReasonEnum._('refundRestored');
const CreditEntryReasonEnum _$creditEntryReasonEnum_conversionReversed =
    const CreditEntryReasonEnum._('conversionReversed');
const CreditEntryReasonEnum _$creditEntryReasonEnum_adjustment =
    const CreditEntryReasonEnum._('adjustment');

CreditEntryReasonEnum _$creditEntryReasonEnumValueOf(String name) {
  switch (name) {
    case 'monthEndConversion':
      return _$creditEntryReasonEnum_monthEndConversion;
    case 'purchaseApplied':
      return _$creditEntryReasonEnum_purchaseApplied;
    case 'refundRestored':
      return _$creditEntryReasonEnum_refundRestored;
    case 'conversionReversed':
      return _$creditEntryReasonEnum_conversionReversed;
    case 'adjustment':
      return _$creditEntryReasonEnum_adjustment;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreditEntryReasonEnum> _$creditEntryReasonEnumValues =
    BuiltSet<CreditEntryReasonEnum>(const <CreditEntryReasonEnum>[
  _$creditEntryReasonEnum_monthEndConversion,
  _$creditEntryReasonEnum_purchaseApplied,
  _$creditEntryReasonEnum_refundRestored,
  _$creditEntryReasonEnum_conversionReversed,
  _$creditEntryReasonEnum_adjustment,
]);

Serializer<CreditEntryCurrencyEnum> _$creditEntryCurrencyEnumSerializer =
    _$CreditEntryCurrencyEnumSerializer();
Serializer<CreditEntryReasonEnum> _$creditEntryReasonEnumSerializer =
    _$CreditEntryReasonEnumSerializer();

class _$CreditEntryCurrencyEnumSerializer
    implements PrimitiveSerializer<CreditEntryCurrencyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'GHS': 'GHS',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'GHS': 'GHS',
  };

  @override
  final Iterable<Type> types = const <Type>[CreditEntryCurrencyEnum];
  @override
  final String wireName = 'CreditEntryCurrencyEnum';

  @override
  Object serialize(Serializers serializers, CreditEntryCurrencyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreditEntryCurrencyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreditEntryCurrencyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreditEntryReasonEnumSerializer
    implements PrimitiveSerializer<CreditEntryReasonEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'monthEndConversion': 'month_end_conversion',
    'purchaseApplied': 'purchase_applied',
    'refundRestored': 'refund_restored',
    'conversionReversed': 'conversion_reversed',
    'adjustment': 'adjustment',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'month_end_conversion': 'monthEndConversion',
    'purchase_applied': 'purchaseApplied',
    'refund_restored': 'refundRestored',
    'conversion_reversed': 'conversionReversed',
    'adjustment': 'adjustment',
  };

  @override
  final Iterable<Type> types = const <Type>[CreditEntryReasonEnum];
  @override
  final String wireName = 'CreditEntryReasonEnum';

  @override
  Object serialize(Serializers serializers, CreditEntryReasonEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreditEntryReasonEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreditEntryReasonEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreditEntry extends CreditEntry {
  @override
  final String id;
  @override
  final int deltaMinor;
  @override
  final CreditEntryCurrencyEnum currency;
  @override
  final CreditEntryReasonEnum reason;
  @override
  final DateTime createdAt;

  factory _$CreditEntry([void Function(CreditEntryBuilder)? updates]) =>
      (CreditEntryBuilder()..update(updates))._build();

  _$CreditEntry._(
      {required this.id,
      required this.deltaMinor,
      required this.currency,
      required this.reason,
      required this.createdAt})
      : super._();
  @override
  CreditEntry rebuild(void Function(CreditEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreditEntryBuilder toBuilder() => CreditEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreditEntry &&
        id == other.id &&
        deltaMinor == other.deltaMinor &&
        currency == other.currency &&
        reason == other.reason &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, deltaMinor.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreditEntry')
          ..add('id', id)
          ..add('deltaMinor', deltaMinor)
          ..add('currency', currency)
          ..add('reason', reason)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class CreditEntryBuilder implements Builder<CreditEntry, CreditEntryBuilder> {
  _$CreditEntry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _deltaMinor;
  int? get deltaMinor => _$this._deltaMinor;
  set deltaMinor(int? deltaMinor) => _$this._deltaMinor = deltaMinor;

  CreditEntryCurrencyEnum? _currency;
  CreditEntryCurrencyEnum? get currency => _$this._currency;
  set currency(CreditEntryCurrencyEnum? currency) =>
      _$this._currency = currency;

  CreditEntryReasonEnum? _reason;
  CreditEntryReasonEnum? get reason => _$this._reason;
  set reason(CreditEntryReasonEnum? reason) => _$this._reason = reason;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  CreditEntryBuilder() {
    CreditEntry._defaults(this);
  }

  CreditEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _deltaMinor = $v.deltaMinor;
      _currency = $v.currency;
      _reason = $v.reason;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreditEntry other) {
    _$v = other as _$CreditEntry;
  }

  @override
  void update(void Function(CreditEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreditEntry build() => _build();

  _$CreditEntry _build() {
    final _$result = _$v ??
        _$CreditEntry._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'CreditEntry', 'id'),
          deltaMinor: BuiltValueNullFieldError.checkNotNull(
              deltaMinor, r'CreditEntry', 'deltaMinor'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'CreditEntry', 'currency'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'CreditEntry', 'reason'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'CreditEntry', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
