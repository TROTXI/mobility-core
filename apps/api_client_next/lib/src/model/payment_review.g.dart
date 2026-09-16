// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_review.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentReviewKindEnum _$paymentReviewKindEnum_refund =
    const PaymentReviewKindEnum._('refund');
const PaymentReviewKindEnum _$paymentReviewKindEnum_dispute =
    const PaymentReviewKindEnum._('dispute');
const PaymentReviewKindEnum _$paymentReviewKindEnum_manualReview =
    const PaymentReviewKindEnum._('manualReview');

PaymentReviewKindEnum _$paymentReviewKindEnumValueOf(String name) {
  switch (name) {
    case 'refund':
      return _$paymentReviewKindEnum_refund;
    case 'dispute':
      return _$paymentReviewKindEnum_dispute;
    case 'manualReview':
      return _$paymentReviewKindEnum_manualReview;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentReviewKindEnum> _$paymentReviewKindEnumValues =
    BuiltSet<PaymentReviewKindEnum>(const <PaymentReviewKindEnum>[
  _$paymentReviewKindEnum_refund,
  _$paymentReviewKindEnum_dispute,
  _$paymentReviewKindEnum_manualReview,
]);

Serializer<PaymentReviewKindEnum> _$paymentReviewKindEnumSerializer =
    _$PaymentReviewKindEnumSerializer();

class _$PaymentReviewKindEnumSerializer
    implements PrimitiveSerializer<PaymentReviewKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'refund': 'refund',
    'dispute': 'dispute',
    'manualReview': 'manual_review',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'refund': 'refund',
    'dispute': 'dispute',
    'manual_review': 'manualReview',
  };

  @override
  final Iterable<Type> types = const <Type>[PaymentReviewKindEnum];
  @override
  final String wireName = 'PaymentReviewKindEnum';

  @override
  Object serialize(Serializers serializers, PaymentReviewKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PaymentReviewKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PaymentReviewKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PaymentReview extends PaymentReview {
  @override
  final String id;
  @override
  final PaymentReviewKindEnum kind;
  @override
  final String editToken;
  @override
  final String purchaseId;
  @override
  final String status;
  @override
  final Money amount;
  @override
  final String? reason;
  @override
  final DateTime updatedAt;

  factory _$PaymentReview([void Function(PaymentReviewBuilder)? updates]) =>
      (PaymentReviewBuilder()..update(updates))._build();

  _$PaymentReview._(
      {required this.id,
      required this.kind,
      required this.editToken,
      required this.purchaseId,
      required this.status,
      required this.amount,
      this.reason,
      required this.updatedAt})
      : super._();
  @override
  PaymentReview rebuild(void Function(PaymentReviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentReviewBuilder toBuilder() => PaymentReviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentReview &&
        id == other.id &&
        kind == other.kind &&
        editToken == other.editToken &&
        purchaseId == other.purchaseId &&
        status == other.status &&
        amount == other.amount &&
        reason == other.reason &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, editToken.hashCode);
    _$hash = $jc(_$hash, purchaseId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentReview')
          ..add('id', id)
          ..add('kind', kind)
          ..add('editToken', editToken)
          ..add('purchaseId', purchaseId)
          ..add('status', status)
          ..add('amount', amount)
          ..add('reason', reason)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PaymentReviewBuilder
    implements Builder<PaymentReview, PaymentReviewBuilder> {
  _$PaymentReview? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PaymentReviewKindEnum? _kind;
  PaymentReviewKindEnum? get kind => _$this._kind;
  set kind(PaymentReviewKindEnum? kind) => _$this._kind = kind;

  String? _editToken;
  String? get editToken => _$this._editToken;
  set editToken(String? editToken) => _$this._editToken = editToken;

  String? _purchaseId;
  String? get purchaseId => _$this._purchaseId;
  set purchaseId(String? purchaseId) => _$this._purchaseId = purchaseId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  MoneyBuilder? _amount;
  MoneyBuilder get amount => _$this._amount ??= MoneyBuilder();
  set amount(MoneyBuilder? amount) => _$this._amount = amount;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PaymentReviewBuilder() {
    PaymentReview._defaults(this);
  }

  PaymentReviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _editToken = $v.editToken;
      _purchaseId = $v.purchaseId;
      _status = $v.status;
      _amount = $v.amount.toBuilder();
      _reason = $v.reason;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentReview other) {
    _$v = other as _$PaymentReview;
  }

  @override
  void update(void Function(PaymentReviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentReview build() => _build();

  _$PaymentReview _build() {
    _$PaymentReview _$result;
    try {
      _$result = _$v ??
          _$PaymentReview._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PaymentReview', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'PaymentReview', 'kind'),
            editToken: BuiltValueNullFieldError.checkNotNull(
                editToken, r'PaymentReview', 'editToken'),
            purchaseId: BuiltValueNullFieldError.checkNotNull(
                purchaseId, r'PaymentReview', 'purchaseId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'PaymentReview', 'status'),
            amount: amount.build(),
            reason: reason,
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'PaymentReview', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'amount';
        amount.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentReview', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
