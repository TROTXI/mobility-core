// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_initiation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RefundInitiationStateEnum _$refundInitiationStateEnum_submitting =
    const RefundInitiationStateEnum._('submitting');
const RefundInitiationStateEnum _$refundInitiationStateEnum_accepted =
    const RefundInitiationStateEnum._('accepted');
const RefundInitiationStateEnum _$refundInitiationStateEnum_unknown =
    const RefundInitiationStateEnum._('unknown');

RefundInitiationStateEnum _$refundInitiationStateEnumValueOf(String name) {
  switch (name) {
    case 'submitting':
      return _$refundInitiationStateEnum_submitting;
    case 'accepted':
      return _$refundInitiationStateEnum_accepted;
    case 'unknown':
      return _$refundInitiationStateEnum_unknown;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RefundInitiationStateEnum> _$refundInitiationStateEnumValues =
    BuiltSet<RefundInitiationStateEnum>(const <RefundInitiationStateEnum>[
  _$refundInitiationStateEnum_submitting,
  _$refundInitiationStateEnum_accepted,
  _$refundInitiationStateEnum_unknown,
]);

Serializer<RefundInitiationStateEnum> _$refundInitiationStateEnumSerializer =
    _$RefundInitiationStateEnumSerializer();

class _$RefundInitiationStateEnumSerializer
    implements PrimitiveSerializer<RefundInitiationStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'submitting': 'submitting',
    'accepted': 'accepted',
    'unknown': 'unknown',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'submitting': 'submitting',
    'accepted': 'accepted',
    'unknown': 'unknown',
  };

  @override
  final Iterable<Type> types = const <Type>[RefundInitiationStateEnum];
  @override
  final String wireName = 'RefundInitiationStateEnum';

  @override
  Object serialize(Serializers serializers, RefundInitiationStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RefundInitiationStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RefundInitiationStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RefundInitiation extends RefundInitiation {
  @override
  final String id;
  @override
  final String purchaseId;
  @override
  final Money amount;
  @override
  final String reason;
  @override
  final RefundInitiationStateEnum state;
  @override
  final String? providerRefundId;
  @override
  final DateTime createdAt;

  factory _$RefundInitiation(
          [void Function(RefundInitiationBuilder)? updates]) =>
      (RefundInitiationBuilder()..update(updates))._build();

  _$RefundInitiation._(
      {required this.id,
      required this.purchaseId,
      required this.amount,
      required this.reason,
      required this.state,
      this.providerRefundId,
      required this.createdAt})
      : super._();
  @override
  RefundInitiation rebuild(void Function(RefundInitiationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefundInitiationBuilder toBuilder() =>
      RefundInitiationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefundInitiation &&
        id == other.id &&
        purchaseId == other.purchaseId &&
        amount == other.amount &&
        reason == other.reason &&
        state == other.state &&
        providerRefundId == other.providerRefundId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, purchaseId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, providerRefundId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefundInitiation')
          ..add('id', id)
          ..add('purchaseId', purchaseId)
          ..add('amount', amount)
          ..add('reason', reason)
          ..add('state', state)
          ..add('providerRefundId', providerRefundId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class RefundInitiationBuilder
    implements Builder<RefundInitiation, RefundInitiationBuilder> {
  _$RefundInitiation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _purchaseId;
  String? get purchaseId => _$this._purchaseId;
  set purchaseId(String? purchaseId) => _$this._purchaseId = purchaseId;

  MoneyBuilder? _amount;
  MoneyBuilder get amount => _$this._amount ??= MoneyBuilder();
  set amount(MoneyBuilder? amount) => _$this._amount = amount;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  RefundInitiationStateEnum? _state;
  RefundInitiationStateEnum? get state => _$this._state;
  set state(RefundInitiationStateEnum? state) => _$this._state = state;

  String? _providerRefundId;
  String? get providerRefundId => _$this._providerRefundId;
  set providerRefundId(String? providerRefundId) =>
      _$this._providerRefundId = providerRefundId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  RefundInitiationBuilder() {
    RefundInitiation._defaults(this);
  }

  RefundInitiationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _purchaseId = $v.purchaseId;
      _amount = $v.amount.toBuilder();
      _reason = $v.reason;
      _state = $v.state;
      _providerRefundId = $v.providerRefundId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefundInitiation other) {
    _$v = other as _$RefundInitiation;
  }

  @override
  void update(void Function(RefundInitiationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefundInitiation build() => _build();

  _$RefundInitiation _build() {
    _$RefundInitiation _$result;
    try {
      _$result = _$v ??
          _$RefundInitiation._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'RefundInitiation', 'id'),
            purchaseId: BuiltValueNullFieldError.checkNotNull(
                purchaseId, r'RefundInitiation', 'purchaseId'),
            amount: amount.build(),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'RefundInitiation', 'reason'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'RefundInitiation', 'state'),
            providerRefundId: providerRefundId,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'RefundInitiation', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'amount';
        amount.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RefundInitiation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
